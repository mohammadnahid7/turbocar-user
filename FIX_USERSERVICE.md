# Fix: Userservice Container Not Starting

## Problem
The userservice container is not running, so you can't access the API at http://localhost:8080

## Root Cause
When running in Docker, the application needs to connect to other services using **container names**, not `localhost`:
- PostgreSQL: Use `postgres` (container name) instead of `localhost`
- Redis: Use `redisemail` (container name) instead of `localhost`
- MinIO: Use `minio` (container name) instead of `localhost`

## Solution Applied
Added environment variable overrides in docker-compose.yml for the userservice container:
- `PDB_HOST=postgres` (container name)
- `PDB_PORT=5432` (container port, not host port)
- `RDB_ADDRESS=redisemail:6379` (container name)
- `MINIO_ENDPOINT=minio:9000` (container name)

## Next Steps

1. **Rebuild and restart the userservice container:**
   ```bash
   docker-compose up -d --build userservice
   ```

2. **Check if it's running:**
   ```bash
   docker-compose ps
   ```
   The `auth` container should show "Up" status.

3. **Check logs if it still fails:**
   ```bash
   docker-compose logs userservice
   ```

4. **If you see errors, try:**
   ```bash
   # Stop everything
   docker-compose down
   
   # Start fresh
   docker-compose up -d --build
   ```

5. **Once running, test the API:**
   ```
   http://localhost:8080/swagger/index.html
   ```

## Understanding Docker Networking

Inside Docker containers:
- **Container names** act as hostnames (e.g., `postgres`, `redisemail`)
- **Ports** are the container's internal ports (e.g., 5432 for PostgreSQL, not 5433)
- Services on the same Docker network can communicate using container names

From your host machine:
- Use `localhost` with **host ports** (e.g., `localhost:5433` for PostgreSQL, `localhost:8080` for API)




