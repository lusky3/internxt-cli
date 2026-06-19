#!/bin/bash
set -e

trap 'echo "Shutting down..."; exit 0' SIGTERM SIGINT

# Docker secrets support: read _FILE variants if set
if [ -n "$INTERNXT_EMAIL_FILE" ] && [ -f "$INTERNXT_EMAIL_FILE" ]; then
  INTERNXT_EMAIL=$(cat "$INTERNXT_EMAIL_FILE")
fi
if [ -n "$INTERNXT_PASSWORD_FILE" ] && [ -f "$INTERNXT_PASSWORD_FILE" ]; then
  INTERNXT_PASSWORD=$(cat "$INTERNXT_PASSWORD_FILE")
fi
if [ -n "$INTERNXT_TOTP_FILE" ] && [ -f "$INTERNXT_TOTP_FILE" ]; then
  INTERNXT_TOTP=$(cat "$INTERNXT_TOTP_FILE")
fi

if [ -z "$INTERNXT_EMAIL" ] || [ -z "$INTERNXT_PASSWORD" ]; then
  echo "Error: INTERNXT_EMAIL and INTERNXT_PASSWORD must be set."
  exit 1
fi

if [ -n "$INTERNXT_TOTP" ]; then
  echo "Generating TOTP..."
  TOTP=$(node -e "const { TOTP } = require('otpauth'); const totp = new TOTP({ secret: process.env.INTERNXT_TOTP }); console.log(totp.generate());")
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
