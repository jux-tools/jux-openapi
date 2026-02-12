#!/bin/bash
# SPDX-FileCopyrightText: 2026 Georges Martin <jrjsmrtn@gmail.com>
# SPDX-License-Identifier: Apache-2.0
#
# Validate OpenAPI specifications using openapi-generator-cli
#
# Usage: ./scripts/validate.sh
#
# Requires: podman or docker, or openapi-generator-cli installed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Validating OpenAPI specifications..."

# Check for container runtime
if command -v podman &> /dev/null; then
    RUNTIME="podman"
elif command -v docker &> /dev/null; then
    RUNTIME="docker"
else
    echo "Error: podman or docker required"
    exit 1
fi

# Validate submission spec
echo ""
echo "=== Validating openapi-submission.yaml ==="
$RUNTIME run --rm \
    -v "$PROJECT_ROOT/specs:/specs:ro" \
    openapitools/openapi-generator-cli validate \
    -i /specs/v1/openapi-submission.yaml

# Validate query spec
echo ""
echo "=== Validating openapi-query.yaml ==="
$RUNTIME run --rm \
    -v "$PROJECT_ROOT/specs:/specs:ro" \
    openapitools/openapi-generator-cli validate \
    -i /specs/v1/openapi-query.yaml

echo ""
echo "All specifications are valid."
