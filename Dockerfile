FROM tuatahifibre/alpine:latest
LABEL "nz.co.tuatahifibre.vendor"="Tuatahi First Fibre" \
      version="1.0" \
      description="Postgres with ability to run pg_dump"

RUN apk add --no-cache postgresql-client \
    tzdata && \
    adduser \
    --uid \
    99999 \
    -D \
    -H \
    pg_dump

ADD dump.sh /dump.sh
RUN chmod +x /dump.sh

ADD start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /dump

USER pg_dump

ENTRYPOINT ["/start.sh"]
CMD [""]