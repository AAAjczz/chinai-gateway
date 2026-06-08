FROM ghcr.io/berriai/litellm:main-stable

LABEL org.opencontainers.image.title="Chinai Gateway"
LABEL org.opencontainers.image.description="One command to unify DeepSeek, Qwen, GLM, Kimi, ERNIE behind an OpenAI-compatible API. Self-hosted."
LABEL org.opencontainers.image.source="https://github.com/AAAjczz/chinai-gateway"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.vendor="xzht"
LABEL org.opencontainers.image.documentation="https://github.com/AAAjczz/chinai-gateway"

# Pre-bake the Chinai Gateway model config
# All API keys use os.environ/ — no secrets in the image
COPY config.yaml /app/config.yaml

# Default: run with baked-in config (can be overridden)
CMD ["--config=/app/config.yaml"]
