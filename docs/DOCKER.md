# Local Docker testing

Run all Docker/API commands from the standalone API repository root (the directory containing `compose.yaml`), not the Flutter repository. Start Docker Desktop with its Linux engine first.

## Preserve the existing installation

```powershell
docker compose config --quiet
docker volume inspect techfix_mysql-data techfix_api-storage --format '{{.Name}}'
docker ps -a --filter label=com.docker.compose.project=techfix --format '{{.Names}} {{.Status}}'
```

Compose project name remains `techfix`. The two volumes are explicitly external, so Docker cannot silently create replacement volumes. Check that existing API/database containers mount these volumes before continuing. Do not start the original Compose stack concurrently. Running the following command from this root reconciles the existing project's services:

```powershell
docker compose up --build -d --wait
docker compose ps
docker compose exec api php artisan migrate:status
docker compose exec api php vendor/phpunit/phpunit/phpunit --do-not-cache-result
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_api.ps1 -CleanupTestEmployee
```

The API publishes `127.0.0.1:8000`; MySQL 8.4 is internal to Docker. Migrations run before the API starts. The `--no-reload` option preserves Docker environment handling. The application key is loaded from `api-storage` and written to a container-local `.env` for exec commands; the host `.env` is never copied into the image. The configuration uses local development credentials and debug mode.

PHPUnit forces in-memory SQLite and does not reset MySQL. The smoke test uses MySQL, creates a uniquely named employee and business records, checks optional customer assignment and orders, removes its business records and logs out. `-CleanupTestEmployee` also deletes only that exact temporary employee via the local API container. Omit that switch when testing a remote URL; that mode leaves the registered employee with its token revoked.

Flutter commands belong in `C:\Projeto Final\TechFix`:

```powershell
flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=http://localhost:8000/api
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

CORS explicitly allows `http://localhost:8080`. Physical phones need a LAN-accessible port binding and firewall configuration.

```powershell
docker compose logs --tail=100 api db
docker compose stop
```

Never remove volumes, reset the database or run `migrate:fresh`. Keep the original backend until validation and explicit authorization to remove it. See [API](API.md), [demo](DEMO.md) and [validation](VALIDATION.md).