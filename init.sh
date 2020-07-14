#!/bin/bash

set -eu

export MAYAN_DATABASES="{default: {ENGINE: django.db.backends.postgresql, HOST: ${CLOUDRON_POSTGRESQL_HOST}, NAME: ${CLOUDRON_POSTGRESQL_DATABASE}, \
                          PASSWORD: ${CLOUDRON_POSTGRESQL_PASSWORD}, USER: ${CLOUDRON_POSTGRESQL_USERNAME}}}"
# export MAYAN_DATABASE_ENGINE=django.db.backends.postgresql
# export MAYAN_DATABASE_NAME=${CLOUDRON_POSTGRESQL_DATABASE}
# export MAYAN_DATABASE_USER=${CLOUDRON_POSTGRESQL_USERNAME}
# export MAYAN_DATABASE_PASSWORD=${CLOUDRON_POSTGRESQL_PASSWORD}
# export MAYAN_DATABASE_HOST=${CLOUDRON_POSTGRESQL_HOST}
# export MAYAN_DATABASE_PORT=${CLOUDRON_POSTGRESQL_PORT}
export MAYAN_CELERY_RESULT_BACKEND="redis://:${CLOUDRON_REDIS_PASSWORD}@${CLOUDRON_REDIS_HOST}:${CLOUDRON_REDIS_PORT}/1"
export MAYAN_CELERY_BROKER_URL="redis://:${CLOUDRON_REDIS_PASSWORD}@${CLOUDRON_REDIS_HOST}:${CLOUDRON_REDIS_PORT}/0"
export MAYAN_MEDIA_ROOT=/app/data/media


if [ ! -e "/run/init-completed" ]; then
  (/app/data/mayan-edms/bin/mayan-edms.py initialsetup;
  rm -rf /var/run/supervisor.sock;
  exec /usr/bin/supervisord -nc /etc/supervisor/supervisord.conf;
  apt remove -y --purge libjpeg-dev libpq-dev libpng-dev libtiff-dev zlib1g-dev;
  touch /run/init-completed)&
fi

chown cloudron:cloudron /app/data -R

rm -rf /var/run/supervisor.sock
exec /usr/bin/supervisord --configuration /etc/supervisor/supervisord.conf --nodaemon -i mayanedms