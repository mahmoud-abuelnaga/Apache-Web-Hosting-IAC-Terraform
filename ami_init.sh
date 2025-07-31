#!/bin/bash
sudo dnf update -y
sudo dnf install httpd zip awscli amazon-cloudwatch-agent -y

sudo systemctl enable --now httpd
sudo aws s3 cp s3://vprofile-bucket-very-new/artifacts/files.zip /var/www/html/
cd /var/www/html || exit 1
sudo unzip files.zip
sudo rm files.zip
sudo systemctl restart httpd

cat << EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json > /dev/null
{
        "agent": {
                "metrics_collection_interval": 60,
                "run_as_user": "root"
        },
        "logs": {
                "logs_collected": {
                        "files": {
                                "collect_list": [
                                        {
                                                "file_path": "/var/log/httpd/access_log",
                                                "log_group_class": "STANDARD",
                                                "log_group_name": "vprofile",
                                                "log_stream_name": "httpd-access-logs",
                                                "retention_in_days": 1
                                        },
                                        {
                                                "file_path": "/var/log/httpd/error_log",
                                                "log_group_class": "STANDARD",
                                                "log_group_name": "vprofile",
                                                "log_stream_name": "httpd-error-logs",
                                                "retention_in_days": 1
                                        }
                                ]
                        }
                }
        },
        "metrics": {
                "aggregation_dimensions": [
                        [
                                "InstanceId"
                        ]
                ],
                "append_dimensions": {
                        "AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
                        "ImageId": "\${aws:ImageId}",
                        "InstanceId": "\${aws:InstanceId}",
                        "InstanceType": "\${aws:InstanceType}"
                },
                "metrics_collected": {
                        "cpu": {
                                "measurement": [
                                        "cpu_usage_idle",
                                        "cpu_usage_iowait",
                                        "cpu_usage_steal",
                                        "cpu_usage_guest",
                                        "cpu_usage_user",
                                        "cpu_usage_system"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ],
                                "totalcpu": true
                        },
                        "disk": {
                                "measurement": [
                                        "used_percent",
                                        "inodes_free"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "diskio": {
                                "measurement": [
                                        "io_time",
                                        "write_bytes",
                                        "read_bytes",
                                        "writes",
                                        "reads"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ],
                                "metrics_collection_interval": 60
                        },
                        "net": {
                                "measurement": [
                                        "bytes_sent",
                                        "bytes_recv",
                                        "packets_sent",
                                        "packets_recv"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "netstat": {
                                "measurement": [
                                        "tcp_established",
                                        "tcp_time_wait"
                                ],
                                "metrics_collection_interval": 60
                        },
                        "swap": {
                                "measurement": [
                                        "swap_used_percent"
                                ],
                                "metrics_collection_interval": 60
                        }
                }
        }
}
EOF

systemctl enable --now amazon-cloudwatch-agent