# chinai-gateway 安全加固指南

> 最后更新：2026-06-11 — Yakit + nuclei 自检补充

## 自检发现的问题（已修复）

| # | 漏洞 | 严重级别 | 状态 | 修复方式 |
|---|------|---------|------|---------|
| 1 | `/v1/models` 公开列出所有模型及详情 | Medium | ✅ | `config.yaml`: `disable_model_list_endpoint: true` |
| 2 | `/metrics` 认证错误信息过于详细（泄露 Bearer 格式） | Low | ✅ | `config.yaml`: `require_auth_for_metrics_endpoint: true` |
| 3 | 错误信息泄露 provider 内部配置 | Low | ✅ | `config.yaml`: `hide_model_details: true` + `redact_user_key_api_info: true` |
| 4 | Swagger API 文档公开（`/`、`/openapi.json`） | Medium | ⚠️ Nginx | `nginx-chinai.conf` 封锁 `/`、`/docs`、`/openapi.json` |
| 5 | 10 个安全响应头缺失 | Medium | ⚠️ Nginx | `nginx-chinai.conf` 添加 HSTS、CSP 等 10 个响应头 |
| 6 | `/metrics` 外网可访问 | Medium | ⚠️ Nginx | Nginx 限制为内网 IP |
| 7 | `/health` 返回 401（无需认证，但泄露 uvicorn 版本） | Low | ℹ️ 不修 | 健康检查端点，无害 |

## 检测工具

| 工具 | 用途 | 结果 |
|------|------|------|
| Yakit Web Fuzzer | 路径爆破 chinai-gateway | 发现 `/` (Swagger)、`/metrics`、`/config` |
| nuclei | 2442 个模板扫描 | 发现 10 个缺失安全头 |
| Yakit MITM | 流量拦截和修改 | 验证了请求修改→重放流程 |

## config.yaml 安全配置（已应用）

```yaml
general_settings:
  disable_model_list_endpoint: true   # 模型列表需认证

litellm_settings:
  require_auth_for_metrics_endpoint: true  # /metrics 需认证
  redact_user_key_api_info: true           # 隐藏 API key 详情
  hide_model_details: true                 # 隐藏 provider 配置详情
  set_verbose: false                       # 关闭详细日志
  drop_params: true                        # 丢弃未知参数
```

---

# 以下为原部署加固内容

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

## 2. Reverse Proxy with TLS + Security Headers

使用 `nginx-chinai.conf`（项目根目录），已包含：
- TLS 1.2/1.3 配置
- 10 个安全响应头（HSTS、CSP、X-Frame-Options 等）
- 速率限制
- `/`、`/docs`、`/openapi.json`、`/redoc` 路径封锁
- `/metrics` 内网限制
- 服务端版本信息隐藏

### 部署（生产环境）

```bash
cp nginx-chinai.conf /etc/nginx/sites-available/chinai
ln -s /etc/nginx/sites-available/chinai /etc/nginx/sites-enabled/
# 改 server_name 和 ssl_certificate 路径
vim /etc/nginx/sites-available/chinai
# TLS 证书
certbot --nginx -d api.your-domain.com
# 重载
nginx -t && systemctl reload nginx
```

### 本地开发
无需 Nginx——LiteLLM 绑定 `127.0.0.1:4000`，外网不可达。

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

```yaml
general_settings:
  rpm_limit: 500           # 全局每分钟请求上限
  rpm_limit_per_key: 100   # 单 key 每分钟上限
```

## 5. Keep LiteLLM Updated

Check [LiteLLM releases](https://github.com/BerriAI/litellm/releases) monthly.

```bash
docker compose pull litellm
docker compose up -d
```

## 6. Database Backups

```bash
# Daily cron job
0 3 * * * cd /opt/chinai-gateway && docker compose exec -T db pg_dump -U litellm litellm > backups/$(date +\%Y\%m\%d).sql
```

## 7. Audit Your Keys

每月去 Admin UI → Keys 页面，删除不认识的和 90 天以上的 key。

## Quick Checklist

- [ ] Firewall: only 80/443 open
- [ ] Nginx + TLS with `nginx-chinai.conf`
- [ ] Swagger/docs paths blocked at Nginx level
- [ ] Model list hidden via `disable_model_list_endpoint`
- [ ] Metrics endpoint restricted to internal
- [ ] Security headers present (验证: `nuclei -t ~/nuclei-templates/http/misconfiguration/`)
- [ ] `.env`: all defaults changed
- [ ] Master key: never shared
- [ ] Scoped keys: created for each application
- [ ] Rate limiting: enabled
- [ ] Backups: scheduled
- [ ] LiteLLM: up to date

## 部署后自检

```bash
# Swagger 应该 404
curl -o /dev/null -w "%{http_code}\n" https://api.your-domain.com/openapi.json

# Model list 应该 401
curl -o /dev/null -w "%{http_code}\n" https://api.your-domain.com/v1/models

# Metrics 应该 403（Nginx 封锁）
curl -o /dev/null -w "%{http_code}\n" https://api.your-domain.com/metrics

# 应该有 HSTS 头
curl -I https://api.your-domain.com/health | grep -i strict-transport-security

# nuclei 自动化扫描
nuclei -u https://api.your-domain.com -t nuclei-templates/http/misconfiguration/ -silent
```
