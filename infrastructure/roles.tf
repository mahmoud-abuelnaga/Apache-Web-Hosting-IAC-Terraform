# ec2 instance role
resource "aws_iam_role" "ec2_instance_role" {
  name = "vprofile-ec2-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_instance_access_s3_policy" {
  name        = "vprofile-s3-artifacts-access-policy"
  description = "Allow ec2 instances of vprofile to access the artifacts in the vprofile s3 bucket"
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "AccessVprofileS3Policy",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:ListBucket"
			],
			"Resource": [
				"arn:aws:s3:::${var.bucket_name}/artifacts/*",
				"arn:aws:s3:::${var.bucket_name}"
			]
		}
	]
})
}

resource "aws_iam_role_policy_attachment" "ec2_instance_access_s3_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ec2_instance_access_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_instance_access_ssm_managed_instance_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "vprofile-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}
