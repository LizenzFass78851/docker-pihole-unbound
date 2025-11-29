FROM pihole/pihole:nightly

RUN apk add --no-cache \
    unbound openssl

COPY unbound-pihole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
COPY 99-edns.conf /etc/dnsmasq.d/99-edns.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN mkdir -p /run/unbound \
    && unbound -V \
    && unbound-anchor -v || true

RUN chown -R unbound:unbound \
    /etc/unbound /run/unbound \
    /usr/share/dnssec-root

RUN command -v capsh >/dev/null 2>&1 || \
    (echo "capsh command not found, installing libcap" && apk add --no-cache libcap)

ENTRYPOINT ["/docker-entrypoint.sh"]
