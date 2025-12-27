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
CMD sh -c 'if [ -n "$DATABASE_URL" ]; then migrate -path migrations -database "$DATABASE_URL" up 2>&1 || echo "Migrations completed or already applied"; fi && ./myapp'