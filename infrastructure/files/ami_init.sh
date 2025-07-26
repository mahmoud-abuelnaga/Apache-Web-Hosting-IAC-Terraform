#!/bin/bash

sudo dnf update -y
sudo dnf install httpd zip awscli amazon-cloudwatch-agent -y

sudo systemctl enable --now httpd
sudo aws s3 cp s3://vprofile-bucket-very-new/artifacts/files.zip /var/www/html/
cd /var/www/html || exit 1
sudo unzip files.zip
sudo rm files.zip
sudo systemctl restart httpd

