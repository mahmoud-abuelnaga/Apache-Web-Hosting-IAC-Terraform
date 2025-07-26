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

variable "ami" {
  type = string
}

variable "sleep_period" {
  type = number
  default = 30
}

variable "instance_user" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "asg_min" {
  type = number
  default = 1
}

variable "asg_desired" {
  type = number
  default = 2
}

variable "asg_max" {
  type = number
  default = 4
}