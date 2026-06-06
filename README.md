# Chinai Gateway

**One command to unify DeepSeek, Qwen, GLM, and Kimi behind a single OpenAI-compatible API.**

Self-hosted. Bring your own keys. Zero data leaves your server.

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
git clone https://github.com/YOUR_USER/chinai-gateway.git
cd chinai-gateway
cp .env.example .env
# Edit .env — add your API keys
```

### 2. Start

```bash
docker compose up -d
```

### 3. Use it

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer YOUR_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
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
    model="deepseek-chat",
    messages=[{"role": "user", "content": "Hello!"}]
)
print(response.choices[0].message.content)
```

### 4. Admin UI

Open `http://localhost:4000/ui` — manage API keys, set rate limits, track spend.

## Supported Models

| Model | Provider | Strengths | Input Price | Output Price |
|-------|----------|-----------|-------------|---------------|
| `deepseek-chat` | DeepSeek V3 | Best price/performance | ¥1/M | ¥2/M |
| `deepseek-reasoner` | DeepSeek R1 | Math, code, logic | ¥4/M | ¥16/M |
| `qwen-plus` | Alibaba Qwen | Chinese understanding | ¥2/M | ¥6/M |
| `qwen-max` | Alibaba Qwen | Best Chinese quality | ¥20/M | ¥60/M |
| `qwen-vl-plus` | Alibaba Qwen | Image understanding | ¥2/M | ¥6/M |
| `glm-4-plus` | Zhipu GLM | Function calling | ¥1/M | ¥4/M |
| `glm-4-flash` | Zhipu GLM | Fast & free tier | Free | Free |
| `glm-4v-plus` | Zhipu GLM | Chinese OCR | ¥5/M | ¥5/M |
| `kimi` | Moonshot | Document analysis | ¥12/M | ¥12/M |
| `kimi-128k` | Moonshot | Ultra-long context | ¥60/M | ¥60/M |

*Prices are approximate. Check provider websites for current pricing.*

See [docs/models.md](docs/models.md) for detailed comparison.

## Getting API Keys

| Provider | Sign-up Link | Notes |
|----------|-------------|-------|
| **DeepSeek** | [platform.deepseek.com](https://platform.deepseek.com) | Cheapest, $2 free credit |
| **Qwen (Alibaba)** | [dashscope.console.aliyun.com](https://dashscope.console.aliyun.com) | Requires Alibaba Cloud account |
| **GLM (Zhipu)** | [open.bigmodel.cn](https://open.bigmodel.cn) | GLM-4-Flash has free tier |
| **Kimi (Moonshot)** | [platform.moonshot.cn](https://platform.moonshot.cn) | 128K context specialist |

## Architecture

```
Your App → localhost:4000/v1/chat/completions (OpenAI format)
                    ↓
              LiteLLM Proxy (Docker)
                    ↓
    ┌──────┬──────┬──────┬──────┐
    ↓      ↓      ↓      ↓
DeepSeek  Qwen   GLM    Kimi
```

- **Zero external dependency** — SQLite, no PostgreSQL needed
- **Memory footprint** — ~300MB, runs on a $5 VPS
- **Your API keys** stay in your `.env` file
- **Your data** stays on your server

## FAQ

**Is this a hosted service?**
No. This is open-source software you deploy yourself. We don't see your data, your keys, or your traffic.

**Why not just use OpenRouter?**
If you're fine with a third party seeing your requests, OpenRouter is great. If you want data privacy, compliance, or just like owning your infra — use Chinai Gateway.

**Can I add more models?**
Yes. Edit `config.yaml` — LiteLLM supports 100+ providers. See [LiteLLM docs](https://docs.litellm.ai/docs/providers).

**Is this production-ready?**
LiteLLM (the engine underneath) is. Chinai Gateway is the batteries-included config layer. For high-traffic production, swap SQLite for PostgreSQL.

## License

MIT — do whatever you want. Just don't blame us if your AI goes rogue.

## Credits

Built on [LiteLLM](https://github.com/BerriAI/litellm), the open-source LLM proxy. This project adds pre-configured Chinese model support, bilingual docs, and a one-command deploy experience.
