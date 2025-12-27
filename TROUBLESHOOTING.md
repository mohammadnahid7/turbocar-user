# Troubleshooting Common Issues

## PostgreSQL Container Exits Immediately

### Issue: Container exits with code 1

**Common Causes:**
1. Invalid environment variable (POSTGRES_PORT doesn't exist)
2. Data directory permissions
3. Missing required environment variables

**Solution:**
The PostgreSQL Docker image uses these environment variables:
- `POSTGRES_USER` ✅ (required)
- `POSTGRES_PASSWORD` ✅ (required)  
- `POSTGRES_DB` ✅ (optional, defaults to POSTGRES_USER)
- `POSTGRES_PORT` ❌ (NOT VALID - container always uses 5432 internally)

The port mapping is done via `ports:` in docker-compose.yml, not environment variables.

**Fix applied:**
- Removed invalid `POSTGRES_PORT` environment variable
- Added default values for safety

**To see detailed error logs:**
```bash
# After refreshing docker session (newgrp docker or logout/login)
docker logs postgres
```

**If data directory has permission issues:**
```bash
# Remove the volume and let Docker recreate it
docker-compose down -v
docker-compose up -d
```

## Port Conflicts

### PostgreSQL Port 5432 Already in Use

**Solution:** Use different host port (already configured)
- Docker PostgreSQL: host port 5433 → container port 5432
- System PostgreSQL: continues on port 5432

**To access Docker PostgreSQL from host:**
```bash
psql -h localhost -p 5433 -U postgres -d wegugin_cars
```

## Docker Permission Denied

See **DOCKER_FIX.md** for detailed solutions.

Quick fix:
```bash
sudo usermod -aG docker $USER
# Log out and log back in, OR use:
newgrp docker
```

## MinIO Image Not Found

**Fixed:** Changed from `bitnami/minio:2024` to `minio/minio:latest`

## Other Issues

Check container logs:
```bash
docker-compose logs postgres-db
docker-compose logs userservice
docker-compose logs minio
```

Check service status:
```bash
docker-compose ps
```

