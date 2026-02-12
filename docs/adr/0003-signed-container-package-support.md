# ADR-0003: Signed Container Package Support

## Status

Proposed

## Context

pytest-jux currently signs individual JUnit XML files using XML digital signatures (XMLDSig) before publishing to the Jux REST API. However, pytest test reports frequently reference external attachments (screenshots, logs, binary artifacts) via URLs or file paths within the XML structure.

Current limitations:
- JUnit XML contains only references to attachments, not the artifacts themselves
- No mechanism to bundle attachments with their associated test report
- Integrity verification applies only to XML, not referenced artifacts
- Attachment availability depends on external systems remaining accessible
- No unified signature covering both report and its attachments

The `.jxz` signed container format is defined in the [jux-container-format](../../../jux-container-format/) project (see `specs/v1/jxz-format.md`). This ADR addresses the jux-openapi specification changes needed to support that format.

## Decision

Add endpoints supporting the `.jxz` signed container package format as defined in the jux-container-format specification.

**API Endpoints:**
```
POST /api/v{N}/reports/package
  Content-Type: application/vnd.jux.report+zip

GET /api/v{N}/reports/{id}/package
  Accept: application/vnd.jux.report+zip
```

The version number will be determined by the jux-openapi versioning policy (see `docs/VERSIONING.md`). If package support is additive and backward-compatible, it may fit in v1; otherwise it warrants a new major version.

**Server-Side Verification Chain:**
1. Verify package signature (`META-INF/SIGNATURE.XML`) against manifest
2. Verify manifest SHA-256 digests against contained files
3. Parse `junit.xml` and resolve attachment references against manifest entries

**Backward Compatibility:**
- Existing `/api/v1/junit/submit` endpoint for XML-only uploads remains unchanged
- Package endpoints are additive; clients may continue sending XML-only
- Package format is optional

## Consequences

### Positive

- Self-contained test reports include all referenced artifacts
- Complete integrity verification from publication to storage
- Simplified artifact management (no external URL dependencies)
- Supports offline review of complete test results
- Enables selective sharing of complete test contexts

### Negative

- Increased storage requirements for attachment data
- Larger network transfers for package uploads
- Additional complexity in signature verification chain
- Client implementations must support ZIP archive creation

### Risks and Mitigations

- **Large payloads**: Implement configurable package size limits; provide streaming upload support
- **ZIP vulnerabilities**: Use well-audited ZIP libraries (e.g., Erlang's `:zip` module); mandatory ZIP slip protection in unpacking code
- **Manifest evolution**: Version manifest schema explicitly via `Jux-Version` header (see jux-container-format spec)

### Security Considerations

- Signature verification must occur before any file extraction
- Manifest must explicitly whitelist allowed MIME types
- Attachment size limits prevent resource exhaustion attacks

## References

- [jux-container-format](../../../jux-container-format/) - `.jxz` container structure specification
- [VERSIONING.md](../VERSIONING.md) - API versioning policy for determining endpoint version
- [ZIP File Format Specification (PKWARE)](https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT)
- [OWASP: XML External Entity Prevention](https://cheatsheetseries.owasp.org/cheatsheets/XML_External_Entity_Prevention_Cheat_Sheet.html)
