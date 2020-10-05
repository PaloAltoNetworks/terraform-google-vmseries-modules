# Route operator API VM

## Usage

1. Place the binary in the file: `modules/gcp/route-operator/ro_api_d`

- The binary should be the Go code compiled for linux/amd64 platform:

```sh
cd modules/gcp/route-operator/go
go build -o ../ro_api_d .
```

2. Then proceed to deploy the binary on VMs:

```sh
terraform init
terraform apply --auto-approve
```

## PanOS Health Checks

Panos devices are constantly healthchecking their partners and they send failure/recovery events to the HTTP(S) API called route-operator (ro).
The ro reacts to the events by dynamically changing routing on the GCP cloud (think `gcloud compute routes` commands).

### Certificates

PanOS seems strict about certificates, so try to be exact here. The intention is simple: to have https API serve the certificate that is trusted by Panos client.

1. On Panorama -> Device -> Certificates create a certificate "caroot", self-signed, mark Certificate Authority yes.
2. Create a certificate "intermediate", signed by "caroot", mark Certificate Authority yes.
3. Create a certificate "route-operator-api":

- Common Name is the same as the Terraform input `var.ro_ip_address`
- Signed by "intermediate"
- Mark Certificate Authority NO
- Add one `IP` attribute, make it the same as the Common Name

4. Export the "caroot" without the private key and import it back on Panorama -> Panorama -> Certificates.
5. Export the "intermediate" without the private key to a file for Terraform and name it the same as input `var.https_interm_pem_file`.
6. Export the "route-operator-api" to a PEM file together with Private Key. Use password e.g. `YourSecretPassword` which you keep only until step 9.
7. Enter the PEM file with text editor (notepad) and split it into two files manually. Put the `CERTIFICATE` part in one file named the same as the terraform input `var.https_cert_pem_file`.
8. Put the `PRIVATE KEY` part in a new file named `xkey.pem`
9. Use it to obtain a passwordless key: `openssl rsa -in xkey.pem -out key.pem -passin pass:YourSecretPassword`
9. Make sure Terraform input `var.https_key_pem_file` points to the generated file `key.pem`.

### HTTP(S) Basic Auth

Decide the new user/password, which can be arbitrary, and encode it:

```sh
echo -n 'mynewuser:newpassword' | base64
bXluZXd1c2VyOm5ld3Bhc3N3b3Jk
```

Put the resulting secret string into Terraform's input `var.http_basic_auth`.

### Setup of PanOS http(s) alerting

Go to Panos -> Device -> Server Profiles -> HTTP.

Send the events from the PanOS device to the route-operator API through https port 8443 (alternatively, through plaintext http port 3000).
Use the type "System" Payload Format "ServiceNow Incident" with some changes:

- Change the URI path to `/api/path-monitoring/panos-event`
- Add the HTTP basic auth header manually (do not use the User/Password UI fields). Header is `Authorization` with the e.g. value `Basic bXluZXd1c2VyOm5ld3Bhc3N3b3Jk` substituting the secret obtained in the section HTTP Basic Auth above for the `bXluZXd1c2VyOm5ld3Bhc3N3b3Jk`.

Note that Panos -> Device -> Server Profiles -> HTTP -> Edit -> Payload Format -> System -> `Send Test Log` will only use the previously committed data (super-confusing!).
The HTTP reponse visible in PanOS webUI is expected to be exactly `409` for a correct test. Any other HTTP response, including even `200` or `301`, is an incorrect result.

### Caveat

Do **not** change the hostname of the firewall VM outside the Terraform (that is, don't use GCP console or `gcloud` to change the instance name).
This hostname is used internally to correctly match the firewall healthcheck result with the route-operator API call.
