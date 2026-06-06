# Chinai Gateway

**一条命令，把 DeepSeek、Qwen、GLM、Kimi 统一成一个 OpenAI 兼容接口。**

自己部署，用自己的 Key，数据不经过第三方。

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
git clone https://github.com/YOUR_USER/chinai-gateway.git
cd chinai-gateway
cp .env.example .env
# 编辑 .env —— 填入你的 API Key
```

### 2. 启动

```bash
docker compose up -d
```

### 3. 调用

```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer 你的MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
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
    model="deepseek-chat",
    messages=[{"role": "user", "content": "你好！"}]
)
print(response.choices[0].message.content)
```

### 4. 管理后台

浏览器打开 `http://localhost:4000/ui` —— 管理 API Key、设限流、看用量。

## 支持的模型

| 模型 | 厂商 | 优势 | 输入价格 | 输出价格 |
|------|------|------|---------|---------|
| `deepseek-chat` | DeepSeek V3 | 性价比之王 | ¥1/百万 | ¥2/百万 |
| `deepseek-reasoner` | DeepSeek R1 | 数学/代码/推理 | ¥4/百万 | ¥16/百万 |
| `qwen-plus` | 阿里通义千问 | 中文理解 | ¥2/百万 | ¥6/百万 |
| `qwen-max` | 阿里通义千问 | 中文最强 | ¥20/百万 | ¥60/百万 |
| `qwen-vl-plus` | 阿里通义千问 | 图片理解 | ¥2/百万 | ¥6/百万 |
| `glm-4-plus` | 智谱 GLM | 工具调用 | ¥1/百万 | ¥4/百万 |
| `glm-4-flash` | 智谱 GLM | 快速+免费额度 | 免费 | 免费 |
| `glm-4v-plus` | 智谱 GLM | 中文 OCR | ¥5/百万 | ¥5/百万 |
| `kimi` | 月之暗面 | 文档分析 | ¥12/百万 | ¥12/百万 |
| `kimi-128k` | 月之暗面 | 超长上下文 | ¥60/百万 | ¥60/百万 |

*价格仅供参考，以各平台官网为准。*

详见 [docs/models.md](docs/models.md) 查看详细对比。

## 获取 API Key

| 厂商 | 注册地址 | 备注 |
|------|---------|------|
| **DeepSeek** | [platform.deepseek.com](https://platform.deepseek.com) | 最便宜，注册送 $2 |
| **通义千问** | [dashscope.console.aliyun.com](https://dashscope.console.aliyun.com) | 需阿里云账号 |
| **智谱 GLM** | [open.bigmodel.cn](https://open.bigmodel.cn) | GLM-4-Flash 有免费额度 |
| **月之暗面 Kimi** | [platform.moonshot.cn](https://platform.moonshot.cn) | 长上下文专家 |

## 常见问题

**这是托管服务吗？**
不是。这是给你自己部署的开源软件。我们看不到你的数据、你的 Key、你的流量。

**和 OpenRouter 有什么区别？**
OpenRouter 是第三方托管服务，数据经过他们。我们是开源软件，你完全掌控。

**能加更多模型吗？**
能。编辑 `config.yaml`——LiteLLM 支持 100+ 提供商。参考 [LiteLLM 文档](https://docs.litellm.ai/docs/providers)。

**能用于生产环境吗？**
底层 LiteLLM 已经生产可用。高流量场景建议把 SQLite 换成 PostgreSQL。

## 许可

MIT —— 随便用，AI 造反了别找我。
