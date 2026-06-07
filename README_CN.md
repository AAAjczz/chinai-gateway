# Chinai Gateway

**一条命令，把 DeepSeek、Qwen、GLM、Kimi、ERNIE 统一成一个 OpenAI 兼容接口。**

自己部署，用自己的 Key，数据不经过第三方。

```bash
# 在线体验（无需部署）
curl -X POST https://chinaigateway.xyz/v1/chat/completions \
  -H "Authorization: Bearer sk-IxF6ZNzPH_M-4_LyxB8Dlg" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4-pro","messages":[{"role":"user","content":"你好"}]}'
```

> 演示 Key 受限——严格限速、$0.05 额度上限、仅提供 DeepSeek 模型。生产环境请[自行部署](#快速开始)。

## 为什么

国产大模型比国外便宜 10 倍以上。但每家平台注册、认证、API 格式都不一样。OpenRouter 解决了统一接入的问题——但它是闭源的，你的数据经过他们的服务器。

**Chinai Gateway** 是开源替代：预配置好的 LiteLLM 技术栈，5 分钟在自己的服务器上跑起来。

| | OpenRouter | Chinai Gateway |
|---|---|---|
| **部署** | 第三方托管 | **你自己的服务器** |
| **数据隐私** | 经过 OpenRouter | **不出你的服务器** |
| **国产模型配置** | 有，通用配置 | **预调优，中英双语文档** |
| **费用** | 平台加价 5.5% | **免费 (MIT)** |
| **源码** | 闭源 | **开源 (MIT)** |

## 快速开始

### 前提

- Docker & Docker Compose
- 至少一家模型提供商的 API Key

### 1. 克隆并配置

```bash
git clone https://github.com/AAAjczz/chinai-gateway.git
cd chinai-gateway
cp .env.example .env
# 编辑 .env —— 填入你的 API Key，并修改所有默认密码
```

> ⚠️ **不要跳过这一步。** `.env` 里有占位密码。使用默认值部署到公网，你的实例几分钟内就会被劫持。
>
> 生产环境请参考完整的[加固指南](docs/hardening.md)。

### 2. 启动

```bash
docker compose up -d
```

> 默认监听 `0.0.0.0:4000`。生产环境请在前面加 nginx 或 Caddy 做 TLS 终止。参见[安全](#安全)。

### 3. 调用

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer 你的MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-v4-pro",
    "messages": [{"role": "user", "content": "用一句话解释量子计算"}]
  }'
```

或用任意 OpenAI SDK：

```python
from openai import OpenAI

client = OpenAI(
    api_key="你的MASTER_KEY",
    base_url="http://localhost:4000/v1"
)

response = client.chat.completions.create(
    model="deepseek-v4-pro",
    messages=[{"role": "user", "content": "你好！"}]
)
print(response.choices[0].message.content)
```

### 4. 管理后台

浏览器打开 `http://localhost:4000/ui` —— 管理 API Key、设限流、看用量。

## 支持的模型

| 模型 | 厂商 | 优势 | 输入价格 | 输出价格 |
|------|------|------|---------|---------|
| `deepseek-v4-pro` | DeepSeek V4 | Agent 专用，1M 上下文 | ¥3/百万 | ¥6/百万 |
| `deepseek-v4-flash` | DeepSeek V4 | 轻量高速，思考模式 | ¥1/百万 | ¥2/百万 |
| `deepseek-chat` | DeepSeek V3 | 旧版——2026.07 下线 | ¥1/百万 | ¥2/百万 |
| `deepseek-reasoner` | DeepSeek R1 | 旧版——2026.07 下线 | ¥4/百万 | ¥16/百万 |
| `qwen-plus` | 阿里通义千问 | 中文理解 | ¥2/百万 | ¥6/百万 |
| `qwen-max` | 阿里通义千问 | 中文最强 | ¥20/百万 | ¥60/百万 |
| `qwen-vl-plus` | 阿里通义千问 | 图片理解 | ¥2/百万 | ¥6/百万 |
| `glm-4-plus` | 智谱 GLM | 工具调用 | ¥1/百万 | ¥4/百万 |
| `glm-4-flash` | 智谱 GLM | 快速+免费额度 | 免费 | 免费 |
| `glm-4v-plus` | 智谱 GLM | 中文 OCR | ¥5/百万 | ¥5/百万 |
| `kimi` | 月之暗面 | 文档分析 | ¥12/百万 | ¥12/百万 |
| `kimi-128k` | 月之暗面 | 超长上下文 | ¥60/百万 | ¥60/百万 |
| `ernie-4.0-turbo` | 百度文心 | 搜索增强中文 | ¥4/百万 | ¥12/百万 |
| `ernie-speed` | 百度文心 | 快速+免费额度 | 免费 | 免费 |

*价格仅供参考，以各平台官网为准。*

详见 [docs/models.md](docs/models.md) 查看详细对比。

## 获取 API Key

| 厂商 | 注册地址 | 备注 |
|------|---------|------|
| **DeepSeek** | [platform.deepseek.com](https://platform.deepseek.com) | 最便宜，注册送 $2 |
| **通义千问** | [dashscope.console.aliyun.com](https://dashscope.console.aliyun.com) | 需阿里云账号 |
| **智谱 GLM** | [open.bigmodel.cn](https://open.bigmodel.cn) | GLM-4-Flash 有免费额度 |
| **月之暗面 Kimi** | [platform.moonshot.cn](https://platform.moonshot.cn) | 长上下文专家 |
| **百度文心 ERNIE** | [console.bce.baidu.com/qianfan](https://console.bce.baidu.com/qianfan/ais/console/applicationConsole/application) | ERNIE-Speed 免费额度 |

## 架构

```
你的应用 → https://your-domain.com/v1/chat/completions
                    ↓
              nginx / Caddy (TLS 终止, 限速)
                    ↓
              LiteLLM Proxy (Docker, 127.0.0.1:4000)
                    ↓
    ┌──────┬──────┬──────┬──────┐
    ↓      ↓      ↓      ↓
DeepSeek  Qwen   GLM    Kimi    ERNIE
```

- **自包含**——Docker Compose + PostgreSQL 一条命令
- **轻量**——~430MB 内存，$5 VPS 就能跑
- **你的 Key** 留在你的 `.env` 文件里
- **你的数据** 不出你的服务器
- **默认安全**——网关只监听 `127.0.0.1`，不直接暴露

## 安全

### 在暴露到公网之前

1. **修改所有默认值。** `.env` 里有占位密码。在 `docker compose up` 之前务必替换 `LITELLM_MASTER_KEY`、`LITELLM_SALT_KEY`、`UI_PASSWORD` 和 `DB_PASSWORD`。
2. **前面加反向代理。** LiteLLM 监听 4000 端口。不要直接暴露到公网。用 nginx 或 Caddy 做 TLS 终止。
3. **防火墙只留 443。** VPS 只对外开放 80 和 443 端口。
4. **定期轮换 master key。** master key 是 root 权限。在管理后台为应用创建有权限范围的 key。

### 信任边界

- **你 → 你的服务器**：HTTPS，传输加密
- **你的服务器 → 模型厂商**：HTTPS，API Key 认证
- **API Key**：存在你的 `.env` 文件里，不会发给我们（我们不提供服务）

### 日志记录了什么

LiteLLM 默认在 PostgreSQL 中记录请求元数据（模型、token 数、延迟）。这些数据保存在你自己的服务器上。请求体默认不记录，除非你手动开启。在[管理后台](http://localhost:4000/ui)可以配置。

### 报告漏洞

发现安全问题？见 [SECURITY.md](SECURITY.md) 了解如何私下报告。

### 生产加固

部署到生产环境？参考[加固指南](docs/hardening.md)——反向代理、防火墙、密钥轮换、备份。

## 常见问题

**这是托管服务吗？**
不是。这是给你自己部署的开源软件。我们看不到你的数据、你的 Key、你的流量。

**和 OpenRouter 有什么区别？**
OpenRouter 是第三方托管服务，数据经过他们。我们是开源软件，你完全掌控。

**能加更多模型吗？**
能。编辑 `config.yaml`——LiteLLM 支持 100+ 提供商。参考 [LiteLLM 文档](https://docs.litellm.ai/docs/providers)。

**能用于生产环境吗？**
底层 LiteLLM 已生产可用，搭配 PostgreSQL 数据持久化。

## 许可

MIT —— 随便用，AI 造反了别找我。
