#!/usr/bin/env bash
# ============================================================
# Chinai Gateway — One-Command VPS Setup
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/AAAjczz/chinai-gateway/master/scripts/setup.sh | bash
#
# Or:
#   git clone https://github.com/AAAjczz/chinai-gateway.git && cd chinai-gateway && bash scripts/setup.sh
# ============================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
info() { echo -e "${CYAN}[i]${NC} $1"; }

echo ""
echo "=============================================="
echo "  Chinai Gateway — Setup"
echo "  Chinese AI models, one OpenAI-compatible API"
echo "=============================================="
echo ""

# ---- Check root / sudo ----
if [ "$(id -u)" -ne 0 ]; then
    warn "This script needs root privileges for package installation."
    warn "Restarting with sudo..."
    exec sudo bash "$0" "$@"
fi

# ---- Detect repo directory ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../docker-compose.yml" ]; then
    REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [ -f "$(pwd)/docker-compose.yml" ]; then
    REPO_DIR="$(pwd)"
else
    REPO_DIR="/opt/chinai-gateway"
fi

# ---- Install Docker ----
if ! command -v docker &>/dev/null; then
    info "Installing Docker..."
    curl -fsSL https://get.docker.com | bash
    log "Docker installed"
else
    log "Docker already installed: $(docker --version)"
fi

# ---- Install Docker Compose plugin ----
if ! docker compose version &>/dev/null; then
    info "Installing Docker Compose plugin..."
    apt update -qq && apt install -y -qq docker-compose-plugin
    log "Docker Compose plugin installed"
else
    log "Docker Compose already installed"
fi

# ---- Install git if missing ----
if ! command -v git &>/dev/null; then
    info "Installing git..."
    apt update -qq && apt install -y -qq git
    log "Git installed"
fi

# ---- Clone repo if needed ----
if [ ! -f "$REPO_DIR/docker-compose.yml" ]; then
    info "Cloning chinai-gateway..."
    git clone https://github.com/AAAjczz/chinai-gateway.git "$REPO_DIR"
    log "Repository cloned to $REPO_DIR"
else
    log "Repository already exists at $REPO_DIR"
fi

cd "$REPO_DIR"

# ---- Configure .env ----
if [ -f .env ]; then
    log ".env file already exists"
else
    cp .env.example .env

    echo ""
    info "=================================================="
    info "  API Key Configuration"
    info "=================================================="
    info "You need at least a DeepSeek API key to get started."
    info "Register at: https://platform.deepseek.com/api_keys"
    info ""
    info "Leave blank to skip, or paste your keys now."
    echo ""

    read -r -p "DeepSeek API Key (required): " DS_KEY
    read -r -p "Qwen API Key (optional):      " QW_KEY
    read -r -p "Zhipu API Key (optional):    " ZP_KEY
    read -r -p "Moonshot API Key (optional):  " MS_KEY

    # Generate random master key and salt
    MASTER_KEY="sk-$(openssl rand -hex 16)"
    SALT_KEY="$(openssl rand -hex 16)"
    ADMIN_PW="$(openssl rand -hex 8)"

    cat > .env << EOF
LITELLM_MASTER_KEY=${MASTER_KEY}
LITELLM_SALT_KEY=${SALT_KEY}
LITELLM_PORT=4000
UI_USERNAME=admin
UI_PASSWORD=${ADMIN_PW}

DEEPSEEK_API_KEY=${DS_KEY}

QWEN_API_KEY=${QW_KEY}
ZHIPU_API_KEY=${ZP_KEY}
MOONSHOT_API_KEY=${MS_KEY}
EOF

    log ".env configured"
    echo ""
    info "--- SAVE THESE CREDENTIALS ---"
    info "Master Key:    ${MASTER_KEY}"
    info "Admin UI:      http://YOUR_IP:4000/ui"
    info "Admin Pass:    ${ADMIN_PW}"
    info "------------------------------"
    echo ""
fi

# ---- Start services ----
info "Starting services..."
docker compose up -d

# Wait for healthy
info "Waiting for gateway to be ready (this may take 30-60s)..."
for i in $(seq 1 30); do
    if curl -s http://localhost:4000/health/liveliness > /dev/null 2>&1; then
        log "Gateway is healthy"
        break
    fi
    sleep 2
done

# ---- Verify ----
MASTER_KEY=$(grep LITELLM_MASTER_KEY .env | cut -d= -f2)
echo ""
info "Running quick verification..."

RESPONSE=$(curl -s -X POST http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer ${MASTER_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hi"}]}' 2>&1 || true)

if echo "$RESPONSE" | grep -q '"content"'; then
    log "API test passed — gateway is working!"
else
    warn "API test failed. Check logs: docker compose logs litellm"
    warn "Response: $RESPONSE"
fi

echo ""
echo "=============================================="
echo "  Setup Complete"
echo "=============================================="
echo ""
echo "  Gateway:       http://localhost:4000"
echo "  Admin UI:      http://YOUR_IP:4000/ui"
echo "  API Endpoint:  http://YOUR_IP:4000/v1"
echo ""
echo "  Next steps:"
echo "  1. Set up Nginx + HTTPS: see docs/deployment.md"
echo "  2. See supported models: curl http://localhost:4000/v1/models -H \"Authorization: Bearer \${MASTER_KEY}\""
echo "  3. Integration examples: docs/examples/usage.md"
echo "=============================================="
