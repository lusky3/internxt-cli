FROM alpine:3.19

WORKDIR /app

RUN apk add --update --no-cache \
    curl \
    ca-certificates \
    openssl \
    nodejs \
    npm \
    bash && \
    addgroup -g 1000 internxt && \
    adduser -D -u 1000 -G internxt internxt

RUN npm install -g @internxt/cli@1.6.2 hotp-totp-cli@1.0.3

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chown internxt:internxt /entrypoint.sh

USER internxt

EXPOSE 3005

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD internxt webdav status || exit 1

ENTRYPOINT ["/entrypoint.sh"]