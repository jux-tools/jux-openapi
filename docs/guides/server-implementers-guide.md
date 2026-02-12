# Server Implementer's Guide

**Version**: 1.0
**Last Updated**: 2026-02-12
**Status**: Draft

## Overview

This guide provides recommendations for server implementations that consume `.jxz` signed containers submitted via the package endpoint defined in [ADR-0003](../adr/0003-signed-container-package-support.md).

It covers the server-side handling chain from receiving a `.jxz` upload through verification, unpacking, and storage. These are non-normative recommendations — implementations may adapt them to their specific technology stack and deployment model.

## Package Reception

### Endpoint

```
POST /api/v{N}/reports/package
Content-Type: application/vnd.jux.report+zip
```

### Request Validation (Before Unpacking)

Servers SHOULD validate the following before any ZIP extraction:

1. **Content-Type** matches `application/vnd.jux.report+zip`
2. **Content-Length** is within configured limits (recommended default: 50 MB)
3. **Request body** is a valid ZIP archive (check magic bytes: `PK\x03\x04`)

Reject invalid requests with `400 Bad Request` before allocating resources for extraction.

### Size Limits

Configure maximum package size based on deployment context:

| Deployment | Recommended Limit | Rationale |
|------------|-------------------|-----------|
| Local workstation | 100 MB | Generous for development use |
| Team server | 50 MB | Balance between utility and resource protection |
| CI/CD high-throughput | 25 MB | Protect against pipeline misconfiguration |

Return `413 Payload Too Large` with a `Retry-After` header if rate limiting applies.

## Verification Chain

Follow the verification process defined in the [jux-container-format specification](../../../jux-container-format/specs/v1/jxz-format.md):

### Step 1: Extract Manifest and Signature

Extract only `META-INF/MANIFEST.MF` and `META-INF/SIGNATURE.XML` initially. Do not extract the full archive until verification passes.

**ZIP Slip Protection**: When extracting, validate that resolved paths do not escape the extraction directory. Reject archives containing entries with `..` path components or absolute paths.

### Step 2: Verify Signature

If `META-INF/SIGNATURE.XML` is present:
- Verify the XMLDSIG signature against the manifest content
- Validate the signing certificate against the server's trust store
- Reject containers with invalid signatures (`422 Unprocessable Entity`)

If `META-INF/SIGNATURE.XML` is absent:
- Apply server policy (accept or reject unsigned containers)
- Local/development servers may accept unsigned containers
- Production/team servers SHOULD require signatures

### Step 3: Validate Digests

For each entry listed in `META-INF/MANIFEST.MF`:
- Compute SHA-256 digest of the corresponding file in the archive
- Compare against the digest recorded in the manifest
- Reject on any mismatch (`422 Unprocessable Entity`)

Also verify:
- All files in the archive (except `META-INF/MANIFEST.MF` itself) have a corresponding manifest entry
- No manifest entries reference files absent from the archive

### Step 4: Parse and Process

After verification passes:
- Parse `junit.xml` as a standard JUnit XML report
- Resolve attachment references against manifest entries
- Process metadata from manifest main section (`Created-By`, `Report-Type`, `Timestamp`)

## Attachment Storage

### Recommended Architecture: Hybrid Storage

Store attachment metadata in the database, attachment content on the filesystem or object storage:

```
Database (metadata only):
  attachments table:
    - id (UUID)
    - name (original filename)
    - mime_type
    - sha256_hash
    - file_size
    - storage_path (relative)
    - scope (report | suite | case)
    - test_run_id (FK)

Filesystem / Object Storage (content):
  {storage_root}/
  ├── attachments/
  │   └── {sha256_prefix}/{sha256}/{original_filename}
  └── packages/          # Optional: original .jxz archives
      └── {test_run_id}.jxz
```

**Rationale**: Keeping binary content out of the database avoids blob-related performance degradation, simplifies backups, and allows the storage backend to scale independently.

### Deduplication

Use SHA-256 digests (already computed during verification) as deduplication keys:
- Before storing an attachment, check if a file with the same SHA-256 already exists
- If it exists, create a metadata record pointing to the existing file
- If it doesn't exist, store the file and create the metadata record

This is particularly effective for screenshots and logs that repeat across test runs.

### Storage Backends

Implementations should support at least one of:

| Backend | Use Case | Notes |
|---------|----------|-------|
| Local filesystem | Workstation, small team | Simple, fast, no dependencies |
| S3-compatible | Team server, cloud | Scalable, durable, supports signed URLs |
| NFS/shared filesystem | On-premise team | Shared access without object storage |

### MIME Type Handling

Maintain an allowlist of accepted MIME types for attachments:

```
image/png, image/jpeg, image/gif, image/svg+xml
text/plain, text/html, text/csv
application/json, application/xml
application/pdf
video/mp4, video/webm
```

Reject or quarantine attachments with unrecognized MIME types.

### Original Package Preservation

Optionally preserve the original `.jxz` container for audit purposes:
- Store in a separate `packages/` directory
- Index by test run ID
- Useful for re-verification or compliance requirements
- Can be pruned by retention policy independently of extracted data

## Cleanup and Retention

### Orphan Detection

Failed transactions may leave unreferenced files on the storage backend. Implement a periodic cleanup job that:
1. Lists all files in the attachment storage directory
2. Checks each against the database metadata
3. Removes files with no corresponding metadata record (after a grace period)

### Retention Policies

Consider configurable retention policies:

| Data | Suggested Default | Notes |
|------|-------------------|-------|
| Test run metadata | Indefinite | Small, valuable for trends |
| Attachment metadata | Match test run | Referential integrity |
| Attachment files | 90 days | Configurable per deployment |
| Original packages | 30 days | Optional, high storage cost |

## Error Handling

### Error Responses for Package Endpoints

| Scenario | HTTP Status | Error Message |
|----------|-------------|---------------|
| Not a ZIP file | 400 | "Invalid package: not a ZIP archive" |
| Missing MANIFEST.MF | 422 | "Invalid .jxz: missing META-INF/MANIFEST.MF" |
| Missing junit.xml | 422 | "Invalid .jxz: missing junit.xml" |
| Signature verification failed | 422 | "Package signature verification failed" |
| Digest mismatch | 422 | "Package integrity check failed: {filename}" |
| Unsigned (when required) | 422 | "Package signature required" |
| Package too large | 413 | "Package exceeds size limit ({limit} bytes)" |
| ZIP slip detected | 400 | "Invalid package: path traversal detected" |

All error responses should follow the standard error format defined in the Jux API specification.

## Security Checklist

- [ ] Validate ZIP structure before extraction
- [ ] Protect against ZIP slip (path traversal)
- [ ] Verify signature before extracting content files
- [ ] Validate all manifest digests before processing
- [ ] Enforce attachment MIME type allowlist
- [ ] Configure maximum package size
- [ ] Rate limit package submissions
- [ ] Isolate extraction to temporary directories with restricted permissions
- [ ] Clean up temporary files on failure

## References

- [jux-container-format specification](../../../jux-container-format/specs/v1/jxz-format.md)
- [ADR-0003: Signed Container Package Support](../adr/0003-signed-container-package-support.md)
- [OWASP: Zip Slip Vulnerability](https://snyk.io/research/zip-slip-vulnerability)
