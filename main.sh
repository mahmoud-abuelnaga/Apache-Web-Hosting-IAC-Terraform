#!/bin/bash
# shellcheck disable=SC1091
source "./functions.sh"
source "./variables.env"

# initialize s3 bucket
print_header "Initializing s3 bucket"
cd "s3_bucket" || die "Failed to change directory to s3_bucket"
terraform init || die "Failed to initialize Terraform in s3_bucket"
terraform apply -auto-approve || die "Failed to apply Terraform in s3_bucket"
cd ..

# download tooplate template
# shellcheck disable=SC2154
if [[ $download_template -eq 1 ]]; then
    print_header "Downloading tooplate template"
    bash "./download_html5up_template.sh" "$html5up_template_url" || die "Failed to download tooplate template"
else
    print_header "Skipping downloading tooplate template"
fi

# upload files to s3 bucket
print_header "Syncing files to s3 bucket"
# shellcheck disable=SC2154
sync_output=$(aws s3 sync ./files "s3://$s3_bucket/artifacts/") || die "Failed to upload files to s3 bucket"
if [[ -z "$sync_output" ]]; then
    print_msg "No files were uploaded to s3 bucket. Ending the script."
    exit 0
fi