resource "aws_s3_bucket" "vprofile_bucket" {
  bucket = var.bucket_name
  tags = {
    "Name" = var.bucket_name
  }
}