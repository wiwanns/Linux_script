#!/bin/bash
set -e

# =========================================================
# CHECK ROOT
# =========================================================
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "======================================"
echo "MSSQL Full Removal Script"
echo "======================================"

# =========================================================
# Detect if MSSQL Installed
# =========================================================
if ! dpkg -l | grep -q mssql-server; then
    echo "No MSSQL Server installation detected."
else
    echo "MSSQL Server detected."

    # Stop Service
    if systemctl list-units --full -all | grep -q mssql-server; then
        echo "Stopping SQL Server service..."
        systemctl stop mssql-server || true
        systemctl disable mssql-server || true
    fi

    # Remove Packages
    echo "Removing MSSQL Server packages..."
    apt purge -y mssql-server mssql-tools unixodbc-dev || true
fi

# =========================================================
# Remove Remaining MSSQL Packages (Auto Detect)
# =========================================================
EXTRA_PKGS=$(dpkg -l | awk '/mssql|msodbcsql/ {print $2}')
if [ ! -z "$EXTRA_PKGS" ]; then
    echo "Removing extra Microsoft SQL related packages..."
    apt purge -y $EXTRA_PKGS || true
fi

apt autoremove -y
apt autoclean

# =========================================================
# Remove Repositories
# =========================================================
echo "Removing Microsoft repositories..."
rm -f /etc/apt/sources.list.d/mssql-server.list
rm -f /etc/apt/sources.list.d/msprod.list
rm -f /etc/apt/sources.list.d/microsoft-prod.list

# =========================================================
# Remove GPG Keys
# =========================================================
rm -f /etc/apt/keyrings/microsoft.gpg

apt update -y

# =========================================================
# Optional: Remove Data Directory
# =========================================================
if [ -d "/var/opt/mssql" ]; then
    echo ""
    read -p "Do you want to DELETE all SQL data files? (yes/no): " CONFIRM
    if [ "$CONFIRM" == "yes" ]; then
        echo "Deleting /var/opt/mssql ..."
        rm -rf /var/opt/mssql
    else
        echo "Data directory preserved."
    fi
fi

# =========================================================
# Remove Inventory File
# =========================================================
if [ -f "/etc/.sql" ]; then
    rm -f /etc/.sql
fi

# =========================================================
# Final Verification
# =========================================================
if dpkg -l | grep -q mssql; then
    echo "Some MSSQL components still exist."
else
    echo ""
    echo "======================================"
    echo "MSSQL Completely Removed Successfully!"
    echo "======================================"
fi
