# Conformance Testing

This directory will contain conformance tests for validating server implementations against the Jux API contract.

## Status

**Status**: Planned (not yet implemented)

## Future Contents

- `test-submission.sh` - Test submission endpoint conformance
- `test-query.sh` - Test query endpoint conformance
- `fixtures/` - Test JUnit XML samples
- `expected/` - Expected response payloads

## Running Conformance Tests

```bash
# Against localhost
./conformance/run-all.sh http://localhost:4000

# Against team server
./conformance/run-all.sh https://team-jux.example.com
```

## Implementation Requirements

Server implementations claiming API v1.0.0 compatibility must:

1. Pass all conformance tests
2. Document any extensions (vendor-prefixed)
3. Follow versioning policy (see `docs/VERSIONING.md`)
