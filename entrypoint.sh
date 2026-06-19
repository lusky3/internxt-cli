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

# Pass credentials via environment variables to avoid exposing them in process args
export INXT_USER="$INTERNXT_EMAIL"
export INXT_PASSWORD="$INTERNXT_PASSWORD"
export INXT_NONINTERACTIVE=true

if [ -n "$INTERNXT_TOTP" ]; then
  echo "Generating TOTP..."
  TOTP=$(node -e "const { TOTP } = require('otpauth'); const totp = new TOTP({ secret: process.env.INTERNXT_TOTP }); console.log(totp.generate());")
  export INXT_TWOFACTORCODE="$TOTP"
  echo "Logging into Internxt..."
  internxt login-legacy
else
  echo "Logging into Internxt without TOTP..."
  internxt login-legacy
fi

# Clean sensitive env vars after login
unset INXT_PASSWORD INXT_TWOFACTORCODE INTERNXT_PASSWORD INTERNXT_TOTP

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
