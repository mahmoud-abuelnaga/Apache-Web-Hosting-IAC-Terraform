resource "aws_s3_bucket" "vprofile_bucket" {
  bucket = var.bucket_name
  tags = {
    "Name" = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "vprofile_bucket_policy" {
  bucket = aws_s3_bucket.vprofile_bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowLoadBalancerLogs",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::054676820928:root"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${var.bucket_name}/logs/AWSLogs/886436923743/*"
      }
    ]
  })
}
