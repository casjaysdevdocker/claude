## 👋 Welcome to claude 🚀

Docker container for running Claude Code CLI with **full Docker-in-Docker support**.

This container provides a complete development environment with:

- **Persistent screen sessions** - Detach/reattach to Claude without losing context
- **Full Docker-in-Docker (DinD)** - Run Docker commands inside Claude Code
- **Claude Code CLI** with `--dangerously-skip-permissions` pre-configured
- **Persistent configuration** in `/config` - Settings and authentication
- **Persistent data** in `/data` - Logs, databases, caches (like `/var`)
- **Persistent workspace** in `/app` - Your project code
- **Multiple authentication methods** - Claude Pro subscription or API key
- **Pre-installed tools** - Docker, Docker Compose, containerd, git, curl, bash, screen
- **Native Claude Code installer** - Uses official installer (not deprecated npm package)  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update claude
```
  
## Install and run container

### Prerequisites

- Docker installed with `--privileged` support
- Authentication via one of:
  - **Claude Pro subscription** (recommended for Max users)
  - **Anthropic API key** (pay-as-you-go)

### Authentication Options

Claude Code supports multiple authentication methods:

#### Option 1: Claude Pro Subscription (Recommended)

If you have a Claude Pro subscription with Claude.com:

- Claude Code will prompt you to authenticate interactively
- Supports Pro and Max tier subscriptions
- No additional API costs
- Just run the container and follow the prompts
- **Tip:** Mount `~/.claude` directory to preserve authentication across container restarts

#### Option 2: Anthropic API Key

For API-based usage with pay-as-you-go billing:

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Create an API key
3. Pass it via environment: `-e ANTHROPIC_API_KEY=sk-ant-api03-...`

**Note:** API keys and Claude Pro subscriptions are separate authentication methods. Use whichever fits your use case.

### Quick Start

**With Claude Pro Subscription:**

```shell
# Start container with Claude in persistent screen session
docker run -d \
--privileged \
--restart unless-stopped \
--name claude-code \
--hostname claude \
-e TZ=${TIMEZONE:-America/New_York} \
-e PUID=$(id -u) \
-e PGID=$(id -g) \
-v "$PWD:$PWD:z" \
-v "$HOME/.config/claude:/config:z" \
-v "$HOME/.local/share/claude:/data:z" \
-v "$HOME/.claude:/root/.claude:z" \
casjaysdevdocker/claude:latest

# Attach to Claude (automatically manages screen session)
docker exec -it claude-code claude

# Detach anytime with: Ctrl+A then D
# Reattach anytime with: docker exec -it claude-code claude
```

**With API Key:**

```shell
export ANTHROPIC_API_KEY="sk-ant-api03-your-key-here"

# Start container with Claude in persistent screen session
docker run -d \
--privileged \
--restart unless-stopped \
--name claude-code \
--hostname claude \
-e TZ=${TIMEZONE:-America/New_York} \
-e PUID=$(id -u) \
-e PGID=$(id -g) \
-e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
-v "$PWD:$PWD:z" \
-v "$HOME/.config/claude:/config:z" \
-v "$HOME/.local/share/claude:/data:z" \
-v "$HOME/.claude:/root/.claude:z" \
casjaysdevdocker/claude:latest

# Attach to Claude (automatically manages screen session)
docker exec -it claude-code claude

