#!/bin/sh
rm -Rf /tmp/etcd-backup
mkdir -p /tmp/etcd-backup
rclone copy remote:etcd-${TOKEN} /tmp/etcd-backup
if [ -f /tmp/etcd-backup/latest ]; then
  if [ -f /opt/etcd-backup/latest ]; then
    DIFF_RET=$(diff /tmp/etcd-backup/latest /opt/etcd-backup/latest)
    if [[ "$?" == "1" ]]; then
      echo "We think that another EtcD instance is running, if it's not the case, it will work in another minute"
      pkill etcd
    fi
  else
    echo "We think that another EtcD instance is running, if it's not the case, it will work in another minute"
    pkill etcd
  fi
fi

output=/opt/etcd-backup/latest
etcd-backup -file=$output -config=/root/backup-configuration.json -etcd-config=/root/etcd-configuration.json dump
DATE=$(date +"%Y-%m-%d-%H-%M")
cp -f $output /opt/etcd-backup/$DATE
/usr/bin/rclone copy /opt/etcd-backup remote:etcd-${TOKEN}
/usr/bin/rclone --min-age=5d delete remote:etcd-${TOKEN}
find /opt/etcd-backup -mtime +5 -exec rm {} \;
