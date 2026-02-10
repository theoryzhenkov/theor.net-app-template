#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[!]${NC} $1" >&2; exit 1; }

NAME="${1:-}"
[ -n "$NAME" ] || error "Usage: ./setup.sh <app-name>

Examples:
  ./setup.sh cue
  ./setup.sh my-cool-app"

# Validate name: lowercase, alphanumeric, hyphens
[[ "$NAME" =~ ^[a-z][a-z0-9-]*$ ]] || error "App name must be lowercase alphanumeric with hyphens (e.g. 'my-app')"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

log "Setting up template for: $NAME"

# Replace 'myapp' with the app name in all text files
# Skip .git, binary files, and this script itself
for file in \
    .github/workflows/deploy.yml \
    .sops.yaml \
    .env.example \
    Dockerfile \
    flake.nix \
    justfile \
    README.md
do
    [ -f "$file" ] || continue
    if grep -q 'myapp' "$file" 2>/dev/null; then
        sed -i'' -e "s/myapp/${NAME}/g" "$file"
        log "Updated $file"
    fi
done

log "Placeholder 'myapp' replaced with '$NAME'"

# Self-destruct
rm -f "$0"
log "Removed setup.sh"

echo ""
log "Template ready! Next steps:"
echo ""
echo "  1. Set up your Dockerfile for your runtime"
echo "     (see comments in Dockerfile for examples)"
echo ""
echo "  2. In the infra repo (theor.net):"
echo "       just app create ${NAME}"
echo "       just app init-secrets ${NAME}"
echo "       # Add the private key to: sops nixos/secrets/secrets.enc.yaml"
echo "       just app generate && just deploy"
echo ""
echo "  3. Configure .sops.yaml with the keys from step 2"
echo "     Replace REPLACE_WITH_APP_PUBLIC_KEY and REPLACE_WITH_LOCAL_PUBLIC_KEY"
echo ""
echo "  4. Create and encrypt secrets:"
echo "       sops secrets/production.enc.yaml"
echo ""
echo "  5. Push to GitHub — CI will build the image and push secrets"
echo ""
