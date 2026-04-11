# lab3/task1 - Этап 1

Локальная конфигурация для Docker Desktop на Windows:
- `pg_a` - primary
- `pg_b` - synchronous standby
- `pg_c` - asynchronous standby с задержкой `10s`
- `pgpool` - единая точка входа на порту `9999`
- `client` - отдельный контейнер для `psql`- подключений и демонстрации

## Что делает конфигурация

1. `pg_a` инициализирует пользователя `replicator`, задает пароль пользователю `postgres`, создает БД `appdb`, таблицы `customers` и `orders`, заполняет их тестовыми данными и создает физические replication slots `slot_b` и `slot_c`.
2. `pg_b` поднимается через `pg_basebackup` от `pg_a`, подключается как `application_name = pg_b` и становится синхронной репликой.
3. `pg_c` поднимается через `pg_basebackup` от `pg_a`, подключается как `application_name = pg_c`, использует `recovery_min_apply_delay = '10s'` и становится асинхронной delayed-репликой.
4. `pgpool` работает в режиме `streaming-replication` и слушает порт `9999`.
5. Для сетевых подключений используется парольная аутентификация `scram-sha-256`, а для локальных подключений внутри postgres-контейнеров - `peer`.

## Быстрый запуск

```cmd
start.cmd
```

Проверить, что все поднялось:

```powershell
docker compose ps
```

Посмотреть логи, если что-то пошло не так:

```powershell
docker compose logs -f pg_a
docker compose logs -f pg_b
docker compose logs -f pg_c
docker compose logs -f pgpool
```

## Демонстрация этапа 1

Запустить готовую демонстрацию:

```cmd
demo.cmd
```

Скрипт покажет:
- `SHOW pool_nodes;` через `pgpool`
- `pg_stat_replication` на primary
- вставку в `customers` и `orders` через `pgpool`
- наличие новых строк на `pg_b` сразу
- отсутствие строк на `pg_c` сразу после коммита
- появление строк на `pg_c` спустя 12 секунд

## Ручные команды

### Подключение к Pgpool

```powershell
docker compose exec client bash -lc "PGPASSWORD=postgres psql -h pgpool -p 9999 -U postgres -d appdb"
```

### Проверка ролей напрямую

```powershell
docker compose exec client bash -lc "PGPASSWORD=postgres psql -h pg_a -U postgres -d postgres -c 'select pg_is_in_recovery();'"

docker compose exec client bash -lc "PGPASSWORD=postgres psql -h pg_b -U postgres -d postgres -c 'select pg_is_in_recovery();'"

docker compose exec client bash -lc "PGPASSWORD=postgres psql -h pg_c -U postgres -d postgres -c 'select pg_is_in_recovery();'"
```

Ожидаемый результат:
- на `pg_a` - `f`
- на `pg_b` и `pg_c` - `t`

### Проверка репликации на primary

```powershell
docker compose exec client bash -lc "PGPASSWORD=postgres psql -h pg_a -U postgres -d postgres -c \"select application_name, state, sync_state from pg_stat_replication order by application_name;\""
```

Ожидаемо:
- `pg_b` имеет `sync_state = 'sync'`
- `pg_c` имеет `sync_state = 'async'`

### Проверка данных на B и C

```powershell
docker compose exec client bash -lc "PGPASSWORD=postgres psql -h pg_b -U postgres -d appdb -c \"select * from customers order by id desc limit 5;\""

docker compose exec client bash -lc "PGPASSWORD=postgres psql -h pg_c -U postgres -d appdb -c \"select * from customers order by id desc limit 5;\""
```

## Остановка

```cmd
stop.cmd
```

## Полный сброс томов и повторная инициализация

```cmd
reset.cmd
start.cmd
```