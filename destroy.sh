#!/bin/bash

cd s3_bucket || exit 1
terraform destroy -auto-approve
cd ../infrastructure || exit 1
terraform destroy -auto-approve
cd ..