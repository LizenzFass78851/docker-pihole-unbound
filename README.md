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
  -e 'FTLCONF_webserver_api_password'='******' \
  -v "$PWD/pihole/pihole/":'/etc/pihole/':'rw' \
  -v "$PWD/pihole/dnsmasq.d/":'/etc/dnsmasq.d/':'rw' \
  --cap-add=NET_ADMIN \
  --hostname=pihole \
  'ghcr.io/lizenzfass78851/docker-pihole-unbound:latest'
```


### Required environment variables

> Vars and descriptions replicated from the [official pihole container](https://github.com/pi-hole/docker-pi-hole/):

| Docker Environment Var | Description|
| --- | --- |
| `TZ: <Timezone>`<br/> | Set your [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) to make sure logs rotate at local midnight instead of at UTC midnight.
| `FTLCONF_webserver_api_password: <Admin password>`<br/> | http://pi.hole/admin password. Run `docker logs pihole \| grep random` to find your random pass.
| `FTLCONF_dns_revServers: <enabled>,<ip-address>[/<prefix-len>],<server>[#<port>],<domain>`<br/> | Enable Reverse server (former also called "conditional forwarding") feature
| `USE_IPV6: <"true"\|"false">`<br/>| Set to `true` if ipv6 is needed for unbound (not required in most use-cases)

Example `.env` file in the same directory as your `docker-compose.yaml` file:

```
TZ=America/Los_Angeles
FTLCONF_webserver_api_password=QWERTY123456asdfASDF
FTLCONF_dns_revServers=true,192.168.0.0/16,192.168.1.1,local
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
    image: pihole/pihole:development # <- update image version here, see: https://github.com/pi-hole/docker-pi-hole/releases
    ports:
      - 53:53/tcp   # DNS
      - 53:53/udp   # DNS
      - 80:80/tcp   # HTTP
      - 443:443/tcp # HTTPS
    environment:
      - TZ=${TZ}
      - FTLCONF_webserver_api_password=${FTLCONF_webserver_api_password}
      - FTLCONF_dns_revServers=${FTLCONF_dns_revServers}
      - FTLCONF_dns_upstreams=unbound # Hardcoded to our Unbound server
      - FTLCONF_dns_dnssec=true # Enable DNSSEC
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
