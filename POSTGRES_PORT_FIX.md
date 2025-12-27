# PostgreSQL Port Conflict Fix

## Problem
Port 5432 is already in use by your system PostgreSQL service.

## Solution Options

### Option 1: Use Docker PostgreSQL on Different Port (Current Setup)
The docker-compose.yml now uses port **5433** on the host (maps to 5432 inside container).

**No changes needed to your `.env` file** - the application inside Docker will still connect to `postgres:5432` (container name), and Docker handles the port mapping.

**To access from your host machine** (if needed):
```bash
psql -h localhost -p 5433 -U postgres -d your_database
```

### Option 2: Stop System PostgreSQL and Use Docker PostgreSQL
If you want to use port 5432 for Docker PostgreSQL:

```bash
# Stop system PostgreSQL
sudo systemctl stop postgresql
sudo systemctl disable postgresql  # Optional: disable on boot

# Then change docker-compose.yml port mapping back to "5432:5432"
```

### Option 3: Remove Docker PostgreSQL and Use System PostgreSQL
If you prefer to use your existing system PostgreSQL:

1. Stop the system PostgreSQL service
2. Create your database manually:
   ```bash
   sudo -u postgres psql
   CREATE DATABASE user_service_db;
   \q
   ```
3. Run migrations from your host machine:
   ```bash
   make mig-up
   ```
4. Remove postgres-db service from docker-compose.yml
5. Update your `.env` to use `PDB_HOST=localhost`
6. For userservice container to connect to host PostgreSQL, you'll need to:
   - Use `extra_hosts: - "host.docker.internal:host-gateway"` 
   - Set `PDB_HOST=host.docker.internal` in .env
   - OR use host network mode (not recommended)

## Current Configuration
- Docker PostgreSQL: Available on host port **5433**, container port 5432
- System PostgreSQL: Still running on port **5432**
- Your application inside Docker connects to Docker PostgreSQL automatically
- Migrations run automatically when you start docker-compose

## Verify Setup

```bash
# Check if Docker PostgreSQL is running
docker-compose ps postgres-db

# Check if system PostgreSQL is still running
systemctl status postgresql

# Access Docker PostgreSQL from host (if needed)
psql -h localhost -p 5433 -U postgres
```

