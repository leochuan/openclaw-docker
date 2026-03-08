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

## Configure Channels (Telegram)

Add the bot token in `.env`:

```env
TELEGRAM_BOT_TOKEN=<your_bot_token_from_BotFather>
```

Then run the interactive setup wizard:

```bash
docker compose run --rm -it openclaw-cli configure
# Select Telegram channel, follow prompts
docker compose restart openclaw-gateway
```

DM your bot on Telegram, then approve the pairing:

```bash
docker compose run --rm openclaw-cli pairing list telegram
docker compose run --rm openclaw-cli pairing approve telegram <CODE>
```

Or approve directly in the Web UI (http://127.0.0.1:18789/).

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
start.ps1            # Windows: pull config + start gateway
stop.ps1             # Windows: stop gateway + push config
start.sh             # macOS/Linux: pull config + start gateway
stop.sh              # macOS/Linux: stop gateway + push config
```

Config and agent data live in a separate private repo (`openclaw-data`):

```
openclaw-data/           # Separate private git repo
  config/
    openclaw.json        #   Main config (model, channels, gateway settings)
    agents/              #   Agent model preferences
    cron/                #   Scheduled tasks
  workspace/
    IDENTITY.md          #   Agent persona
    SOUL.md              #   Agent personality
    USER.md              #   User info for the agent
    ...
```

## Start / Stop Scripts

The scripts auto-sync `openclaw-data` via git:

- **start**: `git pull` → `docker compose up`
- **stop**: `docker compose down` → `git commit + push`

```bash
# Windows
.\start.ps1
.\stop.ps1

# macOS/Linux
./start.sh
./stop.sh
```

## Setup on a Second Machine

If you already have `openclaw-data` on another machine, clone both repos:

```bash
# 1. Clone the docker project
git clone <your-openclaw-docker-repo-url>
cd openclaw-docker

# 2. Clone your config data (put it next to openclaw-docker, or wherever you like)
git clone <your-openclaw-data-repo-url> ../openclaw-data

# 3. Create .env from template
cp .env.example .env

# 4. Edit .env:
#    - Set OPENCLAW_CONFIG_DIR / OPENCLAW_WORKSPACE_DIR to point to your cloned openclaw-data
#    - Generate a new gateway token
#    - Set TELEGRAM_BOT_TOKEN (same token, shared across machines)
#    - Set proxy if needed (or leave empty)

# 5. Re-authenticate GitHub Copilot (tokens are machine-specific)
docker compose up -d openclaw-gateway
docker compose run --rm -it openclaw-cli configure
# Select GitHub Copilot, complete OAuth flow
docker compose restart openclaw-gateway
```

Note: Credentials (GitHub Copilot token, device identity) are machine-specific and git-ignored in `openclaw-data`. You'll need to re-run OAuth on each new machine.

## Platform Notes

- **Windows**: Use forward slashes in `.env` paths (e.g. `C:/Users/you/.openclaw`)
- **macOS**: Proxy settings can be left empty if not needed
- Both platforms use `host.docker.internal` to reach the host from containers
