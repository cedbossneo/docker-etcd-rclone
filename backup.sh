#!/bin/sh
output=/opt/etcd-backup/latest
echo -n "" > $output
etcdctl ls --recursive -p --sort | grep -v '.*/$' | while read line; do (echo -n "$line" && echo -n '==='&& etcdctl get "$line") >> $output; done;
DATE=$(date +"%Y-%m-%d-%H-%M")
cp -f $output /opt/etcd-backup/$DATE
/usr/bin/rclone copy /opt/etcd-backup Openstack:etcd-${TOKEN}
find /opt/etcd-backup -mtime +5 -exec rm {} \;
