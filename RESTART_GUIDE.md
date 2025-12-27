# How to Restart Your Server After Shutdown

## Quick Start Command

After restarting your PC, run:

```bash
cd /home/nahid/Desktop/Programming/Android/user-service-main
docker-compose up -d
```

## If Migrate Service Fails

The `migrate` service is a **one-time job** that runs database migrations. If migrations already ran successfully, it will fail on restart (this is normal).

### Solution 1: Start Services Without Migrate (Recommended)

Since migrations already ran, you can start services without the migrate dependency:

```bash
# Start all services except migrate
docker-compose up -d redis-db postgres-db minio userservice
```

Or modify docker-compose.yml to make migrate optional (see Solution 2).

### Solution 2: Check Migrate Logs

If you want to see why migrate failed:

```bash
docker-compose logs migrate
```

**Common reasons migrate fails:**
- ✅ **Migrations already applied** - This is OK! The database is already up to date.
- ❌ **Database connection error** - Check if PostgreSQL is running
- ❌ **Migration script error** - Check migration files

### Solution 3: Make Migrate Optional (Permanent Fix)

If migrations already ran, you can remove the migrate dependency from userservice:

**Option A: Comment out migrate service** (in docker-compose.yml):
```yaml
  # migrate:
  #   image: migrate/migrate
  #   ...
```

**Option B: Remove migrate from depends_on** (in userservice section):
```yaml
  userservice:
    ...
    depends_on:
      postgres-db:
        condition: service_healthy
      # migrate:  # Comment this out
      #   condition: service_completed_successfully
      redis-db:
        condition: service_started
```

## Complete Restart Procedure

```bash
# 1. Navigate to project directory
cd /home/nahid/Desktop/Programming/Android/user-service-main

# 2. Start services (without migrate if it already ran)
docker-compose up -d redis-db postgres-db minio userservice

# 3. Check status
docker-compose ps

# 4. Verify services are running
# You should see:
# - redisemail: Running
# - postgres: Healthy
# - minio: Running  
# - auth: Running (this is your userservice)
```

## Verify Everything is Working

```bash
# Check all containers
docker-compose ps

# Check application logs
docker-compose logs userservice --tail 20

# Test API (should return Swagger HTML)
curl http://localhost:8080/swagger/index.html
```

## If Services Don't Start

```bash
# Check what's wrong
docker-compose ps
docker-compose logs

# Restart specific service
docker-compose restart userservice

# Rebuild if needed
docker-compose up -d --build userservice
```

## Daily Workflow

**Morning (after PC restart):**
```bash
cd /home/nahid/Desktop/Programming/Android/user-service-main
docker-compose up -d redis-db postgres-db minio userservice
docker-compose ps  # Verify all are running
```

**Evening (before shutdown):**
```bash
# Optional: Stop services (they'll auto-start on next docker-compose up)
docker-compose stop

# Or leave them running - they'll persist across reboots
```

## Troubleshooting

### Port Already in Use
```bash
# Check what's using the port
sudo lsof -i :8080

# Stop conflicting service or change port in docker-compose.yml
```

### Container Won't Start
```bash
# Remove and recreate
docker-compose down
docker-compose up -d --build
```

### Database Connection Issues
```bash
# Check PostgreSQL is healthy
docker-compose ps postgres-db

# Check logs
docker-compose logs postgres-db
```

## Quick Reference

| Task | Command |
|------|---------|
| Start all services | `docker-compose up -d` |
| Start without migrate | `docker-compose up -d redis-db postgres-db minio userservice` |
| Check status | `docker-compose ps` |
| View logs | `docker-compose logs userservice` |
| Stop all | `docker-compose stop` |
| Stop and remove | `docker-compose down` |
| Restart one service | `docker-compose restart userservice` |


