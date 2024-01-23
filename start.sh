#!/bin/bash

set -eu

echo "=> Loading configuration"
export DB="postgres"
export DB_HOST="${CLOUDRON_POSTGRESQL_HOST}"
export DB_NAME="${CLOUDRON_POSTGRESQL_DATABASE}"
export DB_PASSWORD="${CLOUDRON_POSTGRESQL_PASSWORD}"
export DB_PORT="${CLOUDRON_POSTGRESQL_PORT}"
export EMAIL_HOST="${CLOUDRON_MAIL_SMTP_SERVER}"
export EMAIL_PORT="${CLOUDRON_MAIL_SMTP_PORT}"
export EMAIL_HOST_USER="${CLOUDRON_MAIL_SMTP_USERNAME}"
export EMAIL_HOST_PASSWORD="${CLOUDRON_MAIL_SMTP_PASSWORD}"
export EMAIL_USE_TLS=True

[[ -f /app/data/env ]] && mv /app/data/env /app/data/env.sh
[[ ! -f "/app/data/env.sh" ]] && cp /app/pkg/env.sh.template /app/data/env.sh
source /app/data/env.sh

echo "=> Setting permissions"
chown -R cloudron:cloudron /app/data

echo "=> Starting N8N"
exec gosu cloudron:cloudron uwsgi /app/code/docker/uwsgi.ini
