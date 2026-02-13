<!-- SPDX-FileCopyrightText: 2026 Georges Martin <jrjsmrtn@gmail.com> -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Jux API Changelog

This document tracks changes to the Jux API contract independently from application releases. The API version follows [Semantic Versioning](https://semver.org/).

## API Version Format

- **MAJOR**: Breaking changes that require client updates
- **MINOR**: New features that are backward compatible
- **PATCH**: Bug fixes and clarifications that are backward compatible

## Version Support Policy

- **Current major version**: Full support (new features, bug fixes, security updates)
- **Previous major version**: Security updates only for 12 months after new major release
- **Older versions**: Unsupported (best-effort community support)

See [VERSIONING.md](VERSIONING.md) for complete policy details.

---

## v1.0.0 (2025-01-24) - Initial Stable Release

**Status**: Current stable version
**Server Implementations**: jux v0.3.0+, jux_team_server v0.2.0+ (future)
**Client Implementations**: pytest-jux v0.4.0+

### Submission API

#### POST /api/v1/junit/submit

**Accepts**:
- Content-Type: `application/xml`
- Request body: JUnit XML with embedded metadata in `<properties>` elements

**Metadata Properties** (optional, embedded in XML):
- `project`: Project identifier (fallback: "unknown")
- `git:branch`: Git branch name
- `git:commit`: Git commit SHA
- `ci:provider`: CI/CD provider (github, gitlab, jenkins, etc.)
- `ci:build_id`: CI/CD build identifier
- `ci:build_url`: Link to CI/CD build
- `jux:pytest_jux_version`: Client plugin version
- `jux:timestamp`: Submission timestamp (ISO 8601)

**Returns**:
- **201 Created**: Successful submission with test_run object
- **400 Bad Request**: Empty request body or missing required data
- **422 Unprocessable Entity**: Invalid JUnit XML format

**Authentication**:
- Localhost submissions (`127.0.0.1`, `::1`, `localhost`): No authentication required
- Remote submissions: Bearer token required in `Authorization` header

**Example Request**:
```xml
POST /api/v1/junit/submit HTTP/1.1
Host: localhost:4000
Content-Type: application/xml

<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="MyTests" tests="10" failures="2" errors="1" time="5.5">
  <properties>
    <property name="project" value="my-application"/>
    <property name="git:branch" value="main"/>
    <property name="git:commit" value="abc123def456"/>
  </properties>
  <testcase classname="MathTest" name="test_addition" time="0.1"/>
  <!-- ... more test cases ... -->
</testsuite>
```

**Example Response** (201 Created):
```json
{
  "status": "success",
  "message": "Test report submitted successfully",
  "test_run": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "project": "my-application",
    "branch": "main",
    "commit_sha": "abc123def456",
    "total_tests": 10,
    "failures": 2,
    "errors": 1,
    "skipped": 0,
    "success_rate": 70.0,
    "created_at": "2025-01-24T10:30:00Z"
  }
}
```

### Query API

#### GET /api/v1/test_runs

**Query Parameters**:
- `page` (integer, default: 1): Page number for pagination
- `limit` (integer, default: 20, max: 100): Number of results per page
- `project` (string, optional): Filter by project name
- `branch` (string, optional): Filter by git branch
- `date_from` (ISO 8601, optional): Filter by creation date (inclusive)
- `date_to` (ISO 8601, optional): Filter by creation date (inclusive)

**Returns**:
- **200 OK**: Paginated list of test runs with metadata

**Authentication**:
- Same as Submission API (localhost bypass, remote requires Bearer token)

**Example Request**:
```
GET /api/v1/test_runs?project=my-app&page=1&limit=10 HTTP/1.1
Host: localhost:4000
```

**Example Response** (200 OK):
```json
{
  "test_runs": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "project": "my-app",
      "branch": "main",
      "commit_sha": "abc123",
      "total_tests": 10,
      "failures": 2,
      "errors": 1,
      "skipped": 0,
      "success_rate": 70.0,
      "created_at": "2025-01-24T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "total_pages": 5,
    "total_count": 42,
    "limit": 10
  }
}
```

### OpenAPI Specifications

- **Submission API**: [openapi-submission-v1.yaml](openapi-submission-v1.yaml)
- **Query API**: [openapi-query-v1.yaml](openapi-query-v1.yaml)

### Breaking Changes

- None (initial release)

### Deprecations

- None

### Known Limitations

- No GraphQL endpoint (planned for v1.1.0)
- No webhook notifications (planned for v1.2.0)
- No bulk submission endpoint (planned for v1.1.0)
- No streaming API for real-time updates (planned for v2.0.0)

---

## Planned Changes

### v1.1.0 (Planned - Q2 2025)

**New Features** (backward compatible):
- GraphQL endpoint at `/api/v1/graphql` for flexible queries
- Bulk submission endpoint: `POST /api/v1/junit/submit-batch`
- Webhook registration for test completion notifications
- Additional query filters: `status`, `min_failures`, `max_failures`

**Non-Breaking Changes**:
- All existing v1.0.0 endpoints remain unchanged
- New endpoints are additive only
- Existing clients continue working without modification

### v1.2.0 (Planned - Q3 2025)

**New Features** (backward compatible):
- Webhook delivery management (retry, backoff, monitoring)
- Custom metadata fields in test_run
- Search API with full-text search on test names and failure messages

### v2.0.0 (Planned - Q4 2025)

**Breaking Changes** (will require client updates):
- Remove deprecated v1.0 authentication header format (if any deprecations occur)
- Potentially change pagination response structure to include HATEOAS links
- Streaming API may change request/response formats

**Migration Path**:
- v1.x will be supported for 12 months after v2.0.0 release
- Migration guides will be provided
- Deprecation warnings added in v1.x releases leading up to v2.0.0

---

## Compatibility Matrix

| API Version | Server: jux | Server: jux_team_server | Client: pytest-jux | Client: junit-jux | Client: jest-jux |
|-------------|-------------|-------------------------|-------------------|-------------------|------------------|
| v1.0.0      | v0.3.0+     | v0.2.0+ (future)        | v0.4.0+           | Future            | Future           |
| v1.1.0      | v0.4.0+     | v0.3.0+ (future)        | v0.5.0+ (planned) | Future            | Future           |

---

## Migration Guides

### From Pre-release (JSON envelope) to v1.0.0 (Direct XML)

**Old Format** (pre-v1.0.0):
```json
POST /api/junit/submit
Content-Type: application/json

{
  "xml_content": "<?xml version='1.0'?>...",
  "project": "my-app",
  "branch": "main"
}
```

**New Format** (v1.0.0):
```xml
POST /api/v1/junit/submit
Content-Type: application/xml

<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="Tests" tests="10">
  <properties>
    <property name="project" value="my-app"/>
    <property name="git:branch" value="main"/>
  </properties>
  <!-- test cases -->
</testsuite>
```

**Migration Steps**:
1. Update client to send raw XML instead of JSON envelope
2. Embed metadata in `<properties>` elements within XML
3. Change Content-Type header from `application/json` to `application/xml`
4. Update API endpoint from `/api/junit/submit` to `/api/v1/junit/submit`

---

## Community Contributions

Third-party client and server implementations are encouraged! To be listed in the compatibility matrix:

1. Implement conformance tests (see [conformance-tests.md](conformance-tests.md))
2. Document API version compatibility
3. Submit PR to update this changelog with your implementation

**Community Implementations**:
- None yet - be the first!

---

## Feedback and Support

- **Issues**: Report API bugs at https://github.com/jux-tools/jux-tools/issues
- **Discussions**: API design discussions at https://github.com/jux-tools/jux-tools/discussions
- **Documentation**: See [docs/guides/](../guides/) for integration guides

---

**Last Updated**: 2026-01-08
**Maintainers**: Jux Core Team (@jrjsmrtn)
