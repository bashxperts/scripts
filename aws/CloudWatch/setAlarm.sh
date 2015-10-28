#!/bin/bash
# Script By Vivek Poduval
# This script will set StatusCheck and Notify to OPS team

# Describe AWS CLI
awscli=`which aws`

if [ -z $awscli ];then
   echo "AWS CLI not installed"
   exit 0
fi

# Collect all Instances
$awscli ec2 describe-instances | grep InstanceId | awk -F'"' '{print $4}' > INSTANCES

# Set StatusCheck Alarm using AWS CLI
for i in `cat INSTANCES`;
do 
	sed "s/INSTANCE_ID/$i/" alarm-template-statusCheck.json > $i.json
	$awscli cloudwatch put-metric-alarm --cli-input-json file://$i.json
	if [ $? -eq 0 ];then
		echo "Alarm Set for Instance $i"
	else
		echo "Alarm NOT Set for Instance $i"
	fi
	rm -f $i.json
	
done

# Show whole StatusCheck Alarm Summary
echo "SUMMARY"
echo "Status Notification enabled for the following instances"
$awscli cloudwatch describe-alarms | grep AlarmName | grep StatusCheck

