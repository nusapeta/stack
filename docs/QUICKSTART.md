# Quickstart

## 1. Requirements

- Docker Engine with Compose v2
- `curl`, `zstd`, `sha256sum` for the bootstrap step
- About 4 GB RAM for the full national graph, 1 GB for the Java extract

## 2. Get data and start

```bash
cp .env.example .env
scripts/bootstrap.sh          # national graph + place index
docker compose up -d --wait
```

For a smaller download:

```bash
scripts/bootstrap.sh --java
```

Both variants write files into `DATA_DIR` (default `./data`). Bootstrap verifies
every asset against its published `.sha256` before use.

## 3. Check the contract

```bash
BASE_URL=http://127.0.0.1:8080 scripts/e2e.sh
```

The script checks health, car and motor routes, GeoJSON output, POST routing,
place search/reverse, ODbL attribution, and that `/metrics` is blocked.

## 4. Try it

```bash
curl -s 'http://127.0.0.1:8080/healthz' | jq
curl -s 'http://127.0.0.1:8080/route?from=-6.2,106.8&to=-6.2,106.85' | jq
curl -s 'http://127.0.0.1:8080/place/search?q=monas' | jq '.[0]'
curl -s 'http://127.0.0.1:8080/place/reverse?lat=-6.1754&lon=106.8272' | jq
```

## 5. Offline fixtures

Committed fixtures exercise the same Compose contract without downloading a
release:

```bash
scripts/bootstrap.sh --fixtures
DATA_DIR=./data \
NUSAPETA_ROUTE_GRAPH=java-mini.graph \
NUSAPETA_PLACE_INDEX=places-mini.idx \
NUSAPETA_PLACE_MANIFEST=places-mini.idx.json \
NUSAPETA_ROUTE_IMAGE=nusapeta/route:local \
NUSAPETA_PLACE_IMAGE=nusapeta/place:local \
docker compose up -d --wait
```

`--fixtures` verifies `testdata/SHA256SUMS` before staging the files.

Build the local images from the engine repositories:

```bash
(cd ../route && docker build -t nusapeta/route:local .)
(cd ../place && docker build -t nusapeta/place:local .)
```

## 6. Stop

```bash
docker compose down
rm -rf data          # removes downloaded artifacts, not the fixtures
```
