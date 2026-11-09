# bobbyhyam/ynab-mcp-server

A fork of [calebl/ynab-mcp-server](https://github.com/calebl/ynab-mcp-server)
that builds the container image Bobby's homelab runs behind agentgateway.
Why it exists and how it is used: [omni-ops decision 0133](https://github.com/bobbyhyam/omni-ops/blob/main/docs/decisions/0133-ynab-mcp-calebl-fork.md).

`main` is upstream `main` plus the commits below. Upstream releases come in
by merging upstream's tag, never by rebasing, so this history stays a
superset of upstream's.

| Change | Files | Upstream status |
| --- | --- | --- |
| Streamable-HTTP entry point | `src/http.ts`, `src/httpServer.ts`, tests, README | [calebl/ynab-mcp-server#108](https://github.com/calebl/ynab-mcp-server/pull/108) |
| `ynab_get_transactions` newest first | `src/tools/GetTransactionsTool.ts`, tests | [calebl/ynab-mcp-server#109](https://github.com/calebl/ynab-mcp-server/pull/109) |
| HTTP container image | `docker/http.Dockerfile`, `.github/workflows/fork-image.yml`, this file | fork only |

When upstream merges an offered change, the next tag merge absorbs it and
the row comes out of this table.

## Releasing an image

Tag `main` as `<upstream version>-bh.<n>` (for example `0.8.0-bh.1`) and push
the tag. `fork-image.yml` runs the tests and pushes
`ghcr.io/bobbyhyam/ynab-mcp-server:<tag>` for amd64 and arm64. Homelab pins it
by tag and digest. Never create a GitHub release in this fork: upstream's
`publish.yml` would try to publish to npm.
