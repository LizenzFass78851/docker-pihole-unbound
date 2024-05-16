# Pi-Hole + Unbound - 1 Container

## Description

This Docker deployment runs both Pi-Hole and Unbound in a single container. 

The base image for the container is the [official Pi-Hole container](https://hub.docker.com/r/pihole/pihole), with an extra build step added to install the Unbound resolver directly into to the container based on [instructions provided directly by the Pi-Hole team](https://docs.pi-hole.net/guides/unbound/).

# Tags

| Image | Tag | Build |
|:------------------:|:--------------:|:-----------------:|
| ghcr.io/lizenzfass78851/docker-pihole-unbound | stable | [![Build and Publish Docker Image](https://github.com/LizenzFass78851/docker-pihole-unbound/actions/workflows/docker-image.yml/badge.svg?branch=stable)](https://github.com/LizenzFass78851/docker-pihole-unbound/actions/workflows/docker-image.yml) |
| ghcr.io/lizenzfass78851/docker-pihole-unbound | oldstable | [![Build and Publish Docker Image](https://github.com/LizenzFass78851/docker-pihole-unbound/actions/workflows/docker-image.yml/badge.svg?branch=oldstable)](https://github.com/LizenzFass78851/docker-pihole-unbound/actions/workflows/docker-image.yml) |
| ghcr.io/lizenzfass78851/docker-pihole-unbound | beta | [![Build and Publish Docker Image](https://github.com/LizenzFass78851/docker-pihole-unbound/actions/workflows/docker-image.yml/badge.svg?branch=beta)](https://github.com/LizenzFass78851/docker-pihole-unbound/actions/workflows/docker-image.yml) |

- Matrix Build State

[![Build and Publish Docker Image](https://github.com/LizenzFass78851/docker-pihole-unbound/actions/workflows/docker-image-matrix.yml/badge.svg)](https://github.com/LizenzFass78851/docker-pihole-unbound/actions/workflows/docker-image-matrix.yml)

## Usage

First create a `.env` file to substitute variables for your deployment. 

## Docker run

```bash
docker run -d \
  --name='pihole' \
  -e TZ="Europe/Berlin" \
  -e 'TCP_PORT_53'='53' -e 'UDP_PORT_53'='53' -e 'UDP_PORT_67'='67' -e 'TCP_PORT_80'='80' -e 'TCP_PORT_443'='443' \
  -e 'TZ'='Europe/Berlin' \
  -e 'WEBPASSWORD'='******' \
  -v "$PWD/pihole/pihole/":'/etc/pihole/':'rw' \
  -v "$PWD/pihole/dnsmasq.d/":'/etc/dnsmasq.d/':'rw' \
  -v "$PWD/pihole/external.conf":'/etc/lighttpd/external.conf':'rw' \
  --cap-add=NET_ADMIN \
  --hostname=pihole \
  'ghcr.io/lizenzfass78851/docker-pihole-unbound:latest'
```


### Required environment variables

> Vars and descriptions replicated from the [official pihole container](https://github.com/pi-hole/docker-pi-hole/):

| Docker Environment Var | Description|
| --- | --- |
| `FTLCONF_LOCAL_IPV4: <Host's IP>`<br/> | **--net=host mode requires** Set to your server's LAN IP, used by web block modes and lighttpd bind address
| `TZ: <Timezone>`<br/> | Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to make sure logs rotate at local midnight instead of at UTC midnight.
| `WEBPASSWORD: <Admin password>`<br/> | http://pi.hole/admin password. Run `docker logs pihole \| grep random` to find your random pass.
| `REV_SERVER: <"true"\|"false">`<br/> | Enable DNS conditional forwarding for device name resolution
| `REV_SERVER_DOMAIN: <Network Domain>`<br/> | If conditional forwarding is enabled, set the domain of the local network router
| `REV_SERVER_TARGET: <Router's IP>`<br/> | If conditional forwarding is enabled, set the IP of the local network router
| `REV_SERVER_CIDR: <Reverse DNS>`<br/>| If conditional forwarding is enabled, set the reverse DNS zone (e.g. `192.168.0.0/24`)
| `USE_IPV6: <"true"\|"false">`<br/>| Set to `true` if ipv6 is needed for unbound (not required in most use-cases)

Example `.env` file in the same directory as your `docker-compose.yaml` file:

```
FTLCONF_LOCAL_IPV4=192.168.1.10
TZ=America/Los_Angeles
WEBPASSWORD=QWERTY123456asdfASDF
REV_SERVER=true
REV_SERVER_DOMAIN=local
REV_SERVER_TARGET=192.168.1.1
REV_SERVER_CIDR=192.168.0.0/16
HOSTNAME=pihole
DOMAIN_NAME=pihole.local
```

### Using Portainer stacks?

Portainer stacks are a little weird and don't want you to declare your named volumes, so remove this block from the top of the `docker-compose.yaml` file before copy/pasting into Portainer's stack editor:

```yaml
volumes:
  etc_pihole-unbound:
  etc_pihole_dnsmasq-unbound:
```

### Running the stack

```bash
docker-compose up -d
```

> If using Portainer, just paste the `docker-compose.yaml` contents into the stack config and add your *environment variables* directly in the UI.

-----

### Alternative variant
There is also a variant of docker-pihole-unbound that works with separate containers

<details>
  <summary>docker-compose.yml</summary>

```yaml
version: '2'

services:
  pihole:
    container_name: pihole
    image: pihole/pihole:2024.07.0 # <- update image version here, see: https://github.com/pi-hole/docker-pi-hole/releases
    ports:
      - 53:53/tcp   # DNS
      - 53:53/udp   # DNS
      - 80:80/tcp   # HTTP
      - 443:443/tcp # HTTPS
    environment:
      - FTLCONF_LOCAL_IPV4=${FTLCONF_LOCAL_IPV4}
      - TZ=${TZ}
      - WEBPASSWORD=${WEBPASSWORD}
      - REV_SERVER=${REV_SERVER}
      - REV_SERVER_TARGET=${REV_SERVER_TARGET}
      - REV_SERVER_DOMAIN=${REV_SERVER_DOMAIN}
      - REV_SERVER_CIDR=${REV_SERVER_CIDR}
      - PIHOLE_DNS_=unbound # Hardcoded to our Unbound server
      - DNSSEC=true # Enable DNSSEC
    volumes:
      - etc_pihole:/etc/pihole:rw
      - etc_pihole_dnsmasq:/etc/dnsmasq.d:rw
    networks:
      - pihole-unbound
    restart: unless-stopped
    depends_on:
      - unbound

  unbound:
    container_name: unbound
    image: mvance/unbound:latest
    networks:
      - pihole-unbound
    restart: unless-stopped

networks:
  pihole-unbound:

volumes:
  etc_pihole:
  etc_pihole_dnsmasq:
```

</details>

The variant with the `docker-compose.yml` example there is a 2-container solution, which is also shown on the [pihole discourse forum](https://discourse.pi-hole.net/t/pihole-v6-unbound-in-one-docker-container/70091/5) with the type and white connection between the containers (without manual IP's between the containers) declared has also been confirmed.
