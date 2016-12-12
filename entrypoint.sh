#!/bin/bash
MY_IP=`ip -4 addr show scope global dev ethwe | grep inet | awk '{print $2}' | cut -d / -f 1`
rclone copy remote:etcd-${TOKEN} /opt/etcd-backup
input=/opt/etcd-backup/latest
if [[ -f $input ]]
then
  if ! test "`find /opt/etcd-backup/latest -mmin +1`"; then
    echo "We think that another EtcD instance is running, if it's not the case, it will work in another minute"
    exit 1
  fi
  etcd -name etcd \
   -advertise-client-urls http://${MY_IP}:2379,http://${MY_IP}:4001 \
   -listen-client-urls http://localhost:2379,http://localhost:4001 \
   -initial-advertise-peer-urls http://${MY_IP}:2380 \
   -listen-peer-urls http://localhost:2380 \
   -initial-cluster-token etcd-cluster \
   -initial-cluster etcd=http://${MY_IP}:2380 \
   -initial-cluster-state new &
  until curl -s -t 5 http://localhost:2380
  do
    echo "Waiting for etcd"
    sleep 10
  done
  etcd-backup -file=$input -config=/root/backup-configuration.json -etcd-config=/root/etcd-configuration.json restore
  pkill etcd
fi
(
  while true; do
    sleep 60
    /root/backup.sh
  done
) &
etcd -name etcd \
 -advertise-client-urls http://${MY_IP}:2379,http://${MY_IP}:4001 \
 -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
 -initial-advertise-peer-urls http://${MY_IP}:2380 \
 -listen-peer-urls http://0.0.0.0:2380 \
 -initial-cluster-token etcd-cluster \
 -initial-cluster etcd=http://${MY_IP}:2380 \
 -initial-cluster-state new
