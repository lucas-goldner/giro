"""Derives assets/map/sonic_style.json from OpenFreeMap's Liberty style.

Usage: python3 tool/make_sonic_style.py [path/to/liberty.json]
Without a path the current Liberty style is downloaded from OpenFreeMap.

The data (tiles, sprites, glyphs) stays on OpenFreeMap; only the paint is
changed to the Sonic palette used by the HUD (lib/design/sonic/sonic_theme.dart).
"""
import json
import sys
import urllib.request

LIBERTY_URL = 'https://tiles.openfreemap.org/styles/liberty'

BLUE = '#1B5BFF'
NAVY = '#0A1D58'
SKY = '#5FC8FF'
GOLD = '#FFC400'
PALE = '#B9D3FF'
OUTLINE = '#2C57D6'
WHITE = '#FFFFFF'

# The explored map is a toy city in the spirit of Fenn: grassy ground, soft
# asphalt roads with white markings, pastel buildings coloured per building,
# vivid parks, bright water. Unexplored areas are white clay (the fog), so
# the contrast is colourful city versus blank model.
LAND = '#E6EDD2'
RESIDENTIAL = '#EAF0D9'
PARK = '#86DB5E'
GRASS = '#ACE87F'
WOOD = '#62C85E'
SAND = '#FFE9A8'
WATER = '#58C5F2'
BUILDING = '#E8E0D2'
BUILDING_OUTLINE = 'rgba(120, 110, 95, 0.45)'
ROAD_CASING = '#8A93B3'
ROAD_MINOR = '#D9DDE9'
ROAD_MAJOR = '#B7BED6'
ROAD_HIGHWAY = '#A1AAC8'
ROAD_PATH = '#F4F2EA'
RAIL = '#9A9FB5'
LABEL = NAVY
LABEL_SECONDARY = '#4A5A8A'
BOUNDARY = '#C9A86A'
WATER_LABEL = '#1677C8'

# Pastel facades, picked per building from its OSM id so neighbours differ.
PASTELS = ['#F7C8AC', '#BFE9D0', '#D3C8F4', '#F8E7A8', '#C2E1F8', '#F6C2D2',
           '#F9D9B0', '#CDEBB8']


def pastel_by_id():
    expr = ['match', ['%', ['id'], len(PASTELS)]]
    for index, colour in enumerate(PASTELS):
        expr += [index, colour]
    expr.append(PASTELS[0])
    return expr


