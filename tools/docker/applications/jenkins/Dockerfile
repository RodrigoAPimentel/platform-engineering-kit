# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=jenkins/jenkins:lts-jdk11
ARG BUILD_PROFILE=prod
ARG APP_ENV=production

FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="jenkins" \
    org.opencontainers.image.description="Jenkins image aligned to repository Dockerfile template" \
    org.opencontainers.image.version="1.0.0"

ENV APP_ENV=${APP_ENV} \
    JAVA_OPTS=-Djenkins.install.runSetupWizard=false \
    CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml \
    JENKINS_OPTS=--prefix=/jenkins

USER root

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    && curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install --no-install-recommends -y docker-ce-cli \
    && if [ "${BUILD_PROFILE}" = "dev" ]; then apt-get install --no-install-recommends -y git; fi \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins casc.yaml /var/jenkins_home/casc.yaml
COPY --chown=jenkins:jenkins seedjob.groovy /usr/local/seedjob.groovy

USER jenkins

RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt \
    && echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

EXPOSE 8080 50000