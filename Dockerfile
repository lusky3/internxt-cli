FROM alpine:3.23

WORKDIR /app

RUN apk add --update --no-cache \
    bash \
    ca-certificates \
    curl \
    nodejs \
    npm \
    openssl && \
    apk upgrade --no-cache && \
    addgroup -g 1000 internxt && \
    adduser -D -u 1000 -G internxt internxt && \
    npm install -g @internxt/cli@1.6.3 otpauth@9.5.0 && \
    cd /usr/local/lib/node_modules/@internxt/cli && \
    npm install --ignore-scripts axios@1.13.6 fast-xml-parser@5.5.5 undici@6.23.0 --save && \
    cd /usr/local/lib/node_modules/@internxt/cli/node_modules/@internxt/inxt-js && \
    npm install --ignore-scripts axios@1.13.6 --save

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chown internxt:internxt /entrypoint.sh

USER internxt

EXPOSE 3005

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD internxt webdav status || exit 1

ENTRYPOINT ["/entrypoint.sh"]
