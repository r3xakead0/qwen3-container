# Ollama + Open WebUI + Qwen3 with Docker Compose

Local stack to run **Ollama** (model server) + **Open WebUI** (chat-style web interface) using **Docker Compose**.

---

## Quick architecture

- **ollama** → Model API at `http://localhost:11434`
- **open-webui** → Web interface at `http://localhost:3000`
- **model-loader** → One-shot container that downloads the `qwen3:4b` model and then exits

```mermaid
flowchart TB
  %% ====== System Boundary ======
  subgraph SYS[System: Local AI Chat Stack]
    direction TB

    %% --- Container Boundary ---
    subgraph POD[Container Boundary: Docker]
      direction LR

      WEBUI[
        Container: Open WebUI<br>
        Purpose: Chat UI and user management<br>
        Port: 8080 - mapped to 3000
      ]

      OLLAMA[
        Container: Ollama<br>
        Purpose: Model runtime and API<br>
        Port: 11434
      ]

      LOADER[
        Container: Model Loader<br>
        Purpose: Download model at startup<br>
        Runs: ollama pull qwen3:4b
      ]
    end

    %% --- Data Stores ---
    V_OLLAMA[
      Data Store: ollama-data<br>
      Stores: Models and cache
    ]

    V_WEBUI[
      Data Store: open-webui-data<br>
      Stores: Users, chats, config
    ]
  end

  %% ====== External Actor ======
  USER[Person: User]

  %% ====== Relationships ======
  USER -->|Uses browser<br>http://localhost:3000| WEBUI
  USER -->|Optional API access<br>http://localhost:11434| OLLAMA

  WEBUI -->|HTTP<br>OLLAMA_BASE_URL| OLLAMA
  LOADER -->|HTTP<br>Download model| OLLAMA

  OLLAMA -->|Persists model files| V_OLLAMA
  WEBUI -->|Persists application data| V_WEBUI
```

---

## Requirements

- Docker and Docker Compose
- Free ports:
  - `11434` (Ollama)
  - `3000` (Open WebUI)

---

## 1) Installation

### 1.1 Install Docker

**Fedora / RHEL / CentOS**
```bash
sudo dnf install -y docker
sudo systemctl enable --now docker
```

**Ubuntu / Debian**
```bash
sudo apt update && sudo apt install -y docker.io
```

**macOS**
```bash
brew install --cask docker
```

Verify:
```bash
docker --version
docker compose version
```

---

## 2) Configuration

Create a `.env` file in the same directory as `docker-compose.yaml`:

```env
WEBUI_SECRET_KEY=change-me-to-a-long-random-secret
ENABLE_SIGNUP=true
MODEL_NAME=qwen3:8b
```

Generate a secure secret:
```bash
openssl rand -hex 32
```

---

## 3) Execution

From the project directory:

```bash
docker compose up -d
```

Check status:
```bash
docker ps
docker compose ps
```

Access:
- Open WebUI → http://localhost:3000
- Ollama API → http://localhost:11434

> On first access, Open WebUI will ask you to create the first user (admin). This is expected behavior.

---

## 4) Testing and validation

### 4.1 Verify Ollama
```bash
curl http://localhost:11434
```

Expected response:
```
Ollama is running
```

---

### 4.2 List models
```bash
curl http://localhost:11434/api/tags
```

---

### 4.3 Validate Open WebUI
Open in the browser:
```
http://localhost:3000
```

Create a user, log in, and test a chat with the model.

---

### 4.4 Logs
```bash
docker logs ollama-qwen3
docker logs open-webui
docker logs model-loader-qwen3
```

---

## 5) Stop and restart

### Stop
```bash
docker compose stop
```

### Start again
```bash
docker compose start
```

---

## 6) Teardown

### 6.1 Bring down containers (keeps data)
```bash
docker compose down
```

### 6.2 Full cleanup (⚠️ removes volumes)
```bash
docker compose down -v
```

This removes:
- Downloaded models (Ollama)
- Users and conversations (Open WebUI)

---

## Security recommendations

- Change `WEBUI_SECRET_KEY` to a long, random secret
- After creating the first user, disable signups:
  ```env
  ENABLE_SIGNUP=false
  ```
  then recreate containers:
  ```bash
  docker compose up -d --force-recreate
  ```

---

## Expected final state

- Ollama responding on `localhost:11434`
- Open WebUI accessible on `localhost:3000`
- Model available and functional
