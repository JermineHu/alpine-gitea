FROM alpine:3.6
MAINTAINER Jermine <Jermine.hu@qq.com>

ENV USER git
ENV GITEA_CUSTOM /data/gitea
ENV GODEBUG=netdns=go

VOLUME ["/data"]

EXPOSE 22 3000
COPY docker /
COPY gitea /app/gitea/gitea
COPY conf /app/gitea/conf
RUN apk --no-cache add \
    su-exec \
    ca-certificates \
    sqlite \
    bash \
    git \
    linux-pam \
    s6 \
    curl \
    openssh \
    tzdata && \
    addgroup \
    -S -g 1000 \ 
    git && \
    adduser \
    -S -H -D \
    -h /data/git \
    -s /bin/bash \
    -u 1000 \
    -G git \
    git && \
  echo "git:$(dd if=/dev/urandom bs=24 count=1 status=none | base64)" | chpasswd

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]
