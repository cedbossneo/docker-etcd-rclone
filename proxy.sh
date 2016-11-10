#!/bin/bash
(
  while true
  do
    sleep 10
    echo "Testing $1"
    nc -w 1 $1 2379
    if [ $? -eq 1 ]; then
        echo "A known peer went down.  Bad state.  Exiting..."
        pkill etcd
    fi
  done
  pkill etcd
) &
etcd -proxy on --discovery-fallback 'exit' -listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 -initial-cluster etcd=http://$1:2380
