# myapp.theor.net

default:
    @just --list

# --- Development (TODO: adapt for your runtime) ---

# Install dependencies
install:
    @echo "TODO: add install command (e.g. bun install, npm ci)"

# Run dev server
dev:
    @echo "TODO: add dev command (e.g. bun --hot index.ts)"

# Build for production
build:
    @echo "TODO: add build command (e.g. bun build ./index.html --outdir ./dist)"

# --- Docker ---

# Build Docker image
docker-build:
    docker build -t myapp .

# Run Docker container locally (reads .env)
docker-run: docker-build
    docker run --rm --env-file .env -p 3000:3000 myapp

# --- Secrets ---

# Edit encrypted production secrets
secrets:
    sops secrets/production.enc.yaml
