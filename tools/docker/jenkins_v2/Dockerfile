# syntax=docker/dockerfile:1.4
FROM jenkins/jenkins:lts-jdk17 as base
LABEL maintainer="devops@seuemail.com" version="2.0.0" description="Jenkins image hardened and modernized"

# Instala dependências necessárias e Docker CLI
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends lsb-release curl ca-certificates gnupg2 \
    && curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Cria usuário não-root dedicado
RUN groupadd -g 1001 jenkinsuser && useradd -u 1001 -g jenkinsuser -m -s /bin/bash jenkinsuser

# Copia arquivos necessários
COPY --chown=jenkinsuser:jenkinsuser plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkinsuser:jenkinsuser casc.yaml /var/jenkins_home/casc.yaml
COPY --chown=jenkinsuser:jenkinsuser seedjob.groovy /usr/local/seedjob.groovy

# Ajusta permissões
RUN chown -R jenkinsuser:jenkinsuser /var/jenkins_home /usr/share/jenkins/ref /usr/local/seedjob.groovy

USER jenkinsuser

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG="/var/jenkins_home/casc.yaml"
ENV JENKINS_OPTS="--prefix=/jenkins"

RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt && \
    echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

EXPOSE 8080 50000
VOLUME ["/var/jenkins_home"]
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD curl -f http://localhost:8080/login || exit 1
