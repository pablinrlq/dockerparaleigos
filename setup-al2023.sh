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

echo ">> Atualizando pacotes..."
sudo dnf update -y

echo ">> Instalando Docker..."
sudo dnf install -y docker

echo ">> Habilitando e iniciando o serviço Docker..."
sudo systemctl enable --now docker

echo ">> Adicionando o usuário '$USER' ao grupo docker..."
sudo usermod -aG docker "$USER" || true

echo ">> Instalando o plugin docker compose (v2)..."
DOCKER_CLI_PLUGINS="/usr/local/lib/docker/cli-plugins"
sudo mkdir -p "$DOCKER_CLI_PLUGINS"
ARCH="$(uname -m)"
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${ARCH}" \
     -o "${DOCKER_CLI_PLUGINS}/docker-compose"
sudo chmod +x "${DOCKER_CLI_PLUGINS}/docker-compose"

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
