FROM alpine

RUN apk -U add ca-certificates curl bash \
 && rm -rf /var/cache/apk/*

RUN cd /tmp \
  && wget -q http://downloads.rclone.org/rclone-current-linux-386.zip \
  && unzip /tmp/rclone-current-linux-386.zip \
  && mv /tmp/rclone-*-linux-386/rclone /usr/bin \
  && rm -r /tmp/rclone*
ENV ETCD_VER v3.0.14
ENV DOWNLOAD_URL https://github.com/coreos/etcd/releases/download
RUN mkdir /opt && curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /opt && rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && ln -s /opt/etcd-v3.0.14-linux-amd64/etcd /usr/bin/etcd && ln -s /opt/etcd-v3.0.14-linux-amd64/etcdctl /usr/bin/etcdctl

ADD etcd-backup /usr/bin/etcd-backup
ADD backup-configuration.json /root
ADD etcd-configuration.json /root
ADD entrypoint.sh /entrypoint.sh
ADD backup.sh /root/backup.sh
ADD proxy.sh /proxy.sh

CMD ["/entrypoint.sh"]
