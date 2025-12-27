# Next Steps - Your Service is Running! 🎉

## ✅ Current Status
All Docker services are running and healthy:
- ✅ PostgreSQL (port 5433 on host)
- ✅ Redis (port 6380 on host)
- ✅ MinIO (ports 9000, 9001)
- ✅ User Service Application (ports 8080, 8085)

## 🔍 Verify Everything is Working

### 1. Check Service Status
```bash
docker-compose ps
```
All services should show "Up" and "healthy" status.

### 2. Check Application Logs
```bash
docker-compose logs userservice
```
Look for:
- "Server listening at :8085" (gRPC)
- "Listening and serving HTTP on :8080" (REST API)

### 3. Test API Endpoints

#### Option A: Use Swagger UI (Easiest - Recommended)
Open your browser and navigate to:
```
http://localhost:8080/swagger/index.html
```

This provides an interactive interface where you can:
- See all available endpoints
- Test endpoints directly
- View request/response schemas
- See authentication requirements

#### Option B: Use curl (Command Line)

**Register a new user:**
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "name": "John",
    "surname": "Doe",
    "password": "testpassword123",
    "phone": "+1234567890",
    "birth_date": "01-01-1990",
    "gender": "male"
  }'
```

You should get a response with a JWT token:
```json
{
  "Token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Save the token** - you'll need it for protected endpoints!

**Login:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email_or_phone_number": "test@example.com",
    "password": "testpassword123"
  }'
```

**Get user profile (requires authentication):**
```bash
curl -X GET http://localhost:8080/user/profile \
  -H "Authorization: YOUR_JWT_TOKEN_HERE"
```

Replace `YOUR_JWT_TOKEN_HERE` with the token from register/login response.

## 🎯 Quick Test Workflow

1. **Open Swagger UI:**
   ```
   http://localhost:8080/swagger/index.html
   ```

2. **Register a user:**
   - Click on `POST /auth/register`
   - Click "Try it out"
   - Fill in the required fields:
     ```json
     {
       "email": "test@example.com",
       "name": "John",
       "surname": "Doe",
       "password": "testpassword123",
       "phone": "+1234567890",
       "birth_date": "01-01-1990",
       "gender": "male"
     }
     ```
   - Click "Execute"
   - Copy the token from the response

3. **Test protected endpoint:**
   - Click on `GET /user/profile`
   - Click "Authorize" button at the top
   - Paste your token (without "Bearer" prefix, just the token)
   - Click "Authorize" then "Close"
   - Click "Try it out" then "Execute"
   - You should see your user profile!

## 🔧 Additional Services

### MinIO Console (File Storage Management)
Access MinIO web console:
```
http://localhost:9001
```
- Username: Value from `MINIO_ACCESS_KEY_ID` in your .env (default: `minioadmin`)
- Password: Value from `MINIO_SECRET_ACCESS_KEY` in your .env (default: `minioadmin`)

You can:
- View uploaded photos
- Create buckets manually if needed
- Manage file storage

### Check Database
Connect to PostgreSQL from your host machine:
```bash
psql -h localhost -p 5433 -U postgres -d wegugin_cars
```

List tables:
```sql
\dt
```

View users:
```sql
SELECT id, email, name, surname, created_at FROM users;
```

Exit: `\q`

## 📝 Available API Endpoints

### Public Endpoints (No Authentication)
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
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

## 🐛 Troubleshooting

### Service not accessible?
```bash
# Check if services are running
docker-compose ps

# Check logs
docker-compose logs userservice
docker-compose logs postgres-db
docker-compose logs redis-db
docker-compose logs minio
```

### API returns error?
- Check application logs: `docker-compose logs userservice -f`
- Verify database migrations ran: Check postgres logs
- Check Swagger UI for exact error messages

### Connection refused?
- Make sure you're using `localhost:8080` (not 127.0.0.1 if configured differently)
- Check if ports are accessible: `curl http://localhost:8080/swagger/index.html`

## 📚 Next Actions

1. ✅ Test basic registration and login
2. ✅ Test protected endpoints with JWT token
3. 📸 Try uploading a profile photo
4. 📧 Test password reset functionality (requires email config in .env)
5. 🔍 Explore Swagger UI documentation
6. 🧪 Create test users and test different scenarios

## 💡 Development Tips

- **View live logs:** `docker-compose logs -f userservice`
- **Restart a service:** `docker-compose restart userservice`
- **Rebuild application:** `docker-compose up -d --build userservice`
- **Stop all services:** `docker-compose down`
- **Stop and remove data:** `docker-compose down -v` (⚠️ deletes database!)

## 🎉 You're All Set!

Your user service is fully operational. Start testing and developing!

For more information:
- See **SETUP_GUIDE.md** for detailed documentation
- See **QUICK_REFERENCE.md** for command reference
- See **README.md** for project overview





