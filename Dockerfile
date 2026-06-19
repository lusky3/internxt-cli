FROM alpine:3.24

ARG CLI_VERSION=1.6.3

WORKDIR /app

RUN apk add --update --no-cache \
    bash \
    ca-certificates \
    git \
    nodejs \
    npm \
    openssl && \
    apk upgrade --no-cache && \
    addgroup -g 1000 internxt && \
    adduser -D -u 1000 -G internxt internxt && \
    npm install -g @internxt/cli@${CLI_VERSION#v} otpauth@9.5.0 && \
    # CVE mitigations: override vulnerable transitive dependencies until fixed upstream \
    cd /usr/local/lib/node_modules/@internxt/cli && \
    npm install --ignore-scripts axios@1.13.6 fast-xml-parser@5.5.5 undici@7.24.4 --save && \
    cd /usr/local/lib/node_modules/@internxt/cli/node_modules/@internxt/inxt-js && \
    npm install --ignore-scripts axios@1.13.6 undici@7.24.4 --save && \
    npm cache clean --force && \
    apk del git

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    chown internxt:internxt /entrypoint.sh

USER internxt

EXPOSE 3005

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "const http = require('http'); const req = http.get('http://localhost:3005/', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }); req.on('error', () => process.exit(1)); req.setTimeout(5000, () => { req.destroy(); process.exit(1); });"

ENTRYPOINT ["/entrypoint.sh"]