# Detach anytime with: Ctrl+A then D
# Reattach anytime with: docker exec -it claude-code claude
```

**Important notes:**

**File Permissions (PUID/PGID):**

- `-e PUID=$(id -u)` and `-e PGID=$(id -g)` set the user ID and group ID for file ownership
- When PUID/PGID are set (non-zero), the container creates a `claude` user with your UID/GID
- Files created in mounted directories (`/config`, `/data`, `$PWD`) will have **your ownership**, not root
- The container process runs as root, but files get your ownership through user mapping
- This prevents permission issues when editing files on the host
- **Optional:** Omit these (or set to 0) to run as root and have root-owned files

**Working Directory:**

- `-v "$PWD:$PWD:z"` mounts current directory to the **same path** inside container
- Paths in Claude's context **match your host** exactly
- No confusion about `/app` vs actual project location

**Credentials Mount:**

- `-v "$HOME/.claude:/root/.claude:z"` is optional but recommended
- **Mounts entire `.claude` directory**, not just the credentials file
  - Avoids Docker creating directory when file doesn't exist
  - Shares all Claude settings, not just authentication
- **Preserves authentication** across container recreations
- **Shares credentials** between native Claude Code and containerized version
- Only needed for Claude Pro subscription (not needed for API key)

### One-line attach command

```shell
# Start if not running, then attach to Claude
docker start claude-code 2>/dev/null || true && docker exec -it claude-code claude
```

### Pass additional arguments

```shell
# Pass custom arguments to Claude Code CLI
docker run -it --rm \
--privileged \
-e CLAUDE_ADDITIONAL_ARGS="--model opus-4" \
-v "$PWD:$PWD:z" \
-v "$HOME/.config/claude:/config:z" \
-v "$HOME/.local/share/claude:/data:z" \
casjaysdevdocker/claude:latest
```

## Persistent Sessions with Screen

Claude Code runs inside a **persistent `screen` session** by default. This allows you to:

- **Detach** from Claude without stopping it
- **Reattach** to your existing session anytime
- Keep your conversation history and context
- Run long tasks in the background

### Screen Session Management

Claude automatically runs in a persistent screen session. Simply run:

```bash
docker exec -it claude-code claude
```

This will:

- **Attach** to existing session if one exists
- **Create** a new session if none exists

No need to remember screen commands!

### Usage Examples

**Typical Workflow:**

```bash
# 1. Start container (first time only)
docker run -d --privileged --name claude-code \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -v "$PWD:$PWD:z" \
  -v "$HOME/.config/claude:/config:z" \
  -v "$HOME/.local/share/claude:/data:z" \
  casjaysdevdocker/claude:latest

# 2. Attach to Claude (anytime)
docker exec -it claude-code claude

# 3. Work with Claude...

# 4. Detach (keeps running): Ctrl+A then D

# 5. Later, reattach
docker exec -it claude-code claude
```

**Fast attach/detach:**

1. While in Claude, press: `Ctrl+A` then `D` to detach
2. Claude continues running in the background
3. Run `docker exec -it claude-code claude` to reattach anytime

### Screen Quick Reference

| Action                       | Command                                                               |
| ---------------------------- | --------------------------------------------------------------------- |
| Attach to Claude             | `docker exec -it claude-code claude`                                  |
| Detach from session          | `Ctrl+A` then `D`                                                     |
| List all sessions            | `docker exec -it claude-code screen -ls`                              |
| Kill and restart session     | `docker exec -it claude-code screen -X -S claude quit`                |
| Create new window in session | `Ctrl+A` then `C`                                                     |
| Switch between windows       | `Ctrl+A` then `N` (next) or `P` (previous)                            |
| Scroll in session            | `Ctrl+A` then `Esc`, then arrow keys, press `Esc` to exit scroll mode |

## Full Docker-in-Docker Support

This container comes with **full Docker-in-Docker (DinD)** enabled by default:

- Complete Docker daemon runs inside the container
- Docker CLI, Docker Compose, and containerd included
- Requires `--privileged` flag
- Isolated Docker environment from host
- Can build images, run containers, use docker-compose

**Claude Code can execute Docker commands:**

```bash
docker ps
docker build -t myapp .
docker-compose up -d
docker run --rm alpine echo "Hello from nested container"
```

**Note:** Always use `--privileged` flag for full Docker support.

## via docker-compose

**With Claude Pro Subscription:**

```yaml
version: "3.8"
services:
  claude-code:
    image: casjaysdevdocker/claude:latest
    container_name: claude-code
    hostname: claude
    privileged: true
    stdin_open: true
    tty: true
    environment:
      - TZ=America/New_York
      - PUID=${UID:-1000}
      - PGID=${GID:-1000}
      - CLAUDE_ADDITIONAL_ARGS=
    volumes:
      - "./:${PWD}:z"
      - "${HOME}/.config/claude:/config:z"
      - "${HOME}/.local/share/claude:/data:z"
      - "${HOME}/.claude:/root/.claude:z"
    restart: unless-stopped
