#!/bin/sh
rm -Rf /opt/etcd-backup
etcdctl backup \
      --data-dir /opt/etcd/data \
      --wal-dir /opt/etcd/wal \
      --backup-dir /opt/etcd-backup/data
      --backup-wal-dir /opt/etcd-backup/wal
/usr/bin/rclone copy /opt/etcd-backup Openstack:etcd-${TOKEN}
