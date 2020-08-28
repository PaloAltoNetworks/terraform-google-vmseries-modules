variable service_account_id {
  default = "The google_service_account.account_id of the created IAM account, unique string per project."
  type    = string
}

variable display_name {
  default = "Palo Alto Networks Firewall Service Account"
}

