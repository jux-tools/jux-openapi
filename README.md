<!-- SPDX-FileCopyrightText: 2026 Georges Martin <jrjsmrtn@gmail.com> -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# jux-openapi

OpenAPI specifications for the Jux REST API.

## Overview

This repository contains the **single source of truth** for the Jux API contract. Both server (jux) and client (pytest-jux) implementations should conform to these specifications.

## Quick Start

### View API Documentation

```bash
# Using Swagger UI (via Docker/Podman)
podman run -p 8080:8080 -e SWAGGER_JSON=/spec/openapi-submission.yaml \
  -v "$(pwd)/specs/v1:/spec" swaggerapi/swagger-ui
# Open http://localhost:8080
```

### Validate Specifications

```bash
./scripts/validate.sh
./scripts/lint.sh
```

## API Endpoints

### Submission API (v1)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/junit/submit` | Submit JUnit XML test results |

### Query API (v1)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/test_runs` | List test runs with filtering |
| GET | `/api/v1/test_runs/{id}` | Get test run details |
| GET | `/api/v1/test_runs/{id}/test_suites` | List test suites |
| GET | `/api/v1/test_suites/{id}/test_cases` | List test cases |

## Implementations

| Project | Type | Status |
|---------|------|--------|
| [jux](../jux) | Server (Elixir/Phoenix) | Compliant (v0.3.0+) |
| [pytest-jux](../pytest-jux) | Client (Python) | Compliant (v0.4.0) |

## Documentation

- [Versioning Policy](docs/VERSIONING.md)
- [API Changelog](docs/CHANGELOG.md)
- [Architecture Decision Records](docs/adr/)

## License

MIT
