# Based on: https://github.com/microsoft/codeql-container/blob/main/Dockerfile
#     docs: https://docs.github.com/en/code-security/codeql-cli/codeql-cli-manual/query-compile
#           https://github.com/orgs/codeql/packages

FROM ubuntu:24.04
LABEL \
    org.opencontainers.image.title="codeql" \
    org.opencontainers.image.version="1.0" \
    org.opencontainers.image.description="CodeQL container by Red4Sec" \
    org.opencontainers.image.vendor="Red4Sec" \
    org.opencontainers.image.authors="red4sec.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=24.0.2
ENV DOTNET_VERSION=9.0

# Install requirements
# https://codeql.github.com/docs/codeql-overview/system-requirements

RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils \
        apt-transport-https \
        software-properties-common \
        curl wget git jq \
        ca-certificates \
        build-essential \
        unzip gnupg g++ \
        make gcc \
        golang \
        ruby-full \
        default-jdk \
        python3-pip python3-setuptools python3-wheel \
        python3-venv

# Create Python virtual environment

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install rust

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

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

# https://github.com/orgs/codeql/packages

# Download CodeQL packs

RUN codeql pack download \
    codeql/rust-all \
    codeql/rust-queries \
    codeql/actions-all \
    codeql/actions-queries \
    codeql/go-all \
    codeql/go-queries \
    codeql/cpp-all \
    codeql/cpp-queries \
    codeql/javascript-all \
    codeql/javascript-queries \
    codeql/python-all \
    codeql/python-queries \
    codeql/csharp-all \
    codeql/csharp-queries \
    codeql/java-all \
    codeql/java-queries

# Check codeql version

RUN codeql version && \
    codeql resolve queries && \
    codeql resolve packs && \
    codeql resolve languages

# Add Microsoft package feed for .NET

RUN add-apt-repository ppa:dotnet/backports && \
    apt-get update && \
    apt-get install -y --no-install-recommends dotnet-sdk-$DOTNET_VERSION && \
    dotnet --version

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
