FROM haproxy:3.3-alpine

USER root
RUN apk add --no-cache gettext

COPY haproxy.template.cfg /usr/local/etc/haproxy/haproxy.template.cfg
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER haproxy

EXPOSE 8080 8404
ENTRYPOINT ["/entrypoint.sh"]