# Security

## Reporting a problem

Do not open a public issue for an exploitable vulnerability. Use the GitHub
private security advisory at
<https://github.com/nusapeta/stack/security/advisories/new>. Include:

- the commit or release version;
- the Compose command and environment used;
- reproduction steps;
- possible impact.

An acknowledgement follows within 7 days, best-effort. There is no SLA and no
promise of a fix date.

## Security model

The default stack has no authentication. It is safe only when the gateway port
stays on loopback, or when a trusted TLS terminator or tunnel enforces access
control in front. [docs/SECURITY-MODEL.md](docs/SECURITY-MODEL.md) explains the
three supported ways to expose it and what each one costs.

| Asset | Threat | Mitigation |
|---|---|---|
| Gateway | Unauthenticated public access | Bind `127.0.0.1`; tunnel overlay is opt-in |
| Containers | Write access or privilege escalation | `read_only`, `cap_drop: ALL`, `no-new-privileges`, UID 65532 |
| Engine ports | Direct access around the gateway | No host port published for route, route-motor, or place |
| Metrics | Information leak | Gateway runs `-block-metrics` |
| Data | Corrupt or substituted release | `bootstrap.sh` verifies `.sha256` before use |
| Proxy headers | Rate-limit spoofing | `-trust-proxy` only in the tunnel overlay |

## What counts as a vulnerability

- A way to reach an engine port around the gateway in the default Compose file.
- A checksum bypass in `bootstrap.sh`.
- Container breakout caused by the stack configuration.
- A rate-limit bypass through forwarded headers without a trusted proxy.
- A secret or private path committed to the repository.

## What does not count

- The stack being reachable if you publish its port yourself.
- Missing authentication; that is a documented design choice.
- Wrong routes or search results caused by engine or OSM data.
- Resource exhaustion after lowering the documented memory limits.

## Dependencies

- GitHub Actions are pinned to major versions and updated by Dependabot.
- Engine images are versioned; `latest` is not used in `.env.example`.
- New actions or images MUST be explained in the pull request.
