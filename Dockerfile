FROM alpine

RUN apk -U add ca-certificates \
 && rm -rf /var/cache/apk/*

RUN cd /tmp \
  && wget -q http://downloads.rclone.org/rclone-current-linux-386.zip \
  && unzip /tmp/rclone-current-linux-386.zip \
  && mv /tmp/rclone-*-linux-386/rclone /usr/bin \
  && rm -r /tmp/rclone*
RUN ETCD_VER=v3.0.14 DOWNLOAD_URL=https://github.com/coreos/etcd/releases/download curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz && tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /usr/bin --strip-components=1 && rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

ADD crontab /var/spool/cron/crontabs/root
ADD entrypoint.sh /entrypoint.sh
ADD backup.sh /root/backup.sh

CMD ["/entrypoint.sh"]
