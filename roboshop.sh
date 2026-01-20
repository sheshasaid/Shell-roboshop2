#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-078f63d14c419cf3c"
ZONE_ID="Z10433352FG8G3570MODR"
DOMAIN_NAME="daws86s.art"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-078f63d14c419cf3c --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    #Get Private IP
    if [instance != "frontend" ]; then
        (aws ec2 describe-instances --instance-ids i-0fce07e0f753c5e4d --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        (aws ec2 describe-instances --instance-ids i-0fce07e0f753c5e4d --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi
    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Updating record set"
    ,"Changes": [{
      "Action"              : "CREATE"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$RECORD_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }
  ' 
done
