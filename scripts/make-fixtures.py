#!/usr/bin/env python3
"""Generate the tiny OSM fixture used by stack integration tests.

Requires pyosmium, e.g. `uv run --with osmium scripts/make-fixtures.py`.
The generated PBF is committed; CI never runs this script.
"""

from pathlib import Path

import osmium
from osmium.osm import mutable

OUT = Path(__file__).resolve().parent.parent / "testdata" / "mini.osm.pbf"


def node(writer, node_id, lat, lon, **tags):
    writer.add_node(mutable.Node(id=node_id, location=(lon, lat), tags=tags))


def way(writer, way_id, refs, **tags):
    writer.add_way(mutable.Way(id=way_id, nodes=refs, tags=tags))


writer = osmium.SimpleWriter(str(OUT), overwrite=True)

# Connected roads inside central Jakarta, roughly 4 km end to end.
node(writer, 10, -6.2000, 106.8000)
node(writer, 11, -6.2010, 106.8100)
node(writer, 12, -6.2020, 106.8200)
node(writer, 13, -6.2030, 106.8300)
node(writer, 14, -6.2040, 106.8400)
way(writer, 100, [10, 11, 12, 13, 14], highway="residential", name="Jalan Mini")
node(writer, 15, -6.2050, 106.8450)
node(writer, 16, -6.2000, 106.8500)
way(writer, 101, [14, 15, 16], highway="primary", name="Jalan Utama")

node(writer, 20, -6.1754, 106.8272, name="Monas", historic="monument",
     tourism="attraction")
node(writer, 21, -6.2000, 106.8000, name="Jakarta Mini", place="city")
node(writer, 22, -6.2010, 106.8110, name="Indomaret", shop="convenience")
node(writer, 23, -6.2030, 106.8300, name="Gedung Mini", building="yes")

writer.close()
print(OUT)
