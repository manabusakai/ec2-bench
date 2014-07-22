#!/bin/bash

usage() {
    echo "Usage: $(basename ${0}) -c [count] -u [url]"
}

while getopts "c:u:" option
do
    case ${option} in
        c)
            instance_count=${OPTARG}
            ;;
        u)
            target_url=${OPTARG}
            ;;
        *)
            usage 1>&2
            exit 1
            ;;
    esac
done

# Config file check
if [ ! -r ~/.aws/config ]; then
    echo "Cannot read config file." 1>&2
    exit 1
fi

# Command check
if ! type -p jq > /dev/null; then
    echo "Command not found: jq" 1>&2
    exit 1
fi

work_dir=`mktemp -d /tmp/aws.XXXXXX`
user_data="${work_dir}/user-data.txt"
output_file="${work_dir}/output.json"

cat <<EOF > ${user_data}
#cloud-config
packages:
 - httpd
runcmd:
 - [ab, -n, 50000, -c, 50, "${target_url}"]
 - [shutdown, -h, now]
EOF

aws ec2 run-instances \
    --image-id ami-29dc9228 \
    --instance-type t2.micro \
    --count ${instance_count} \
    --associate-public-ip-address \
    --user-data file://${user_data} \
    > ${output_file}

instance_id=`cat ${output_file} | jq -r ".Instances[].InstanceId"`

aws ec2 create-tags \
    --resources ${instance_id} \
    --tags Key=Name,Value=apache-bench \
    > /dev/null

rm -r ${work_dir}

# Complete message
instance_id_list=`echo ${instance_id} | sed -e "s/\s/ /g"`
echo "Instances: ${instance_id_list}"
echo "Cleanup command: aws ec2 terminate-instances --instance-ids ${instance_id_list}"

exit $?
