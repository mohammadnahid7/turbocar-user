FROM golang:1.23.4 AS builder

WORKDIR /app

COPY . .

RUN go mod download

# Note: .env file is not needed - Railway uses environment variables directly
# The app will use env vars from Railway, godotenv.Load will just log if .env is missing

RUN CGO_ENABLED=0 GOOS=linux go build -C ./cmd -a -installsuffix cgo -o ./../myapp .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/myapp .
COPY --from=builder /app/api/email/template.html ./api/email/
COPY --from=builder /app/app.log ./
# Note: .env file is not copied - Railway uses environment variables directly

EXPOSE 8080

CMD ["./myapp"]