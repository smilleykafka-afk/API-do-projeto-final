# TechFix REST API

Standalone Laravel 12 API for TechFix. Run commands from this repository root. The Flutter application remains at `C:\Projeto Final\TechFix` and connects by URL; its files were not changed.

## Docker setup

Start Docker Desktop (Linux engine). See [Docker instructions](docs/DOCKER.md) for volume checks before startup. Compose uses project `techfix` and the existing external volumes `techfix_mysql-data` and `techfix_api-storage`. Missing volumes cause startup to fail instead of creating an empty database or a new application key. Never run the old and new Compose definitions concurrently.

```powershell
docker compose config --quiet
docker compose up --build -d --wait
docker compose ps
docker compose exec api php artisan migrate:status
docker compose exec api php vendor/phpunit/phpunit/phpunit --do-not-cache-result
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_api.ps1 -CleanupTestEmployee
```

API: `http://localhost:8000/api`; health: `http://localhost:8000/up`. PHPUnit uses isolated in-memory SQLite; the smoke test uses live MySQL. Do not reset the database or delete volumes. Host `.env` is preserved locally, ignored by Git and excluded from Docker builds. Container startup reuses the application key stored in the storage volume and runs pending migrations.

## Flutter connection

Run these commands from the separate Flutter repository:

```powershell
cd 'C:\Projeto Final\TechFix'
flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=http://localhost:8000/api
# Android emulator:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

CORS permits `http://localhost:8080`; authentication uses Sanctum bearer tokens. Moving source does not change the published port or API URL.

## API and administration

Registration creates employees. Only administrators manage users. Create/promote an administrator interactively with `docker compose exec api php artisan techfix:admin admin@example.com`. There are no built-in administrator credentials.

The existing implementation provides authentication, profile, dashboard, employees and CRUD for clientes, aparelhos, ordens-servico, parts and users. Device customers are optional; orders require a device. Legacy IMEI data remains supported. Records are shared by shop staff. See the [API contract](docs/API.md), [Postman collection](docs/TechFix.postman_collection.json), [demo](docs/DEMO.md) and [validation report](docs/VALIDATION.md). Regenerate Postman with `powershell -File tools/build_postman.ps1`.

For a non-Docker installation: install PHP 8.2+, Composer and MySQL, run `composer install`, configure the preserved local `.env`, then `php artisan migrate` and `php artisan serve --host=0.0.0.0 --port=8000 --no-reload`. Only generate a key for a genuinely new installation. Tests additionally require PDO SQLite. Use HTTPS and disable debug mode for deployment.

## Transfer preservation

The previous destination project is preserved locally in `.migration-backup/destination-before-techfix/`, excluded from Git and Docker builds. The original backend at `C:\Projeto Final\TechFix\backend` remains intact. Its removal requires separate user authorization after validation.