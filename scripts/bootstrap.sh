#!/usr/bin/env bash
# Download the data release and prepare ./data for docker compose.
#
#   scripts/bootstrap.sh            # national graph (552 MB compressed)
#   scripts/bootstrap.sh --java     # Java-only graph (228 MB compressed)
#
# Every asset is verified against the .sha256 file published next to it. The
# script needs curl, zstd, and sha256sum; it never writes outside DATA_DIR.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

tag=${NUSAPETA_DATA_TAG:-data-2026.11}
data_dir=${DATA_DIR:-./data}
route_repo=${NUSAPETA_ROUTE_REPO:-nusapeta/route}
place_repo=${NUSAPETA_PLACE_REPO:-nusapeta/place}
release_base=${NUSAPETA_RELEASE_BASE:-https://github.com}
graph_asset=indonesia-v5-2026.11.graph.zst
graph_name=indonesia.graph
if [[ ${1:-} == --java ]]; then
  graph_asset=java-v5-2026.11.graph.zst
  graph_name=java.graph
elif [[ -n ${1:-} ]]; then
  echo "usage: $0 [--java]" >&2
  exit 2
fi

for tool in curl zstd sha256sum install; do
  command -v "$tool" >/dev/null || { echo "missing required tool: $tool" >&2; exit 2; }
done

mkdir -p "$data_dir"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

download() { # repo asset destination
  local repo=$1 asset=$2 dest=$3
  local url="$release_base/$repo/releases/download/$tag/$asset"
  echo "fetch $asset"
  curl -fsSL --retry 5 --retry-all-errors "$url" -o "$tmp/$asset"
  curl -fsSL --retry 5 --retry-all-errors "$url.sha256" -o "$tmp/$asset.sha256"
  (cd "$tmp" && sha256sum -c "$asset.sha256")
  install -m 0644 "$tmp/$asset" "$data_dir/$dest"
}

download "$route_repo" "$graph_asset" "$graph_asset"
download "$place_repo" places-2026.11.idx places-2026.11.idx
download "$place_repo" places-2026.11.idx.json places-2026.11.idx.json

echo "decompress $graph_asset"
zstd -d -f "$data_dir/$graph_asset" -o "$data_dir/$graph_name"
rm -f "$data_dir/$graph_asset"
curl -fsSL --retry 5 --retry-all-errors \
  "$release_base/$route_repo/releases/download/$tag/LICENSE-DATA" \
  -o "$data_dir/LICENSE-DATA"

cat <<EOF
data ready in $data_dir
  graph      $graph_name
  place      places-2026.11.idx (+ manifest)
  license    LICENSE-DATA
next: docker compose up -d --wait && scripts/e2e.sh
EOF
