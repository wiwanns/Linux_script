#!/bin/bash
set -e

echo "Removing all .NET SDKs..."
sudo apt remove --purge -y 'dotnet-*'

echo "Removing ASP.NET runtimes..."
sudo apt remove --purge -y 'aspnetcore-*'

echo "Removing .NET host..."
sudo apt remove --purge -y 'netstandard-*'

echo "Cleaning unused packages..."
sudo apt autoremove -y
sudo apt autoclean

echo "Removing Microsoft repository..."
sudo rm -f /etc/apt/sources.list.d/microsoft-prod.list
sudo rm -f /etc/apt/trusted.gpg.d/microsoft.gpg

echo "Removing leftover folders..."
sudo rm -rf /usr/share/dotnet
sudo rm -rf /etc/dotnet
sudo rm -rf ~/.dotnet

echo "Updating package list..."
sudo apt update -y

echo "All .NET versions completely removed!"
