#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-078f63d14c419cf3c"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-078f63d14c419cf3c --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [instance != "frontend" ]; then
        aws ec2 describe-instances --instance-ids i-0fce07e0f753c5e4d --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        aws ec2 describe-instances --instance-ids i-0fce07e0f753c5e4d --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
    echo "$instance: $IP"
done
