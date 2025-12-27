# User Service - Complete Setup Guide for Arch Linux

## 📋 Project Summary

This is a **User Management Microservice** built with Go that provides comprehensive user authentication and profile management functionality. The service uses a hybrid architecture combining **gRPC** for internal communication and **REST API** (via Gin framework) for external HTTP endpoints.

### Key Features:
- **User Registration & Authentication**: JWT-based authentication with bcrypt password hashing
- **Profile Management**: Get, update, and delete user profiles
- **Password Management**: Change password, forgot password, and reset password via email verification
- **Photo Upload**: Upload and manage user profile photos using MinIO object storage
- **Email Notifications**: Send password reset codes via email
- **Role-based Access**: Supports admin and user roles
- **Swagger API Documentation**: Auto-generated API docs available at `/swagger/*`

### Architecture:
- **Database**: PostgreSQL for persistent data storage
- **Cache**: Redis for temporary data (password reset codes)
- **Object Storage**: MinIO for storing user photos
- **Communication**: gRPC for internal services, REST API for clients
- **Framework**: Gin for HTTP routing, gRPC for internal calls

---

## 🔧 Required Dependencies (Arch Linux)

### 1. Go Programming Language
```bash
sudo pacman -S go
```
**Version Required**: Go 1.23.4 or higher
**Verify Installation**: `go version`

### 2. PostgreSQL Database
```bash
sudo pacman -S postgresql
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service
```
**Initialize database** (first time only):
```bash
sudo -u postgres initdb -D /var/lib/postgres/data
```

### 3. Redis Cache
```bash
sudo pacman -S redis
sudo systemctl enable redis.service
sudo systemctl start redis.service
```

### 4. Docker & Docker Compose (Recommended)
```bash
sudo pacman -S docker docker-compose
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker $USER
```
**Note**: Log out and log back in for docker group changes to take effect.

### 5. Protocol Buffers Compiler (protoc)
```bash
sudo pacman -S protobuf
```

### 6. Go Protocol Buffer Plugins
```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

### 7. Database Migration Tool
```bash
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```
**Note**: Add `~/go/bin` to your PATH if not already there:
```bash
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc
source ~/.bashrc
```

### 8. Swagger/OpenAPI Documentation Tool (Optional)
```bash
go install github.com/swaggo/swag/cmd/swag@latest
```

---

## 📝 Environment Configuration

Create a `.env` file in the project root directory with the following variables:

```env
# PostgreSQL Database Configuration
PDB_HOST=localhost
PDB_PORT=5432
PDB_USER=postgres
PDB_PASSWORD=your_password_here
PDB_NAME=user_service_db

# Server Configuration
USER_SERVICE=:8085
USER_ROUTER=:8080

# JWT Token Secret Key (Use a strong random string)
TOKEN_KEY=your_very_secret_jwt_key_here_change_this

# Redis Configuration
RDB_ADDRESS=localhost:6379
RDB_PASSWORD=

# MinIO Object Storage Configuration
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY_ID=minioadmin
MINIO_SECRET_ACCESS_KEY=minioadmin
MINIO_BUCKET_NAME=photos
MINIO_PUBLIC_URL=http://localhost:9000/minio/photos

