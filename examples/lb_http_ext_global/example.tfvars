project  = "example"
region   = "us-west1"
ssh_keys = "centos:<public key>"

custom_request_headers = ["X-Forwarded-For: {client_ip_address}"]