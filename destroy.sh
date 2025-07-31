#!/bin/bash

# constants
DESTROY_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# sources
source "$DESTROY_PREFIX/bash-scripts/general/functions/general.sh"
source "$DESTROY_PREFIX/bash-scripts/general/functions/print.sh"
source "$DESTROY_PREFIX/bash-scripts/aws/functions/ami.sh"
source "$DESTROY_PREFIX/variables.env"

print_header "Destroying bucket"
aws s3 rm "s3://$s3_bucket" --recursive
cd "$DESTROY_PREFIX/s3_bucket" || die "Failed to change directory to s3_bucket"
terraform destroy || die "Failed to destroy s3_bucket" "$?"

print_header "Destroying infrastructure"
cd "$DESTROY_PREFIX/infrastructure" || die "Failed to change directory to infrastructure"
terraform destroy || die "Failed to destroy infrastructure" "$?"
cd .. || die "Failed to change directory to parent directory"

print_header "Deregistering ami"
ami_id=$(grep -i launch_template_image_id "$DESTROY_PREFIX/infrastructure/terraform.tfvars" | awk -F'"' '{print $2}')
deregister_ami_and_delete_its_snapshot "$ami_id"