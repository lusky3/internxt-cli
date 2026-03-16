# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it by:

1. **Do NOT** open a public issue
2. Email the maintainer or use GitHub's private vulnerability reporting
3. Include detailed steps to reproduce the issue
4. Allow reasonable time for a fix before public disclosure

## Security Considerations

### Credentials

This container requires sensitive credentials (email, password, TOTP secret). Best practices:

- Use Docker secrets instead of environment variables in production
- Never commit `.env` files with real credentials
- Rotate credentials regularly
- Use strong, unique passwords

### Network Security

- WebDAV runs on HTTP by default (port 3005)
- Consider using a reverse proxy with HTTPS for production
- Restrict network access to trusted clients only

### Updates

- Images are automatically rebuilt when new Internxt CLI versions are released
- Always use specific version tags in production, not `latest`
- Review changelogs before updating
