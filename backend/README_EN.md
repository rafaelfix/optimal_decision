# Back end

This module contains a backend system written in Python using the Django framework.
The backend system uses the database manager PostgreSQL to store data, and
offers a REST API over HTTP, used by the [app](../frontend/).

## Startup guide

Below is a guide to help you get started with developing the backend system.

### Local development via Docker

To facilitate configuration of the environment in which the backend system runs, Docker is used and
Docker Compose. The Docker configuration means that the same environment can be used both under local
development and under deployment on the production server. It is also possible to develop the backend system
without using Docker, but there are no instructions for this method.

Follow the instructions below to get started with local development via Docker:

1. Check that your processor supports virtualization and that it is enabled in the BIOS settings.
 [Here's a guide](https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html).

2. Install [Docker Desktop](https://docs.docker.com/desktop/) (recommended).
 It is also possible to use [Docker Engine](https://docs.docker.com/engine/) _without_ Docker Desktop
 if you also install [Docker Compose](https://docs.docker.com/compose/), but Docker Desktop
 is easier to use and includes both Docker Engine and Docker Compose.

3. Install [Python](https://www.python.org/), version 3.10 or higher.

4. Generate .env files for your computer by running the Python script `gen_env.py` from the same folder as this README file.
 These files contain environment variables that are set by Docker Compose. The variables contain, among other things, secret keys, database passwords and device-specific configuration and thus should not
 saved in Git.

5. Start Docker Desktop (you _don't_ have to choose to log in with account).

6. Start the backend system using Docker Compose, by running the `docker compose up -d` command in the same folder as this README file.

7. The backend system should now be reachable locally, via port 8088. Note that the app must be reset
 to use the local server instead of the production server.
 See ["How to connect the app to a local server"](../frontend/README.md#how-to-connect-the-app-to-a-local-server).

### Tips

Below are some tips and information about Docker and configuration that may be useful to know:

- When using Docker Compose, you must be in the same folder as this README file in order for Compose to find its configuration files.
- Docker Desktop automatically starts the Backend system when Docker Desktop is started,
 once the backend system has been installed.
- The backend system's database is stored in a Docker volume, so all data remains for the time being
 the volume is removed explicitly.
- Additional commands and flags are of particular interest:
 - `docker compose up [--detach] [--force-recreate] [--build]`
 - `docker compose down [--volumes]`
 - `docker compose start`
 - `docker compose stop`
 - `docker compose logs [--follow]`
 - `docker compose exec -it`
 - `docker compose copy`
 - `docker compose ps [--all]`
- There is a lot of useful information about Docker to read in [the official documentation](https://docs.docker.com/).

### Common commands

Below are examples of common commands used when developing the backend system.

> **NOTE!** Many of these commands assume that you are working in the same folder as this README file.

Start the backend system as a background service:

```
>> docker compose up -d
```

Reboot the backend system with a freshly built image (to deploy changes you made to the code):

```
>> docker compose up -d --build
```

Start the backend system in Docker Compose "watch mode", so you don't have to rebuild manually every time you change the code:

```
>> docker compose watch
```

Stop the backend system:

```
>> docker compose stop
```

Check the status of the backend system:

```
>> docker compose ps -a
```

Inspect the running log of the backend system:

```
>> docker compose logs -f
```

Connect to web server container:

```
>> docker compose exec -it web sh
```

Connect to database container:

```
>> docker compose exec -it db sh
```

#### The database

Note: `olle_dev_db` is the default name of the database used in the app, see gen_env.py.

Connect to the `olle_dev_db` database using the Postgres console (must run in database container):

```
>> psql -U olle_dev_user olle_dev_db
```

Connect to the `postgres` database using the Postgres console (must run in database container):

```
>> psql -U olle_dev_user postgres
```

Restore the `olle_dev_db` database (to be run in the Postgres console for the `postgres` database):

```
>> drop database olle_dev_db;
>> create database olle_dev_db;
```

List all databases (to be run in the Postgres console for the `postgres` database):

```
>> \l
```

List all tables in a database (to be run in the Postgres console):

```
>> \dt
```

Display all data from a table (to be run in the Postgres console):

>> SELECT * FROM <table>;
Exit the database/console (should run in the Postgres console):

>> \q
Generate diagram of the database schema based on Django models (to be run in web server container):

>> python3 manage.py graph_models olle -o olle_models.pdf
Copy chart out of web server container (must run outside container):

>> docker compose cp web:/home/app/web/olle_models.pdf .
Display all data from the database in JSON format, from Django (to be run in web server container):

>> python3 manage.py dumpdata olle --indent 4
Display all data from a specific table in the database (e.g. Task) in JSON format, from Django (to be run in web server container):

>> python3 manage.py dumpdata olle.Task --indent 4
Show all emails that have been "sent" from the local web server (must run in web server container):

>> cat sent_emails/*
To use the backend system's REST API with CSV as the response format, an administrator account is required. To create an administrator account, use the following command (to be run in the web server container):

>> python3 manage.py createsuperuser
Django
The commands below are assumed to be used in the web server container unless otherwise specified. If they are to be used on the host computer, Python needs to be run correctly according to the operating system and configuration. Crib:

Linux & macOS: python3 <file> <args>
Windows: python <file> <args>
All Django commands are run with:

>> python manage.py <command>
To deploy changes to the database the following commands need to be run: Note that these are only relevant if you personally change the database as all migrations are version managed and migrated on startup

To create the migration, use:

>> python manage.py makemigrations olle
To apply all migrations, use:

>> python manage.py migrate
To de-apply all migrations use:

>> python manage.py migrate olle zero
ATTENTION! The above only works if all migrations are reversible.

To restore the database when you have problems with irreversible migrations or the like is used (must be run in the database container):

>> psql -U olle_dev_user postgres

>> drop database olle_dev_db;

>> create database olle_dev_db;

>> \q
Or, alternatively, to restore all containers and volumes (including the database) for the backend system (must be run out of container):

>> docker compose down --volumes

>> docker compose up -d
After this, you can apply migrations again to set up the new database.

Tests
Run all tests (must run in web server container):

>> python manage.py test [APP]
Run all tests and create a coverage report (to be run in web server container):

>> coverage run --source='.' manage.py test [APP]
View the report (to be run in web server container):

>> coverage report
Production server
The production server that can be reached via optimalmeasurements.it.liu.se is administered by LiU-IT, but limited access is issued on request. This limited access includes SSH access (but only via LiU's network) as well as membership in the docker and server-admins groups. As a member of these groups, you can use Docker to deploy and manage the backend system on the production server. In the folder /home/shared/ (owned by the server admins) are the files that belong to the commissioning of the backend system.

Externally, the backend system on the production server can be accessed via HTTPS at the address https://optimalmeasurements.it.liu.se/http/ (even outside LiU's network) and the traffic is then forwarded internally to the root of the backend system's web server on port 8088, via an Ngnix configuration administered by LiU-IT.

How to deploy the backend system on the production server
To deploy on the production server, you first need to login to the shell via SSH. From there you can run Docker commands to start/stop/fetch the containers/images needed. When deploying to production, a special Docker Compose file is used, docker-compose-prod.yml, which contains settings for the production server. The biggest difference is that the backend system's web server downloads a ready-built (via GitLab CI) image directly from the GitLab repot's container registry instead of it being built from the source code.

Where are the files located?
The Docker Compose file used for the production environment is located in the /home/shared/olle_backend/2024/ folder. There are also env files for the production environment, which are used by the Compose file.

A copy of the compose file is in the Git repot (see docker-compose-prod.yml), which can be used to test that the settings for the production environment also work locally.

How do you do it?
To deploy with docker-compose-prod.yml basically the same commands are used as for normal deployment, but don't forget the -f flag on the compose command which specifies which Compose file to use, and --pull always to always retrieve the latest image from the container registry. For example, to deploy recently built containers from the main branch:

docker compose -f docker-compose-prod.yml up -d --pull always
Before deploying docker-compose-prod.yml the first time, you need to login to the GitLab project's Docker registry:

GitLab docs
Docker docs
Run the command docker login gitlab.liu.se:5000/emiho191/tddd96-pum09-2024 and log in with your LiU account.

ATTENTION! This must be done both in the production environment and on your own computer, if you also want to test docker-compose-prod.yml there.

Also note that you must take down the backend system used during development with docker compose down before deploying docker-compose-prod.yml on your machine. Otherwise you will be running two backend systems at the same time trying to share the same network port.

When you're done testing docker-compose-prod.yml, run docker compose -f docker-compose-prod.yml down so you can deploy the development environment again with docker compose up -d --build.

Miscellaneous
See the maintenance.md and database_description.md documents.

bla.

