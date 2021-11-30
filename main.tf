provider "google" {
  user_project_override = true
  access_token          = var.access_token
  project               = "airline1-sabre-wolverine"
  region                = "us-central1"
}

resource "google_vpc_access_connector" "vpc_conn_example" {
  name          = "vpc-connector12"
  ip_cidr_range = "10.8.0.0/28"
  network       = "us-dev-appid-syst-demo-vpc"
}

resource "google_service_account" "example" {
 account_id   = "service-account-id1"
 display_name = "Function Example Service Account"
 project      = "airline1-sabre-wolverine"
}

resource "google_storage_bucket" "bucket" {
  name     = "my-dev-appid-storage-demo-gcsbucket"
  location = "us"
  encryption {
      default_kms_key_name = "projects/airline1-sabre-wolverine/locations/us/keyRings/savita-keyring-us/cryptoKeys/savita-key-us" #google_kms_crypto_key_iam_member.gcs_encryption.id
  }
   labels = {
    owner = "hybridenv"
    application_division = "pci"
    application_name = "app1"
    application_role = "auth"
    au = "0223092"
    gcp_region = "us" 
    environment = "dev" 
    created = "20211124"   
  }
}

resource "google_storage_bucket_object" "archive" {
  name   = "HelloWorld12"
  bucket = google_storage_bucket.bucket.name
  source = "./python_code/main.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "my-dev-app-syst-demo-function"
  description = "My function"
  runtime     = "python39"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "hello_world"
  
  environment_variables = {
    MY_ENV_VAR = "my-env-var-value"
    GOOGLE_FUNCTION_SOURCE = "main.py"
  }
  
   labels = {
    owner = "hybridenv"
    application_division = "pci"
    application_name = "app1"
    application_role = "auth"
    au = "0223092"
    gcp_region = "us" 
    environment = "dev" 
    created = "20211124"   
  }
  
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  vpc_connector    = google_vpc_access_connector.vpc_conn_example.id
  vpc_connector_egress_settings = "ALL_TRAFFIC"
  service_account_email = google_service_account.example.email
  #service_account_email = null
}

# IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  #member = "serviceAccount:demo-sentinel-sa@airline1-sabre-wolverine.iam.gserviceaccount.com"
  member = "serviceAccount:${google_service_account.example.email}"
}
