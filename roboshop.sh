#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-063f4a8b92c8783d5"
ZONE_ID="Z10433352FG8G3570MODR"
DOMAIN_NAME="daws86s.art"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "forntend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi
    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
  --hosted-zone-id Z10433352FG8G3570MODR \
  --change-batch '{
    "Comment": "Updating Record Sets",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$RECORD_NAME'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            { "Value": "'$IP'" }
          ]
        }
      }
    ]
  }'

done