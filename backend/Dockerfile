# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install dependencies needed for fetching modules and building
RUN apk add --no-cache git ca-certificates

# Set Go proxy to default (direct or proxy.golang.org)
ENV GOPROXY=https://proxy.golang.org,direct

# Download and install goose binary for migrations
RUN go install github.com/pressly/goose/v3/cmd/goose@latest

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies with BuildKit cache mount
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Copy the source code
COPY . .

# Build the main application with BuildKit cache mounts
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -installsuffix cgo -o main ./cmd/server/main.go

# Build the seeder tool with BuildKit cache mounts
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -installsuffix cgo -o seeder ./cmd/seeder/main.go

# Final stage
FROM alpine:latest

WORKDIR /app

# Install timezone data, ca-certificates, and netcat for waiting for postgres
RUN apk --no-cache add tzdata ca-certificates netcat-openbsd

# Copy the Pre-built binaries from the builder stage
COPY --from=builder /app/main .
COPY --from=builder /app/seeder .
COPY --from=builder /go/bin/goose /usr/local/bin/goose

# Copy migrations and entrypoint script
COPY db/migrations ./db/migrations
COPY scripts/entrypoint.sh ./scripts/entrypoint.sh

# Ensure migration script is executable
RUN chmod +x ./scripts/entrypoint.sh

# Expose port 8080
EXPOSE 8080

# Environment variables for Goose handled through DATABASE_URL in entrypoint
ENV GOOSE_DRIVER=postgres
ENV GOOSE_DBSTRING=""

# Entrypoint manages migration + app startup
ENTRYPOINT ["./scripts/entrypoint.sh"]