# Email Configuration (for password reset)
SENDER_EMAIL=your_email@gmail.com
APP_PASSWORD=your_app_specific_password
```

**Important Notes**:
- Replace `your_password_here` with your actual PostgreSQL password
- Generate a strong random string for `TOKEN_KEY` (you can use: `openssl rand -base64 32`)
- For Gmail, you need to generate an "App Password" from your Google Account settings (not your regular password)
- `MINIO_PUBLIC_URL` should point to where your MinIO files will be publicly accessible
- **Docker vs Manual Setup**: If using Docker Compose, set `PDB_HOST=postgres-db` (container name). If running manually, use `PDB_HOST=localhost`

---

## 🚀 Step-by-Step Setup Instructions

### Option 1: Using Docker Compose (Recommended - Easiest)

1. **Create the `.env` file** with the configuration above

2. **Create Docker network** (required by docker-compose.yml):
   ```bash
   docker network create wegugin
   ```

3. **Fix MinIO volume path** (if needed):
   The docker-compose.yml references `/opt/minio-data` as a bind mount. Create it or modify the volume configuration:
   ```bash
   sudo mkdir -p /opt/minio-data
   sudo chown $USER:$USER /opt/minio-data
   ```
   
   **Alternative**: If you prefer not to use a bind mount, you can modify `docker-compose.yml` and change the `minio_data` volume from:
   ```yaml
   minio_data:
     driver: local
     driver_opts:
       type: none
       o: bind
       device: /opt/minio-data
   ```
   to:
   ```yaml
   minio_data:
     driver: local
   ```
   This will use Docker's default volume management instead.

4. **Start all services**:
   ```bash
   docker-compose up -d
   ```
   
   This will start:
   - PostgreSQL database
   - Redis cache
   - MinIO object storage
   - Database migrations (automatically)
   - User service application

5. **Check service status**:
   ```bash
   docker-compose ps
   ```

6. **View logs**:
   ```bash
   docker-compose logs -f userservice
   ```

### Option 2: Manual Setup (For Development)

1. **Create PostgreSQL Database**:
   ```bash
   sudo -u postgres psql
   ```
   In PostgreSQL prompt:
   ```sql
   CREATE DATABASE user_service_db;
   CREATE USER postgres WITH PASSWORD 'your_password_here';
   GRANT ALL PRIVILEGES ON DATABASE user_service_db TO postgres;
   \q
   ```

2. **Start PostgreSQL and Redis**:
   ```bash
   sudo systemctl start postgresql
   sudo systemctl start redis
   ```

3. **Run Database Migrations**:
   ```bash
   make mig-up
   ```
   Or manually:
   ```bash
   migrate -path migrations -database 'postgres://postgres:your_password@localhost:5432/user_service_db?sslmode=disable' up
   ```

4. **Install Go Dependencies**:
   ```bash
   go mod download
   ```

5. **Generate Swagger Documentation** (optional):
   ```bash
   make swag
   ```
   Or manually:
   ```bash
   ~/go/bin/swag init -g ./api/router.go -o api/docs
   ```

6. **Run the Application**:
   ```bash
   make run
   ```
   Or directly:
   ```bash
   go run cmd/main.go
   ```

---

## 🧪 Testing the Service

### 1. Check Service Health

The service runs on two ports:
- **REST API (HTTP)**: `http://localhost:8080`
- **gRPC Service**: `localhost:8085`

### 2. Access Swagger Documentation

Open your browser and navigate to:
```
http://localhost:8080/swagger/index.html
```

This provides interactive API documentation where you can test endpoints directly.

### 3. Test API Endpoints

#### Register a New User
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "John",
    "surname": "Doe",
    "password": "securepassword123",
    "phone": "+1234567890",
    "birth_date": "01-01-1990",
    "gender": "male"
  }'
```

**Response**: You'll receive a JWT token
```json
{
  "Token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### Login
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email_or_phone_number": "test@example.com",
    "password": "securepassword123"
  }'
```

#### Get User Profile (Authenticated)
```bash
curl -X GET http://localhost:8080/user/profile \
  -H "Authorization: YOUR_JWT_TOKEN_HERE"
```

#### Update User Profile
```bash
curl -X PUT http://localhost:8080/user/profile \
  -H "Authorization: YOUR_JWT_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane",
    "surname": "Smith",
    "birth_date": "15-05-1992",
    "gender": "female",
    "address": "123 Main St",
    "phone_number": "+1234567890"
  }'
```

#### Upload Profile Photo
```bash
curl -X POST http://localhost:8080/user/photo \
  -H "Authorization: YOUR_JWT_TOKEN_HERE" \
  -F "file=@/path/to/your/image.jpg"
```

#### Forgot Password (Sends code to email)
```bash
curl -X POST http://localhost:8080/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

#### Reset Password
```bash
curl -X POST http://localhost:8080/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "code": "123456",
    "password": "newpassword123"
  }'
```

---

## 📁 Project Structure

```
user-service-main/
├── api/                    # HTTP API layer
│   ├── auth/              # JWT authentication utilities
│   ├── docs/              # Swagger documentation
│   ├── email/             # Email sending functionality
│   ├── handler/           # HTTP request handlers
│   └── middleware/        # Authentication middleware
├── cmd/                   # Application entry point
│   └── main.go
├── config/                # Configuration management
├── genproto/              # Generated gRPC code from .proto files
├── logs/                  # Logging utilities
├── migrations/            # Database migration files
├── model/                 # Data models
├── protos/                # Protocol buffer definitions
├── scripts/               # Build scripts
├── service/               # Business logic layer
├── storage/               # Data access layer
│   ├── postgres/         # PostgreSQL implementation
│   └── redis/            # Redis cache implementation
├── docker-compose.yml     # Docker services configuration
├── Dockerfile            # Application Docker image
├── go.mod                # Go module dependencies
└── Makefile              # Build automation
```

---

## 🔍 Troubleshooting

