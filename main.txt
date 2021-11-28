provider "google" {
  user_project_override = true
  access_token          = var.access_token
  project               = "airline1-sabre-wolverine"
  region                = "us-central1"
}

resource "google_storage_bucket" "bucket" {
  name     = "test-bucket-demo-28"
  location = "us"
}

resource "google_storage_bucket_object" "archive" {
  name   = "HelloWorld.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./python_code/main.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "function-test"
  description = "My function"
  runtime     = "python39"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "hello_world"
  labels = {
    my-label = "my-label-value"
  }

  environment_variables = {
    MY_ENV_VAR = "my-env-var-value"
    GOOGLE_FUNCTION_SOURCE = "main.py"
  }
}

# IAM entry for a single user to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:demo-sentinel-sa@airline1-sabre-wolverine.iam.gserviceaccount.com"
}