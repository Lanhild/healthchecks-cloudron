FROM cloudron/base:4.2.0@sha256:46da2fffb36353ef714f97ae8e962bd2c212ca091108d768ba473078319a47f4

RUN mkdir -p /app/pkg /app/code
WORKDIR /app/code

RUN git clone https://github.com/healthchecks/healthchecks /app/code/.

RUN apt-get update && \
    apt-get install -y build-essential git libpq-dev libmariadb-dev libffi-dev libssl-dev libcurl4-openssl-dev libpython3-dev rustc pkg-config python3-pip libcurl4 libpq5 libmariadb3 libxml2 && \
    rm -rf /var/cache/apt /var/lib/apt/lists

ENV USE_GZIP_MIDDLEWARE=True
ENV PYTHONUNBUFFERED=1
ENV CARGO_NET_GIT_FETCH_WITH_CLI true
RUN \
    pip install --upgrade pip && \
    pip wheel --wheel-dir /app/code/wheels apprise uwsgi mysqlclient minio -r /app/code/requirements.txt && \
    pip install --upgrade pip && \
    pip install --no-cache /app/code/wheels/*

RUN rm -rf /app/code/.git && \
    rm -rf /app/code/hc/local_settings.py && \
    DEBUG=False SECRET_KEY=build-key python3 /app/code/manage.py collectstatic --noinput && \
    DEBUG=False SECRET_KEY=build-key python3 /app/code/manage.py compress

RUN sed -i 's|chdir = /opt/healthchecks|chdir = /app/code|g' /app/code/docker/uwsgi.ini

COPY start.sh env.sh.template /app/pkg/

CMD [ "/app/pkg/start.sh" ]
