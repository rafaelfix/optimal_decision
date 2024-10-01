#!/bin/sh

echo "Waiting for postgres..."

while ! nc -z $SQL_HOST $SQL_PORT; do
  sleep 0.1
done

echo "PostgreSQL started"

# Apply pending migrations to DB, if any exist
python3 manage.py migrate

exec "$@"
