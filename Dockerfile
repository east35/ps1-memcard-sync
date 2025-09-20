FROM alpine:3

RUN apk add --no-cache coreutils tzdata

ENV WATCH_DIR=/watch
ENV POLL_INTERVAL=2
ENV PUID=0
ENV PGID=0

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/watch"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]