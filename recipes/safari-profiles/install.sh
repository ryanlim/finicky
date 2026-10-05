#!/bin/sh
# Installs the redirect server to ~/.finicky-helper and runs it as a launchd user
# agent. Safe to re-run (updates the files and restarts the agent). Does not touch
# /etc/hosts.
# Port: FINICKY_HELPER_PORT=1234 ./install.sh (default 48731). Use the same
# port in your Finicky config.
set -e
src=$(cd "$(dirname "$0")" && pwd)
dest_dir="${FINICKY_HELPER_DIR:-$HOME/.finicky-helper}"
port="${FINICKY_HELPER_PORT:-48731}"
label=se.johnste.finicky.safari-profiles
plist="$HOME/Library/LaunchAgents/$label.plist"

case "$port" in
  ""|*[!0-9]*) echo "FINICKY_HELPER_PORT must be a number" >&2; exit 1 ;;
esac

mkdir -p "$dest_dir" "$HOME/Library/LaunchAgents"
cp "$src/server.py" "$src/redirect.html" "$dest_dir/"
sed -e "s|__DIR__|$dest_dir|g" -e "s|__PORT__|$port|g" "$src/$label.plist" > "$plist"

launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$plist"
echo "Installed to $dest_dir; agent $label running on port $port."
echo "Next: add your hostnames to /etc/hosts, see README.md."
