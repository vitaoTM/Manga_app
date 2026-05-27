# Migration Plan: PostgreSQL → SQLite + Litestream on Render

## Context

- **Current state**: Rails 8.1.2 app on Render using PostgreSQL (paid tier expired)
- **Target state**: SQLite on Render persistent disk, replicated to Cloudflare R2 via Litestream
- **Already in place**: `litestream` gem (0.14.0), `aws-sdk-s3` gem, S3 for Active Storage, partial litestream config stubs
- **Active Storage**: stays on S3 — only the relational DB moves to SQLite

---

## Storage Provider Decision

### Cloudflare R2 (recommended for Litestream)
- S3-compatible API → zero code change vs AWS S3
- **No egress fees** — critical since Litestream streams WAL changes continuously
- 10 GB free storage, $0.015/GB after
- Add as a second R2 bucket alongside your existing S3 bucket (Active Storage stays on S3)

### AWS S3 (alternative)
- Already configured, one less provider to set up
- Egress fees will apply to every WAL segment Litestream reads back during restore
- Use a separate prefix (`litestream/`) in the same bucket to isolate DB replicas from uploads

---

## Approach A — Practical / Fast

Minimal changes, get off Postgres quickly. No Solid Cache/Queue yet.

### Steps

**1. Gemfile**

```diff
- gem "pg", "~> 1.1"
+ gem "sqlite3", ">= 2.1"
```

`litestream` is already there. Keep `aws-sdk-s3`.

**2. `config/database.yml`**

Replace the entire file:

```yaml
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  database: /data/db/production.sqlite3
```

> `/data` = Render persistent disk mount point.

**3. `config/initializers/litestream.rb`**

Uncomment and fill in:

```ruby
Rails.application.configure do
  config.litestream.replica_bucket    = ENV["LITESTREAM_REPLICA_BUCKET"]
  config.litestream.replica_key_id    = ENV["LITESTREAM_REPLICA_KEY_ID"]
  config.litestream.replica_access_key = ENV["LITESTREAM_REPLICA_ACCESS_KEY"]
  # For Cloudflare R2:
  config.litestream.replica_endpoint  = ENV["LITESTREAM_REPLICA_ENDPOINT"]
  # For AWS S3 only (no endpoint needed):
  # config.litestream.replica_region  = "us-east-1"
end
```

**4. `config/litestream.yml`**

```yaml
dbs:
  - path: /data/db/production.sqlite3
    replicas:
      - type: s3
        bucket: ${LITESTREAM_REPLICA_BUCKET}
        path: production
        access-key-id: ${LITESTREAM_REPLICA_KEY_ID}
        secret-access-key: ${LITESTREAM_REPLICA_ACCESS_KEY}
        endpoint: ${LITESTREAM_REPLICA_ENDPOINT}   # remove line if using AWS S3
        force-path-style: true                      # required for R2; remove for AWS
```

**5. Dockerfile**

```diff
- apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
+ apt-get install --no-install-recommends -y curl libjemalloc2 libvips libsqlite3-0 && \

- apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
+ apt-get install --no-install-recommends -y build-essential git libsqlite3-dev libyaml-dev pkg-config && \
```

Add Litestream binary download in the build stage:

```dockerfile
# Install Litestream binary
ARG LITESTREAM_VERSION=0.3.13
RUN curl -L "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-v${LITESTREAM_VERSION}-linux-$(dpkg --print-architecture).tar.gz" \
    | tar -xz -C /usr/local/bin
```

**6. `bin/docker-entrypoint`**

Modify to restore from Litestream before migrating, and start the replication sidecar:

```bash
#!/bin/bash -e

# Only restore in production and if DB doesn't already exist
if [ "$RAILS_ENV" = "production" ]; then
  mkdir -p /data/db
  if [ ! -f /data/db/production.sqlite3 ]; then
    echo "Restoring from Litestream..."
    litestream restore -if-replica-exists /data/db/production.sqlite3 || true
  fi
fi

bundle exec rails db:prepare

# Start Litestream replication in background alongside the app
if [ "$RAILS_ENV" = "production" ]; then
  exec litestream replicate -exec "$*"
else
  exec "$@"
fi
```

