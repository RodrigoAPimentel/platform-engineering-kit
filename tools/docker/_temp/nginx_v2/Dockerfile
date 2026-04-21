# syntax=docker/dockerfile:1.4
FROM nginx:1.27-alpine
LABEL maintainer="devops@seuemail.com" version="2.0.0" description="NGINX image modernizada e segura"

USER root

# Cria usuário não-root dedicado
RUN addgroup -g 1010 nginxuser && adduser -D -u 1010 -G nginxuser nginxuser

# Copia arquivos customizados (ajuste conforme necessário)
COPY error_pages/ /usr/share/nginx/html/
COPY nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY sites-enabled/ /etc/nginx/conf.d/

RUN chown -R nginxuser:nginxuser /usr/share/nginx/html /etc/nginx/templates /etc/nginx/conf.d

USER nginxuser

EXPOSE 80 443
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD curl -f http://localhost || exit 1
