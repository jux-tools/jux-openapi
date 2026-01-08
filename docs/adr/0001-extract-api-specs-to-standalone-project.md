# ADR-0001: Extract API Specifications to Standalone Project

## Status

Accepted (2026-01-08)

## Context

The Jux REST API specifications were originally developed within the `jux` server project at `jux/docs/api/`. This location made sense during initial development when the API was tightly coupled to the server implementation.

However, as the ecosystem evolved, several issues emerged:

1. **Multiple Consumers**: Both `jux` (server) and `pytest-jux` (client) need to conform to the API contract. Having the specs in one project creates an implicit dependency direction.

2. **Independent Versioning**: The API contract should version independently from the server implementation. A server bug fix shouldn't require a new API version, and vice versa.

3. **Compliance Gap**: The jux server is NOT YET compliant with the v1.0.0 API specs, while pytest-jux v0.4.0 IS compliant. This asymmetry highlights the need for the spec to be the authoritative source.

4. **Third-Party Implementations**: The API-first architecture (ADR-0013 in jux) envisions community clients and alternative servers. A standalone spec repository enables this ecosystem.

5. **Tooling Requirements**: OpenAPI validation, linting, and conformance testing are better managed in a dedicated project with its own CI/CD pipeline.

## Decision

Extract the Jux REST API specifications to a new standalone project: `jux-openapi`.

### Repository Structure

```
jux-openapi/
├── specs/v1/
│   ├── openapi-submission.yaml
│   └── openapi-query.yaml
├── docs/
│   ├── VERSIONING.md
│   ├── CHANGELOG.md
│   └── adr/
├── scripts/
│   ├── validate.sh
│   └── lint.sh
└── conformance/
```

### Migration Plan

1. Copy specs from `jux/docs/api/` to `jux-openapi/specs/v1/`
2. Keep reference/redirect in original location
3. Update both jux and pytest-jux to reference jux-openapi
4. Establish jux-openapi as the single source of truth

### Version Alignment

- jux-openapi v1.0.0 = API contract v1.0.0
- Future API versions (v2.0.0) get new jux-openapi releases
- Server and client projects reference specific jux-openapi versions

## Consequences

### Positive

1. **Single Source of Truth**: Clear ownership of the API contract
2. **Independent Versioning**: API, server, and client evolve separately
3. **Ecosystem Enablement**: Third parties can build compatible implementations
4. **Better Tooling**: Dedicated validation and conformance testing
5. **Clear Compliance Tracking**: Easy to see which implementations are compliant

### Negative

1. **Additional Repository**: More projects to maintain
2. **Coordination Overhead**: Breaking changes require coordination across projects
3. **Documentation Duplication**: Some content may need to exist in multiple places

### Neutral

1. **No Code Changes**: This is purely a reorganization of specifications
2. **Existing Specs Unchanged**: The OpenAPI content remains the same

## Related Decisions

- **jux ADR-0013**: API-First Architecture (established the need for stable API contract)
- **pytest-jux Sprint 4**: Implemented client compliance with API v1.0.0

## References

- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
- [API Design Guidelines (Microsoft)](https://github.com/microsoft/api-guidelines)
- [Stripe API Versioning](https://stripe.com/docs/api/versioning)
