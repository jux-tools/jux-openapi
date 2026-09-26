# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**jux-openapi** is the single source of truth for the Jux REST API contract. It contains OpenAPI specifications that define the interface between:
- **jux** (Elixir/Phoenix server) - implements the API
- **pytest-jux** (Python client) - consumes the API
- Future clients (junit-jux, jest-jux, etc.)

## Repository Structure

```
jux-openapi/
├── specs/
│   └── v1/
│       ├── openapi-submission.yaml   # POST /api/v1/junit/submit
│       └── openapi-query.yaml        # GET /api/v1/test_runs, etc.
├── docs/
│   ├── VERSIONING.md                 # Semantic versioning policy
│   ├── CHANGELOG.md                  # API version history
│   ├── adr/                          # Architecture Decision Records
│   └── architecture/
│       └── jux-api-architecture.dsl  # C4 model
├── scripts/
│   ├── validate.sh                   # OpenAPI validation
│   └── lint.sh                       # Spectral linting
├── conformance/
│   └── README.md                     # Conformance test framework (future)
└── .spectral.yaml                    # Linting rules
```

## Commands

### Validate OpenAPI Specs
```bash
./scripts/validate.sh
```

### Lint OpenAPI Specs
```bash
./scripts/lint.sh
```

### View C4 Architecture
```bash
podman run -it --rm -p 8080:8080 \
  -v "$(pwd)/docs/architecture:/usr/local/structurizr" \
  structurizr/lite
# Open http://localhost:8080
```

## API Versions

| Version | Status | Description |
|---------|--------|-------------|
| v1.0.1 | Current | Licence metadata corrected to Apache-2.0 |
| v1.0.0 | Superseded | Initial stable release |

## Versioning Policy

- **MAJOR**: Breaking changes (require client updates)
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes and clarifications

See `docs/VERSIONING.md` for complete policy.

## Related Projects

| Project | Relationship |
|---------|--------------|
| `jux/` | Server implementation (compliant with v1.0.0) |
| `pytest-jux/` | Client implementation (compliant with v1.0.0) |

## Development Guidelines

### Modifying Specs
1. Edit specs in `specs/v1/`
2. Run `./scripts/validate.sh` to check syntax
3. Run `./scripts/lint.sh` to check style
4. Update `docs/CHANGELOG.md`
5. Bump version if needed per `docs/VERSIONING.md`

### Breaking Changes
- Require MAJOR version bump
- 2-version deprecation period
- Migration guide required

### Adding New Endpoints
- Add to appropriate spec file
- MINOR version bump
- Update CHANGELOG.md

## Git Configuration

- **Primary remote**: `home` (private git server)
- **Secondary remote**: `github` (public)
- **Branch strategy**: Gitflow (develop → main)

## ADR Format

```markdown
# ADR-NNNN: Title

## Status
Proposed | Accepted | Deprecated | Superseded

## Context
Why this decision is needed.

## Decision
What we decided.

## Consequences
What results from the decision.
```

## Status

**Current Version**: 1.0.1
**API Status**: Stable
**Server Compliance**: jux v0.3.0+ compliant
**Client Compliance**: pytest-jux v0.4.0 compliant
