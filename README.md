# User Service

A comprehensive User Management Microservice built with Go, providing authentication, profile management, and media upload capabilities.

## 📖 Documentation

For complete setup and installation instructions, see **[SETUP_GUIDE.md](./SETUP_GUIDE.md)**

## 🚀 Quick Start

1. **Prerequisites**: Install Go, PostgreSQL, Redis, Docker, and required tools (see SETUP_GUIDE.md)
2. **Configuration**: Create `.env` file (see SETUP_GUIDE.md for template)
3. **Run**: `docker-compose up -d` (or `make run` for manual setup)
4. **Test**: Visit `http://localhost:8080/swagger/index.html`

## 🏗️ Architecture

- **Framework**: Gin (REST API) + gRPC (internal communication)
- **Database**: PostgreSQL
- **Cache**: Redis
- **Object Storage**: MinIO
- **Authentication**: JWT tokens
- **API Documentation**: Swagger/OpenAPI

## 📋 Features

- User registration and authentication
- JWT-based session management
- Profile management (CRUD operations)
- Password reset via email
- Profile photo upload/download
- Role-based access control (admin/user)

## 🔧 API Endpoints

### Public Endpoints
- `POST /auth/register` - Register new user
- `POST /auth/login` - User login
- `POST /auth/forgot-password` - Request password reset code
- `POST /auth/reset-password` - Reset password with code
- `GET /auth/user/:id` - Get user by ID

### Protected Endpoints (Require JWT Token)
- `GET /user/profile` - Get current user profile
- `PUT /user/profile` - Update user profile
- `POST /user/change-password` - Change password
- `POST /user/photo` - Upload profile photo
- `DELETE /user/photo` - Delete profile photo
- `DELETE /user/delete` - Delete user account

## 📝 Environment Variables

See SETUP_GUIDE.md for complete environment variable documentation and `.env` file template.

## 🛠️ Development

```bash
# Run setup script to check dependencies and create .env
./setup.sh

# Run database migrations
make mig-up

# Generate Swagger documentation
make swag

# Run the service
make run

# Or use Docker Compose
docker-compose up -d
```

## 📚 Documentation

- **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Complete installation and setup guide
- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Quick reference for common commands and API examples
- **.env.template** - Environment variables template