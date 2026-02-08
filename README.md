# Internxt CLI Docker

Docker container for running [Internxt CLI](https://github.com/internxt/cli) with WebDAV support.

## Features

- Automated login with email/password authentication
- TOTP (2FA) support
- WebDAV server for mounting Internxt Drive
- Automatic version tracking and updates via GitHub Actions
- Lightweight Alpine-based image

## Quick Start

```bash
docker run -d \
  -e INTERNXT_EMAIL="your@email.com" \
  -e INTERNXT_PASSWORD="yourpassword" \
  -p 3005:3005 \
  ghcr.io/yourusername/internxt-cli:latest
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `INTERNXT_EMAIL` | Yes | Your Internxt account email |
| `INTERNXT_PASSWORD` | Yes | Your Internxt account password |
| `INTERNXT_TOTP` | No | TOTP secret for 2FA (if enabled) |

## Usage

### With Docker Compose

```yaml
services:
  internxt:
    image: ghcr.io/yourusername/internxt-cli:latest
    environment:
      INTERNXT_EMAIL: "your@email.com"
      INTERNXT_PASSWORD: "yourpassword"
      INTERNXT_TOTP: "your-totp-secret"
    ports:
      - "3005:3005"
    restart: unless-stopped
```

### Mounting WebDAV

Once running, you can mount the WebDAV server:

**Linux/macOS:**
```bash
mount -t davfs http://localhost:3005 /mnt/internxt
```

**Windows:**
```
Map Network Drive → http://localhost:3005
```

## Automatic Updates

This repository includes a GitHub Actions workflow that:
- Checks hourly for new Internxt CLI releases
- Automatically builds and publishes updated Docker images
- Tags images with both version number and `latest`

## Building Locally

```bash
docker build -t internxt-cli .
```

## License

This Docker wrapper is provided as-is. Internxt CLI is subject to its own license terms.
