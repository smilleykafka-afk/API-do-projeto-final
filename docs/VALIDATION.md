# Standalone API validation — 2026-11-15

Commands below were run from this standalone repository root. The original backend at `C:\Projeto Final\TechFix\backend` and the separate Flutter application were left intact.

- Preserved the previous destination files in ignored `.migration-backup/destination-before-techfix/` before transfer. Verified application files, migrations, routes and tests against the source by SHA-256; `composer.lock` and local `.env` match exactly. No environment secret or bearer token was included in the report.
- `docker compose config --quiet`: passed. Build context is this root; project name remains `techfix`. Verified existing `techfix_mysql-data` and `techfix_api-storage` volumes and the previous containers' mounts before starting. Both previous containers were stopped. Volumes are explicitly external to prevent accidental replacement.
- Started Docker Desktop's installed Linux engine. `docker compose up --build -d --wait`: passed; API and MySQL healthy. API publishes `127.0.0.1:8000`. The same Compose project was reconciled; no parallel old stack was started.
- `docker compose exec api php artisan migrate:status`: all six migrations already executed, including nullable device customer. No database reset or volume removal was performed.
- `docker compose exec api php vendor/phpunit/phpunit/phpunit --do-not-cache-result`: **9 tests passed, 103 assertions**, isolated in-memory SQLite.
- Live MySQL `tools/test_api.ps1 -CleanupTestEmployee`: passed registration/employee role enforcement, bearer auth, profile, device with omitted customer/IMEI, order for that device, customer assignment/unlink, status history and dashboard. Removed only that run's order/device/customer/employee and revoked its token.
- Compared ordered row digests before and after the live check for users, personal access tokens, customers, devices (including legacy IMEI), orders, repair history and parts: all identical. This verifies existing records/roles/tokens survived the checks; database auto-increment sequences naturally advance when temporary rows are created and deleted. The running application key matches the existing storage-volume key.
- `GET /up`: HTTP 200. Actual CORS OPTIONS preflight from `http://localhost:8080` permits the origin and Authorization/Content-Type headers. Compose explicitly sets the same allowed origins as `config/cors.php`.
- New cleanup helper: PHP syntax check and Laravel Pint passed after formatting. PowerShell smoke-test syntax parsed successfully. Postman generator ran and reproduced the original collection contract; its output path now resolves relative to the script location.
- `.env` and destination backup are Git-ignored and Docker-excluded. `--no-reload` is retained; container-local application-key handling is preserved (removed a duplicate identical write).

## Remaining scope and environment limitations

No API/Docker blocker remains after starting Docker Desktop. Flutter was not modified or launched; Chrome, Android emulator and physical-device end-to-end checks were not performed. Postman itself was not run. The Flutter client can use the unchanged URL with the commands in the root README. The host's non-Docker PHP setup was not validated; Docker provides dependencies and the tested runtime.

The historical reports below describe the earlier combined Flutter/backend repository. Their old MySQL-pending statements are superseded by this successful standalone MySQL validation; Flutter-specific limitations remain historical unless separately verified.

---
# Validation report

## Optional device customer (2026-11-14)

- Device forms now allow an unassigned customer and no longer show an IMEI input. Existing customer links and legacy IMEI data are preserved.
- Added a migration making `aparelhos.cliente_id` nullable while retaining its foreign key. API validation accepts an omitted/null customer and rejects invalid customer IDs.
- Backend PHPUnit: 9 tests passed, 103 assertions, including an order for a device without a customer, assigning/unassigning a customer, and invalid customer validation.
- Laravel Pint check passed for changed PHP files.
- Docker rebuilt successfully and both services became healthy; migration applied on startup.
- Live MySQL API check passed: created a device without client/IMEI, created an order for it, then removed both temporary records and logged out.
- Flutter format/analyze/test execution was declined for this change, so those checks were not rerun.

## Docker setup (2026-11-14)

- Added a local Laravel API + MySQL 8.4 Compose environment; see [Docker testing](DOCKER.md).
- `docker compose config --quiet`: passed.
- Started Docker Desktop's Linux engine and built the API image successfully.
- `docker compose up -d --wait`: passed; API and MySQL containers healthy.
- MySQL migration status: all five migrations ran successfully.
- Containerized PHPUnit: 8 tests passed, 87 assertions (isolated in-memory SQLite).
- `tools/test_api.ps1`: passed against the running MySQL API after the final configuration fix, covering registration, employee role enforcement, bearer authentication, profile, customer/device/order creation, repair status history, dashboard, cleanup and logout.
- Fixed container application-key availability for `docker compose exec` commands. Added `--no-reload` to prevent Laravel's development server from stripping Docker environment variables when the container-local `.env` exists.
- Smoke-test business records were removed. Two test employee accounts from successful runs remain; their tokens were revoked by logout.
- Docker validation completes the MySQL check below for the container environment. Android build/device validation remains pending.

- `dart analyze lib test`: passed, no issues.
- `flutter test --no-pub`: 6 tests passed, covering validators, unauthenticated routing, loaded/empty/error UI states, bearer headers, secure token storage, logout, expired tokens, and malformed API responses.
- `php -d extension=pdo_sqlite vendor/phpunit/phpunit/phpunit --testdox`: 8 tests passed, 87 assertions. Six tests cover TechFix workflows; two are the Laravel starter checks.
- `php artisan route:list --path=api --except-vendor`: 12 route definitions, including parameterized resource CRUD.
- Dart files formatted and PHP application files formatted with Laravel Pint.
- Screenshots capture actual Flutter widgets with deterministic mocked API responses, not a live Android session.

## Remaining environment checks

- `flutter analyze` crashes inside the installed SDK's LSP JSON handshake on this accented Windows path. Direct `dart analyze lib test` succeeds.
- No MySQL server was listening on port 3306 during validation. Migrations and API workflows were tested using in-memory SQLite; MySQL execution is pending local database startup/configuration.
- Android platform generation was declined during the session. No Android build or emulator/device run was performed. Follow the README to generate the Android host project and configure networking.
- The Postman collection is delivered for manual use; Postman itself was not run. Automated Laravel feature tests exercise the endpoints instead.
