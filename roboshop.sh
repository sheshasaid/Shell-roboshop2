#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-063f4a8b92c8783d5"

for instance in $@
do
    INSTANCEID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-063f4a8b92c8783d5 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "forntend" ]; then
        $IP=(aws ec2 describe-instances --instance-ids i-0b8cd5a0835e06253 --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        $IP=(aws ec2 describe-instances --instance-ids i-0b8cd5a0835e06253 --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance: $IP"
done