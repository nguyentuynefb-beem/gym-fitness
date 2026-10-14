#!/usr/bin/env bash
set -euo pipefail

SSL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${SSL_DIR}"

echo "Generating self-signed SSL certificate for localhost and 127.0.0.1..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "${SSL_DIR}/server.key" \
  -out "${SSL_DIR}/server.crt" \
  -subj "/C=VN/ST=Hanoi/L=Hanoi/O=TitanFitness/OU=IT/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

chmod 644 "${SSL_DIR}/server.crt"
chmod 644 "${SSL_DIR}/server.key"
echo "SSL certificates successfully generated at ${SSL_DIR}"
