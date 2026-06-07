# Model Comparison

## Pricing (per 1M tokens)

| Model | Input | Output | Cached Input | Free Tier |
|-------|-------|--------|--------------|-----------|
| `deepseek-v4-pro` | ¥3.00 | ¥6.00 | ¥0.025 | No |
| `deepseek-v4-flash` | ¥1.00 | ¥2.00 | — | No |
| `deepseek-chat` | ¥1.00 | ¥2.00 | ¥0.25 | No |
| `deepseek-reasoner` | ¥4.00 | ¥16.00 | ¥1.00 | No |
| `qwen-plus` | ¥2.00 | ¥6.00 | — | No |
| `qwen-max` | ¥20.00 | ¥60.00 | — | No |
| `qwen-vl-plus` | ¥2.00 | ¥6.00 | — | No |
| `glm-4-plus` | ¥1.00 | ¥4.00 | — | No |
| `glm-4-flash` | Free | Free | — | Yes |
| `glm-4v-plus` | ¥5.00 | ¥5.00 | — | No |
| `kimi` (8K) | ¥12.00 | ¥12.00 | — | No |
| `kimi-128k` | ¥60.00 | ¥60.00 | — | No |
| `ernie-4.0-turbo` | ¥4.00 | ¥12.00 | — | No |
| `ernie-speed` | Free | Free | — | Yes |

*USD equivalents: roughly divide CNY by 7.*

## Capability Matrix

| Model | Context | Vision | Function Calling | Streaming | Best For |
|-------|---------|--------|------------------|-----------|----------|
| `deepseek-v4-pro` | 1M | ❌ | ✅ | ✅ | Agent, code, reasoning |
| `deepseek-v4-flash` | 1M | ❌ | ✅ | ✅ | General, budget, speed |
| `deepseek-chat` | 64K | ❌ | ✅ | ✅ | General chat |
| `deepseek-reasoner` | 64K | ❌ | ❌ | ✅ | Math, code, logic |
| `qwen-plus` | 128K | ❌ | ✅ | ✅ | Chinese text |
| `qwen-max` | 32K | ❌ | ✅ | ✅ | Best Chinese |
| `qwen-vl-plus` | 32K | ✅ | ❌ | ✅ | Image analysis |
| `glm-4-plus` | 128K | ❌ | ✅ | ✅ | Tool calling |
| `glm-4-flash` | 128K | ❌ | ✅ | ✅ | Speed, free tier |
| `glm-4v-plus` | 16K | ✅ | ✅ | ✅ | Chinese OCR |
| `kimi` | 8K | ❌ | ✅ | ✅ | File reading |
| `kimi-128k` | 128K | ❌ | ✅ | ✅ | Long docs |
| `ernie-4.0-turbo` | 8K | ❌ | ✅ | ✅ | Search-enhanced Chinese |
| `ernie-speed` | 128K | ❌ | ✅ | ✅ | Fast, free tier |

## Recommendation by Task

| Task | Best Model | Budget Model |
|------|-----------|--------------|
| General chat (EN) | `deepseek-v4-pro` | `deepseek-v4-flash` |
| General chat (CN) | `qwen-max` | `qwen-plus` |
| Coding | `deepseek-v4-pro` | `deepseek-v4-flash` |
| Math / Logic | `deepseek-v4-pro` | `deepseek-v4-flash` |
| Agent / Tool use | `deepseek-v4-pro` | `glm-4-plus` |
| Translation | `qwen-plus` | `glm-4-flash` |
| Summarization | `kimi-128k` | `deepseek-chat` |
| Tool use / Agents | `glm-4-plus` | `deepseek-chat` |
| Image understanding | `qwen-vl-plus` | — |
| Document OCR (CN) | `glm-4v-plus` | — |
| Long document QA | `kimi-128k` | `qwen-plus` |
| Search-enhanced query | `ernie-4.0-turbo` | `ernie-speed` |
