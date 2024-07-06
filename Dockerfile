# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

SHELL ["/bin/bash", "-c"]

ARG GO_VERSION
ARG GO_AMD64_SHA256_CHECKSUM
ARG GO_ARM64_SHA256_CHECKSUM

# hadolint ignore=DL4006,SC2086
RUN \
    set -E -e -o pipefail \
    # Install dependencies. \
    && homelab install gnupg \
    # Download the release. \
    && mkdir -p /tmp/go-download \
    && PKG_ARCH="$(dpkg --print-architecture)" \
    && curl \
        --silent \
        --fail \
        --location \
        --remote-name \
        --output-dir /tmp/go-download https://go.dev/dl/go${GO_VERSION:?}.linux-${PKG_ARCH:?}.tar.gz \
    && curl \
        --silent \
        --fail \
        --location \
        --remote-name \
        --output-dir /tmp/go-download https://go.dev/dl/go${GO_VERSION:?}.linux-${PKG_ARCH:?}.tar.gz.asc \
    # Download the public keys for verification. \
    && gpg --batch --keyserver hkp://keyserver.ubuntu.com --recv-keys "EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796" \
    && gpg --verbose --verify /tmp/go-download/go${GO_VERSION:?}.linux-${PKG_ARCH:?}.tar.gz.asc \
    && if [[ "${PKG_ARCH:?}" == "amd64" ]]; then \
            go_sha256_checksum=${GO_AMD64_SHA256_CHECKSUM:?}; \
        elif [[ "${PKG_ARCH:?}" == "arm64" ]]; then \
            go_sha256_checksum=${GO_ARM64_SHA256_CHECKSUM:?}; \
        else \
            echo "Unsupported arch ${PKG_ARCH:?} for checksum"; \
            exit 1; \
        fi \
    && echo "${go_sha256_checksum:?} /tmp/go-download/go${GO_VERSION:?}.linux-${PKG_ARCH:?}.tar.gz" | sha256sum -c \
    # Unpack and install the release. \
    && tar -C /opt -xvf /tmp/go-download/go${GO_VERSION:?}.linux-${PKG_ARCH:?}.tar.gz \
    # Setup misc directories. \
    && mkdir -p /go /go/src /go/bin \
    # Clean up. \
    && rm -rf /tmp/go-download \
    && homelab remove gpg \
    && homelab cleanup

ENV GOROOT="/opt/go"
ENV GOPATH="/go"
ENV GOTOOLCHAIN="local"
ENV PATH="$GOPATH/bin:/opt/go/bin:${PATH}"

STOPSIGNAL SIGHUP
