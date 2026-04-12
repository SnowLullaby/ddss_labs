FROM postgres:16
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends pgpool2 \
    && rm -rf /var/lib/apt/lists/*
COPY pgpool/pgpool.conf /etc/pgpool2/pgpool.conf
COPY pgpool/pool_hba.conf /etc/pgpool2/pool_hba.conf
COPY pgpool/pool_passwd /etc/pgpool2/pool_passwd
COPY pgpool/pcp.conf /etc/pgpool2/pcp.conf
COPY scripts/wait-for-services.sh /usr/local/bin/wait-for-services.sh
COPY scripts/pgpool-failover.sh /usr/local/bin/pgpool-failover.sh
RUN chmod 600 /etc/pgpool2/pcp.conf \
    && chmod +x /usr/local/bin/wait-for-services.sh \
    && chmod +x /usr/local/bin/pgpool-failover.sh \
    && mkdir -p /var/run/postgresql /var/log/pgpool \
    && chown -R postgres:postgres /var/run/postgresql /var/log/pgpool /etc/pgpool2
ENV PATH="/usr/sbin:/usr/bin:/bin:${PATH}"
USER postgres
CMD ["bash", "-lc", "wait-for-services.sh pg_a 5432 pg_b 5432 pg_c 5432 && exec /usr/sbin/pgpool -D -n -f /etc/pgpool2/pgpool.conf -a /etc/pgpool2/pool_hba.conf"]
