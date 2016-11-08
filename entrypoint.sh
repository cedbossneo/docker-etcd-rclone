#!/bin/sh
cat <<EOF > /root/.rclone.conf
[Openstack]
type = swift
user = ${OS_USERNAME}
key = ${OS_PASSWORD}
auth = ${OS_AUTH_URL}
tenant = ${OS_TENANT_NAME}
region = ${OS_REGION_NAME}
EOF

rclone copy Openstack:etcd-${TOKEN} /opt/etcd
etcd -data-dir=/opt/etcd/data -wal-dir=/opt/etcd/wal -force-new-cluster
crond -f
