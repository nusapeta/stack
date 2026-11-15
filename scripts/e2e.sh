#!/usr/bin/env bash
# Cross-engine contract test. Run after `docker compose up -d --wait`.
#   BASE_URL=http://127.0.0.1:8080 scripts/e2e.sh
set -euo pipefail

base=${BASE_URL:-http://127.0.0.1:8080}
pass=0
fail=0

check() { # name status expected [jq-filter]
  local name=$1 status=$2 expected=$3 filter=${4:-}
  if [[ $status != "$expected" ]]; then
    echo "FAIL $name: HTTP $status (expected $expected)" >&2
    fail=$((fail + 1))
    return
  fi
  if [[ -n $filter ]]; then
    if ! jq -e "$filter" "$tmp" >/dev/null; then
      echo "FAIL $name: body does not satisfy $filter" >&2
      fail=$((fail + 1))
      return
    fi
  fi
  echo "ok   $name"
  pass=$((pass + 1))
}

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

status=$(curl -sS -o "$tmp" -w '%{http_code}' "$base/")
check "map page" "$status" 200

status=$(curl -sS -o "$tmp" -w '%{http_code}' "$base/healthz")
check "route health" "$status" 200 \
  '.ok == true and .profiles.mobil.upstream.regions[0].format == 5 and .profiles.motor.upstream.ok == true'

status=$(curl -sS -o "$tmp" -w '%{http_code}' \
  "$base/route?from=-6.2000,106.8000&to=-6.2000,106.8500")
check "car route" "$status" 200 '.distance_m > 0'

status=$(curl -sS -o "$tmp" -w '%{http_code}' \
  "$base/route?from=-6.2000,106.8000&to=-6.2000,106.8500&profile=motor")
check "motor route" "$status" 200 '.distance_m > 0'

status=$(curl -sS -o "$tmp" -w '%{http_code}' \
  "$base/route?from=-6.2000,106.8000&to=-6.2000,106.8500&format=geojson")
check "geojson route" "$status" 200 '.geojson.type == "FeatureCollection"'

status=$(curl -sS -o "$tmp" -w '%{http_code}' \
  -X POST "$base/route" -H 'Content-Type: application/json' \
  -d '{"from":{"lat":-6.2,"lng":106.8},"to":{"lat":-6.2,"lng":106.85}}')
check "POST route" "$status" 200 '.distance_m > 0'

status=$(curl -sS -o "$tmp" -w '%{http_code}' "$base/place/search?q=Monas&limit=5")
check "place search" "$status" 200 'any(.[]; .name | test("Monas"; "i"))'

status=$(curl -sS -o "$tmp" -w '%{http_code}' \
  "$base/place/reverse?lat=-6.1754&lon=106.8272")
check "place reverse" "$status" 200 '.licence | test("ODbL")'

status=$(curl -sS -o "$tmp" -w '%{http_code}' "$base/metrics")
check "metrics blocked" "$status" 404

echo "passed=$pass failed=$fail"
[[ $fail -eq 0 ]]
