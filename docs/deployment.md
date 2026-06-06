# Deployment Guide

Deploy Chinai Gateway on your own server in 5 minutes.

## Prerequisites

- A server (VPS) with at least **1 GB RAM** and **2 GB free disk**
- A domain name pointing to your server (optional, for HTTPS)
- Ubuntu 20.04+ / Debian 11+ (other Linux distros work, adjust package commands)

## Quick Deploy (Recommended)

```bash
# 1. Clone the repo
git clone https://github.com/AAAjczz/chinai-gateway.git
cd chinai-gateway

# 2. Configure your API keys
cp .env.example .env
nano .env   # Fill in your keys

# 3. Start the gateway
docker compose up -d

# 4. Verify
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hi"}]}'
```

That's it. Your OpenAI-compatible API is now running at `http://localhost:4000/v1`.

## One-Command VPS Setup

If you're on a fresh VPS, use the setup script:

```bash
curl -sSL https://raw.githubusercontent.com/AAAjczz/chinai-gateway/master/scripts/setup.sh | bash
```

This installs Docker (if needed), clones the repo, and starts the gateway.

## Manual Steps

### 1. Install Docker & Docker Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com | bash

# Verify
docker --version
docker compose version
```

### 2. Get Your API Keys

Register at these platforms to get API keys:

| Provider | Sign-up URL | Model Prefix |
|----------|------------|--------------|
| DeepSeek | https://platform.deepseek.com/api_keys | `deepseek-chat`, `deepseek-reasoner` |
| Alibaba Qwen | https://dashscope.console.aliyun.com/apiKey | `qwen-plus`, `qwen-max`, `qwen-vl-plus` |
| Zhipu GLM | https://open.bigmodel.cn/usercenter/apikeys | `glm-4-plus`, `glm-4-flash`, `glm-4v-plus` |
| Moonshot Kimi | https://platform.moonshot.cn/console/api-keys | `kimi`, `kimi-128k` |

At minimum, get a DeepSeek key (free registration, pay-as-you-go).

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and fill in:

```ini
LITELLM_MASTER_KEY=sk-CHANGE-ME-at-least-20-chars
LITELLM_SALT_KEY=another-random-string-20-chars
UI_USERNAME=admin
UI_PASSWORD=your-admin-password

DEEPSEEK_API_KEY=sk-your-deepseek-key-here

# Optional — uncomment when you have keys
# QWEN_API_KEY=sk-your-qwen-key
# ZHIPU_API_KEY=your-zhipu-key
# MOONSHOT_API_KEY=sk-your-moonshot-key
```

### 4. Start Services

```bash
docker compose up -d
```

Wait ~30 seconds for PostgreSQL to initialize and LiteLLM to run database migrations.

Check status:

```bash
docker compose ps
```

Both `chinai-db` and `chinai-gateway` should show `Up` (healthy).

### 5. Verify

```bash
# Test chat completion
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hello!"}]}'

# List available models
curl http://localhost:4000/v1/models \
  -H "Authorization: Bearer YOUR_MASTER_KEY"

# Check health
curl http://localhost:4000/health/liveliness
```

### 6. Access Admin UI

Open `http://YOUR_SERVER_IP:4000/ui` in your browser. Log in with `UI_USERNAME` / `UI_PASSWORD` from your `.env`.

The admin UI lets you:
- View usage logs and spending
- Create virtual keys with rate limits and budget caps
- Monitor per-model latency and error rates

## Setting Up Nginx + HTTPS

### Install Nginx

```bash
apt update && apt install -y nginx
```

### Configure Reverse Proxy

Create `/etc/nginx/sites-available/chinai-gateway`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
        client_max_body_size 50M;
    }
}
```

Enable and reload:

```bash
ln -sf /etc/nginx/sites-available/chinai-gateway /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
```

### Get Free HTTPS with Let's Encrypt

```bash
apt install -y certbot python3-certbot-nginx
certbot --nginx -d your-domain.com -d www.your-domain.com \
  --non-interactive --agree-tos -m your-email@example.com --redirect
```

Certificates auto-renew via systemd timer. Verify:

```bash
systemctl status certbot.timer
```

### Test External Access

```bash
curl https://your-domain.com/v1/chat/completions \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-chat","messages":[{"role":"user","content":"Hi"}]}'
```

## Updating

```bash
cd chinai-gateway
git pull
docker compose pull
docker compose up -d --force-recreate
```

Your database (API keys, usage logs) is stored in the `pgdata/` volume and persists across updates.

## Troubleshooting

### Gateway fails to start

Check logs:

```bash
docker compose logs litellm
```

Common issues:
- **"the URL must start with the protocol postgresql://"** — PostgreSQL container isn't healthy yet. Wait and retry: `docker compose up -d`
- **401 on /health** — Normal. Use `/health/liveliness` instead.
- **DeepSeek API returns error** — Verify your `DEEPSEEK_API_KEY` in `.env` and run `docker compose restart`

### PostgreSQL won't start

```bash
docker compose logs db
```

If you see disk space errors, check: `df -h`. You need at least 500 MB free.

### Can't access from outside

1. Check firewall: `ufw allow 80/tcp && ufw allow 443/tcp`
2. Check Nginx: `systemctl status nginx`
3. Check the gateway is listening: `curl http://localhost:4000/health/liveliness`

### Database migration errors after update

Rare. Reset the database (this deletes all keys and logs):

```bash
docker compose down -v
docker compose up -d
```

## Resource Usage

On a 1 GB VPS running both PostgreSQL and LiteLLM:

| Component | RAM | CPU (idle) |
|-----------|-----|------------|
| PostgreSQL | ~80 MB | ~1% |
| LiteLLM | ~300 MB | ~2% |
| Nginx | ~50 MB | 0% |
| **Total** | **~430 MB** | ~3% |

Fits comfortably on budget VPS plans ($2–5/month).
