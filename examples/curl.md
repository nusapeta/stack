# curl examples

Base URL: `http://127.0.0.1:8080`.

## Health

```bash
curl -s "$BASE/healthz" | jq '{ok, regions: [.regions[] | {name, format, nodes}]}'
```

## Route

```bash
# car (default)
curl -s "$BASE/route?from=-6.2,106.8&to=-6.2,106.85" | jq

# motor
curl -s "$BASE/route?from=-6.2,106.8&to=-6.2,106.85&profile=motor" | jq

# GeoJSON, simplified to 5 m
curl -s "$BASE/route?from=-6.2,106.8&to=-6.2,106.85&format=geojson&simplify=5" | jq

# POST with explicit body
curl -s -X POST "$BASE/route" \
  -H 'Content-Type: application/json' \
  -d '{"from":{"lat":-6.2,"lng":106.8},"to":{"lat":-6.2,"lng":106.85}}' | jq
```

Routes over 100 km return `422` with `"reason":"too_far"`. Snap failures return
`422` with `"reason":"snap"`.

## Place

```bash
curl -s "$BASE/place/search?q=monas&limit=5" | jq
curl -s "$BASE/place/reverse?lat=-6.1754&lon=106.8272" | jq
```

Every place result carries `licence: "ODbL 1.0, © OpenStreetMap contributors"`.

## Rate limits and metrics

The gateway allows 15 requests/minute per IP (burst 5) for routing and 240/minute
(burst 40) for place. Exceeding routing returns `429` with `Retry-After`.

`/metrics` is deliberately blocked at the gateway:

```bash
curl -si "$BASE/metrics" | head -1   # HTTP/1.1 404
```
