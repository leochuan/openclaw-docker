# OpenClaw Docker Setup

Personal [OpenClaw](https://github.com/openclaw/openclaw) deployment via Docker Compose.

## Prerequisites

- Docker Desktop (or Docker Engine + Compose v2)
- At least 2 GB RAM

## Quick Start

```bash
# 1. Clone and enter the project
git clone <your-repo-url>
cd <project-dir>

# 2. Create .env from template
cp .env.example .env

# 3. Generate a gateway token and fill it in .env
#    Linux/macOS:
openssl rand -hex 32
#    PowerShell:
#    -join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Max 256) })

# 4. Edit .env — set paths, token, and proxy (if needed)

# 5. Create data directories
mkdir -p openclaw-data/config openclaw-data/workspace

# 6. Start the gateway
docker compose up -d openclaw-gateway

# 7. Run the onboarding wizard
docker compose run --rm openclaw-cli onboard --mode local --no-install-daemon

# 8. Restart gateway to apply config
docker compose restart openclaw-gateway
```

## Access the Web UI

Open http://127.0.0.1:18789/ in your browser.

Get the dashboard URL with token:

```bash
docker compose run --rm openclaw-cli dashboard --no-open
```

If you see "pairing required":

```bash
docker compose run --rm openclaw-cli devices list
docker compose run --rm openclaw-cli devices approve <requestId>
```

## Configure Model (e.g. GitHub Copilot OAuth)

```bash
docker compose run --rm openclaw-cli configure
# Select GitHub Copilot, follow the OAuth flow in your browser.
# If the callback page errors, paste the full redirect URL back into the terminal.

docker compose restart openclaw-gateway
```

## Configure Channels (optional)

```bash
# Telegram
docker compose run --rm openclaw-cli channels add --channel telegram --token "<bot_token>"

# Discord
docker compose run --rm openclaw-cli channels add --channel discord --token "<bot_token>"

# WhatsApp (QR code)
docker compose run --rm openclaw-cli channels login

# Restart after channel changes
docker compose restart openclaw-gateway
```

## Common Commands

| Command | Description |
|---------|-------------|
| `docker compose up -d openclaw-gateway` | Start the gateway |
| `docker compose down` | Stop everything |
| `docker compose restart openclaw-gateway` | Restart gateway (after config changes) |
| `docker compose ps` | Check container status |
| `docker compose logs -f openclaw-gateway` | Tail gateway logs |
| `docker compose run --rm openclaw-cli <cmd>` | Run a one-off CLI command |
| `docker compose exec openclaw-gateway openclaw <cmd>` | Run command inside the running gateway |

## Proxy

If you need a proxy (e.g. V2Ray), set these in `.env`:

```env
HTTP_PROXY=http://host.docker.internal:10808
HTTPS_PROXY=http://host.docker.internal:10808
```

`host.docker.internal` resolves to the host machine from inside Docker.

Make sure your proxy allows connections from LAN (bind to `0.0.0.0`, not `127.0.0.1`).

For Docker image pulls, configure the proxy in **Docker Desktop → Settings → Resources → Proxies** instead.

## File Structure

```
.env.example         # Template (committed to git)
.env                 # Your actual config (git-ignored, contains secrets)
docker-compose.yml   # Service definitions (cross-platform)
openclaw-data/       # Runtime data (git-ignored)
  config/            #   OpenClaw config, credentials, sessions
  workspace/         #   Agent workspace
```

## Platform Notes

- **Windows**: Use forward slashes in `.env` paths (e.g. `C:/Users/you/.openclaw`)
- **macOS**: Proxy settings can be left empty if not needed
- Both platforms use `host.docker.internal` to reach the host from containers
