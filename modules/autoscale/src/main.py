import googleapiclient.discovery
from google.cloud import secretmanager
from logging import getLogger, basicConfig, INFO, error, warning, info
from xml.etree import ElementTree as et
from xml.etree.ElementTree import Element
from os import getenv
from panos.panorama import Panorama


class init_parameters:
    """
    This Class is used for create data structure with values used in further function.
    """
    pan_ip: str = getenv('PANORAMA_IP')
    # license_manager: str = getenv('LM')
    secret_name: str = getenv('SECRET_NAME')


def autoscale_delete_event(event, context):
    """Triggered by a change to a Log Sink.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    import base64
    import json

    # Extracting the log data from the Pub/Sub message.
    configure_logger()
    pubsub_message = json.loads(base64.b64decode(event['data']).decode('utf-8'))
    instance_id = pubsub_message['resource']['labels']['instance_id']
    project_id = pubsub_message['resource']['labels']['project_id']
    zone = pubsub_message['resource']['labels']['zone']
    details = get_instance_details(project_id, zone, instance_id)
    interfaces = details['networkInterfaces']
    items = details['metadata']['items']
    igm_name = find_igm_name(items)
    primary_ip = get_primary_ip(interfaces)
    info(f"Start de-license process for instance: {instance_id}, primary IP: {primary_ip}")

    # get credentials from Secret Manager and login to Panorama
    credentials = get_secret()
    panorama = Panorama(init_parameters().pan_ip, credentials.get('user'), credentials.get('pass'))

    # list all devices under the configured license manager
    cmd = f'show plugins sw_fw_license devices license-manager \"{igm_name}\"'
    firewalls_parsed = panorama_cmd(panorama, cmd)

    if firewalls_parsed.attrib['status'] == 'success':
        do_commit = False
        info('-> in firewall parsing')
        # loop through a list of FWs
        for fw in firewalls_parsed[0][0]:
            ip_obj = fw.find('ip')
            info('-> looping FW')
            if ip_obj is not None:
                ip = ip_obj.text
                info(f'-> working on {ip}')
                if ip is not None and ip == primary_ip:
                    info(f"-> Found FW match by primary IP ({primary_ip})")
                
                    serial_obj = fw.find('serial')
                    if serial_obj is not None:
                        serial = serial_obj.text
                        info(f'-> SERIAL: {serial}')
                        if serial_obj.text is not None:
                            info(f'-> De-licensing Firewall: {serial} ...')
                            cmd = f'request plugins sw_fw_license deactivate license-manager \"{igm_name}\" devices member "{serial}"'
                            resp_parsed = panorama_cmd(panorama, cmd)
                            if resp_parsed.attrib['status'] == 'success':
                                info('Success')
                                do_commit = True
                            else:
                                error('Failed')
        # commit changes in case we did de-license a FW
        if do_commit:
            info('-> committing changes')
            panorama.commit(sync=False, admins='__sw_fw_license')


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
    name = f"projects/{getenv('PROJECT_ID')}/secrets/{init_parameters().secret_name}/versions/latest"
    response = client.access_secret_version(name=name)
    resp_str = response.payload.data.decode('UTF-8')
    resp_list = resp_str.split(",")
    return {'user': resp_list[0],
            'pass': resp_list[1]}
