# TechFix REST API

API independente do TechFix, desenvolvida com Laravel 12. Execute os comandos na raiz deste repositório. A aplicação Flutter permanece em `C:\Projeto Final\TechFix` e se conecta pela URL; seus arquivos não foram alterados.

## Configuração com Docker

Inicie o Docker Desktop com o mecanismo Linux. Consulte as [instruções do Docker](docs/DOCKER.md) para verificar os volumes antes da inicialização. O Compose utiliza o projeto `techfix` e os volumes externos existentes `techfix_mysql-data` e `techfix_api-storage`. Se os volumes estiverem ausentes, a inicialização falhará para evitar a criação de um banco de dados vazio ou de uma nova chave da aplicação. Nunca execute as configurações antiga e nova do Compose ao mesmo tempo.

```powershell
docker compose config --quiet
docker compose up --build -d --wait
docker compose ps
docker compose exec api php artisan migrate:status
docker compose exec api php vendor/phpunit/phpunit/phpunit --do-not-cache-result
powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_api.ps1 -CleanupTestEmployee
```

API: `http://localhost:8000/api`; verificação de funcionamento: `http://localhost:8000/up`. O PHPUnit utiliza um banco SQLite isolado em memória; o teste básico de funcionamento utiliza o MySQL em execução. Não reinicialize o banco de dados nem exclua os volumes. O arquivo `.env` da máquina é preservado localmente, ignorado pelo Git e excluído das compilações do Docker. A inicialização do contêiner reutiliza a chave da aplicação armazenada no volume de armazenamento e executa as migrações pendentes.

## Conexão com o Flutter

Execute estes comandos no repositório separado da aplicação Flutter:

```powershell
cd 'C:\Projeto Final\TechFix'
flutter run -d chrome --web-port=8080 --dart-define=API_BASE_URL=http://localhost:8000/api
# Emulador Android:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

O CORS permite a origem `http://localhost:8080`; a autenticação utiliza tokens do tipo Bearer do Sanctum. A mudança de localização do código-fonte não altera a porta publicada nem a URL da API.

## API e administração

O cadastro cria funcionários. Somente administradores podem gerenciar usuários. Crie ou promova um administrador de forma interativa com `docker compose exec api php artisan techfix:admin admin@example.com`. Não há credenciais de administrador predefinidas.

A implementação atual oferece autenticação, perfil, painel, funcionários e operações de criação, consulta, atualização e exclusão (CRUD) de clientes, aparelhos, ordens de serviço, peças e usuários. A associação de clientes aos aparelhos é opcional; as ordens de serviço exigem um aparelho. Os dados legados de IMEI continuam sendo aceitos. Os registros são compartilhados entre os funcionários da loja. Consulte o [contrato da API](docs/API.md), a [coleção do Postman](docs/TechFix.postman_collection.json), a [demonstração](docs/DEMO.md) e o [relatório de validação](docs/VALIDATION.md). Gere novamente a coleção do Postman com `powershell -File tools/build_postman.ps1`.

Para instalar sem Docker: instale PHP 8.2 ou superior, Composer e MySQL, execute `composer install`, configure o arquivo `.env` local preservado e execute `php artisan migrate` e `php artisan serve --host=0.0.0.0 --port=8000 --no-reload`. Gere uma chave apenas para uma instalação realmente nova. Os testes também exigem a extensão PDO SQLite. Utilize HTTPS e desative o modo de depuração em produção.

## Preservação dos arquivos durante a transferência

O projeto que existia anteriormente no destino está preservado localmente em `.migration-backup/destination-before-techfix/`, excluído do Git e das compilações do Docker. O backend original em `C:\Projeto Final\TechFix\backend` permanece intacto. Sua remoção exige uma autorização específica do usuário após a validação.
