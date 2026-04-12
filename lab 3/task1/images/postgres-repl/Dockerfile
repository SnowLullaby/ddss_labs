FROM postgres:16
COPY scripts/standby-entrypoint.sh /usr/local/bin/standby-entrypoint.sh
COPY scripts/postgres-keepalive.sh /usr/local/bin/postgres-keepalive.sh

RUN chmod +x /usr/local/bin/standby-entrypoint.sh \
    /usr/local/bin/postgres-keepalive.sh

ENTRYPOINT ["/usr/local/bin/postgres-keepalive.sh"]
CMD ["postgres"]
