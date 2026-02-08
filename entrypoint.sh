#!/bin/bash
set -e

trap 'echo "Shutting down..."; exit 0' SIGTERM SIGINT

if [ -z "$INTERNXT_EMAIL" ] || [ -z "$INTERNXT_PASSWORD" ]; then
  echo "Error: INTERNXT_EMAIL and INTERNXT_PASSWORD must be set."
  exit 1
fi

if [ -n "$INTERNXT_TOTP" ]; then
  echo "Generating TOTP..."
  TOTP=$(totp "$INTERNXT_TOTP")
  echo "Logging into Internxt..."
  internxt login --email="$INTERNXT_EMAIL" --password="$INTERNXT_PASSWORD" --twofactor="$TOTP" --non-interactive
else
  echo "Logging into Internxt without TOTP..."
  internxt login --email="$INTERNXT_EMAIL" --password="$INTERNXT_PASSWORD" --non-interactive
fi

if ! internxt webdav-config --http; then
  echo "Error: Failed to configure WebDAV"
  exit 1
fi

if ! internxt webdav enable; then
  echo "Error: Failed to enable WebDAV"
  exit 1
fi

echo "WebDAV enabled successfully"

while true; do
  internxt --version
  if ! internxt webdav status; then
    echo "Warning: WebDAV status check failed"
  fi
  sleep 300 &
  wait $!
done
