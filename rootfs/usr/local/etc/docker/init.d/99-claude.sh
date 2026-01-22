#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202601221200-git
# @@Author           :  CasjaysDev
# @@Contact          :  CasjaysDev <docker-admin@casjaysdev.pro>
# @@License          :  MIT
# @@Copyright        :  Copyright 2026 CasjaysDev
# @@Created          :  Wed Jan 22 12:00:00 PM EST 2026
# @@File             :  99-claude.sh
# @@Description      :  Init script to run Claude Code CLI
# @@Changelog        :  newScript
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC1001,SC1003,SC2001,SC2003,SC2016,SC2031,SC2090,SC2115,SC2120,SC2155,SC2199,SC2229,SC2317,SC2329
# - - - - - - - - - - - - - - - - - - - - - - - - -
SCRIPT_NAME="$(basename "$0" 2>/dev/null)"
SCRIPT_PID_FILE="/run/init.d/$SCRIPT_NAME.pid"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set env/config variables
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-/config/claude}"
CLAUDE_SETTINGS_FILE="${CLAUDE_SETTINGS_FILE:-$CLAUDE_CONFIG_DIR/settings.json}"
CLAUDE_WORK_DIR="${CLAUDE_WORK_DIR:-${PWD:-/app}}"
CLAUDE_ADDITIONAL_ARGS="${CLAUDE_ADDITIONAL_ARGS:-}"
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
# Tell init system this service doesn't use traditional PID tracking
SERVICE_USES_PID="no"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Show authentication info
if [ -n "$ANTHROPIC_API_KEY" ]; then
  echo "Using Anthropic API key from environment"
else
  echo "No API key detected - Claude Code will prompt for authentication"
  echo "You can use either:"
  echo "  1. Anthropic API key: -e ANTHROPIC_API_KEY=your_key"
  echo "  2. Claude Pro subscription: Claude Code will authenticate interactively"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Ensure claude config directory exists
mkdir -p "$CLAUDE_CONFIG_DIR" 2>/dev/null || true
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Initialize settings.json if it doesn't exist
if [ ! -f "$CLAUDE_SETTINGS_FILE" ]; then
  if [ -f "/usr/local/share/template-files/config/claude/settings.json" ]; then
    echo "Initializing Claude Code settings from template"
    cp -f "/usr/local/share/template-files/config/claude/settings.json" "$CLAUDE_SETTINGS_FILE"
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set up symlink for settings in home directory
mkdir -p "$HOME/.claude" 2>/dev/null || true
if [ ! -L "$HOME/.claude/settings.json" ]; then
  ln -sf "$CLAUDE_SETTINGS_FILE" "$HOME/.claude/settings.json" 2>/dev/null || true
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Change to working directory
cd "$CLAUDE_WORK_DIR" || exit 1
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Write PID file
echo $$ >"$SCRIPT_PID_FILE"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Start Claude Code CLI
echo "Starting Claude Code CLI in persistent screen session..."
echo "Working directory: $CLAUDE_WORK_DIR"
echo "Settings: $CLAUDE_SETTINGS_FILE"
echo ""
echo "To attach to Claude session: docker exec -it <container> screen -r claude"
echo "To detach from session: Ctrl+A then D"
echo "To list sessions: screen -ls"
echo "---"
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Check if screen session already exists
if screen -list | grep -q "\.claude[[:space:]]"; then
  echo "Claude screen session already running"
  exit 0
else
  # Start claude in a detached screen session named "claude"
  screen -dmS claude bash -c "cd '$CLAUDE_WORK_DIR' && claude --dangerously-skip-permissions $CLAUDE_ADDITIONAL_ARGS"

  # Wait a moment for screen to initialize
  sleep 2

  # Verify screen session was created
  if screen -list | grep -q "\.claude[[:space:]]"; then
    echo "Claude screen session started successfully"
    echo "Attach with: screen -r claude"
    exit 0
  else
    echo "Failed to start Claude screen session" >&2
    exit 1
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
