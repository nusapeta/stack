# Mulai cepat

> Dokumen ini berbahasa Indonesia. Ringkasan Inggris: [QUICKSTART](QUICKSTART.md).

## 1. Kebutuhan

- Docker Engine dengan Compose v2
- `curl`, `zstd`, `sha256sum` untuk bootstrap
- Sekitar 4 GB RAM untuk graph nasional, 1 GB untuk extract Jawa

## 2. Ambil data dan jalankan

```bash
cp .env.example .env
scripts/bootstrap.sh          # graph nasional + index place
docker compose up -d --wait
```

Untuk unduhan lebih kecil:

```bash
scripts/bootstrap.sh --java
```

Kedua varian menulis ke `DATA_DIR` (default `./data`). Bootstrap memverifikasi
setiap aset dengan `.sha256` yang diterbitkan bersama aset itu.

## 3. Uji kontrak

```bash
BASE_URL=http://127.0.0.1:8080 scripts/e2e.sh
```

Skrip memeriksa health, rute mobil dan motor, output GeoJSON, POST route,
search/reverse place, atribusi ODbL, dan `/metrics` yang diblokir.

## 4. Coba

```bash
curl -s 'http://127.0.0.1:8080/healthz' | jq
curl -s 'http://127.0.0.1:8080/route?from=-6.2,106.8&to=-6.2,106.85' | jq
curl -s 'http://127.0.0.1:8080/place/search?q=monas' | jq '.[0]'
curl -s 'http://127.0.0.1:8080/place/reverse?lat=-6.1754&lon=106.8272' | jq
```

## 5. Fixture offline

Fixture yang di-commit menguji kontrak Compose yang sama tanpa mengunduh rilis:

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

`--fixtures` memverifikasi `testdata/SHA256SUMS` sebelum menyalin file.

Bangun image lokal dari repo engine:

```bash
(cd ../routeid && docker build -t nusapeta/route:local .)
(cd ../placeid && docker build -t nusapeta/place:local .)
```

## 6. Berhenti

```bash
docker compose down
rm -rf data          # menghapus artefak unduhan, bukan fixture
```
