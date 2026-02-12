# ADR-0001: Record Architecture Decisions

## Status

Accepted (2026-02-12)

## Context

Design decisions for the Jux REST API contract need to be recorded so that current and future contributors can understand why the API is shaped the way it is.

Workspace-level ADRs in `jux-tools/docs/adr/` cover cross-project decisions. This project needs its own ADRs for decisions specific to the API specification itself — such as endpoint design, versioning choices, or authentication strategy.

## Decision

Use Architecture Decision Records (ADRs) in `docs/adr/`, following the conventions established across the jux-tools workspace:

- **Numbering**: `NNNN-short-title.md` (zero-padded, sequential)
- **Internal title**: `ADR-NNNN: Title`
- **Statuses**: Proposed, Accepted, Deprecated, Superseded
- **Scope**: Decisions about the API specification, its tooling, and its evolution — not cross-project concerns already covered by workspace ADRs

## Consequences

- API-specific decisions are documented close to the specification they affect
- Cross-project decisions remain in the workspace ADR directory
- Contributors can trace the rationale behind API design choices without consulting external sources
