import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify, render_template_string

app = Flask(__name__)

START_TIME = datetime.now(timezone.utc)

PAGE = """
<!doctype html>
<html lang="pt-br">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mini App · Docker + Amazon Linux 2023</title>
  <style>
    :root { color-scheme: light dark; }
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
           margin: 0; min-height: 100vh; display: grid; place-items: center;
           background: linear-gradient(135deg, #232f3e, #ff9900); color: #fff; }
    .card { background: rgba(0,0,0,.35); backdrop-filter: blur(6px);
            padding: 2.5rem 3rem; border-radius: 16px; box-shadow: 0 10px 40px rgba(0,0,0,.4);
            max-width: 520px; }
    h1 { margin: 0 0 .25rem; font-size: 1.6rem; }
    .sub { opacity: .8; margin: 0 0 1.5rem; }
    dl { display: grid; grid-template-columns: auto 1fr; gap: .5rem 1rem; margin: 0; }
    dt { opacity: .75; }
    dd { margin: 0; font-weight: 600; word-break: break-all; }
    a { color: #ffd58a; }
    .pill { display: inline-block; background:#00c853; color:#022; font-weight:700;
            padding:.15rem .6rem; border-radius:999px; font-size:.8rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 Mini App rodando <span class="pill">OK</span></h1>
    <p class="sub">Flask em contêiner Docker · Amazon Linux 2023</p>
    <dl>
      <dt>Hostname (contêiner)</dt><dd>{{ hostname }}</dd>
      <dt>Hora do servidor (UTC)</dt><dd>{{ now }}</dd>
      <dt>Uptime</dt><dd>{{ uptime }}</dd>
      <dt>Versão do app</dt><dd>{{ version }}</dd>
    </dl>
    <p style="margin-top:1.5rem">Health check em <a href="/health">/health</a> · API em <a href="/api/info">/api/info</a></p>
  </div>
</body>
</html>
"""


def _uptime():
    delta = datetime.now(timezone.utc) - START_TIME
    total = int(delta.total_seconds())
    h, rem = divmod(total, 3600)
    m, s = divmod(rem, 60)
    return f"{h:02d}:{m:02d}:{s:02d}"


@app.route("/")
def index():
    return render_template_string(
        PAGE,
        hostname=socket.gethostname(),
        now=datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S"),
        uptime=_uptime(),
        version=os.getenv("APP_VERSION", "1.0.0"),
    )


@app.route("/health")
def health():
    return jsonify(status="ok", uptime=_uptime())


@app.route("/api/info")
def info():
    return jsonify(
        app="mini-app-docker",
        version=os.getenv("APP_VERSION", "1.0.0"),
        hostname=socket.gethostname(),
        server_time_utc=datetime.now(timezone.utc).isoformat(),
        uptime=_uptime(),
    )


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    app.run(host="0.0.0.0", port=port)
