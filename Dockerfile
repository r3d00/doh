FROM rustlang/rust:nightly as build
###
### DNS over HTTPs
###

# Compile DOH proxy without https support
# This image is intended to run behind a reverse proxy for tls termination
RUN cargo install doh-proxy --no-default-features

# Runtime container
FROM debian:buster-slim

# Metadata
LABEL version="1.0.0" \
    maintainer="ms <ms@red0.pro>" \
    description="DNS over HTTPs"

# Environment variables to configure doh
ENV VIRTUAL_HOST doh.domain.local
ENV LISTEN_HOST 0.0.0.0
ENV LISTEN_PORT 3000
ENV MAX_CONCURRENT_CLIENTS 512
ENV MAX_CONCURRENT_CONNECTIONS 16
ENV MIN_TTL 10
ENV MAX_TTL 604800
ENV URI /dns
ENV PUBLIC_IP 100.100.100.100
ENV UPSTREAM_DNS_HOST 9.9.9.9
ENV UPSTREAM_DNS_PORT 53
ENV TIMEOUT 10

# Prepare doh-proxy service
WORKDIR /srv
COPY --chown=root:root --from=build /usr/local/cargo/bin/doh-proxy /srv/
COPY --chown=root:root entrypoint.sh /srv/
RUN chmod +x /srv/doh-proxy && /srv/doh-proxy -V

# Expose default port
EXPOSE 3000

# Create entrypoint based on env variables
ENTRYPOINT ["./entrypoint.sh"]