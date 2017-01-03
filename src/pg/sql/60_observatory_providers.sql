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
