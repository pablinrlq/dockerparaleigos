<div align="center">

# Docker para Leigos

**Uma aplicação Flask em container, do zero até rodando numa EC2 com Amazon Linux 2023.**

![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=flat-square&logo=flask&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![Amazon EC2](https://img.shields.io/badge/Amazon_EC2-FF9900?style=flat-square&logo=amazonec2&logoColor=white)

</div>

## Sobre

Fiz este projeto para mostrar o caminho completo de um container sem pular etapa:
escrever a aplicação, empacotar em imagem, subir com Compose e publicar numa instância
na AWS com um script que prepara a máquina sozinho.

A aplicação é pequena de propósito: uma página de status e dois endpoints JSON.
O foco está no empacotamento e na publicação.

| Rota | Retorno |
| --- | --- |
| `/` | Página HTML de status, com tempo no ar |
| `/health` | Health check: `{"status": "ok"}` |
| `/api/info` | Informações do app em JSON |

**Boas práticas no Dockerfile:** usuário sem root dentro do container, `HEALTHCHECK`
configurado e `.dockerignore` para manter a imagem enxuta.

## Rodando no seu computador

Com o [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado:

```bash
git clone https://github.com/pablinrlq/dockerparaleigos.git
cd dockerparaleigos
docker compose up --build
```

Abra <http://localhost:8080>.

## Publicando numa EC2 (Amazon Linux 2023)

**1. Copie o projeto para a instância**

```bash
ssh -i sua-chave.pem ec2-user@IP-PUBLICO
sudo dnf install -y git
git clone https://github.com/pablinrlq/dockerparaleigos.git
cd dockerparaleigos
```

**2. Rode o script de instalação**

```bash
chmod +x setup-al2023.sh
./setup-al2023.sh
```

Ele instala o Docker, ativa o serviço, instala o Compose v2 e sobe a aplicação com
`docker compose up -d --build`.

**3. Libere a porta no Security Group**

No console da AWS: EC2 › Security Groups › regras de entrada › **TCP 8080** liberado
para o seu IP (ou `0.0.0.0/0` para qualquer um).

**4. Acesse** `http://IP-PUBLICO:8080`

<details>
<summary>Instalando sem o script</summary>

```bash
sudo dnf install -y docker
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # saia e entre de novo na sessão

# só Docker
docker build -t dockerparaleigos .
docker run -d -p 8080:8080 --name mini-app dockerparaleigos

# ou com Compose
docker compose up -d --build
```

</details>

## Comandos úteis

```bash
docker ps                          # containers rodando
docker logs -f mini-app            # logs em tempo real
curl http://localhost:8080/health  # testa o health check
docker compose down                # para e remove
```

## Estrutura

```
├── app.py               aplicação Flask
├── requirements.txt     dependências Python
├── Dockerfile           imagem com usuário sem root e healthcheck
├── docker-compose.yml   um serviço, porta 8080
├── setup-al2023.sh      prepara o Amazon Linux 2023 e sobe o app
└── .dockerignore
```

---

<div align="center">
<sub>Feito por <a href="https://github.com/pablinrlq">Pablo Moises</a></sub>
</div>
