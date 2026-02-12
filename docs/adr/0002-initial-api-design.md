# ADR-0002: Initial API Design (v1.0.0)

## Status

Accepted (2026-01-08)

## Context

Jux needs a REST API for clients to submit JUnit XML test reports and query stored results. The API must support two deployment scenarios:

1. **Local workstation**: A developer running tests locally submits to `localhost:4000` — low friction, no auth
2. **Team CI/CD**: Automated pipelines submit to a shared server — requires authentication and rate limiting

Key design questions:
- How should clients submit test reports? (raw XML vs JSON envelope vs multipart)
- How should metadata (project, git info, CI context) be transmitted?
- How should authentication work across local and remote scenarios?
- What query capabilities are needed?

## Decision

### Submission: Direct XML with Embedded Metadata

**Endpoint**: `POST /api/v1/junit/submit`
**Content-Type**: `application/xml`

Clients submit raw JUnit XML with metadata embedded in standard `<property>` elements inside `<testsuite>`:

```xml
<testsuite name="Tests" tests="10">
  <properties>
    <property name="project" value="my-app"/>
    <property name="git:branch" value="main"/>
    <property name="git:commit" value="abc123"/>
    <property name="ci:provider" value="github"/>
  </properties>
  ...
</testsuite>
```

**Rationale**: Using `<properties>` is part of the JUnit XML schema, so the submitted document remains valid JUnit XML. No wrapper format needed. Namespaced prefixes (`git:`, `ci:`, `jux:`, `env:`) avoid collisions with test framework properties.

**Alternatives rejected**:
- **JSON envelope** (`{"xml_content": "...", "project": "..."}`) — requires clients to serialize XML inside JSON; metadata separated from report
- **Multipart form** — more complex for clients; metadata in separate parts loses co-location with XML

### Authentication: Localhost Bypass

- **Localhost** (`127.0.0.1`, `::1`, `localhost`): No authentication required
- **Remote**: Bearer token in `Authorization` header

**Rationale**: Local development should be zero-friction. A developer running `pytest --jux-submit` against their own workstation shouldn't need API keys. Remote/team servers require authentication to prevent unauthorized submissions.

### Query API: RESTful with Pagination

- `GET /api/v1/test_runs` — list with filtering (project, branch, status, date range) and pagination
- `GET /api/v1/test_runs/{id}` — detail with nested test suites
- `GET /api/v1/test_runs/{id}/test_suites` — suites for a run
- `GET /api/v1/test_suites/{id}/test_cases` — cases for a suite

**Pagination**: Page-based (`page` + `per_page`, default 20, max 100) with metadata in response (`current_page`, `total_pages`, `total_count`).

**Rationale**: Standard REST patterns. Hierarchical resources (runs > suites > cases) mirror the JUnit XML structure. Page-based pagination is simpler than cursor-based for the expected data volumes.

### URL Versioning

API version in URL path: `/api/v1/...`

**Rationale**: Explicit, visible, and easy to route. Simpler than header-based versioning for debugging and documentation.

### Response Format

- **Success**: JSON with relevant data and summary statistics (`success_rate`, counts)
- **Errors**: Structured JSON with `error`, `details`, and `suggestions` fields

**Rationale**: Actionable error responses reduce client debugging time. The `suggestions` array guides users toward fixes.

### Spec Organization

Two separate OpenAPI files:
- `openapi-submission.yaml` — write path (POST)
- `openapi-query.yaml` — read path (GET)

**Rationale**: Separation of concerns. Submission and query have different auth patterns, rate limits, and evolution trajectories. Clients may implement only one side.

## Consequences

### Positive

- Zero-friction local development (no auth setup needed)
- Standard JUnit XML remains valid after metadata embedding
- Namespaced properties extensible without breaking changes
- Separate spec files allow independent evolution of read/write APIs
- Actionable error responses improve developer experience

### Negative

- Metadata in XML properties is less discoverable than a dedicated metadata endpoint
- Localhost bypass requires careful network configuration in containerized environments
- Two spec files require coordinated versioning for shared schemas
- Page-based pagination may be inefficient for very large result sets

## References

- [JUnit XML Schema](https://github.com/junit-team/junit5/blob/main/platform-tests/src/test/resources/jenkins-junit.xsd) — `<properties>` element specification
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.4.html)
- [HTTP API Design Guidelines (Microsoft)](https://github.com/microsoft/api-guidelines)
