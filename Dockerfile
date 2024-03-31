# set version label
ARG BASE_VERSION

#FROM pihole/pihole:"${BASE_VERSION}"
FROM pihole/pihole:development-v6
RUN apk add --no-cache \
    unbound 

#COPY lighttpd-external.conf /etc/lighttpd/external.conf 
COPY unbound-pihole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
COPY 99-edns.conf /etc/dnsmasq.d/99-edns.conf
RUN mkdir -p /etc/services.d/unbound
COPY unbound-run /etc/services.d/unbound/run

ENTRYPOINT ["/sbin/tini", "--", "start.sh"]