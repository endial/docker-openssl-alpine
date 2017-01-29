FROM endial/base-alpine

MAINTAINER Endial Fang ( endial@126.com )

# default variables
ENV COUNTY "CN"
ENV STATE "GuangDong"
ENV LOCATION "ShenZhen"
ENV ORGANISATION "Tidying Lab."
ENV ROOT_CN "Root"
ENV ISSUER_CN "Authentication Center"
ENV PUBLIC_CN "tidying.org"
ENV ROOT_NAME "root"
ENV ISSUER_NAME "intermediate"
ENV PUBLIC_NAME "public"
ENV RSA_KEY_NUMBITS "4048"
ENV DAYS "365"

# install openssl
RUN  apk update \
  && apk add openssl \
  && rm -rf /var/cache/apk/*

# certificate directories
ENV CERT_DIR "/etc/ssl/certs"
VOLUME ["$CERT_DIR"]

COPY *.ext /
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD []
