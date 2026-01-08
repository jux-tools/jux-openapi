#!/bin/bash
# Lint OpenAPI specifications using Spectral
#
# Usage: ./scripts/lint.sh
#
# Requires: podman or docker, or spectral installed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Linting OpenAPI specifications..."

# Check for container runtime
if command -v podman &> /dev/null; then
    RUNTIME="podman"
elif command -v docker &> /dev/null; then
    RUNTIME="docker"
else
    echo "Error: podman or docker required"
    exit 1
fi

# Lint submission spec
echo ""
echo "=== Linting openapi-submission.yaml ==="
$RUNTIME run --rm \
    -v "$PROJECT_ROOT:/work:ro" \
    stoplight/spectral lint \
    --ruleset /work/.spectral.yaml \
    /work/specs/v1/openapi-submission.yaml

# Lint query spec
echo ""
echo "=== Linting openapi-query.yaml ==="
$RUNTIME run --rm \
    -v "$PROJECT_ROOT:/work:ro" \
    stoplight/spectral lint \
    --ruleset /work/.spectral.yaml \
    /work/specs/v1/openapi-query.yaml

echo ""
echo "Linting complete."
