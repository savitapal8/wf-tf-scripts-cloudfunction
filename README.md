# wf-tf-scripts-cloudfunction

google_vpc_access_connector
google_cloudfunctions_function
google_cloudfunctions_function_iam_member
google_api_gateway_gateway
google_api_gateway_api_config
google_api_gateway_api


resource "google_cloudfunctions_function" "example" {
 name              = "function-test"
 description       = "My function"
 runtime           = "<CODE_LANGUAGE>"
 ingress_settings = "ALLOW_INTERNAL_ONLY"
 ...
}

# Creating a VPC connector
resource "google_vpc_access_connector" "example" {
  name          = "<VPC-CONNECTOR-NAME>"
  ip_cidr_range = "<IP_CIDR_RANGE>"
  network       = "<VPC_NETWORK>"
}


resource "google_cloudfunctions_function" "example" {
 name                            = "function-test"
 description                     = "My function"
 runtime                         = "<CODE_LANGUAGE>"
 vpc_connector                 = google_vpc_access_connector.id
 vpc_connector_egress_settings = "ALL_TRAFFIC"
 ...
}

resource "google_service_account" "example" {
 account_id   = "service-account-id"
 display_name = "Function Example Service Account"
 project      = "<PROJECT_ID>"
 ...
}

# Creating a function that uses the created SA
resource "google_cloudfunctions_function" "example" {
 name                  = "function-test"
 description           = "My function"
 runtime               = "<CODE_LANGUAGE>"
 service_account_email = google_service_account.example.email
 ...
}