```

**With API Key:**

```yaml
version: "3.8"
services:
  claude-code:
    image: casjaysdevdocker/claude:latest
    container_name: claude-code
    hostname: claude
    privileged: true
    stdin_open: true
    tty: true
    environment:
      - TZ=America/New_York
      - PUID=${UID:-1000}
      - PGID=${GID:-1000}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - CLAUDE_ADDITIONAL_ARGS=
    volumes:
      - "./:${PWD}:z"
      - "${HOME}/.config/claude:/config:z"
      - "${HOME}/.local/share/claude:/data:z"
      - "${HOME}/.claude:/root/.claude:z"
    restart: unless-stopped
```

Save as `docker-compose.yml` and run:

```shell
# With Claude Pro - no API key needed
docker-compose up -d
docker-compose exec claude-code claude

# With API key
export ANTHROPIC_API_KEY="sk-ant-api03-..."
docker-compose up -d
docker-compose exec claude-code claude
```

## Configuration

### Environment Variables

**Authentication:**

- `ANTHROPIC_API_KEY` (optional): Your Anthropic API key
  - Not required if using Claude Pro subscription with credentials file
  - Use either API key OR credentials file, not both

**User Permissions:**

- `PUID` (recommended): User ID for file ownership (default: 0/root)
  - Use `$(id -u)` to match your host user
  - **Controls file ownership** on mounted volumes (`/config`, `/data`, `$PWD`)
  - When non-zero, creates a `claude` user inside container with your UID
  - Container process runs as root, files created get mapped to your UID through `chown`
  - If set to 0 or omitted, files are owned by root (no user mapping)
- `PGID` (recommended): Group ID for file ownership (default: 0/root)
  - Use `$(id -g)` to match your host group
  - When non-zero, creates a `claude` group inside container with your GID
  - Prevents permission issues when editing files on the host
  - If set to 0 or omitted, files are owned by root group (no group mapping)

**General:**

- `TZ` (optional): Timezone (default: America/New_York)
- `CLAUDE_ADDITIONAL_ARGS` (optional): Additional arguments to pass to Claude Code CLI
- `CLAUDE_CONFIG_DIR` (optional): Config directory path (default: /config/claude)
- `CLAUDE_WORK_DIR` (optional): Working directory path (default: current PWD)

### Settings File

The container uses a persistent settings file located at `/config/claude/settings.json`.
On first run, it will be initialized with a default configuration that includes:

- Permissions for common operations (Read, Write, WebSearch, Bash commands)
- `--dangerously-skip-permissions` flag enabled by default
- Pre-configured hooks for file operations
- Thinking mode set to "off"
- Auto-commit disabled

You can modify this file to customize Claude Code's behavior. The file persists between container restarts.

### Volume Mounts

**Required volumes:**

- `/config` - Configuration directory (contains settings.json)
- `/data` - Application data directory (logs, databases, caches, Docker volumes, etc.)
- `$PWD:$PWD` - **Current directory mounted to same path** inside container
  - Paths in Claude's context match your host exactly
  - No path translation needed
  - Files created have your user ownership (when using PUID/PGID)

**Optional but recommended:**

- `~/.claude` → `/root/.claude` - Claude Pro authentication and settings
  - **Preserves authentication** across container recreations
  - **Shares credentials** with native Claude Code installation (`.credentials.json`)
  - **Shares all Claude settings** between host and container
  - **Only needed for Claude Pro** (not required if using API key)
  - Directory and files created automatically on first authentication
  - **Better than mounting just the file** - avoids Docker creating directory when file doesn't exist

**Understanding the directory structure:**

- `$PWD:$PWD` - Your project source code (transparent path mapping)
- `/config` - Container configuration and Claude settings
- `/data` - Runtime data (databases, logs, docker volumes, temp files, caches)
  - Example: `/data/logs` - Application and Docker daemon logs
  - Example: `/data/postgres` - PostgreSQL data
  - Example: `/data/mysql` - MySQL data
  - Example: `/data/redis` - Redis persistence
  - Similar to `/var` on traditional Linux systems

### Docker-in-Docker Details

This container runs a **full Docker daemon** by default:

- Docker CLI, Docker Compose, containerd pre-installed
- Isolated Docker environment (separate from host)
- Can build images, run containers, use docker-compose
- Requires `--privileged` flag
- Uses VFS storage driver for compatibility
- Docker daemon starts automatically on container startup

## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/claude
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/claude" "$HOME/Projects/github/casjaysdevdocker/claude"
```
  
