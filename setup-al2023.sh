#!/usr/bin/env bash
#
# Instala Docker + plugin Compose numa instância Amazon Linux 2023
# e sobe a mini aplicação.
#
# Uso (dentro da instância, no diretório do projeto):
#   chmod +x setup-al2023.sh
#   ./setup-al2023.sh
#
set -euo pipefail

# Usuário real mesmo se o script for executado com sudo
TARGET_USER="${SUDO_USER:-$USER}"

echo ">> Atualizando pacotes..."
sudo dnf update -y

echo ">> Instalando Docker..."
sudo dnf install -y docker

echo ">> Habilitando e iniciando o serviço Docker..."
sudo systemctl enable --now docker

echo ">> Adicionando o usuário '$TARGET_USER' ao grupo docker..."
sudo usermod -aG docker "$TARGET_USER" || true

DOCKER_CLI_PLUGINS="/usr/local/lib/docker/cli-plugins"
sudo mkdir -p "$DOCKER_CLI_PLUGINS"

# compose usa nomes tipo 'x86_64'; buildx usa 'amd64'/'arm64'
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  BARCH="amd64" ;;
  aarch64) BARCH="arm64" ;;
  *)       BARCH="$ARCH" ;;
esac

echo ">> Instalando o plugin docker compose (v2)..."
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${ARCH}" \
     -o "${DOCKER_CLI_PLUGINS}/docker-compose"
sudo chmod +x "${DOCKER_CLI_PLUGINS}/docker-compose"

echo ">> Instalando o plugin docker buildx (exigido pelo 'compose build')..."
BUILDX_TAG="$(curl -fsSL https://api.github.com/repos/docker/buildx/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)"
sudo curl -SL "https://github.com/docker/buildx/releases/download/${BUILDX_TAG}/buildx-${BUILDX_TAG}.linux-${BARCH}" \
     -o "${DOCKER_CLI_PLUGINS}/docker-buildx"
sudo chmod +x "${DOCKER_CLI_PLUGINS}/docker-buildx"

echo ">> Versões instaladas:"
sudo docker --version
sudo docker compose version || true

echo ">> Construindo e subindo a aplicação..."
sudo docker compose up -d --build

echo
echo "======================================================================"
echo " Pronto! A aplicação está no ar na porta 8080."
echo " Teste local:   curl http://localhost:8080/health"
echo " Do navegador:  http://<IP-PUBLICO-DA-EC2>:8080"
echo
echo " Libere a porta 8080/TCP no Security Group da instância."
echo " Faça 'logout/login' (ou 'newgrp docker') para usar docker sem sudo."
echo "======================================================================"
