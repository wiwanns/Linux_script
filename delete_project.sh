#!/bin/bash
set -e

# =========================================================
# CHECK ROOT
# =========================================================
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

# =========================================================
# DOMAIN INPUT
# =========================================================
PROJECT_DOMAIN="$1"

if [ -z "$PROJECT_DOMAIN" ]; then
  echo "Usage: $0 yourdomain.com"
  exit 1
fi

PROJECT_NAME=$(echo "$PROJECT_DOMAIN" | cut -d '.' -f1)

BASE_PATH="/var/www/vhost-live/$PROJECT_NAME"
CONFIG_DIR="$BASE_PATH/config"
PROJECT_NGINX_CONF="$CONFIG_DIR/include.conf"
MAIN_NGINX_CONF="/etc/nginx/sites-available/ZZzmahendra.conf"
SERVICE_FILE="/etc/systemd/system/$PROJECT_NAME.service"

echo ""
echo "======================================"
echo "Deleting project: $PROJECT_DOMAIN"
echo "======================================"

# =========================================================
# STOP & REMOVE SYSTEMD SERVICE (if exists)
# =========================================================
if [ -f "$SERVICE_FILE" ]; then
    echo "Stopping systemd service..."
    systemctl stop "$PROJECT_NAME" || true
    systemctl disable "$PROJECT_NAME" || true
    rm -f "$SERVICE_FILE"
    systemctl daemon-reload
    echo "Service removed."
else
    echo "No systemd service found."
fi

# =========================================================
# REMOVE INCLUDE LINE FROM MAIN NGINX FILE
# =========================================================
if [ -f "$MAIN_NGINX_CONF" ]; then
    echo "Removing nginx include entry..."
    sed -i "\|$PROJECT_NGINX_CONF|d" "$MAIN_NGINX_CONF"
fi

# =========================================================
# DELETE PROJECT DIRECTORY (includes config/include.conf)
# =========================================================
if [ -d "$BASE_PATH" ]; then
    rm -rf "$BASE_PATH"
    echo "Project directory removed: $BASE_PATH"
else
    echo "Project directory not found."
fi

# =========================================================
# RELOAD NGINX SAFELY
# =========================================================
if nginx -t; then
    systemctl reload nginx
    echo "Nginx reloaded successfully."
else
    echo "⚠ Nginx config test failed. Please check manually."
fi

echo ""
echo "======================================"
echo "Project $PROJECT_DOMAIN deleted successfully."
echo "======================================"
echo ""