**7. `render.yaml`** (create at repo root)

```yaml
services:
  - type: web
    name: manga-app
    runtime: docker
    plan: starter         # $7/mo — has persistent disk support
    disk:
      name: sqlite-data
      mountPath: /data
      sizeGB: 10
    envVars:
      - key: RAILS_MASTER_KEY
        sync: false
      - key: RAILS_ENV
        value: production
      - key: LITESTREAM_REPLICA_BUCKET
        sync: false
      - key: LITESTREAM_REPLICA_KEY_ID
        sync: false
      - key: LITESTREAM_REPLICA_ACCESS_KEY
        sync: false
      - key: LITESTREAM_REPLICA_ENDPOINT    # e.g. https://<account>.r2.cloudflarestorage.com
        sync: false
      - key: APP_HOST
        sync: false
```

**8. Data migration**

```bash
# On your local machine, export from Postgres
pg_dump --no-owner --no-acl -F p manga_app_development > dump.sql

# Import into local SQLite dev DB (using sequel gem as bridge)
bundle exec rails db:schema:load   # creates SQLite schema from schema.rb
# Manually seed critical data or use a one-time script:
# See: https://github.com/jeremyevans/sequel for pg→sqlite ETL if you have real prod data
```

> If production data is minimal or you can recreate it, just `db:schema:load` + `db:seed` is enough.

---

## Approach B — Structured / Full Rails 8 SQLite Stack

Full multi-database setup activating Solid Cache, Solid Queue, and Solid Cable — the Rails 8 default production stack, now running entirely on SQLite.

This is the "right" long-term architecture. More steps upfront, but zero ongoing infra debt.

### Why this matters

Rails 8 ships Solid Cache/Queue/Cable designed specifically for SQLite. They remove Redis, Sidekiq, and Action Cable deps. You get durable background jobs + caching on-process with no extra services.

### Additional steps on top of Approach A

**database.yml — full multi-DB**

```yaml
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  primary:
    <<: *default
    database: db/development.sqlite3
  cache:
    <<: *default
    database: db/development_cache.sqlite3
    migrations_paths: db/cache_migrate
  queue:
    <<: *default
    database: db/development_queue.sqlite3
    migrations_paths: db/queue_migrate
  cable:
    <<: *default
    database: db/development_cable.sqlite3
    migrations_paths: db/cable_migrate

test:
  <<: *default
  database: db/test.sqlite3

production:
  primary:
    <<: *default
    database: /data/db/production.sqlite3
  cache:
    <<: *default
    database: /data/db/production_cache.sqlite3
    migrations_paths: db/cache_migrate
  queue:
    <<: *default
    database: /data/db/production_queue.sqlite3
    migrations_paths: db/queue_migrate
  cable:
    <<: *default
    database: /data/db/production_cable.sqlite3
    migrations_paths: db/cable_migrate
```

**`config/environments/production.rb` — activate Solid stack**

```diff
- config.cache_store = :memory_store
+ config.cache_store = :solid_cache_store

- config.active_job.queue_adapter = :async
+ config.active_job.queue_adapter = :solid_queue
```

Also add:

```ruby
config.action_cable.cable = { "adapter" => "solid_cable" }
```

**Solid Queue initializer — `config/initializers/solid_queue.rb`**

```ruby
SolidQueue::Server.configure do |config|
  config.recurring_tasks = {
    # add scheduled jobs here if needed
  }
end
```

**Litestream config for all 4 databases**

