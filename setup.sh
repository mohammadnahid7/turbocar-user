#!/bin/bash

# User Service Setup Script for Arch Linux
# This script helps automate the initial setup process

set -e

echo "🚀 User Service Setup Script"
echo "=============================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠ .env file not found. Creating from template...${NC}"
    if [ -f .env.template ]; then
        cp .env.template .env
        echo -e "${GREEN}✓ Created .env file from template${NC}"
        echo -e "${YELLOW}⚠ Please edit .env file and update the configuration values${NC}"
    else
        echo -e "${RED}✗ .env.template not found. Please create .env file manually.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ .env file exists${NC}"
fi

# Check for required commands
echo ""
echo "Checking required tools..."
MISSING_TOOLS=()

command -v go >/dev/null 2>&1 || MISSING_TOOLS+=("go")
command -v docker >/dev/null 2>&1 || MISSING_TOOLS+=("docker")
command -v docker-compose >/dev/null 2>&1 || MISSING_TOOLS+=("docker-compose")
command -v psql >/dev/null 2>&1 || MISSING_TOOLS+=("postgresql")
command -v redis-cli >/dev/null 2>&1 || MISSING_TOOLS+=("redis")
command -v protoc >/dev/null 2>&1 || MISSING_TOOLS+=("protobuf")

if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All required tools are installed${NC}"
else
    echo -e "${YELLOW}⚠ Missing tools: ${MISSING_TOOLS[*]}${NC}"
    echo "Install them with: sudo pacman -S ${MISSING_TOOLS[*]}"
fi

# Check for Go tools
echo ""
echo "Checking Go tools..."
GO_TOOLS_MISSING=()

if [ ! -f ~/go/bin/protoc-gen-go ]; then
    GO_TOOLS_MISSING+=("protoc-gen-go")
fi

if [ ! -f ~/go/bin/protoc-gen-go-grpc ]; then
    GO_TOOLS_MISSING+=("protoc-gen-go-grpc")
fi

if [ ! -f ~/go/bin/migrate ]; then
    GO_TOOLS_MISSING+=("migrate")
fi

if [ ${#GO_TOOLS_MISSING[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All Go tools are installed${NC}"
else
    echo -e "${YELLOW}⚠ Missing Go tools: ${GO_TOOLS_MISSING[*]}${NC}"
    echo "Install them with:"
    for tool in "${GO_TOOLS_MISSING[@]}"; do
        case $tool in
            "protoc-gen-go")
                echo "  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
                ;;
            "protoc-gen-go-grpc")
                echo "  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
                ;;
            "migrate")
                echo "  go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest"
                ;;
        esac
    done
fi

# Create Docker network if it doesn't exist
echo ""
echo "Checking Docker network..."
if docker network inspect wegugin >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker network 'wegugin' exists${NC}"
else
    echo -e "${YELLOW}⚠ Docker network 'wegugin' not found. Creating...${NC}"
    docker network create wegugin
    echo -e "${GREEN}✓ Docker network 'wegugin' created${NC}"
fi

# Create MinIO data directory
echo ""
echo "Checking MinIO data directory..."
if [ -d /opt/minio-data ]; then
    echo -e "${GREEN}✓ MinIO data directory exists${NC}"
else
    echo -e "${YELLOW}⚠ MinIO data directory not found. Creating...${NC}"
    sudo mkdir -p /opt/minio-data
    sudo chown $USER:$USER /opt/minio-data
    echo -e "${GREEN}✓ MinIO data directory created${NC}"
fi

# Download Go dependencies
echo ""
echo "Downloading Go dependencies..."
if go mod download; then
    echo -e "${GREEN}✓ Go dependencies downloaded${NC}"
else
    echo -e "${RED}✗ Failed to download Go dependencies${NC}"
    exit 1
fi

echo ""
echo "=============================="
echo -e "${GREEN}Setup check complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your configuration"
echo "2. For Docker setup: docker-compose up -d"
echo "3. For manual setup: make mig-up && make run"
echo ""
echo "See SETUP_GUIDE.md for detailed instructions."

