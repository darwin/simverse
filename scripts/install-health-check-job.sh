#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "this tool is macOS only"
  exit 1
fi

AGENTS_DIR=~/Library/LaunchAgents
PLIST_NAME=simverse-health-check.plist
PLIST_SOURCE="launchd/$PLIST_NAME"
PLIST_PATH="$AGENTS_DIR/$PLIST_NAME"

cp "$PLIST_SOURCE" "$AGENTS_DIR"
launchctl unload "$PLIST_PATH"
launchctl load -w "$PLIST_PATH"