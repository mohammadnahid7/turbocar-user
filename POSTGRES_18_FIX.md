# PostgreSQL 18+ Volume Format Fix

## Issue
PostgreSQL 18+ Docker images changed the data directory structure. The old volume format is incompatible.

## Solution Applied
Changed PostgreSQL image from `postgres:latest` (which pulls version 18+) to `postgres:17` which uses the traditional volume format.

## Steps to Fix

1. **Remove old volumes and containers:**
   ```bash
   docker-compose down -v
   ```
   This removes the old volume with incompatible data format.

2. **Start fresh with PostgreSQL 17:**
   ```bash
   docker-compose up -d
   ```

## Alternative: Use PostgreSQL 18+ with New Format

If you want to use PostgreSQL 18+, change the volume mount in docker-compose.yml:

```yaml
volumes:
  - db:/var/lib/postgresql  # Changed from /var/lib/postgresql/data
```

And remove the old volume:
```bash
docker-compose down -v
docker volume rm user-service-main_db
docker-compose up -d
```

**Current setup uses PostgreSQL 17** which is stable and widely compatible.

