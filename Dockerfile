FROM debian:buster-slim

ENV CODE="code"
ENV SERVER="smart"

ARG VERSION="expressvpn_2.6.0.32-1_armhf.deb"

COPY files/ /expressvpn/

RUN apt-get update && apt-get install -y --no-install-recommends \
    expect curl ca-certificates iproute2 wget jq \
    && wget -q https://download.expressvpn.xyz/clients/linux/${VERSION} -O /expressvpn/${VERSION} \
    && dpkg -i /expressvpn/${VERSION} \
    && rm -rf /expressvpn/*.deb \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --autoremove -y wget \
	&& rm -rf /var/log/*.log

HEALTHCHECK --start-period=30s --timeout=5s --interval=1m --retries=3 CMD bash /expressvpn/healthcheck.sh

ENTRYPOINT ["/bin/bash", "/expressvpn/start.sh"]
