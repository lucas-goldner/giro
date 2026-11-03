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
LAND = '#F4F7FF'
RESIDENTIAL = '#E8EEFC'
PARK = '#8FE37A'
GRASS = '#A9ECA0'
WOOD = '#7FD98A'
SAND = '#FFF1B8'
BUILDING = '#C8D8FF'
BUILDING_3D = '#B9D3FF'
ROAD_CASING = '#9FB4E8'
ROAD_MAJOR = '#FFD84D'
ROAD_HIGHWAY = '#FFB347'
RAIL = '#8A9BC9'
LABEL = NAVY
LABEL_SECONDARY = OUTLINE


def recolour(style):
    style['name'] = 'Giro Sonic'
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
                paint['fill-opacity'] = 0.55
                paint['fill-outline-color'] = '#5FC86A'
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
                paint['fill-color'] = '#BFEFFF'
                paint['fill-opacity'] = 0.5
            elif lid in ('landuse_cemetery', 'landuse_hospital', 'landuse_school'):
                paint['fill-color'] = '#DCE6FF'
            elif lid == 'water':
                paint['fill-color'] = SKY
            elif lid == 'building':
                paint['fill-color'] = BUILDING
                paint['fill-outline-color'] = 'rgba(44, 87, 214, 0.35)'
            elif lid.startswith('aeroway'):
                paint['fill-color'] = '#DDE5F7'
            elif lid == 'road_area_pattern':
                paint['fill-color'] = WHITE
                paint.pop('fill-pattern', None)
        elif t == 'fill-extrusion':
            paint['fill-extrusion-color'] = BUILDING_3D
            paint['fill-extrusion-opacity'] = 0.9
        elif t == 'line':
            if 'waterway' in lid:
                paint['line-color'] = SKY
            elif lid.startswith('boundary'):
                paint['line-color'] = OUTLINE
            elif 'rail' in lid:
                paint['line-color'] = RAIL
            elif lid.endswith('_casing'):
                paint['line-color'] = ROAD_CASING
            elif 'motorway' in lid or 'trunk_primary' in lid:
                paint['line-color'] = ROAD_HIGHWAY if 'motorway' in lid else GOLD
            elif 'secondary_tertiary' in lid:
                paint['line-color'] = ROAD_MAJOR
            elif 'path_pedestrian' in lid:
                paint['line-color'] = WHITE
            elif lid.startswith('aeroway'):
                paint['line-color'] = WHITE
            else:
                paint['line-color'] = WHITE
        elif t == 'symbol':
            if lid.startswith('label_'):
                paint['text-color'] = LABEL
                paint['text-halo-color'] = WHITE
            elif lid.startswith('poi') or lid.startswith('highway-name') or 'label' in lid:
                paint['text-color'] = LABEL_SECONDARY
                paint['text-halo-color'] = WHITE
            if lid.startswith('water'):
                paint['text-color'] = '#1677C8'
    return style


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
