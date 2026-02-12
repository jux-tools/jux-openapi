<!-- SPDX-FileCopyrightText: 2026 Georges Martin <jrjsmrtn@gmail.com> -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# Jux API Versioning Policy

**Version**: 1.0
**Last Updated**: 2025-01-24
**Status**: Active

## Overview

This document defines the versioning policy for the Jux API contract. The policy ensures predictable evolution, backward compatibility commitments, and clear migration paths for client and server implementations.

## Semantic Versioning

The Jux API follows [Semantic Versioning 2.0.0](https://semver.org/) with API-specific interpretations:

### Version Format: MAJOR.MINOR.PATCH

- **MAJOR** (e.g., 1.0.0 → 2.0.0): Breaking changes requiring client updates
- **MINOR** (e.g., 1.0.0 → 1.1.0): New features that are backward compatible
- **PATCH** (e.g., 1.0.0 → 1.0.1): Bug fixes and clarifications that are backward compatible

### Version Examples

```
v1.0.0 - Initial stable release
v1.0.1 - Bug fix: Correct success_rate calculation for edge case
v1.1.0 - New feature: Add GraphQL endpoint (backward compatible)
v2.0.0 - Breaking change: Change pagination response structure
```

## What Constitutes a Breaking Change?

### MAJOR Version Bump Required

Breaking changes include any modifications that **require existing clients to update their code**:

#### 1. **Endpoint Changes**
- Removing an endpoint (e.g., delete `POST /api/v1/junit/submit`)
- Renaming an endpoint (e.g., `/test_runs` → `/runs`)
- Changing HTTP method (e.g., POST → PUT)

#### 2. **Request Changes**
- Removing required fields from request body
- Making optional fields required
- Changing field data types (e.g., string → integer)
- Changing request format (e.g., JSON → XML)
- Removing support for query parameters

#### 3. **Response Changes**
- Removing fields from response body
- Changing field data types in responses
- Changing HTTP status codes for success scenarios
- Restructuring response payload format

#### 4. **Authentication Changes**
- Changing authentication mechanism (e.g., Bearer token → OAuth2)
- Removing localhost authentication bypass
- Adding authentication requirement to previously public endpoint

#### 5. **Behavior Changes**
- Changing calculation logic (e.g., success_rate formula)
- Changing default values for query parameters
- Changing sorting or filtering behavior

### Examples of Breaking Changes

❌ **Breaking**: Remove `project` field from test_run response
```json
// v1.0.0 (old)
{"id": "123", "project": "my-app"}

// v2.0.0 (breaking)
{"id": "123"}  // project removed
```

❌ **Breaking**: Change success_rate from float to integer
```json
// v1.0.0 (old)
{"success_rate": 87.5}

// v2.0.0 (breaking)
{"success_rate": 88}  // rounded to integer
```

❌ **Breaking**: Require authentication for localhost
```bash
# v1.0.0 (old)
curl http://localhost:4000/api/v1/test_runs  # Works

# v2.0.0 (breaking)
curl http://localhost:4000/api/v1/test_runs  # 401 Unauthorized
```

## What is NOT a Breaking Change?

### MINOR Version Bump (Backward Compatible)

Non-breaking changes include additions that **do not require existing clients to update**:

#### 1. **Additive Endpoint Changes**
- Adding new endpoints (e.g., add `POST /api/v1/junit/submit-batch`)
- Adding new HTTP methods to existing resources (e.g., add PATCH to supplement PUT)

#### 2. **Additive Request Changes**
- Adding optional query parameters
- Adding optional fields to request body
- Accepting new enum values for existing fields

#### 3. **Additive Response Changes**
- Adding new fields to response body (clients ignore unknown fields)
- Adding new HTTP status codes for edge cases (e.g., add 429 Rate Limit)
- Adding response headers

#### 4. **Behavior Enhancements**
- Improving performance without changing output
- Adding new filter options as query parameters
- Expanding validation to accept more inputs

### Examples of Non-Breaking Changes

✅ **Non-Breaking**: Add optional `limit` parameter
```bash
# v1.0.0 (old)
GET /api/v1/test_runs?page=1  # Works

# v1.1.0 (new)
GET /api/v1/test_runs?page=1&limit=50  # Works with new param
GET /api/v1/test_runs?page=1  # Still works without new param
```

✅ **Non-Breaking**: Add new field to response
```json
// v1.0.0 (old)
{"id": "123", "project": "my-app"}

// v1.1.0 (new)
{"id": "123", "project": "my-app", "tags": ["ci", "nightly"]}
// Old clients ignore "tags" field
```

✅ **Non-Breaking**: Add new endpoint
```
v1.0.0: POST /api/v1/junit/submit exists
v1.1.0: POST /api/v1/junit/submit-batch added (v1 endpoint unchanged)
```

## Deprecation Policy

Before removing functionality (breaking change), features must be **deprecated for 2 MAJOR versions**:

### Deprecation Process

1. **Announcement** (MINOR version)
   - Mark feature as deprecated in OpenAPI spec
   - Add `Deprecated: true` response header
   - Update CHANGELOG-API.md with deprecation notice
   - Provide migration guide

2. **Warning Period** (at least 2 MAJOR versions)
   - Feature continues to work fully
   - Documentation shows deprecation warnings
   - Clients encouraged to migrate

3. **Removal** (MAJOR version after warning period)
   - Feature removed in new MAJOR version
   - Previous MAJOR version still supported for 12 months

### Deprecation Example

```
v1.0.0: Feature X introduced
v1.5.0: Feature X deprecated (warning added)
       Migration guide provided for Feature Y
v2.0.0: Feature X still works (warning continues)
v3.0.0: Feature X removed (clients must use Feature Y)
       v2.x supported for 12 months
```

### Deprecation Notice Format

**Response Header**:
```
Deprecated: true
Sunset: 2026-01-24T00:00:00Z
Link: <https://docs.jux.dev/migrations/feature-x-to-y>; rel="deprecation"
```

**OpenAPI Spec**:
```yaml
deprecated: true
x-deprecation:
  date: "2025-06-01"
  sunset: "2026-01-24"
  migration_guide: "https://docs.jux.dev/migrations/feature-x-to-y"
```

## Version Support Windows

### Support Levels

| Version Status | Support Level | Duration |
|----------------|--------------|----------|
| **Current MAJOR** | Full support: new features, bug fixes, security updates | Ongoing |
| **Previous MAJOR** | Security updates only | 12 months after new MAJOR release |
| **Older MAJOR** | Unsupported (best-effort community support) | N/A |

### Example Support Timeline

```
2025-01-24: v1.0.0 released (current)
2025-06-01: v1.5.0 released (current, minor update)
2026-01-24: v2.0.0 released (current)
            v1.x supported for security updates (12 months)
2027-01-24: v1.x end of support
            v2.x current
2027-06-01: v3.0.0 released (current)
            v2.x supported for security updates (12 months)
            v1.x unsupported
```

## URL Versioning Strategy

### API Version in URL Path

The API version is included in the URL path for clear versioning:

```
/api/v1/junit/submit   - Version 1.x endpoints
/api/v2/junit/submit   - Version 2.x endpoints (future)
```

### No Version = Latest Stable

Endpoints without version prefix redirect to current stable:

```
/api/junit/submit → /api/v1/junit/submit (redirects to latest stable)
```

**Recommendation**: Clients should always specify version explicitly to avoid surprises.

### Version Negotiation

Clients can request specific version via header (future):

```http
Accept: application/vnd.jux.v1+json
```

Currently only URL-based versioning is supported.

## Migration Support

### Migration Guides

For each MAJOR version, comprehensive migration guides are provided:

- **Side-by-side comparisons** of old vs new API calls
- **Code examples** in multiple languages
- **Automated migration scripts** where possible
- **Deprecation timelines** with sunset dates

**Location**: `docs/migrations/v1-to-v2.md`

### Testing Against Multiple Versions

During deprecation period, clients can test against both versions:

```bash
# Test against current stable (v1)
curl http://localhost:4000/api/v1/test_runs

# Test against next version (v2 preview)
curl http://localhost:4000/api/v2/test_runs
```

### Version-Specific Documentation

Each API version has dedicated documentation:

- OpenAPI specs: `openapi-submission-v1.yaml`, `openapi-submission-v2.yaml`
- Changelogs: `CHANGELOG-API.md` (all versions tracked)
- Guides: Version-specific integration guides

## Backward Compatibility Commitments

### Client Expectations

**Clients can rely on**:
- No breaking changes within MAJOR version
- Additive changes only in MINOR versions
- Bug fixes without behavior changes in PATCH versions
- 2 MAJOR version deprecation warning period
- 12-month support window for previous MAJOR version

**Clients must tolerate**:
- New optional fields in responses (ignore unknown fields)
- New HTTP status codes for edge cases
- New query parameters (clients don't have to use them)
- Performance improvements

### Server Implementation Requirements

**Server implementations MUST**:
- Implement full OpenAPI specification for claimed version
- Return documented HTTP status codes
- Accept all specified request formats
- Include all documented response fields
- Follow authentication patterns

**Server implementations MAY**:
- Add vendor-specific extensions (prefixed with `x-vendor-`)
- Provide additional response fields beyond spec
- Accept additional optional parameters
- Implement optimizations

## API Evolution Process

### 1. Proposal Phase
- New features proposed via GitHub Issues
- Community discussion and feedback
- Design review by maintainers

### 2. Specification Phase
- OpenAPI spec updated with proposed changes
- Breaking vs non-breaking analysis
- Version bump determination (MAJOR/MINOR/PATCH)

### 3. Implementation Phase
- Reference implementation in official server (jux/jux_team_server)
- Conformance tests added
- Documentation updated

### 4. Release Phase
- CHANGELOG-API.md updated
- Migration guides published (if MAJOR version)
- OpenAPI specs released as GitHub assets
- Announcement to community

## Conformance Testing

All server implementations claiming compatibility with a specific API version MUST:

1. **Pass conformance test suite** (see `conformance-tests.md`)
2. **Document version compatibility** in README
3. **Follow deprecation policy** for any extensions

### Self-Certification

Implementations can self-certify by:
1. Running conformance tests
2. Documenting test results
3. Submitting compatibility claim via PR to CHANGELOG-API.md

## Exception Handling

### Emergency Security Fixes

In rare cases, security vulnerabilities may require immediate breaking changes:

- **Process**: Announce on security mailing list, provide 7-day warning if possible
- **Support**: Extended support for affected versions (case-by-case)
- **Documentation**: Incident report published explaining necessity

### Accidental Breaking Changes

If breaking change shipped unintentionally:

- **PATCH release**: Revert breaking change if caught quickly
- **MINOR release**: Restore old behavior, add new behavior as opt-in
- **Communication**: Incident report, apology, lessons learned

## Community Involvement

### RFC Process for Major Changes

MAJOR version changes require RFC (Request for Comments):

1. Draft RFC with proposed changes
2. 30-day comment period
3. Address feedback and revise
4. Final approval by maintainers
5. Implementation begins

**Location**: `docs/rfcs/` directory

### Third-Party Implementation Input

Maintainers of third-party implementations have input on:
- Breaking change proposals
- Deprecation timelines
- Migration guide content

## References

- [Semantic Versioning 2.0.0](https://semver.org/)
- [HTTP API Design Guidelines (Microsoft)](https://github.com/microsoft/api-guidelines)
- [OpenAPI Versioning Best Practices](https://swagger.io/specification/)
- [Stripe API Versioning](https://stripe.com/docs/api/versioning) (inspiration)

---

**Maintained by**: Jux Core Team
**Feedback**: https://github.com/jrjsmrtn/jux-tools/issues
**Version**: 1.0
**Effective Date**: 2025-01-24
