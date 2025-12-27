FROM golang:1.24 AS builder

WORKDIR /app

COPY . .

RUN go mod download

# Note: .env file is not needed - Railway uses environment variables directly
# The app will use env vars from Railway, godotenv.Load will just log if .env is missing

RUN CGO_ENABLED=0 GOOS=linux go build -C ./cmd -a -installsuffix cgo -o ./../myapp .

FROM golang:1.24-alpine AS migrate-builder

# Install migrate tool in builder stage
# Using latest version which requires Go 1.24+
RUN go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

FROM alpine:latest

WORKDIR /app

# Copy migrate binary from builder
COPY --from=migrate-builder /go/bin/migrate /usr/local/bin/migrate

# Copy application files
COPY --from=builder /app/myapp .
COPY --from=builder /app/api/email/template.html ./api/email/
COPY --from=builder /app/app.log ./
COPY --from=builder /app/migrations ./migrations

# Note: .env file is not copied - Railway uses environment variables directly

EXPOSE 8080

# Run migrations before starting the app
# Note: Railway provides DATABASE_URL automatically for PostgreSQL
CMD sh -c 'echo "Checking for DATABASE_URL..."; if [ -n "$DATABASE_URL" ]; then echo "Running migrations with DATABASE_URL..."; migrate -path migrations -database "$DATABASE_URL" up; MIGRATE_EXIT=$?; if [ $MIGRATE_EXIT -eq 0 ]; then echo "Migrations completed successfully!"; elif [ $MIGRATE_EXIT -eq 1 ]; then echo "Migration error occurred!"; exit 1; else echo "Migrations already applied or no change needed (exit code: $MIGRATE_EXIT)"; fi; else echo "ERROR: DATABASE_URL not set! Cannot run migrations."; exit 1; fi && echo "Starting application..." && ./myapp'