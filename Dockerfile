FROM golang:1.23.4 AS builder

WORKDIR /app

COPY . .

RUN go mod download

# Note: .env file is not needed - Railway uses environment variables directly
# The app will use env vars from Railway, godotenv.Load will just log if .env is missing

RUN CGO_ENABLED=0 GOOS=linux go build -C ./cmd -a -installsuffix cgo -o ./../myapp .

FROM alpine:latest

# Install Go for migrate tool
RUN apk add --no-cache go git

WORKDIR /app

COPY --from=builder /app/myapp .
COPY --from=builder /app/api/email/template.html ./api/email/
COPY --from=builder /app/app.log ./
COPY --from=builder /app/migrations ./migrations

# Install migrate tool
RUN go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Note: .env file is not copied - Railway uses environment variables directly

EXPOSE 8080

# Run migrations before starting the app
CMD sh -c 'if [ -n "$DATABASE_URL" ]; then ~/go/bin/migrate -path migrations -database "$DATABASE_URL" up || echo "Migration failed or already applied"; fi && ./myapp'