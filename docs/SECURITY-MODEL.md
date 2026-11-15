# Security model

The stack is a single-tenant research deployment. It has **no authentication,
no accounts, and no per-key quota**. The gateway applies one rate limit per
client IP (15 requests/minute, burst 5 by default; `-place-rate 240` /
`-place-burst 40` for geocoding) and blocks `/metrics`. Everything else is
open to whoever can reach the port.

That is a deliberate design choice, not an oversight: the intended use is
offline or LAN routing on a machine you already control. It becomes unsafe the
moment the port is reachable from the internet, so the default `compose.yml`
publishes every port on `127.0.0.1` only.

## What is protected

| Layer | Control |
|---|---|
| Gateway port | Bound to `127.0.0.1`, never `0.0.0.0` |
| Engine ports | Not published to the host; reachable only on the Compose network |
| Processes | `read_only: true`, `cap_drop: ALL`, `no-new-privileges`, UID 65532 |
| Metrics | `-block-metrics` — `/metrics` returns 404 through the gateway |
| Data integrity | `scripts/bootstrap.sh` verifies the published `.sha256` before mounting |
| Client IP | Taken from the socket unless `-trust-proxy` is set |

`-trust-proxy` is set only in `compose.tunnel.yml`. With it, the gateway
believes `X-Forwarded-For`; a client that reaches the gateway directly can
therefore choose its own rate-limit bucket. Never set it on a port that is
also reachable without the proxy.

## Three supported ways to expose it

### 1. Cloudflare Tunnel (no open port)

```bash
CLOUDFLARE_TUNNEL_TOKEN=... docker compose -f compose.yml -f compose.tunnel.yml up -d
```

`cloudflared` dials out, so the host needs no inbound port and no firewall
change. Point the tunnel's public hostname at `http://gateway:8080` on the
Compose network, not at a host port. Cloudflare terminates TLS and can add
Access policies in front of the hostname. The overlay enables `-trust-proxy`
because Cloudflare is the only path in.

### 2. Reverse proxy with TLS

Run nginx, Caddy, or Traefik on the same host, terminate TLS there, and proxy
to `127.0.0.1:8080`. Keep the gateway on loopback. Set `-trust-proxy` only if
the proxy is the sole route to the gateway and it overwrites
`X-Forwarded-For` (nginx: `proxy_set_header X-Forwarded-For
$proxy_add_x_forwarded_for;`). Otherwise leave it off and every client shares
one bucket — cheap protection against a single scraper, useless against many.

Add `limit_req` at the proxy as well; the gateway limit is per IP and does not
know about botnets.

### 3. Private network (WireGuard, Tailscale, SSH tunnel)

The safest option if the users are known: publish nothing, and let clients
join the private network. An SSH tunnel is enough for one person:

```bash
ssh -N -L 8080:127.0.0.1:8080 you@host
```

## Known limits

- No authentication, so no way to attribute or throttle a specific user.
- Rate limiting is in-memory and resets when the gateway restarts.
- Requests above 100 km return `422 too_far`; there is no global request
  timeout beyond the route server's own `-timeout 10s`.
- The gateway does not sanitise responses from the engines; it is a router,
  not a WAF.
- Container images are pinned by tag, not digest, in `.env.example`.

## Reporting

See [SECURITY.md](../SECURITY.md) for the private advisory channel and the
7-day acknowledgement target.
