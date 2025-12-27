# Quick Reference Guide

## 📦 Installation (Arch Linux)

```bash
# Install all dependencies
sudo pacman -S go postgresql redis docker docker-compose protobuf

# Install Go tools
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
go install github.com/swaggo/swag/cmd/swag@latest

# Add Go bin to PATH
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
source ~/.bashrc

# Start services
sudo systemctl enable --now postgresql redis docker
sudo usermod -aG docker $USER  # Log out/in after this
```

## 🚀 Quick Start

```bash
# 1. Run setup script (checks dependencies, creates .env if needed)
./setup.sh

# 2. Edit .env file with your settings
nano .env

# 3. Choose one:

# Option A: Docker Compose (Easiest)
docker network create wegugin
sudo mkdir -p /opt/minio-data && sudo chown $USER:$USER /opt/minio-data
docker-compose up -d

# Option B: Manual Setup
make mig-up        # Run migrations
make run           # Start service
```

## 🔧 Common Commands

```bash
# Database migrations
make mig-up        # Apply migrations
make mig-down      # Rollback migrations
make mig-force     # Force migration version

# Development
make run           # Run the application
make swag          # Generate Swagger docs

# Docker Compose
docker-compose up -d              # Start all services
docker-compose down               # Stop all services
docker-compose logs -f userservice  # View application logs
docker-compose ps                 # Check service status

# Docker services
docker-compose logs postgres-db   # PostgreSQL logs
docker-compose logs redis-db      # Redis logs
docker-compose logs minio         # MinIO logs
```

## 🌐 Access Points

- **REST API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger/index.html
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin)
- **gRPC Service**: localhost:8085

## 🔑 Environment Variables Summary

| Variable | Description | Example |
|----------|-------------|---------|
| `PDB_HOST` | PostgreSQL host | `localhost` or `postgres-db` (Docker) |
| `PDB_PORT` | PostgreSQL port | `5432` |
| `PDB_USER` | Database user | `postgres` |
| `PDB_PASSWORD` | Database password | `your_password` |
| `PDB_NAME` | Database name | `user_service_db` |
| `USER_SERVICE` | gRPC port | `:8085` |
| `USER_ROUTER` | HTTP port | `:8080` |
| `TOKEN_KEY` | JWT secret key | Generate with `openssl rand -base64 32` |
| `RDB_ADDRESS` | Redis address | `localhost:6379` |
| `MINIO_ENDPOINT` | MinIO endpoint | `localhost:9000` |
| `MINIO_ACCESS_KEY_ID` | MinIO access key | `minioadmin` |
| `MINIO_SECRET_ACCESS_KEY` | MinIO secret key | `minioadmin` |
| `SENDER_EMAIL` | Email for notifications | `your_email@gmail.com` |
| `APP_PASSWORD` | Email app password | Gmail App Password |

## 📡 API Testing Examples

### Register User
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "John",
    "surname": "Doe",
    "password": "password123",
    "phone": "+1234567890",
    "birth_date": "01-01-1990",
    "gender": "male"
  }'
```

### Login
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email_or_phone_number": "test@example.com",
    "password": "password123"
  }'
```

### Get Profile (Authenticated)
```bash
curl -X GET http://localhost:8080/user/profile \
  -H "Authorization: YOUR_JWT_TOKEN"
```

### Upload Photo
```bash
curl -X POST http://localhost:8080/user/photo \
  -H "Authorization: YOUR_JWT_TOKEN" \
  -F "file=@/path/to/image.jpg"
```

## 🐛 Troubleshooting

```bash
# Check if ports are in use
lsof -i :8080
lsof -i :8085

# Check service status (Docker)
docker-compose ps

# Check service status (Systemd)
sudo systemctl status postgresql redis

# View all logs
docker-compose logs

# Reset everything (Docker)
docker-compose down -v
docker network rm wegugin
docker network create wegugin
docker-compose up -d
```

## 📚 Documentation Files

- **SETUP_GUIDE.md** - Complete installation and setup guide
- **README.md** - Project overview
- **QUICK_REFERENCE.md** - This file
- **.env.template** - Environment variables template

