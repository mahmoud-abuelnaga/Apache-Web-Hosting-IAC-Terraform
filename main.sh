#!/bin/bash

# constants
MAIN_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# variables
launch_template_image_id=""

# sources
source "$MAIN_PREFIX/variables.env"
source "$MAIN_PREFIX/bash-scripts/general/functions/general.sh"
source "$MAIN_PREFIX/bash-scripts/general/functions/print.sh"
source "$MAIN_PREFIX/bash-scripts/aws/functions/ami.sh"
source "$MAIN_PREFIX/bash-scripts/aws/functions/role.sh"


# initialize s3 bucket
print_header "Initializing s3 bucket"
cd "$MAIN_PREFIX/s3_bucket" || die "Failed to change directory to s3_bucket"
terraform init || die "Failed to initialize Terraform in s3_bucket"
terraform apply || die "Failed to apply Terraform in s3_bucket"
cd ..

# download tooplate template
if [[ $download_template -eq 1 ]]; then
    print_header "Downloading template"
    bash "$MAIN_PREFIX/download_html5up_template.sh" "$html5up_template_url" || die "Failed to download tooplate template"
else
    print_header "Skipping downloading tooplate template"
fi

# upload files to s3 bucket
print_header "Syncing files to s3 bucket"
sync_output=$(aws s3 sync "$MAIN_PREFIX/files" "s3://$s3_bucket/artifacts/") || die "Failed to upload files to s3 bucket"
if [[ -z "$sync_output" ]]; then
    print_msg "No files were uploaded to s3 bucket. Ending the script."
else
    print_msg "Files were uploaded to s3 bucket"

    print_header "Checking if role exists"
    print_msg "Checking if role $ec2_role_name exists"

    aws iam get-role --role-name "$ec2_role_name" &> "/dev/null"
    if [[ $? -eq 0 ]]; then
        print_msg "Role $ec2_role_name already exists"
    else
        print_header "Creating role"
        role_arn=$(create_role "$ec2_role_name" "$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
    )") || die "Failed to create role" "$?"

        print_header "Creating custom policy"
        policy_arn=$(create_policy "$custom_policy_name" "$(cat <<EOF
{
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
				"arn:aws:s3:::$s3_bucket/artifacts/*",
				"arn:aws:s3:::$s3_bucket"
			]
		}
	]
}
EOF
    )") || die "Failed to create custom policy" "$?"

        print_header "Attaching policies to role"
        attach_policy_to_role "$ec2_role_name" "$policy_arn" || die "Failed to attach policy to role" "$?"
        attach_policy_to_role "$ec2_role_name" "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" || die "Failed to attach policy to role" "$?"

        instance_profile_arn=$(create_instance_profile "$ec2_profile_name") || die "Failed to create instance profile" "$?"
        add_role_to_instance_profile "$ec2_profile_name" "$ec2_role_name" || die "Failed to add role to instance profile" "$?"
    fi

    launch_template_image_id=$(create_ami_with_live_script "$ami_id" "$vpc_id" "$subnet_id" "$MAIN_PREFIX/ami_init.sh" "$ec2_user" "$ami_name" "$ami_name" "$ec2_profile_name") || die "Failed to create ami with live script" "$?"
    print_msg "Launch template image id: $launch_template_image_id"
    sed -i "s|launch_template_image_id.*|launch_template_image_id = \"$launch_template_image_id\"|" "$MAIN_PREFIX/infrastructure/terraform.tfvars"
fi

print_header "Creating infrastructure"
cd "$MAIN_PREFIX/infrastructure" || die "Failed to change directory to infrastructure"
terraform init || die "Failed to initialize Terraform in infrastructure"
terraform apply || die "Failed to apply Terraform in infrastructure"
cd ..
