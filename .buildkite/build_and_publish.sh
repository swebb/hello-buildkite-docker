#!/bin/bash

set -euo pipefail

REGISTRY="packages.buildkite.com/steve-playground/hello-buildkite-docker"
IMAGE="${REGISTRY}/hello-buildkite"
TAG="${IMAGE}:${BUILDKITE_BUILD_NUMBER}"
buildkite-agent oidc request-token --audience "https://${REGISTRY}" --lifetime 300 | docker login ${REGISTRY} --username=buildkite --password-stdin
docker build --no-cache --push -t "${TAG}" .
DIGEST="$(skopeo inspect docker://"${TAG}" --format '{{.Digest}}')"
SIGSTORE_ID_TOKEN="$(buildkite-agent oidc request-token --audience sigstore)"
export SIGSTORE_ID_TOKEN
# now we can sign! This includes pushing the signature to the registry as well
COSIGN_EXPERIMENTAL=1 cosign sign --yes --registry-referrers-mode oci-1-1 "${IMAGE}@${DIGEST}"
