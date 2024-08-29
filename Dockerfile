# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG GO_VERSION
ARG GO_AMD64_SHA256_CHECKSUM
ARG GO_ARM64_SHA256_CHECKSUM

# hadolint ignore=DL4006,SC2086,SC3040
RUN \
    set -E -e -o pipefail \
    && export HOMELAB_VERBOSE=y \
    # Install go. \
    && homelab install-go \
        ${GO_VERSION:?} \
        ${GO_AMD64_SHA256_CHECKSUM:?} \
        ${GO_ARM64_SHA256_CHECKSUM:?} \
    # Clean up. \
    && homelab remove gpg \
    && homelab cleanup

ENV GOROOT="/opt/go"
ENV GOPATH="/go"
ENV GOTOOLCHAIN="local"
ENV PATH="$GOPATH/bin:/opt/go/bin:${PATH}"

STOPSIGNAL SIGHUP
