variable "region" {
  type = string
  default = "eu-central-1"
}

variable "zones" {
  type = list(string)
  default = [ "eu-central-1a", "eu-central-1b" ]
}

variable "bucket_name" {
  type = string
}