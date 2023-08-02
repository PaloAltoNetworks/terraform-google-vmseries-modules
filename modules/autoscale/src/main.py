from googleapiclient.discovery import build
from google.cloud import secretmanager
from functions_framework import cloud_event
from cloudevents.http import CloudEvent

from json import loads
from logging import getLogger, basicConfig, INFO, DEBUG
from xml.etree import ElementTree as et
from xml.etree.ElementTree import Element
from os import getenv
from base64 import b64decode

from panos.panorama import Panorama


class ConfigureLogger:
    def __init__(self, *args, **kwargs):
        self.logger = getLogger(self.__class__.__name__)
        basicConfig(format="%(asctime)s %(message)s")
        self.logger.setLevel(INFO if getenv("logger_level") else DEBUG)


class VMSeriesAutoscaling(ConfigureLogger):
    def __init__(self, cloud_event: CloudEvent):
        super().__init__()

        self.panorama_address = getenv("PANORAMA_ADDRESS")
        self.panorama2_address = getenv("PANORAMA2_ADDRESS")
        self.project_id = getenv("PROJECT_ID")

        self.panorama_username, self.panorama_password = self.init_panorama_credentials()

        self.main(cloud_event)

    def init_panorama_credentials(self) -> tuple[str, str]:
        """
        Helper function used to get secret from Secret Manager.

        :return: Panorama username, Panorama password
        """
        secret_name = getenv("SECRET_NAME")

        client = secretmanager.SecretManagerServiceClient()
        name = f"projects/{self.project_id}/secrets/{secret_name}/versions/latest"
        response = client.access_secret_version(name=name)
        secret_str = response.payload.data.decode("UTF-8")

        return secret_str.split("|", 1)[0], secret_str.split("|", 1)[1]

    def main(self, cloud_event: CloudEvent):
        """
        Main function is used for handle  (instance launch or instance terminate).

        :param cloud_event: CloudEvent pub/sub message
        :return: none
        """

        # Parsing pub/sub message
        pubsub_message = loads(b64decode(cloud_event.data["message"]["data"]).decode("utf-8"))
        instance_id = pubsub_message["resource"]["labels"]["instance_id"]
        project_id = pubsub_message["resource"]["labels"]["project_id"]
        zone = pubsub_message["resource"]["labels"]["zone"]

        details = self.get_vm_instance_details(project_id, zone, instance_id)

        vm_primary_ip = self.get_vm_instance_primary_ip(details)
        vm_mig_name = self.get_vm_instance_mig_name(details)
        self.logger.info(
            f"Parsed VM-Series {instance_id} details from the pub/sub event: \
                IP={vm_primary_ip}, MIG={vm_mig_name}"
        )

        # It is assumed that Panorama LM name is equal to MIG name
        self.delicense_fw_by_ip(vmseries_ip_address=vm_primary_ip, panorama_lm_name=vm_mig_name)

    def panorama_cmd(self, panorama, cmd: str, xml: bool = True, cmd_xml: bool = True) -> Element:
        """
        Helper function used for call command to Panorama.

        :param panorama: Panorama object
        :param cmd: command send further to Panorama
        :param xml: (bool) Return value should be a string
        :param cmd_xml: (bool) True: cmd is not XML, False: cmd is XML
        :return: Output of executed command
        """
        self.logger.info(f"Call Panorama with: '{cmd}' command.")
        request = panorama.op(cmd=cmd, xml=xml, cmd_xml=cmd_xml)
        return et.fromstring(request)

    def get_vm_instance_details(self, project: str, zone: str, instance_name: str) -> dict:
        """
        Helper function used to get CE VM instance details.

        :param project: VM instance GCP project ID
        :param zone: VM instance zone
        :param instance_name: VM instance name
        :return: VM instance details dictionary
        """
        compute = build("compute", "v1")
        request = compute.instances().get(project=project, zone=zone, instance=instance_name)
        response = request.execute()
        return response

    def get_vm_instance_primary_ip(self, details: dict) -> str:
        """
        Helper function used to get CE VM instance primary .

        :param details: VM instance details dictionary
        :return: Primary IP address of the VM instance
        """

        for interface in details["networkInterfaces"]:
            if interface["name"] == "nic1":
                primary_ip = interface["networkIP"]
                return primary_ip
        else:
            raise Exception("No primary IP address found!")

    def get_vm_instance_mig_name(self, details: dict) -> str:
        """
        Helper function used to get Managed Instance Group name from VM instance details.

        :param details: VM instance details dictionary
        :return: MIG name string
        """
        items = details["metadata"]["items"]
        for item in items:
            if item["key"] == "created-by":
                return item["value"].split("/")[-1]

    def delicense_fw_by_ip(self, vmseries_ip_address: str, panorama_lm_name: str) -> bool:
        """
        Function used to de-license VM-Series using plugin sw_fw_license.
        In order to deactivate license used by VM-Series with specified IP address, 
        below steps are done:
        - connect to Panorama using acquired secrets
        - list all devices in license manager
        - de-license only this IP address, which is matching the firewall

        :param vmseries_ip_address: VM primary IP address
        :param panorama_lm_name: Panorama License Manager name
        :return: True if VM-Series was de-licensed correctly, False in other case
        """

        delicensed = False

        # Check if there is defined 2 Panorama server
        if self.panorama2_address:
            # Check if first Panorama is active - if not, the use second Panorama for de-licensing
            if self.check_is_active_in_ha(
                self.panorama_address, self.panorama_username, self.panorama_password
            ):
                # De-license using active, first Panorama instance from Active-Passive HA cluster
                delicensed = self.request_panorama_delicense_fw(
                    vmseries_ip_address,
                    self.panorama_address,
                    self.panorama_username,
                    self.panorama_password,
                    panorama_lm_name,
                )
            else:
                # De-license using active, second Panorama instance from Active-Passive HA cluster
                delicensed = self.request_panorama_delicense_fw(
                    vmseries_ip_address,
                    self.panorama2_address,
                    self.panorama_username,
                    self.panorama_password,
                    panorama_lm_name,
                )
        else:
            # De-license using the only 1 Panorama instance
            delicensed = self.request_panorama_delicense_fw(
                vmseries_ip_address,
                self.panorama_address,
                self.panorama_username,
                self.panorama_password,
                panorama_lm_name,
            )

            return delicensed

        return delicensed

    def check_is_active_in_ha(
        self, panorama_hostname, panorama_username, panorama_password
    ) -> bool:
        """
        Function used to check if provided Panorama hostname is active

        :param panorama_hostname: Hostname of the Panorama server
        :param panorama_username: Account's name
        :param panorama_password: Account's password
        :return: True if Panorama is active in HA cluster
        """
        try:
            # Set status of active
            active = False

            # Connect to selected Panorama instance
            self.logger.info(
                f"Connecting to '{panorama_hostname}' using user '{panorama_username}''"
            )
            panorama = Panorama(
                hostname=panorama_hostname,
                api_username=panorama_username,
                api_password=panorama_password,
            )

            # Check high-availability state
            cmd = "show high-availability state"
            firewalls_parsed = self.panorama_cmd(panorama, cmd=cmd)

            # Check if in active state
            for info in firewalls_parsed[0]:
                if info.tag == "local-info":
                    for attr in info:
                        if attr.tag == "state":
                            active = "active" in attr.text

            # Return high-availability state
            return active
        except:
            self.logger.info(
                f"Error while checking high-availability state for Panorama {panorama_hostname}"
            )
            return False

    def request_panorama_delicense_fw(
        self,
        vmseries_ip_address,
        panorama_hostname,
        panorama_username,
        panorama_password,
        panorama_lm_name,
    ) -> bool:
        """
        Function used to de-license VM-Series using plugin sw_fw_license running on Panorama server

        :param vmseries_ip_address: IP address of the MGMT interface for VM-Series
        :param panorama_hostname: Hostname of the Panorama server
        :param panorama_username: Account's name
        :param panorama_password: Account's password
        :return: True if VM-Series was de-licensed correctly, False in other case
        """
        try:
            # Set status of delicensing
            delicensed = False

            # Connect to selected Panorama instance
            self.logger.info(
                f"Connecting to '{panorama_hostname}' using user '{panorama_username}', \
                    license manager '{panorama_lm_name}'"
            )
            panorama = Panorama(
                hostname=panorama_hostname,
                api_username=panorama_username,
                api_password=panorama_password,
            )

            # List all devices under the configured license manager
            cmd = f'show plugins sw_fw_license devices license-manager "{panorama_lm_name}"'
            firewalls_parsed = self.panorama_cmd(panorama, cmd=cmd)

            # If the command succeeded, start sweeping the list of FWs
            if firewalls_parsed.attrib["status"] == "success":
                do_commit = False
                self.logger.info(
                    "Iterating over firewall list received from FW SW Licensing plugin"
                )
                for fw in firewalls_parsed[0][0]:
                    ip_obj = fw.find("ip")
                    # For each firewall from the list, check if IP address is matching 
                    # value of vmseries_ip_address
                    if ip_obj is not None:
                        ip = ip_obj.text
                        if ip is not None and ip == vmseries_ip_address:
                            serial_obj = fw.find("serial")
                            self.logger.info(f"Found VM-Series with management IP {ip}")
                            if serial_obj is not None:
                                serial = serial_obj.text
                                self.logger.info(
                                    f"VM-Series with management IP {ip} has s/n {serial}"
                                )

                                # If IP address is the same as destroyed VM and serial is not none, 
                                # then delicense firewall
                                if serial_obj.text is not None:
                                    self.logger.info(
                                        f"De-licensing firewall {serial}, license manager \
                                            {panorama_lm_name}..."
                                    )
                                    cmd = f'request plugins sw_fw_license deactivate \
                                        license-manager "{panorama_lm_name}" devices member "{serial}"'
                                    resp_parsed = self.panorama_cmd(panorama, cmd)
                                    if resp_parsed.attrib["status"] == "success":
                                        self.logger.info(
                                            f"De-licensing firewall {serial} succeeded!"
                                        )
                                        do_commit = True
                                        delicensed = True
                                    else:
                                        self.logger.info(f"De-licensing firewall {serial} failed")
                        else:
                            self.logger.info(
                                f"Found VM-Series with management IP {ip} != {vmseries_ip_address}"
                            )

                # Commit changes in case we did de-license a FW
                if do_commit:
                    self.logger.info("Committing changes in Panorama")
                    panorama.commit(sync=False, admins="__sw_fw_license")

            # Return final result of de-licensing
            return delicensed
        except:
            self.logger.info(
                f"Error while de-licensing VM-Series using Panorama {panorama_hostname}"
            )
            return False


@cloud_event
def autoscale_delete_event(cloud_event: CloudEvent):
    VMSeriesAutoscaling(cloud_event)