## Build container

```shell
cd "$HOME/Projects/github/casjaysdevdocker/claude"
buildx
```

## Quick Reference

### Start Container (First Time)

```bash
# Claude Pro users
docker run -d --privileged --restart unless-stopped --name claude-code \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -v "$HOME/.config/claude:/config:z" \
  -v "$HOME/.local/share/claude:/data:z" \
  -v "$PWD:$PWD:z" \
  -v "$HOME/.claude:/root/.claude:z" \
  casjaysdevdocker/claude:latest

# API Key users
export ANTHROPIC_API_KEY="sk-ant-api03-..."
docker run -d --privileged --restart unless-stopped --name claude-code \
  -e PUID=$(id -u) -e PGID=$(id -g) \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v "$HOME/.config/claude:/config:z" \
  -v "$HOME/.local/share/claude:/data:z" \
  -v "$PWD:$PWD:z" \
  -v "$HOME/.claude:/root/.claude:z" \
  casjaysdevdocker/claude:latest
```

### Daily Usage

```bash
# Attach to Claude (creates or attaches to screen session)
docker exec -it claude-code claude

# Detach: Ctrl+A then D

# One-liner to start container and attach
docker start claude-code 2>/dev/null || true && docker exec -it claude-code claude
```

## Troubleshooting

### "Cannot start Docker-in-Docker daemon - insufficient privileges"

- **Solution:** Add `--privileged` flag to your docker run command
- This container requires privileged mode for full Docker-in-Docker support

### Authentication prompts

- **Claude Pro users:** Follow the interactive prompts to authenticate
- **API users:** Set `ANTHROPIC_API_KEY` environment variable

### Credentials file issues

**Problem:** Authentication not persisting across container restarts

**Solution:** Mount the entire `~/.claude` directory, not just the file:
```bash
# ✅ Correct - mount directory
-v "$HOME/.claude:/root/.claude:z"

# ❌ Wrong - Docker creates directory if file doesn't exist
-v "$HOME/.claude/.credentials.json:/root/.claude/.credentials.json:z"
```

**Why:** If the file doesn't exist on host, Docker creates it as a **directory** instead, breaking authentication.

### Docker commands not working inside container

- Ensure you're using `--privileged` flag
- Wait a few seconds for Docker daemon to initialize
- Check logs: `docker logs claude-code`

### Screen session issues

```bash
# Just run claude - it will create a session if needed
docker exec -it claude-code claude

# List all screen sessions (advanced)
docker exec -it claude-code screen -ls

# Force kill screen session and create new one
docker exec -it claude-code screen -X -S claude quit
docker exec -it claude-code claude

# Manually restart the init script (if needed)
docker exec -it claude-code /usr/local/etc/docker/init.d/99-claude.sh
```

## Authors

🤖 casjay: [Github](https://github.com/casjay) 🤖
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
