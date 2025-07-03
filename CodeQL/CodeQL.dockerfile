# Based on: https://github.com/microsoft/codeql-container/blob/main/Dockerfile
#     docs: https://docs.github.com/en/code-security/codeql-cli/codeql-cli-manual/query-compile
#           https://github.com/orgs/codeql/packages

FROM ubuntu:24.04 AS codeql_base
MAINTAINER "R4S Team"

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=24.0.2
ENV DOTNET_VERSION=9.0

# Install codeql

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils \
        apt-transport-https \
        software-properties-common \
        curl wget git jq \
        ca-certificates \
        build-essential \
        unzip gnupg g++ \
        make gcc \
        golang

# Get the latest version of the codeql-cli

WORKDIR /tmp
RUN curl -s https://api.github.com/repos/github/codeql-cli-binaries/releases/latest \
    | grep "browser_download_url.*linux64.zip" \
    | cut -d '"' -f 4 \
    | xargs curl -L -o codeql.zip \
    && unzip codeql.zip \
    && rm codeql.zip

RUN mv codeql* /opt/codeql/
ENV PATH="/opt/codeql:${PATH}"

# Copy rules repository

# WORKDIR /opt/codeql
# RUN git clone --depth 1 --branch main https://github.com/github/codeql codeql-repo

# https://github.com/orgs/codeql/packages

RUN codeql pack download codeql/rust-queries
RUN codeql pack download codeql/go-queries
RUN codeql pack download codeql/cpp-queries
RUN codeql pack download codeql/javascript-queries
RUN codeql pack download codeql/python-queries
RUN codeql pack download codeql/csharp-queries
RUN codeql pack download codeql/java-queries

# Check codeql version

RUN codeql version
RUN codeql resolve queries
RUN codeql resolve packs
RUN codeql resolve languages

# Install Python

RUN apt-get install -y --no-install-recommends \
    python3-pip python3-setuptools python3-wheel \
    python3-venv

# Create virtual environment and Clean

RUN python3 -m venv /opt/venv && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/venv/bin:$PATH"

# Add Microsoft package feed for .NET

RUN add-apt-repository ppa:dotnet/backports && \
    apt-get update && \
    apt-get install -y --no-install-recommends dotnet-sdk-$DOTNET_VERSION

RUN dotnet --version

# Install Java for tools/builds

RUN apt-get install -y --no-install-recommends default-jdk apt-transport-https

# Install NVM and Node.js

ENV NVM_DIR=/root/.nvm

RUN curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    chmod -R 755 $NVM_DIR && \
    bash -c ". $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && nvm use default"

ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Update npm and disable notifier

RUN node -v && npm -v
RUN npm install -g npm@11.4.1 && npm config set update-notifier false

# Cache rules

RUN codeql query compile \
    --threads=0 --additional-packs=/opt/codeql \
    $(find /root/.codeql/packages/codeql/ -type f -name "*.qls") || true

# Clean

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*
