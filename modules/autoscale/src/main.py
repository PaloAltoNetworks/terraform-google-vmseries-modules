
from dataclasses import dataclass
import functions_framework

from google.cloud import secretmanager
import googleapiclient.discovery
from cloudevents.http import CloudEvent

from panos.panorama import Panorama

from logging import getLogger, basicConfig, INFO, error, warning, info
from xml.etree import ElementTree as et
from xml.etree.ElementTree import Element
from os import getenv
import base64
import json

@dataclass
class InitParameters:
    """
    This Class is used for create data structure with values used in further function.
    """
    panorama_address: str = getenv('PANORAMA_ADDRESS')
    secret_name: str = getenv('SECRET_NAME')
    project_id: str = getenv('PROJECT_ID')

@functions_framework.cloud_event
def autoscale_delete_event(cloud_event: CloudEvent) -> None:

    # Extracting the log data from the Pub/Sub message.
    configure_logger()

    pubsub_message = json.loads(base64.b64decode(cloud_event.data['message']['data']).decode('utf-8'))
    instance_id = pubsub_message['resource']['labels']['instance_id']
    project_id = pubsub_message['resource']['labels']['project_id']
    zone = pubsub_message['resource']['labels']['zone']
    details = get_instance_details(project_id, zone, instance_id)
    interfaces = details['networkInterfaces']
    items = details['metadata']['items']
    igm_name = find_igm_name(items)
    primary_ip = get_primary_ip(interfaces)
    info(f"-> Start delicensing process for instance: {instance_id}, primary IP: {primary_ip}")

    # get credentials from Secret Manager and login to Panorama
    credentials = get_secret()
    panorama = Panorama(InitParameters().panorama_address, credentials.get('user'), credentials.get('pass'))

    # list all devices under the configured license manager
    cmd = f'show plugins sw_fw_license devices license-manager \"{igm_name}\"'
    firewalls_parsed = panorama_cmd(panorama, cmd)

    match_found = False
    if firewalls_parsed.attrib['status'] == 'success':
        do_commit = False
        info('-> Looping through sw_fw_license plugin output...')
        # loop through a list of FWs
        for fw in firewalls_parsed[0][0]:
            ip_obj = fw.find('ip')
            if ip_obj is not None:
                ip = ip_obj.text
                info(f'-> FW: {ip}')
                if ip is not None and ip == primary_ip:
                    info(f"-> Found FW match by primary IP ({primary_ip})")
                    match_found = True
                
                    serial_obj = fw.find('serial')
                    if serial_obj is not None:
                        serial = serial_obj.text
                        info(f'-> FW s/n: {serial}')
                        if serial_obj.text is not None:
                            info(f'-> Request delicensing for firewall s/n {serial}...')
                            cmd = f'request plugins sw_fw_license deactivate license-manager \"{igm_name}\" devices member "{serial}"'
                            resp_parsed = panorama_cmd(panorama, cmd)
                            if resp_parsed.attrib['status'] == 'success':
                                info('-> Success!')
                                do_commit = True
                            else:
                                error('-> Failed!')
        # commit changes in case we did de-license a FW
        if do_commit:
            info('-> committing changes')
            panorama.commit(sync=False, admins='__sw_fw_license')
    if not match_found:
        warning(f'-> Delicensing process for instance: {instance_id}, primary IP: {primary_ip} was not successful: firewall not found.')


def get_instance_details(project, zone, instance_name):
    compute = googleapiclient.discovery.build('compute', 'v1')
    request = compute.instances().get(project=project, zone=zone, instance=instance_name)
    response = request.execute()
    return response


def find_igm_name(items):
    for item in items:
        if item['key'] == 'created-by':
            igm = (item['value']).split("/")[-1]
            return igm


def get_primary_ip(interfaces):
    for interface in interfaces:
        if interface['name'] == 'nic1':
            primary_ip = interface['networkIP']
            return primary_ip
    else:
        raise Exception("No primary IP found")


def configure_logger():
    """
    Create and configure logger instance.
    :return: None
    """
    basicConfig(format='%(asctime)s %(message)s')
    logger = getLogger()
    logger.setLevel(INFO)


def panorama_cmd(panorama, cmd: str, xml: bool = True, cmd_xml: bool = True) -> Element:
    """
    Helper function used for call command to Panorama.
    :param panorama: Panorama object
    :param cmd: command send further to Panorama
    :param xml: (bool) Return value should be a string
    :param cmd_xml: (bool) True: cmd is not XML, False: cmd is XML
    :return:
    """
    info(f"Call Panorama with: {cmd} command.")
    response = panorama.op(cmd=cmd, xml=xml, cmd_xml=cmd_xml)
    info(f"Response: {response}")
    return et.fromstring(response)


def get_secret() -> dict:
    """
    Small helper function call for secret string in Google Cloud
    :return: dict
    """
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{InitParameters().project_id}/secrets/{InitParameters().secret_name}/versions/latest"
    response = client.access_secret_version(name=name)
    resp_str = response.payload.data.decode('UTF-8')
    resp_list = resp_str.split("|", 1)
    return {'user': resp_list[0],
            'pass': resp_list[1]}
