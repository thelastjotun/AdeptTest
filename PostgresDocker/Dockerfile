FROM postgis/postgis:16-3.4

ENV POSTGRES_USER adept
ENV POSTGRES_PASSWORD 12345678
ENV POSTGRES_DB adeptTest

RUN apt-get update

COPY init.sql /docker-entrypoint-initdb.d/init.sql