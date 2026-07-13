# Mini App · Docker + Amazon Linux 2023

Mini aplicação web em **Python/Flask**, empacotada em **Docker**, pronta para rodar
numa instância **Amazon Linux 2023** (EC2).

Mostra uma página de status e expõe endpoints de health check e API JSON.

## Estrutura

```
mini-app-docker/
├── app.py               # Aplicação Flask
├── requirements.txt     # Dependências Python
├── Dockerfile           # Build da imagem (usuário sem root + healthcheck)
├── docker-compose.yml   # Orquestração de 1 serviço
├── .dockerignore
├── setup-al2023.sh      # Instala Docker no AL2023 e sobe o app
└── README.md
```

## Endpoints

| Rota        | Descrição                          |
|-------------|------------------------------------|
| `/`         | Página HTML de status              |
| `/health`   | Health check (`{"status":"ok"}`)   |
| `/api/info` | Infos do app em JSON               |

---

## Como rodar na instância Amazon Linux 2023

### 1. Envie os arquivos para a EC2

```bash
# do seu computador
scp -i sua-chave.pem -r mini-app-docker ec2-user@<IP-PUBLICO>:~
```

Ou clone/copie os arquivos direto na instância.

### 2. Conecte e execute o script

```bash
ssh -i sua-chave.pem ec2-user@<IP-PUBLICO>
cd mini-app-docker
chmod +x setup-al2023.sh
./setup-al2023.sh
```

O script instala o Docker, habilita o serviço, instala o Compose v2 e
sobe a aplicação com `docker compose up -d --build`.

### 3. Libere a porta no Security Group

No console da AWS → EC2 → Security Groups → regras de entrada (inbound),
adicione: **Custom TCP · porta 8080 · origem 0.0.0.0/0** (ou seu IP).

### 4. Acesse

```
http://<IP-PUBLICO-DA-EC2>:8080
```

---

## Rodando manualmente (sem o script)

```bash
# Instalar Docker no AL2023
sudo dnf install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # relogar depois

# Opção A: só Docker
docker build -t mini-app-docker .
docker run -d -p 8080:8080 --name mini-app mini-app-docker

# Opção B: Docker Compose
docker compose up -d --build
```

## Comandos úteis

```bash
docker ps                      # containers rodando
docker logs -f mini-app        # ver logs
curl http://localhost:8080/health
docker compose down            # parar e remover
```

## Rodar no seu Windows para testar antes (opcional)

Com Docker Desktop instalado:

```powershell
cd mini-app-docker
docker compose up --build
# abra http://localhost:8080
```
