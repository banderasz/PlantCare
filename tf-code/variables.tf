variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = "plantcare-420709"
}
variable "region" {
  description = "Google Cloud Platform region to deploy resources to"
  type        = string
  default     = "europe-west3"
}
variable "tf_service_account" {
  description = "Terraform service acount"
  type        = string
  default     = "sa-plantcare-tf@plantcare-420709.iam.gserviceaccount.com"
}