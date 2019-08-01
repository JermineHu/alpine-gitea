FROM gitea/gitea:1.9.0 as gitea-env
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && apk update && apk add upx binutils
RUN apk add --no-cache tzdata && \
        echo ${TIME_ZONE} > /etc/timezone && \
        ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/timezone
RUN cd /app/gitea && strip --strip-unneeded gitea && upx -9 gitea
FROM alpine:edge
MAINTAINER Jermine <Jermine.hu@qq.com>
ENV TIME_ZONE Asia/Shanghai
ENV USER git
ENV GITEA_CUSTOM /data/gitea

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && apk update && apk --no-cache add \
    bash \
    ca-certificates \
    curl \
    gettext \
    git \
    linux-pam \
    openssh \
    s6 \
    su-exec
    
RUN addgroup \
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

VOLUME ["/data"]
WORKDIR /data
ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]

COPY --from=gitea-env  /etc /etc
COPY --from=gitea-env  /usr/bin/entrypoint /usr/bin/entrypoint 
COPY --from=gitea-env /app/gitea/gitea /app/gitea/gitea
COPY --from=gitea-env /etc/timezone /etc/timezone
COPY --from=gitea-env /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime
RUN ln -s /app/gitea/gitea /usr/local/bin/gitea
