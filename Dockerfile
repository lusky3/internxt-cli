FROM alpine:latest

WORKDIR /app

RUN apk add --update --no-cache \
    curl \
    ca-certificates \
    openssl \
    nodejs \
    npm

RUN npm install -g @internxt/cli hotp-totp-cli

ENV INTERNXT_EMAIL=""
ENV INTERNXT_PASSWORD=""
ENV INTERNXT_TOTP=""

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3005

ENTRYPOINT ["/entrypoint.sh"]