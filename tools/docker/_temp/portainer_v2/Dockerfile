# syntax=docker/dockerfile:1.4
FROM portainer/portainer-ce:2.19.4
LABEL maintainer="devops@seuemail.com" version="2.0.0" description="Portainer image modernizada e segura"

USER root

# Cria usuário não-root dedicado
RUN addgroup -g 1011 portaineruser && adduser -D -u 1011 -G portaineruser portaineruser

RUN chown -R portaineruser:portaineruser /data

USER portaineruser

EXPOSE 9443 9000
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD curl -kf https://localhost:9443 || exit 1
