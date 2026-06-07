# Chinai Gateway

**One command to unify DeepSeek, Qwen, GLM, Kimi, and ERNIE behind a single OpenAI-compatible API.**

Self-hosted. Bring your own keys. Zero data leaves your server.

```bash
# Try it on our demo server (no deployment needed)
curl -X POST https://chinaigateway.xyz/v1/chat/completions \
  -H "Authorization: Bearer sk-IxF6ZNzPH_M-4_LyxB8Dlg" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4-pro","messages":[{"role":"user","content":"Hello!"}]}'
```

> The demo key is restricted — strict rate limit, $0.05 budget cap, DeepSeek models only. For production, [deploy your own](#quick-start).

## Why

Chinese AI models are 10x cheaper than Western alternatives. But each provider has a different API, different docs, different auth. OpenRouter solves this — but it's closed-source, and your data transits their servers.

**Chinai Gateway** is the open-source alternative: a pre-configured LiteLLM stack that you deploy on your own infrastructure in 5 minutes.

| | OpenRouter | Chinai Gateway |
|---|---|---|
| **Deployment** | Hosted (their servers) | **Your server** |
| **Data privacy** | Passes through OpenRouter | **Never leaves your infra** |
| **Chinese models** | Yes, generic config | **Pre-tuned configs, docs in EN/ZH** |
| **Cost** | +5.5% platform fee | **Free (MIT)** |
| **Source** | Closed | **Open (MIT)** |

## Quick Start

### Prerequisites

- Docker & Docker Compose
- API keys from at least one provider (see below)

### 1. Clone and configure

```bash
git clone https://github.com/AAAjczz/chinai-gateway.git
cd chinai-gateway
cp .env.example .env
# Edit .env — add your API keys AND change all default passwords
```

> ⚠️ **Do not skip this.** The `.env` has placeholder passwords. Deploying with defaults on a public server will get your instance hijacked within minutes.
> 
> For production, follow the full [Hardening Guide](docs/hardening.md).

### 2. Start

```bash
docker compose up -d
```

> This exposes port 4000 on `0.0.0.0` by default. For production, put nginx or Caddy in front with TLS. See [Security](#security).

### 3. Use it

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-v4-pro",
    "messages": [{"role": "user", "content": "Explain quantum computing in one sentence."}]
  }'
```

Or with any OpenAI SDK:

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_MASTER_KEY",
    base_url="http://localhost:4000/v1"
)

response = client.chat.completions.create(
    model="deepseek-v4-pro",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

### 4. Admin UI

Open `http://localhost:4000/ui` — manage API keys, set rate limits, track spend.

## Supported Models

| Model | Provider | Strengths | Input Price | Output Price |
|-------|----------|-----------|-------------|---------------|
| `deepseek-v4-pro` | DeepSeek V4 | Agent-ready, 1M ctx, near Opus 4.6 | ¥3/M | ¥6/M |
| `deepseek-v4-flash` | DeepSeek V4 | Lightweight, thinking mode | ¥1/M | ¥2/M |
| `deepseek-chat` | DeepSeek V3 | Legacy — deprecated 2026-07 | ¥1/M | ¥2/M |
| `deepseek-reasoner` | DeepSeek R1 | Legacy — deprecated 2026-07 | ¥4/M | ¥16/M |
| `qwen-plus` | Alibaba Qwen | Chinese understanding | ¥2/M | ¥6/M |
| `qwen-max` | Alibaba Qwen | Best Chinese quality | ¥20/M | ¥60/M |
| `qwen-vl-plus` | Alibaba Qwen | Image understanding | ¥2/M | ¥6/M |
| `glm-4-plus` | Zhipu GLM | Function calling | ¥1/M | ¥4/M |
| `glm-4-flash` | Zhipu GLM | Fast & free tier | Free | Free |
| `glm-4v-plus` | Zhipu GLM | Chinese OCR | ¥5/M | ¥5/M |
| `kimi` | Moonshot | Document analysis | ¥12/M | ¥12/M |
| `kimi-128k` | Moonshot | Ultra-long context | ¥60/M | ¥60/M |
| `ernie-4.0-turbo` | Baidu ERNIE | Search-enhanced Chinese | ¥4/M | ¥12/M |
| `ernie-speed` | Baidu ERNIE | Fast & free tier | Free | Free |

*Prices are approximate. Check provider websites for current pricing.*

See [docs/models.md](docs/models.md) for detailed comparison.

## Getting API Keys

| Provider | Sign-up Link | Notes |
|----------|-------------|-------|
| **DeepSeek** | [platform.deepseek.com](https://platform.deepseek.com) | Cheapest, $2 free credit |
| **Qwen (Alibaba)** | [dashscope.console.aliyun.com](https://dashscope.console.aliyun.com) | Requires Alibaba Cloud account |
| **GLM (Zhipu)** | [open.bigmodel.cn](https://open.bigmodel.cn) | GLM-4-Flash has free tier |
| **Kimi (Moonshot)** | [platform.moonshot.cn](https://platform.moonshot.cn) | 128K context specialist |
| **ERNIE (Baidu)** | [console.bce.baidu.com/qianfan](https://console.bce.baidu.com/qianfan/ais/console/applicationConsole/application) | ERNIE-Speed free tier |

## Architecture

```
Your App → https://your-domain.com/v1/chat/completions
                    ↓
              nginx / Caddy (TLS termination, rate limiting)
                    ↓
              LiteLLM Proxy (Docker, 127.0.0.1:4000)
                    ↓
    ┌──────┬──────┬──────┬──────┐
    ↓      ↓      ↓      ↓
DeepSeek  Qwen   GLM    Kimi    ERNIE
```

- **Self-contained** — Docker Compose, PostgreSQL included
- **Memory footprint** — ~430MB, runs on a $5 VPS
- **Your API keys** stay in your `.env` file
- **Your data** stays on your server
- **Secure by default** — gateway binds `127.0.0.1`, never exposed to the internet directly

## Security

### Before you expose this to the internet

1. **Change all defaults.** `.env` has placeholder values. Replace `LITELLM_MASTER_KEY`, `LITELLM_SALT_KEY`, `UI_PASSWORD`, and `DB_PASSWORD` before `docker compose up`.
2. **Put a reverse proxy in front.** LiteLLM listens on port 4000. Do NOT expose it directly. Use nginx or Caddy to terminate TLS.
3. **Firewall everything except 443.** Your VPS should only have ports 80 and 443 open to the world.
4. **Rotate your master key regularly.** The master key is root. Create scoped keys for applications via the Admin UI.

### Trust boundaries

- **You → Your server**: HTTPS, encrypted in transit
- **Your server → Model providers**: HTTPS, API key auth
- **API keys**: Stored in your `.env` file, never sent to us (we don't run a service)

### What's logged

LiteLLM logs request metadata (model, tokens, latency) to PostgreSQL by default. This data stays on your server. Request bodies are not logged unless you enable it. See the [Admin UI](http://localhost:4000/ui) to configure logging.

### Reporting

Found a security issue? See [SECURITY.md](SECURITY.md) for how to report it privately.

### Hardening

Deploying to production? Follow the [Hardening Guide](docs/hardening.md) — reverse proxy, firewall, key rotation, backups.

## FAQ

**Is this a hosted service?**
No. This is open-source software you deploy yourself. We don't see your data, your keys, or your traffic.

**Why not just use OpenRouter?**
If you're fine with a third party seeing your requests, OpenRouter is great. If you want data privacy, compliance, or just like owning your infra — use Chinai Gateway.

**Can I add more models?**
Yes. Edit `config.yaml` — LiteLLM supports 100+ providers. See [LiteLLM docs](https://docs.litellm.ai/docs/providers).

**Is this production-ready?**
LiteLLM (the engine underneath) is. Chinai Gateway is the batteries-included config layer with PostgreSQL persistence.

## License

MIT — do whatever you want. Just don't blame us if your AI goes rogue.

## Credits

Built on [LiteLLM](https://github.com/BerriAI/litellm), the open-source LLM proxy. This project adds pre-configured Chinese model support, bilingual docs, and a one-command deploy experience.
