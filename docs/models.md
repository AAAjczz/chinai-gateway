# Model Comparison

## Pricing (per 1M tokens)

| Model | Input | Output | Cached Input | Free Tier |
|-------|-------|--------|--------------|-----------|
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

*USD equivalents: roughly divide CNY by 7.*

## Capability Matrix

| Model | Context | Vision | Function Calling | Streaming | Best For |
|-------|---------|--------|------------------|-----------|----------|
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

## Recommendation by Task

| Task | Best Model | Budget Model |
|------|-----------|--------------|
| General chat (EN) | `deepseek-chat` | `deepseek-chat` |
| General chat (CN) | `qwen-max` | `qwen-plus` |
| Coding | `deepseek-chat` | `deepseek-chat` |
| Math / Logic | `deepseek-reasoner` | `deepseek-chat` |
| Translation | `qwen-plus` | `glm-4-flash` |
| Summarization | `kimi-128k` | `deepseek-chat` |
| Tool use / Agents | `glm-4-plus` | `deepseek-chat` |
| Image understanding | `qwen-vl-plus` | — |
| Document OCR (CN) | `glm-4v-plus` | — |
| Long document QA | `kimi-128k` | `qwen-plus` |
