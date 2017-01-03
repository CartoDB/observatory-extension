CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetOverpass(query text)
RETURNS table (lat Numeric, lon Numeric, "type" TEXT, id Numeric, tags TEXT) as $$

    from observatory.osm import get_overpass
    return get_overpass(query)

$$ LANGUAGE plpythonu;
