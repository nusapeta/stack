# Nusapeta Stack

**A self-hosted geo stack for Indonesia: routing + geocoding, one file per
engine, under 20 MB idle, rebuilt in minutes, no database.**

The two engines are [nusapeta/route](https://github.com/nusapeta/route) and
[nusapeta/place](https://github.com/nusapeta/place). This repository is the
compose bundle: two route profiles, one gateway, no build step on the host.

| Metric | Value |
|---|---:|
| Idle RSS, whole stack | **±17 MB** |
| Route graph, national | **1.6 GB** on disk (552 MB compressed) |
| Place index | **142 MB** |
| Place build from the national PBF | **228 s** |

```bash
cp .env.example .env
scripts/bootstrap.sh          # download + verify data-2026.11
docker compose up -d --wait
scripts/e2e.sh
```

Gateway: <http://127.0.0.1:8080>. Routing, geocoding, and the combined API are
served on that single loopback port.

## What runs

| Service | Image | Memory | Role |
|---|---|---:|---|
| `route` | `ghcr.io/nusapeta/route:0.1.0` | 1536m | car profile |
| `route-motor` | same | 1536m | motor profile |
| `place` | `ghcr.io/nusapeta/place:0.1.0` | 256m | geocoder index |
| `gateway` | same as route | 64m | public surface, rate limits, `/place` prefix |

Data is mounted read-only from `DATA_DIR` (default `./data`). The national
graph is 1.6 GB raw, 552 MB compressed; the place index is 142 MB. For a quick
run, use the committed fixtures:

```bash
DATA_DIR=./testdata \
NUSAPETA_ROUTE_GRAPH=java-mini.graph \
NUSAPETA_PLACE_INDEX=places-mini.idx \
NUSAPETA_PLACE_MANIFEST=places-mini.idx.json \
NUSAPETA_ROUTE_IMAGE=nusapeta/route:local \
NUSAPETA_PLACE_IMAGE=nusapeta/place:local \
docker compose up -d --wait
```

The fixtures cover central Jakarta only (7 graph nodes, 6 place features).
They exist to test the integration, not to answer real queries.

## Security and limits

- Every published port binds `127.0.0.1`. There is no authentication.
- Containers are read-only, drop all capabilities, and run as UID 65532.
- `/metrics` is blocked at the gateway; read it from the route containers.
- Public deployment is a separate decision: put a TLS terminator or tunnel in
  front and keep the loopback binding. `compose.tunnel.yml` is an optional
  overlay.
- Application limits: routes above 100 km return `422 too_far`; the gateway
  rate limit is 15 requests/minute per IP (burst 5).
- Data is ODbL 1.0. If you serve it, attribute OpenStreetMap contributors and
  keep `LICENSE-DATA` with the derived database.

## Documentation

- [QUICKSTART](docs/QUICKSTART.md) (English) and [QUICKSTART.id](docs/QUICKSTART.id.md)
- [ARCHITECTURE](docs/ARCHITECTURE.md)
- [Security model](docs/SECURITY-MODEL.md) — the three supported ways to expose it
- [Open-source execution plan](docs/OPENSOURCE-PLAN.md)
- [curl examples](examples/curl.md)
- [Flutter polyline snippet](examples/flutter/route_client.dart)
- [Contributing](CONTRIBUTING.md), [security policy](SECURITY.md), and
  [code of conduct](CODE_OF_CONDUCT.md)

## License

Compose files and scripts: MIT. Data artifacts: ODbL 1.0.
