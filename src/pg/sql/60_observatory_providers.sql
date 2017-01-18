CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetOverpass(
  query text
) RETURNS TABLE (
  geom TEXT,
  "type" TEXT,
  id TEXT,
  properties TEXT
) AS $$

    from observatory.osm import get_overpass
    import plpy
    import json

    result = get_overpass(query)

    return [{
      'geom': json.dumps(feature['geometry']),
      'type': feature['type'],
      'id': str(feature['id']),
      'properties': json.dumps(feature['properties'])
    } for feature in result]

$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetOverpass(
  query text
) RETURNS TABLE (
  geom Geometry(Geometry, 4326),
  "type" TEXT,
  id TEXT,
  properties JSON
) AS $$
BEGIN
  RETURN QUERY
  EXECUTE $string$
    SELECT ST_GeomFromGeojson(geom) geom,
           "type",
           id,
           properties::JSON
    FROM cdb_observatory._OBS_GetOverPass($1)
  $string$ USING query
  RETURN;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetOverpassPOI(
  within_geom Geometry(Geometry, 4326),
  filters TEXT[] DEFAULT ARRAY[ 'pub', 'bar', 'restaurant', 'fast_food',
  'cafe', 'food_court', 'ice_cream', 'college', 'kindergarten', 'library',
  'school', 'music_school', 'driving_school', 'language_school', 'university',
  'bicycle_rental', 'boat_sharing', 'car_rental', 'car_sharing', 'car_wash',
  'ferry_terminal', 'fuel', 'bank', 'bureau_de_change', 'clinic', 'dentist',
  'doctors', 'hospital', 'nursing_home', 'pharmacy', 'social_facility',
  'veterinary', 'blood_donation', 'arts_centre', 'brothel', 'casino',
  'community_centre', 'cinema', 'gambling', 'nightclub', 'planetarium',
  'social_centre', 'stripclub', 'swingerclub', 'studio', 'theatre',
  'animal_boarding', 'animal_shelter', 'courthouse', 'coworking_space',
  'crematorium', 'dive_centre', 'dojo', 'embassy', 'fire_station',
  'internet_cafe', 'marketplace', 'place_of_worship', 'police', 'post_office',
  'prison', 'townhall', 'waste_transfer_station'
  ],
  name TEXT DEFAULT NULL
) RETURNS TABLE (
  geom Geometry(Geometry, 4326),
  "type" TEXT,
  id TEXT,
  properties JSON
) AS $$
DECLARE
  osm_bbox TEXT;
  query TEXT;
BEGIN
  osm_bbox := replace(replace(replace(regexp_replace(box2d(within_geom)::TEXT,
          E'(\\-?\\d+\\.?\\d+) (\\-?\\d+\\.?\\d+)',
          E'\\2 \\1', 'g'),
        ' ', ','),
      'BOX(', ''),
    ')', '');

  EXECUTE $string$
    WITH filters AS (SELECT UNNEST($1) as filter)
    SELECT ' ( '
     'node ["name"]["amenity"~"' || String_Agg(filter, '|') || '"] (' || $2 || '); ' ||
     'way  ["name"]["amenity"~"' || String_Agg(filter, '|') || '"] (' || $2 || '); ' ||
     'node ["name"][shop] (' || $2 || '); ' ||
     'way  ["name"][shop] (' || $2 || '); ' ||
     'relation  ["name"][shop] (' || $2 || ')) '
    FROM filters
  $string$
  INTO query
  USING filters, osm_bbox, name;

  RAISE NOTICE '%', query;
  RETURN QUERY
  EXECUTE $string$
    WITH results AS (SELECT ST_SetSRID(ST_GeomFromGeojson(geom), 4326) geom,
           "type",
           id,
           properties::JSON
    FROM cdb_observatory._OBS_GetOverPass($1))
    SELECT * FROM results WHERE ST_Within(geom, $2)
  $string$ USING query, within_geom
  RETURN;
END;
$$ LANGUAGE plpgsql;