### Issue: "connection refused" when starting
- **Solution**: Ensure PostgreSQL, Redis, and MinIO services are running
- Check: `sudo systemctl status postgresql redis`
- For Docker: `docker-compose ps`

### Issue: "migration failed"
- **Solution**: Check database connection string in `.env`
- Verify database exists: `psql -U postgres -l`
- Check migration files are in `migrations/` directory

### Issue: "protoc: command not found"
- **Solution**: Install protobuf: `sudo pacman -S protobuf`

### Issue: "permission denied" on Docker
- **Solution**: 
  1. Add user to docker group (if not already):
     ```bash
     sudo usermod -aG docker $USER
     ```
  2. **IMPORTANT**: Log out and log back in (or restart terminal) for group changes to take effect
  3. Verify Docker service is running:
     ```bash
     sudo systemctl status docker
     sudo systemctl start docker  # if not running
     ```
  4. Test: `docker ps` should work without sudo
  5. Alternative (without logging out): Use `newgrp docker` to start a new shell with updated groups
  6. See **DOCKER_FIX.md** for detailed troubleshooting

### Issue: MinIO connection error
- **Solution**: 
  - Check MinIO is running: `docker-compose ps minio`
  - Verify `MINIO_ENDPOINT` in `.env` matches MinIO container port
  - Check MinIO logs: `docker-compose logs minio`

### Issue: Email sending fails
- **Solution**: 
  - For Gmail, use App Password (not regular password)
  - Enable 2-factor authentication in Google Account
  - Generate App Password: Google Account → Security → App passwords

### Issue: Port already in use
- **Solution**: 
  - Check what's using the port: `lsof -i :8080` or `netstat -tulpn | grep 8080`
  - Change ports in `.env` file
  - Kill the process or stop conflicting service

### Issue: Docker network "wegugin" not found
- **Solution**: Create the network manually:
  ```bash
  docker network create wegugin
  ```

### Issue: MinIO volume mount error
- **Solution**: 
  - Create the directory: `sudo mkdir -p /opt/minio-data && sudo chown $USER:$USER /opt/minio-data`
  - OR modify docker-compose.yml to use default volume (remove driver_opts section from minio_data volume)
  - OR use the setup script: `./setup.sh`

### Issue: Cannot connect to PostgreSQL from Docker container
- **Solution**: 
  - If using Docker Compose, ensure `PDB_HOST=postgres-db` (container name) in `.env`
  - If running manually, use `PDB_HOST=localhost`
  - Check PostgreSQL is accepting connections: `docker-compose ps postgres-db`

---

## 📚 Additional Resources

- **Swagger UI**: `http://localhost:8080/swagger/index.html`
- **MinIO Console**: `http://localhost:9001` (default credentials: minioadmin/minioadmin)
- **PostgreSQL Connection**: `psql -U postgres -d user_service_db`

---

## 🛑 Stopping the Services

### Docker Compose:
```bash
docker-compose down
```

### Manual Services:
```bash
# Stop the Go application: Ctrl+C
sudo systemctl stop postgresql redis
```

---

## 📝 Notes

- The service uses **soft deletes** (deleted_at field) for user records
- JWT tokens expire after **6 months**
- Password reset codes stored in Redis expire after **10 minutes**
- Birth date format should be **DD-MM-YYYY** (e.g., "01-01-1990")
- Gender values accepted: `male`, `female`, `other`
- Default user role is `user`, can be `admin` or `user`

---

## 🎯 Quick Start Checklist

- [ ] Install Go, PostgreSQL, Redis, Docker, protoc
- [ ] Install Go tools (protoc-gen-go, protoc-gen-go-grpc, migrate, swag)
- [ ] Create `.env` file with all required variables (or run `./setup.sh` for automated checks)
- [ ] Start PostgreSQL and Redis services (if not using Docker)
- [ ] Create Docker network: `docker network create wegugin`
- [ ] Create MinIO data directory: `sudo mkdir -p /opt/minio-data` (or modify docker-compose.yml)
- [ ] Run database migrations: `make mig-up`
- [ ] Install dependencies: `go mod download`
- [ ] Generate Swagger docs: `make swag` (optional)
- [ ] Start services: `docker-compose up -d` OR `make run`
- [ ] Test: Visit `http://localhost:8080/swagger/index.html`

## 🤖 Automated Setup Script

A setup script is available to help with initial configuration checks:

```bash
./setup.sh
```

This script will:
- Check for required tools and Go dependencies
- Create `.env` file from template if missing
- Create Docker network if it doesn't exist
- Create MinIO data directory
- Download Go module dependencies
- Provide status report of your setup

---

**Happy Coding! 🚀**

