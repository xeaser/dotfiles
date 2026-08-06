#!/usr/bin/env bash
# Build the AWS SigV4 proxy used by the opencode `bedrock-mantle` and `bedrock-codex`
# providers (signs requests to the codex-bedrock account so GPT-5.x / Converse models
# work without static credentials). Output: ~/go/bin/aws-sigv4-proxy
#
# Requires: go, git. Run once per machine (or to update the proxy).
set -euo pipefail

dst="$HOME/go/bin/aws-sigv4-proxy"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Cloning awslabs/aws-sigv4-proxy..."
git clone --depth 1 https://github.com/awslabs/aws-sigv4-proxy.git "$tmp/src" >/dev/null 2>&1

echo "Building -> $dst"
mkdir -p "$HOME/go/bin"
( cd "$tmp/src" && go build -o "$dst" ./cmd/aws-sigv4-proxy )

echo "Built aws-sigv4-proxy at $dst"