def recolour(style):
    style['name'] = 'Giro Sonic'
    # Warm key light from the upper left; walls get a gentle gradient.
    style['light'] = {'anchor': 'viewport', 'color': '#FFF3DC',
                      'position': [1.15, 210, 35], 'intensity': 0.35}
    style['metadata'] = {
        'giro:derived-from': 'OpenFreeMap Liberty',
        'giro:generator': 'tool/make_sonic_style.py',
    }
    for layer in style['layers']:
        lid = layer['id']
        paint = layer.setdefault('paint', {})
        t = layer['type']
        if t == 'background':
            paint['background-color'] = LAND
        elif lid == 'natural_earth':
            paint['raster-saturation'] = -0.6
        elif t == 'fill':
            if lid.startswith('park'):
                paint['fill-color'] = PARK
                paint['fill-opacity'] = 0.7
                paint['fill-outline-color'] = '#56B84A'
            elif lid == 'landuse_residential':
                paint['fill-color'] = RESIDENTIAL
            elif lid in ('landcover_wood',):
                paint['fill-color'] = WOOD
                paint['fill-opacity'] = 0.45
            elif lid in ('landcover_grass', 'landuse_pitch', 'landuse_track'):
                paint['fill-color'] = GRASS
                paint['fill-opacity'] = 0.5
            elif lid in ('landcover_sand',):
                paint['fill-color'] = SAND
            elif lid in ('landcover_ice',):
                paint['fill-color'] = WHITE
            elif lid in ('landcover_wetland',):
                paint['fill-color'] = '#A5E3F5'
                paint['fill-opacity'] = 0.5
            elif lid in ('landuse_cemetery', 'landuse_hospital', 'landuse_school'):
                paint['fill-color'] = '#EFE4CF'
            elif lid == 'water':
                paint['fill-color'] = WATER
            elif lid == 'building':
                paint['fill-color'] = pastel_by_id()
                paint['fill-outline-color'] = BUILDING_OUTLINE
            elif lid.startswith('aeroway'):
                paint['fill-color'] = '#E8E0CE'
            elif lid == 'road_area_pattern':
                paint['fill-color'] = WHITE
                paint.pop('fill-pattern', None)
        elif t == 'fill-extrusion':
            # Opaque: translucent extrusions are composited without depth
            # sorting and show seams between building parts. Always on; the
            # toy city is meant to be seen tilted.
            paint['fill-extrusion-color'] = pastel_by_id()
            paint['fill-extrusion-opacity'] = 1
            paint['fill-extrusion-vertical-gradient'] = False
        elif t == 'line':
            if 'waterway' in lid:
                paint['line-color'] = WATER
            elif lid.startswith('boundary'):
                paint['line-color'] = BOUNDARY
            elif 'rail' in lid:
                paint['line-color'] = RAIL
            elif lid.endswith('_casing'):
                paint['line-color'] = ROAD_CASING
            elif 'motorway' in lid or 'trunk_primary' in lid:
                paint['line-color'] = ROAD_HIGHWAY
            elif 'secondary_tertiary' in lid or lid.endswith('_link'):
                paint['line-color'] = ROAD_MAJOR
            elif 'path_pedestrian' in lid:
                paint['line-color'] = ROAD_PATH
            elif lid.startswith('aeroway'):
                paint['line-color'] = ROAD_PATH
            else:
                paint['line-color'] = ROAD_MINOR
        elif t == 'symbol':
            if lid.startswith('label_'):
                paint['text-color'] = LABEL
                paint['text-halo-color'] = WHITE
            elif lid.startswith('poi') or lid.startswith('highway-name') or 'label' in lid:
                paint['text-color'] = LABEL_SECONDARY
                paint['text-halo-color'] = WHITE
            if lid.startswith('water'):
                paint['text-color'] = WATER_LABEL
    add_road_markings(style)
    return style


def add_road_markings(style):
    """White dashed centre lines on bigger roads, under the buildings."""
    layer = {
        'id': 'giro_road_markings',
        'type': 'line',
        'source': 'openmaptiles',
        'source-layer': 'transportation',
        'minzoom': 15,
        'filter': ['all',
                   ['match', ['geometry-type'], ['LineString', 'MultiLineString'], True, False],
                   ['match', ['get', 'class'],
                    ['motorway', 'trunk', 'primary', 'secondary', 'tertiary'], True, False],
                   ['!=', ['get', 'brunnel'], 'tunnel']],
        'layout': {'line-cap': 'butt', 'line-join': 'round'},
        'paint': {
            'line-color': 'rgba(255, 255, 255, 0.85)',
            'line-width': ['interpolate', ['exponential', 1.3], ['zoom'], 15, 0.6, 18, 1.8],
            'line-dasharray': [3, 3],
        },
    }
    index = next(i for i, l in enumerate(style['layers']) if l['id'] == 'building')
    style['layers'].insert(index, layer)


def main():
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as handle:
            style = json.load(handle)
    else:
        with urllib.request.urlopen(LIBERTY_URL) as response:
            style = json.load(response)
    style = recolour(style)
    with open('assets/map/sonic_style.json', 'w') as handle:
        json.dump(style, handle, separators=(',', ':'), ensure_ascii=False)
        handle.write('\n')
    print('wrote assets/map/sonic_style.json with', len(style['layers']), 'layers')


if __name__ == '__main__':
    main()
