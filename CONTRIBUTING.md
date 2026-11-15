# Contributing

Nusapeta Stack is the integration layer for [nusapeta/route](https://github.com/nusapeta/route)
and [nusapeta/place](https://github.com/nusapeta/place): Compose services, a
gateway, bootstrap and contract scripts, and small committed fixtures. Engine
changes belong in the engine repositories.

## Before changing the stack

1. Read [README.md](README.md), [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md),
   and [docs/QUICKSTART.md](docs/QUICKSTART.md).
2. Reproduce the current behavior with `scripts/e2e.sh`.
3. Contract changes that cross the gateway need an issue first. The gateway is
   a route-engine binary; do not fork it here.

## Setup

Requires Docker with Compose v2, curl, `jq`, and Python 3 for the fixture
helper.

```bash
cp .env.example .env
scripts/bootstrap.sh --fixtures
docker compose up -d --wait
scripts/e2e.sh
docker compose down -v
```

The fixtures cover central Jakarta only. They test integration, not routing or
search quality.

## Rules

- Do not commit `.env`, downloaded graphs, indexes, or release archives.
- Keep every published port bound to `127.0.0.1`.
- Keep `read_only`, `cap_drop`, and `no-new-privileges` on engine containers.
- Keep memory limits in `compose.yml` aligned with the documented budget.
- `scripts/bootstrap.sh` MUST verify checksums before using downloaded data.
- `scripts/e2e.sh` MUST fail on contract drift; do not weaken a check to make
  CI pass.
- New fixtures MUST stay small (≤2 MB per file) and be reproducible with
  `scripts/make-fixtures.py`.
- Do not copy engine code into this repository.

## Pull request

- [ ] `bash -n scripts/*.sh` passes.
- [ ] `docker compose config` is valid.
- [ ] `scripts/e2e.sh` passes with fixtures.
- [ ] No `.env`, graph, index, or archive is included.
- [ ] Documentation is updated when behavior changes.
- [ ] Commits carry `Signed-off-by` (DCO).

Use imperative commit messages that name the area, for example
`compose: drop gateway capabilities`.

## DCO

The repository uses Developer Certificate of Origin 1.1, with no CLA. Every
commit MUST include a sign-off line:

```text
Signed-off-by: Your Name <you@example.com>
```

Add it with `git commit -s`. Contributions without a sign-off are not merged.

## License

By submitting a contribution, you agree to license it under MIT. OSM-derived
data remains ODbL 1.0; see [README.md](README.md#security-and-limits).
