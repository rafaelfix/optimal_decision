#!/usr/bin/env python3
import uuid

# Suggested names for default "development" user and database
DEV_USER = "olle_dev_user"
DEV_DATABASE = "olle_dev_db"


def gen_env():
    django_key = uuid.uuid4()
    pg_pass = uuid.uuid4()

    with open(".env.web", "w") as env_web:
        env_web.write(
            # Django settings, see: django_backend/settings.py
            f"DJANGO_ALLOWED_HOSTS=*\n"
            f"SECRET_KEY={django_key}\n"
            f"SQL_HOST=db\n"
            f"SQL_PORT=5432\n"
            f"SQL_USER={DEV_USER}\n"
            f"SQL_PASSWORD={pg_pass}\n"
            f"SQL_DATABASE={DEV_DATABASE}\n"
        )

    with open(".env.db", "w") as env_db:
        env_db.write(
            # Postgres Docker image settings, see: https://github.com/docker-library/docs/blob/master/postgres/README.md#environment-variables
            f"POSTGRES_USER={DEV_USER}\n"
            f"POSTGRES_PASSWORD={pg_pass}\n"
            f"POSTGRES_DB={DEV_DATABASE}\n"
        )


if __name__ == "__main__":
    print("Generating .env.web and .env.db files...")
    gen_env()
