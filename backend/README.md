# Backend

Denna modul innehåller ett backend-system skrivet i Python med ramverket Django.
Backend-systemet använder databashanteraren PostgreSQL för att lagra data, och
erbjuder en REST-API via HTTP, som används av [appen](../frontend/).

## Uppstartsguide

Nedan följer en guide som hjälper dig att komma igång med utveckling av backend-systemet.

### Lokal utveckling via Docker

För att underlätta konfiguration av den miljö som backend-systemet körs i används Docker och
Docker Compose. Docker-konfigurationen innebär att samma miljö kan användas både under lokal
utveckling och under driftsättning på produktionsservern. Det går även att utveckla backend-systemet
utan att använda Docker, men det finns inga instruktioner för denna metod.

Följ instruktionerna nedan för att komma igång med lokal utveckling via Docker:

1. Kontrollera att din processor stödjer virtualisering och att det är aktiverat i BIOS-inställningarna.
   [Här finns en guide](https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html).

2. Installera [Docker Desktop](https://docs.docker.com/desktop/) (rekommenderas).
   Det går också att använda [Docker Engine](https://docs.docker.com/engine/) _utan_ Docker Desktop
   om man även installerar [Docker Compose](https://docs.docker.com/compose/), men Docker Desktop
   är enklare att använda och innehåller både Docker Engine och Docker Compose.

3. Installera [Python](https://www.python.org/), version 3.10 eller högre.

4. Generera .env-filer för din dator genom att köra Python-skriptet `gen_env.py` från samma mapp som denna README-fil ligger i.
   Dessa filer innehåller miljövariabler som sätts av Docker Compose. Variablerna innehåller bland annat hemliga nycklar, databaslösenord och enhetsspecifik konfiguration och ska därmed inte
   sparas i Git.

5. Starta Docker Desktop (du behöver _inte_ välja att logga in med konto).

6. Starta backend-systemet med hjälp av Docker Compose, genom att köra kommandot `docker compose up -d` i samma mapp som denna README-fil ligger i.

7. Backend-systemet ska nu gå att nå lokalt, via port 8088. Notera att appen måste ställas om
   för att använda den lokala servern istället för produktionsservern.
   Se ["Hur man ansluter appen mot en lokal server"](../frontend/README.md#hur-man-ansluter-appen-mot-en-lokal-server).

### Tips

Nedan följer några tips och information om Docker och konfigurationen som kan vara bra att känna till:

- När du använder Docker Compose måste du stå i samma mapp som denna README-fil ligger i för att Compose ska hitta sina konfigurationsfiler.
- Docker Desktop startar automatiskt Backend-systemet när Docker Desktop startas,
  om backend-systemet väl har installerats en gång.
- Backend-systemets databas lagras i en Docker-volym, så all data finns kvar så länge inte
  volymen tas bort explicit.
- Föjande kommandon och flaggor är av särskilt intresse:
  - `docker compose up [--detach] [--force-recreate] [--build]`
  - `docker compose down [--volumes]`
  - `docker compose start`
  - `docker compose stop`
  - `docker compose logs [--follow]`
  - `docker compose exec -it`
  - `docker compose copy`
  - `docker compose ps [--all]`
- Det finns mycket användbar information om Docker att läsa i [den officiella dokumentationen](https://docs.docker.com/).

### Vanliga kommandon

Nedan följer exempel på vanliga kommandon som används vid utveckling av backend-systemet.

> **OBS!** Många av dessa kommandon utgår från att du arbetar i samma mapp som denna README-fil ligger i.

Starta backend-systemet som en bakgrundstjänst:

```
>> docker compose up -d
```

Starta om backend-systemet med en nybyggd image (för att driftsätta ändringar du har gjort i koden):

```
>> docker compose up -d --build
```

Starta backend-systemet i Docker Compose "watch mode", så att du slipper bygga om manuellt varje gång du ändrar i koden:

```
>> docker compose watch
```

Stoppa backend-systemet:

```
>> docker compose stop
```

Kontrollera status för backend-systemet:

```
>> docker compose ps -a
```

Inspektera den löpande loggen för backend-systemet:

```
>> docker compose logs -f
```

Anslut till webbserver-container:

```
>> docker compose exec -it web sh
```

Anslut till databas-container:

```
>> docker compose exec -it db sh
```

#### Databasen

Notera: `olle_dev_db` är standardnamnet på databasen som används i appen, se gen_env.py.

Anslut till `olle_dev_db`-databasen med Postgres-konsolen (ska köras i databas-container):

```
>> psql -U olle_dev_user olle_dev_db
```

Anslut till `postgres`-databasen med Postgres-konsolen (ska köras i databas-container):

```
>> psql -U olle_dev_user postgres
```

Återställ `olle_dev_db`-databasen (ska köras i Postgres-konsolen för `postgres`-databasen):

```
>> drop database olle_dev_db;
>> create database olle_dev_db;
```

Lista alla databaser (ska köras i Postgres-konsolen för `postgres`-databasen):

```
>> \l
```

Lista alla tabeller i en databas (ska köras i Postgres-konsolen):

```
>> \dt
```

Visa all data ur en tabell (ska köras i Postgres-konsolen):

```
>> SELECT * FROM <table>;
```

Gå ut ur databasen/konsolen (ska köras i Postgres-konsolen):

```
>> \q
```

Generera diagram över databasschemat utifrån Django-modeller (ska köras i webbserver-container):

```
>> python3 manage.py graph_models olle -o olle_models.pdf
```

Kopiera diagram ut ur webbserver-container (ska köras utanför container):

```
>> docker compose cp web:/home/app/web/olle_models.pdf .
```

Visa all data ur databasen i JSON-format, från Django (ska köras i webbserver-container):

```
>> python3 manage.py dumpdata olle --indent 4
```

Visa all data ur en specifik tabell i databasen (t.ex. `Task`) i JSON-format, från Django (ska köras i webbserver-container):

```
>> python3 manage.py dumpdata olle.Task --indent 4
```

Visa alla mejl som har "skickats" från den lokala webbservern (ska köras i webbserver-container):

```
>> cat sent_emails/*
```

För att använda backend-systemets REST API med CSV som svarsformat krävs ett administratörskonto.
För att skapa ett administratörskonto används följande kommando (ska köras i webbserver-container):

```
>> python3 manage.py createsuperuser
```

#### Django

Nedanstående kommandon utgår från att de används i webbserver-containern om inget annat anges. Om de ska användas på värddatorn behöver Python köras på rätt sätt enligt operativsystem och konfiguration. Lathund:

- **Linux & macOS:** `python3 <file> <args>`
- **Windows:** `python <file> <args>`

Alla [Django-kommandon](https://docs.djangoproject.com/en/5.0/ref/django-admin/) körs med:

```
>> python manage.py <command>
```

För att driftsätta ändringar i databasen behöver följande kommandos köras: **Notera att dessa bara är relevanta om du personligen ändrar databasen då alla migrationer versionshanteras och migreras vid uppstart**

> För att skapa migreringen används:
>
> ```
> >> python manage.py makemigrations olle
> ```

> För att applicera alla migrations används:
>
> ```
> >> python manage.py migrate
> ```

För att av-applicera alla migrations används:

```
>> python manage.py migrate olle zero
```

> **OBS!** Ovanstående fungerar bara om alla migrations är [reversible](https://docs.djangoproject.com/en/4.2/topics/migrations/#reversing-migrations).

För att återställa databasen när du har problem med irreversible migrations eller liknande används (ska köras i databas-container):

```
>> psql -U olle_dev_user postgres

>> drop database olle_dev_db;

>> create database olle_dev_db;

>> \q
```

Eller, alternativt, för att återställa alla containers och volumes (inklusive databasen) för backend-systemet (ska köras utanför container):

```
>> docker compose down --volumes

>> docker compose up -d
```

Efter detta kan du applicera migrations igen för att sätta upp den nya databasen.

#### Tester

Kör alla tester (ska köras i webbserver-container):

```
>> python manage.py test [APP]
```

Kör alla tester och skapa en coverage rapport (ska köras i webbserver-container):

```
>> coverage run --source='.' manage.py test [APP]
```

Visa rapporten (ska köras i webbserver-container):

```
>> coverage report
```

## Produktionsserver

Produktionsservern som går att nå via `optimalmeasurements.it.liu.se` administreras av LiU-IT, 
men begränsad åtkomst ges ut på begäran. Denna begränsade åtkomst innefattar SSH-åtkomst (dock enbart via LiUs nätverk)
samt medlemskap i grupperna `docker` och `server-admins`. Som medlem i dessa grupper kan man använda Docker
för att driftsätta och hantera backend-systemet på produktionsservern. I mappen `/home/shared/` (som ägs av `server-admins`)
ligger de filer som hör till driftsättningen av backend-systemet.

Utåt sett kan backend-systemet på produktionsservern nås via HTTPS på addressen `https://optimalmeasurements.it.liu.se/http/` 
(även utanför LiUs nätverk) och trafiken vidarebefordras sedan internt till roten av backend-systemets webbserver på port 8088,
via en Ngnix-konfiguration som administreras av LiU-IT.

### Hur man driftsätter backend-systemet på produktionsservern

För att driftsätta på produktionsservern behöver du först logga in i skalet via SSH.
Därifrån kan du köra Docker-kommandon för att starta/stoppa/hämta de containers/images som behövs.
När man driftsätter för produktion används en särskild Docker Compose-fil, `docker-compose-prod.yml`,
som innehåller inställningar för produktionsservern. Den största skillnaden är att backend-systemets
webbserver hämtar en färdigbyggd (via GitLab CI) image direkt från GitLab-repots container registry
istället för att den byggs från källkoden.

#### Var ligger filerna?

Docker Compose-filen som används för produktionsmiljön ligger i mappen `/home/shared/olle_backend/2024/`.
Där ligger även env-filer för produktionsmiljön, som används av Compose-filen.

En kopia av compose-filen ligger i Git-repot (se [`docker-compose-prod.yml`](./docker-compose-prod.yml)),
som kan användas för att testa att inställningarna för produktionsmiljön även funkar lokalt.

#### Hur gör man?

För att deploya med `docker-compose-prod.yml` används i princip samma kommandon som för vanlig deployment,
men glöm inte `-f`-flaggan på `compose`-kommandot som specifierar vilken Compose-fil som ska användas,
och `--pull always` för att alltid hämta senaste avbilden från containerregistret. Till exempel,
för att driftsätta senast byggda container från main-branchen:

```
docker compose -f docker-compose-prod.yml up -d --pull always
```

Innan du deployar `docker-compose-prod.yml` första gången måste du logga in på GitLab-projektets Docker registry:

- [GitLab docs](https://docs.gitlab.com/ee/user/packages/container_registry/authenticate_with_container_registry.html)
- [Docker docs](https://docs.docker.com/reference/cli/docker/login/)

Kör kommandot `docker login gitlab.liu.se:5000/emiho191/tddd96-pum09-2024` och logga in med ditt LiU-konto.

> **OBS!** Detta måste göras både i produktionsmiljön och på din egna dator, om du även vill testa `docker-compose-prod.yml` där.

Tänk också på att du måste ta ner backend-systemet som används under utveckling med `docker compose down`
innan du driftsätter `docker-compose-prod.yml` på din dator.
Annars kommer du köra två backend-system samtidigt som försöker dela på samma nätverksport.

När du är färdig med att testa `docker-compose-prod.yml`, kör `docker compose -f docker-compose-prod.yml down`
så att du kan deploya utvecklingsmiljön igen med `docker compose up -d --build`.

## Övrigt

Se dokumenten [maintenance.md](./maintenance.md) och [database_description.md](./database_description.md).
