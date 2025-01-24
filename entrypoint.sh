#!/bin/bash
set -e

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

echo "Enabling WebDAV..."
internxt webdav-config --http
internxt webdav enable

echo "Starting WebDAV status monitoring..."
while true; do
  internxt --version
  internxt webdav status
  sleep 300
done
