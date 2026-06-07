# Production Hardening Guide

Your Chinai Gateway instance works out of the box for local dev. Before you put it on a public server, do these things. In order.

## 1. Firewall

Your VPS should only have ports 80 and 443 open.

```bash
# UFW (Ubuntu/Debian)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

```bash
# firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --remove-port=4000/tcp
sudo firewall-cmd --reload
```

**Port 4000 should never face the internet.** The gateway binds to `127.0.0.1` by default — even if your firewall is misconfigured, it won't accept connections from outside.

## 2. Reverse Proxy with TLS

### nginx

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate     /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # Modern TLS only
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;

    # Rate limit — prevents brute force and abuse
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    location / {
        proxy_pass http://127.0.0.1:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_read_timeout 120s;
        proxy_send_timeout 120s;
    }
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$host$request_uri;
}
```

### Caddy (simpler, auto-TLS)

```
your-domain.com {
    reverse_proxy 127.0.0.1:4000
}
```

Caddy handles TLS certificates automatically. Two lines, done.

## 3. Create Scoped API Keys

The master key (`LITELLM_MASTER_KEY`) is root. Never hand it to applications or team members.

Open the Admin UI at `https://your-domain.com/ui`, log in with your master key, and create scoped keys:

| Use case | Permissions |
|----------|------------|
| Personal scripts | All models, rate limit: 100/min |
| Team member | Specific models only |
| Public demo | Read-only, hard rate limit |
| CI/CD testing | Budget cap: $5/month |

## 4. Rate Limiting

LiteLLM supports per-key rate limits. In the Admin UI, or via `config.yaml`:

```yaml
litellm_settings:
  rpm_per_key: 100        # Requests per minute, per key
  rpm_per_key_max: 1000   # Hard cap
```

## 5. Keep LiteLLM Updated

Check [LiteLLM releases](https://github.com/BerriAI/litellm/releases) monthly.

```bash
# Pull latest image
docker compose pull litellm

# Recreate container
docker compose up -d
```

The `main-stable` tag is updated with every stable release. We review releases before bumping the pinned tag in this repo.

## 6. Database Backups

PostgreSQL data is in `./pgdata/`. Back it up:

```bash
# Daily cron job
0 3 * * * cd /opt/chinai-gateway && docker compose exec -T db pg_dump -U litellm litellm > backups/$(date +\%Y\%m\%d).sql
```

## 7. Audit Your Keys

Every month, go to the Admin UI → Keys tab. Delete keys you don't recognize. Rotate keys older than 90 days.

## Quick Checklist

- [ ] Firewall: only 80/443 open
- [ ] Reverse proxy: nginx or Caddy with TLS
- [ ] `.env`: all defaults changed
- [ ] Master key: never shared
- [ ] Scoped keys: created for each application
- [ ] Rate limiting: enabled
- [ ] Backups: scheduled
- [ ] LiteLLM: up to date
