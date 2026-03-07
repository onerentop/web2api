FROM python:3.12-slim

ARG FINGERPRINT_CHROMIUM_URL="https://github.com/adryfish/fingerprint-chromium/releases/download/142.0.7444.175/ungoogled-chromium-142.0.7444.175-1-x86_64_linux.tar.xz"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    WEB2API_DATA_DIR=/data \
    HOME=/data

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    xvfb \
    xauth \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libfontconfig1 \
    libgbm1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libu2f-udev \
    libvulkan1 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    libxrender1 \
    libxshmfence1 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L --fail "${FINGERPRINT_CHROMIUM_URL}" -o /tmp/fingerprint-chromium.tar.xz \
    && mkdir -p /opt/fingerprint-chromium \
    && tar -xf /tmp/fingerprint-chromium.tar.xz -C /opt/fingerprint-chromium --strip-components=1 \
    && rm -f /tmp/fingerprint-chromium.tar.xz

COPY pyproject.toml /tmp/pyproject.toml
RUN python - <<'PY'
import subprocess
import tomllib

with open("/tmp/pyproject.toml", "rb") as f:
    deps = tomllib.load(f)["project"]["dependencies"]

subprocess.check_call(["pip", "install", "--no-cache-dir", *deps])
PY

COPY . /app

RUN chmod +x /app/docker/entrypoint.sh

VOLUME ["/data"]
EXPOSE 9000

ENTRYPOINT ["/app/docker/entrypoint.sh"]
