# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest `master` | ✅ |
| Tagged releases (when available) | ✅ |
| Older commits | ❌ |

We're a small project. Security fixes go to `master` immediately.

## Reporting a Vulnerability

**Do not open a public issue for security vulnerabilities.**

Email the maintainer directly: [security@chinaigateway.xyz](mailto:security@chinaigateway.xyz)

If you don't get a response within 48 hours, open a public issue — we may have missed your email.

**What to include:**
- Steps to reproduce
- Affected version / commit hash
- Impact assessment (data exposure? privilege escalation? denial of service?)
- Any suggested fix (optional but appreciated)

We aim to acknowledge within 24 hours and patch within 72.

## Disclosure Policy

- Reporter gets credited in the release notes (unless you prefer anonymity)
- CVE requested if the impact warrants it
- Public disclosure after fix is merged and deployed

## Threat Model

### What we protect

1. **Your API keys** — stored in `.env`, loaded into LiteLLM as environment variables. Never sent to us.
2. **Your request data** — transits your server only. We don't run a hosted service.
3. **Your master key** — root credential for the gateway. Compromise = full control.

### What we assume

- **You trust your VPS.** The gateway runs on your infrastructure. If your host is compromised, no software-level hardening helps.
- **You trust the model providers you configure.** Requests are forwarded to DeepSeek/Qwen/GLM/Kimi/ERNIE. Their privacy policies apply to the data you send them.
- **You trust LiteLLM.** The gateway runs LiteLLM in Docker. LiteLLM is MIT-licensed and maintained by BerriAI. We review their releases before bumping the image tag.

### What we do NOT protect against

- Physical access to your server
- Root compromise of your host OS
- Supply chain attacks on Docker Hub or PyPI (we pin image SHAs where possible)

### Attack surface

| Component | Exposure | Mitigation |
|-----------|----------|------------|
| LiteLLM (port 4000) | Localhost only by default | Bind `127.0.0.1`, put nginx/Caddy in front |
| PostgreSQL | Internal Docker network only | No host port exposed |
| Admin UI (/ui) | Behind LiteLLM auth | Master key + UI password |
| Nginx/Caddy | Public (443) | TLS termination, rate limiting |

## Security Best Practices for Deployers

1. **Change all defaults before `docker compose up`.** Master key, salt key, DB password, UI password.
2. **Put a reverse proxy in front.** See [docs/hardening.md](docs/hardening.md) for nginx example.
3. **Firewall everything except 80/443.** LiteLLM's port 4000 should never face the internet directly.
4. **Create scoped API keys for applications.** Don't hand out the master key to clients.
5. **Rotate your master key regularly.**
6. **Keep LiteLLM updated.** Check [their releases](https://github.com/BerriAI/litellm/releases) and bump `docker-compose.yml` accordingly.
7. **Monitor the Admin UI** for unusual spend patterns or unknown API keys.
