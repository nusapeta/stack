# Changelog

All user-visible changes are recorded here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[SemVer](https://semver.org/).

## [Unreleased]

## [0.1.0] - unreleased

First public release.

### Added

- Compose stack with route (car), route-motor, place, and gateway services.
- Optional Cloudflare Tunnel overlay with `-trust-proxy` on the gateway.
- `scripts/bootstrap.sh` for `data-2026.11`, with `.sha256` verification and a
  fixture path for CI.
- `scripts/e2e.sh` contract test for routing, geocoding, POST bodies, ODbL
  attribution, and blocked `/metrics`.
- Small Jakarta fixtures and a SHA-256 manifest for offline CI.
- English and Indonesian quick starts, architecture notes, curl examples, and a
  Flutter polyline snippet.

### Security

- Every published port binds `127.0.0.1`.
- Engine containers run read-only, with all capabilities dropped, UID 65532,
  and no privilege escalation.
- The gateway blocks `/metrics` and applies per-IP rate limits.

### Known limitations

- No map UI and no authentication.
- Fixtures are not a routing or search benchmark.
- The 100 km route cap and 15 requests/minute gateway limit are product
  defaults, not tuning suggestions for public deployment.
