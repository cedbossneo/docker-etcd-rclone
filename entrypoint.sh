#!/bin/bash
cat <<EOF > /root/.rclone.conf
[Openstack]
type = swift
user = ${OS_USERNAME}
key = ${OS_PASSWORD}
auth = ${OS_AUTH_URL}
tenant = ${OS_TENANT_NAME}
region = ${OS_REGION_NAME}
EOF

MY_IP=`ip -4 addr show scope global dev ethwe | grep inet | awk '{print $2}' | cut -d / -f 1`
rclone copy Openstack:etcd-${TOKEN} /opt/etcd-backup
if [[ -f /opt/etcd-backup/latest ]]
then
  etcd -name etcd \
   -advertise-client-urls http://localhost:2379,http://localhost:4001 \
   -listen-client-urls http://localhost:2379,http://localhost:4001 \
   -initial-advertise-peer-urls http://localhost:2380 \
   -listen-peer-urls http://localhost:2380 \
   -initial-cluster-token etcd-cluster \
   -initial-cluster etcd=http://localhost:2380 \
   -initial-cluster-state new &
  until curl -s -t 5 http://localhost:2380
  do
    echo "Waiting for etcd"
    sleep 10
  done
  IFS=$'\r\n'
  XYZ=($(cat /opt/etcd-backup/latest))

  for item in "${!XYZ[@]}"; do
    x="${XYZ[$item]}"
    key=$(echo $x | awk -F "===" '{print $1}')
    value=$(echo $x | awk -F "===" '{print $2}')
    etcdctl set $key $value
    echo "Restoring $key"
  done;
  pkill etcd
fi
crond
etcd -name etcd \
 -advertise-client-urls http://${MY_IP}:2379,http://${MY_IP}:4001 \
 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
 -initial-advertise-peer-urls http://${MY_IP}:2380 \
 -listen-peer-urls http://0.0.0.0:2380 \
 -initial-cluster-token etcd-cluster \
 -initial-cluster etcd=http://${MY_IP}:2380 \
 -initial-cluster-state new
