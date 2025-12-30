#!/bin/bash
set -e

echo "============================================"
echo " Installing AWS CLI v2 & Docker on Ubuntu "
echo "============================================"

# Ensure script is run with sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root or with sudo"
  exit 1
fi

echo "➡ Updating system packages..."
apt update -y

echo "➡ Installing required utilities..."
apt install -y unzip curl ca-certificates gnupg lsb-release

# -----------------------------
# AWS CLI v2 Installation
# -----------------------------
echo "➡ Installing AWS CLI v2..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -o awscliv2.zip
./aws/install --update

echo "✅ AWS CLI installed successfully:"
aws --version

# Cleanup
rm -rf aws awscliv2.zip

# -----------------------------
# Docker Installation
# -----------------------------
echo "➡ Setting up Docker repository..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

echo "➡ Updating package index..."
apt update -y

echo "➡ Installing Docker Engine..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "➡ Enabling Docker service..."
systemctl enable docker
systemctl start docker

# -----------------------------
# Docker Post-Install Steps
# -----------------------------
USERNAME=${SUDO_USER:-$USER}
echo "➡ Adding user '$USERNAME' to docker group..."
usermod -aG docker "$USERNAME"

echo "✅ Docker installed successfully:"
docker --version

echo "➡ Testing Docker installation..."
docker run hello-world || true
sudo apt install python3-pip
echo "============================================"
echo " ✅ Installation Completed Successfully!"
echo " 🔁 Please log out and log back in OR reboot"
echo "    to use Docker without sudo."
echo "============================================"
