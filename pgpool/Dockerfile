# same base as postgres:10
FROM debian:jessie
ARG POSTGRES_CLIENT_VERSION=10
ARG PGPOOL_VERSION=3.6\*

RUN groupadd -r postgres --gid=999 && useradd -r -g postgres -d /home/postgres  --uid=999 postgres

RUN set -ex \
  && apt-get update \
  && apt-get install -y \
    libffi-dev \
    libssl-dev \
    wget \
    gnupg2 \
  && wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add - \
  && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' \
  && apt-get update \
  && apt-get install -y \
    postgresql-client-${POSTGRES_CLIENT_VERSION} \
    pgpool2=${PGPOOL_VERSION}

ENV DOCKERIZE_VERSION v0.5.0
RUN set -ex \
  && wget https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

ENV GOSU_VERSION 1.10
RUN set -ex \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
  && chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

RUN set -ex \
  && touch /var/log/postgresql/pgpool_status \
  && chown postgres /var/log/postgresql/pgpool_status

COPY ./bin /usr/local/bin/pgpool
COPY ./configs /var/pgpool_configs

RUN chmod +x -R /usr/local/bin/pgpool

ENV CHECK_USER replication_user
ENV CHECK_PASSWORD replication_pass
ENV CHECK_PGCONNECT_TIMEOUT 10
ENV WAIT_BACKEND_TIMEOUT 120
ENV REQUIRE_MIN_BACKENDS 0
ENV SSH_ENABLE 0
ENV NOTVISIBLE "in users profile"

EXPOSE 22
EXPOSE 5432
EXPOSE 9898

HEALTHCHECK --interval=1m --timeout=10s --retries=5 \
  CMD /usr/local/bin/pgpool/has_write_node.sh

CMD ["/usr/local/bin/pgpool/entrypoint.sh"]