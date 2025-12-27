package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
	"github.com/spf13/cast"
)

type Config struct {
	Postgres PostgresConfig
	Server   ServerConfig
	Token    TokensConfig
	Redis    RedisConfig
	Minio    MinioConfig
	Email    EmailConfig
}

type PostgresConfig struct {
	PDB_NAME     string
	PDB_PORT     string
	PDB_PASSWORD string
	PDB_USER     string
	PDB_HOST     string
}

type RedisConfig struct {
	RDB_ADDRESS  string
	RDB_PASSWORD string
}

type ServerConfig struct {
	USER_SERVICE string
	USER_ROUTER  string
}

type TokensConfig struct {
	TOKEN_KEY string
}

type MinioConfig struct {
	MINIO_ENDPOINT          string
	MINIO_ACCESS_KEY_ID     string
	MINIO_SECRET_ACCESS_KEY string
	MINIO_BUCKET_NAME       string
	MINIO_PUBLIC_URL        string
}

type EmailConfig struct {
	SENDER_EMAIL string
	APP_PASSWORD string
}

func Load() *Config {
	if err := godotenv.Load(".env"); err != nil {
		log.Printf("error while loading .env file: %v", err)
	}

	return &Config{
		Postgres: getPostgresConfig(),
		Server: ServerConfig{
			USER_SERVICE: getPort("USER_SERVICE", "8085"),
			USER_ROUTER:  getPort("USER_ROUTER", "8080"),
		},
		Token: TokensConfig{
			TOKEN_KEY: cast.ToString(coalesce("TOKEN_KEY", "your_secret_key")),
		},
		Redis: RedisConfig{
			RDB_ADDRESS:  cast.ToString(coalesce("RDB_ADDRESS", "localhost:6379")),
			RDB_PASSWORD: cast.ToString(coalesce("RDB_PASSWORD", "")),
		},
		Minio: MinioConfig{
			MINIO_ENDPOINT:          cast.ToString(coalesce("MINIO_ENDPOINT", "access_key")),
			MINIO_ACCESS_KEY_ID:     cast.ToString(coalesce("MINIO_ACCESS_KEY_ID", "access_key")),
			MINIO_SECRET_ACCESS_KEY: cast.ToString(coalesce("MINIO_SECRET_ACCESS_KEY", "access_key")),
			MINIO_BUCKET_NAME:       cast.ToString(coalesce("MINIO_BUCKET_NAME", "twit_images")),
			MINIO_PUBLIC_URL:        cast.ToString(coalesce("MINIO_PUBLIC_URL", "http://localhost:9000/minio/")),
		},
		Email: EmailConfig{
			SENDER_EMAIL: cast.ToString(coalesce("SENDER_EMAIL", "your_email@example.com")),
			APP_PASSWORD: cast.ToString(coalesce("APP_PASSWORD", "your_password")),
		},
	}
}

func coalesce(key string, value interface{}) interface{} {
	val, exist := os.LookupEnv(key)
	if exist {
		return val
	}
	return value
}

// getPostgresConfig returns PostgreSQL configuration, checking Railway's DATABASE_URL first
func getPostgresConfig() PostgresConfig {
	// Railway provides DATABASE_URL in format: postgres://user:password@host:port/dbname
	if databaseURL := os.Getenv("DATABASE_URL"); databaseURL != "" {
		// Parse DATABASE_URL
		// Format: postgres://user:password@host:port/dbname?sslmode=disable
		// We'll extract components or use the URL directly
		// For now, try to parse it
		host := cast.ToString(coalesce("PGHOST", coalesce("PDB_HOST", "localhost")))
		port := cast.ToString(coalesce("PGPORT", coalesce("PDB_PORT", "5432")))
		user := cast.ToString(coalesce("PGUSER", coalesce("PDB_USER", "postgres")))
		dbname := cast.ToString(coalesce("PGDATABASE", coalesce("PDB_NAME", "postgres")))
		password := cast.ToString(coalesce("PGPASSWORD", coalesce("PDB_PASSWORD", "")))
		
		// Railway also provides individual variables, check those first
		if os.Getenv("PGHOST") != "" {
			host = cast.ToString(coalesce("PGHOST", "localhost"))
		}
		if os.Getenv("PGPORT") != "" {
			port = cast.ToString(coalesce("PGPORT", "5432"))
		}
		if os.Getenv("PGUSER") != "" {
			user = cast.ToString(coalesce("PGUSER", "postgres"))
		}
		if os.Getenv("PGDATABASE") != "" {
			dbname = cast.ToString(coalesce("PGDATABASE", "postgres"))
		}
		if os.Getenv("PGPASSWORD") != "" {
			password = cast.ToString(coalesce("PGPASSWORD", ""))
		}
		
		return PostgresConfig{
			PDB_HOST:     host,
			PDB_PORT:     port,
			PDB_USER:     user,
			PDB_NAME:     dbname,
			PDB_PASSWORD: password,
		}
	}
	
	// Fallback to individual variables or defaults
	return PostgresConfig{
		PDB_HOST:     cast.ToString(coalesce("PDB_HOST", "localhost")),
		PDB_PORT:     cast.ToString(coalesce("PDB_PORT", "5432")),
		PDB_USER:     cast.ToString(coalesce("PDB_USER", "postgres")),
		PDB_NAME:     cast.ToString(coalesce("PDB_NAME", "postgres")),
		PDB_PASSWORD: cast.ToString(coalesce("PDB_PASSWORD", "3333")),
	}
}

// getPort returns the port with ":" prefix, checking PORT env var first (Railway compatibility)
func getPort(envKey string, defaultPort string) string {
	// Railway sets PORT environment variable
	if port := os.Getenv("PORT"); port != "" {
		return ":" + port
	}
	// Check for custom env var
	if port := os.Getenv(envKey); port != "" {
		if port[0] != ':' {
			return ":" + port
		}
		return port
	}
	// Return default with ":"
	if defaultPort[0] != ':' {
		return ":" + defaultPort
	}
	return defaultPort
}
