FROM postgres:latest
LABEL "nz.co.tuatahifibre.vendor"="Tuatahi First Fibre" \
      version="1.0" \
      description="Postgres with ability to run pg_dump"

RUN apt-get update && \
    apt-get install -y cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD dump.sh /dump.sh
RUN chmod +x /dump.sh

ADD start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /dump

ENTRYPOINT ["/start.sh"]
CMD [""]