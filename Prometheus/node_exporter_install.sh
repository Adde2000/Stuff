#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-latest}"
USER="node_exporter"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT


# Create dedicated node_exporter user without shell
if ! id -u "$USER" >/dev/null 2>&1; then
  useradd --system --no-create-home --shell /sbin/nologin "$USER"
fi


# Get latest Prometheus Node Exporter URL
if [[ "$VERSION" == "latest" ]]; then
  ARCHIVE_URL="$(curl -fsSL https://api.github.com/repos/prometheus/node_exporter/releases/latest \
    | grep browser_download_url \
    | grep linux-amd64 \
    | head -n1 \
    | cut -d '"' -f 4)"
else
  ARCHIVE_URL="https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz"
fi


# Download and extract tar
curl -fsSL "$ARCHIVE_URL" -o "$TMP_DIR/node_exporter.tar.gz"
tar -xzf "$TMP_DIR/node_exporter.tar.gz" -C "$TMP_DIR"

# Install to binary directory and set permissions
install -m 0755 "$TMP_DIR"/node_exporter-*.linux-amd64/node_exporter "$INSTALL_DIR/node_exporter"
chown "$USER:$USER" "$INSTALL_DIR/node_exporter"


# Create systemd service file running as node_exporter user
cat > "$SERVICE_FILE" <<'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


# Reload systemd, enable and start service and show status
systemctl daemon-reload
systemctl enable --now node_exporter
for i in {1..30}; do
  if systemctl is-active --quiet node_exporter && curl -fsS http://localhost:9100/metrics >/dev/null; then
    break
  fi
  sleep 1
done
systemctl status node_exporter --no-pager