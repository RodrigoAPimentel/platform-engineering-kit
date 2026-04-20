# syntax=docker/dockerfile:1.4
FROM quay.io/keycloak/keycloak:24.0
LABEL maintainer="devops@seuemail.com" version="2.0.0" description="Keycloak image modernizada e segura"

USER root

# Cria usuário não-root dedicado
RUN groupadd -g 1002 keycloakuser && useradd -u 1002 -g keycloakuser -m -s /bin/bash keycloakuser

# Ajusta permissões
RUN chown -R keycloakuser:keycloakuser /opt/keycloak

USER keycloakuser

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD curl -f http://localhost:8080/realms/master || exit 1