```yaml
dbs:
  - path: /data/db/production.sqlite3
    replicas:
      - type: s3
        bucket: ${LITESTREAM_REPLICA_BUCKET}
        path: production/primary
        access-key-id: ${LITESTREAM_REPLICA_KEY_ID}
        secret-access-key: ${LITESTREAM_REPLICA_ACCESS_KEY}
        endpoint: ${LITESTREAM_REPLICA_ENDPOINT}
        force-path-style: true

  - path: /data/db/production_cache.sqlite3
    replicas:
      - type: s3
        bucket: ${LITESTREAM_REPLICA_BUCKET}
        path: production/cache
        access-key-id: ${LITESTREAM_REPLICA_KEY_ID}
        secret-access-key: ${LITESTREAM_REPLICA_ACCESS_KEY}
        endpoint: ${LITESTREAM_REPLICA_ENDPOINT}
        force-path-style: true

  - path: /data/db/production_queue.sqlite3
    replicas:
      - type: s3
        bucket: ${LITESTREAM_REPLICA_BUCKET}
        path: production/queue
        access-key-id: ${LITESTREAM_REPLICA_KEY_ID}
        secret-access-key: ${LITESTREAM_REPLICA_ACCESS_KEY}
        endpoint: ${LITESTREAM_REPLICA_ENDPOINT}
        force-path-style: true

  - path: /data/db/production_cable.sqlite3
    replicas:
      - type: s3
        bucket: ${LITESTREAM_REPLICA_BUCKET}
        path: production/cable
        access-key-id: ${LITESTREAM_REPLICA_KEY_ID}
        secret-access-key: ${LITESTREAM_REPLICA_ACCESS_KEY}
        endpoint: ${LITESTREAM_REPLICA_ENDPOINT}
        force-path-style: true
```

**`bin/docker-entrypoint` — restore all 4 DBs**

```bash
#!/bin/bash -e

if [ "$RAILS_ENV" = "production" ]; then
  mkdir -p /data/db
  for db in production production_cache production_queue production_cable; do
    if [ ! -f "/data/db/${db}.sqlite3" ]; then
      echo "Restoring ${db} from Litestream..."
      litestream restore -if-replica-exists "/data/db/${db}.sqlite3" || true
    fi
  done
fi

bundle exec rails db:prepare

if [ "$RAILS_ENV" = "production" ]; then
  exec litestream replicate -exec "$*"
else
  exec "$@"
fi
```

**Generate Solid migrations (one-time, run locally)**

```bash
bin/rails solid_cache:install
bin/rails solid_queue:install
bin/rails solid_cable:install
```

---

## Recommended Sequence (Approach B as target, A as stepping stone)

```
[ ] 1. Set up Cloudflare R2 bucket (or AWS S3 prefix)
        → Create bucket, get Access Key ID + Secret + endpoint URL

[ ] 2. Gemfile: swap pg → sqlite3, bundle install

[ ] 3. config/database.yml: switch to sqlite3, multi-DB layout

[ ] 4. config/initializers/litestream.rb: wire ENV vars

[ ] 5. config/litestream.yml: configure all 4 DB replicas

[ ] 6. Dockerfile: swap postgres-client/libpq-dev → libsqlite3, add litestream binary

[ ] 7. bin/docker-entrypoint: restore + replicate logic

[ ] 8. config/environments/production.rb: activate solid_cache + solid_queue

[ ] 9. Generate + commit Solid migrations locally

[ ] 10. Data migration:
         - If prod data is minimal: db:schema:load + seed
         - If real data: use sequel or pg_dump + custom import script

[ ] 11. render.yaml: persistent disk + env var declarations

[ ] 12. Push to Render, verify:
         - App boots and runs db:prepare
         - Litestream starts and streams to R2
         - Check Render logs for litestream replicate output
         - Verify R2 bucket receives WAL segments
```

---

## Risk Notes

| Risk | Mitigation |
|---|---|
| SQLite WAL mode needed for concurrent reads | Rails sqlite3 adapter enables WAL by default in Rails 8 |
| Persistent disk lost on Render service delete | Litestream R2 backup is the recovery path — test restore before going live |
| Postgres-specific SQL in migrations | Review migrations for `::text` casts, `ILIKE`, `now()` — these don't exist in SQLite |
| Active Storage files already in S3 | No change needed — Active Storage is independent of the relational DB |
| `schema.rb` type drift | Run `rails db:schema:dump` after first SQLite migrate to regenerate in sqlite format |

---

## Cost After Migration

| Item | Cost |
|---|---|
| Render Starter web service | ~$7/mo |
| Render persistent disk (10 GB) | ~$2.50/mo |
| Cloudflare R2 (under 10 GB) | $0 |
| AWS S3 (Active Storage, existing) | Pay per use |
| **Total DB infra** | **~$9.50/mo vs Render Postgres $7+ (now expired)** |

