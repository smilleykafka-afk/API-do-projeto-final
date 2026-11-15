# Original transfer request (historical reference)

The transfer described below has been carried out. Current root commands are in ../README.md and DOCKER.md; results are in VALIDATION.md. Original source paths below identify the preserved Flutter repository.

# Instructions for Codex in the separate API project

Open your chosen API folder in Codex, then paste the following prompt. The current workspace in that session is the destination; no destination path needs to be filled in here. This is a Codex prompt, not a PowerShell command.

```text
Set up the standalone TechFix Laravel 12 REST API in the current workspace folder and connect it to the existing Flutter app at C:\Projeto Final\TechFix.

The existing API has NOT yet been moved. Its source is at C:\Projeto Final\TechFix\backend. First read the source project's README.md, docs/API.md, docs/DOCKER.md and docs/VALIDATION.md. Inspect the destination before writing; preserve any existing files and do not overwrite conflicts blindly. If access outside this workspace requires approval, request it.

Safely copy the existing backend into this workspace root, preserving source, migrations, composer.lock, Dockerfile, docker/entrypoint.sh, .dockerignore, hidden configuration files and local .env. Do not recreate a generic Laravel API or discard the implemented business rules. Keep secrets out of version control and never print their values. Copy the source project's compose.yaml, API/Postman/demo/validation documentation, and tools/test_api.ps1 and tools/build_postman.ps1 into appropriate directories here. Inspect relative paths in copied scripts and documentation and update them for this standalone layout. Keep the original backend intact until the new API has been validated and the user authorizes final removal from the Flutter project.

Inspect the transferred files and Docker configuration. With API source at this repository root, Compose must use build: . instead of build: ./backend. Preserve the Compose project name techfix and its existing mysql-data and api-storage volumes. Verify that Compose resolves to the existing techfix_mysql-data and techfix_api-storage volumes before starting. Never run down -v, migrate:fresh, database resets, or remove volumes: they contain the existing database and application key. Do not run old and new Compose stacks concurrently under this project name. Preserve the --no-reload option and container application-key handling. Keep host .env secrets out of Git and Docker build context.

The Flutter application stays in C:\Projeto Final\TechFix. Keep its API contract compatible with docs/API.md and the Postman collection. Flutter uses --dart-define=API_BASE_URL=http://localhost:8000/api for Chrome and http://10.0.2.2:8000/api for Android emulators. Browser origin http://localhost:8080 must be allowed by CORS. Inspect config/cors.php and Compose environment overrides.

Maintain Sanctum bearer authentication, registration/login/logout/profile, dashboard, employees, and CRUD for clientes, aparelhos, ordens-servico, parts and admin-only users. A device's cliente_id is optional/nullable. Orders still require a device. The Flutter device form has no IMEI input; retain existing legacy IMEI data. Preserve existing records, roles and tokens.

Verify docker compose config, start/rebuild with docker compose up --build -d --wait, inspect migration status, and run php vendor/phpunit/phpunit/phpunit --do-not-cache-result inside the API container. Tests use isolated SQLite; live API requests use MySQL. Validate the optional-client device/order workflow and clean up only temporary records created by the check. Do not print secrets or authentication tokens.

Update the new API README and documentation to use commands from this new repository root. Report checks actually performed and any remaining environment issues. Do not modify the separate Flutter repository without a specific request.
```

The Flutter app connects by URL, so moving source folders does not change its API URL when Docker continues publishing port 8000.
