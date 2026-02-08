# Internxt CLI Docker

Docker container for running [Internxt CLI](https://github.com/internxt/cli) with WebDAV support.

## Features

- Automated login with email/password authentication
- TOTP (2FA) support
- WebDAV server for mounting Internxt Drive
- Automatic version tracking and updates via GitHub Actions
- Multi-platform support (amd64, arm64)
- Security scanning with Trivy
- Runs as non-root user
- Health checks included

## Quick Start

```bash
# From GitHub Container Registry
docker run -d \
  -e INTERNXT_EMAIL="your@email.com" \
  -e INTERNXT_PASSWORD="yourpassword" \
  -p 3005:3005 \
  ghcr.io/lusky3/internxt-cli:latest

# From Docker Hub
docker run -d \
  -e INTERNXT_EMAIL="your@email.com" \
  -e INTERNXT_PASSWORD="yourpassword" \
  -p 3005:3005 \
  yourusername/internxt-cli:latest
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

### Using Docker Secrets (Recommended)

```yaml
services:
  internxt:
    image: ghcr.io/yourusername/internxt-cli:latest
    environment:
      INTERNXT_EMAIL_FILE: /run/secrets/internxt_email
      INTERNXT_PASSWORD_FILE: /run/secrets/internxt_password
    secrets:
      - internxt_email
      - internxt_password
    ports:
      - "3005:3005"
    restart: unless-stopped

secrets:
  internxt_email:
    file: ./secrets/email.txt
  internxt_password:
    file: ./secrets/password.txt
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

## Security

- Container runs as non-root user (UID 1000)
- See [SECURITY.md](SECURITY.md) for security considerations
- Use Docker secrets for credentials in production
- Consider using HTTPS reverse proxy

## Automatic Updates

This repository includes a GitHub Actions workflow that:
- Checks hourly for new Internxt CLI releases
- Automatically builds and publishes updated Docker images
- Tags images with both version number and `latest`
- Scans images for vulnerabilities with Trivy
- Supports multiple architectures (amd64, arm64)

## Building Locally

```bash
docker build -t internxt-cli .
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

Internxt CLI is subject to its own license terms.

