CREATE TABLE IF NOT EXISTS obs_65f29658e096ca1485bf683f65fdbc9f05ec3c5d (
    cartodb_id integer NOT NULL,
    the_geom public.geometry(Geometry,4326),
    the_geom_webmercator public.geometry(Geometry,3857),
    geoid text,
    x10 text,
    x2 text,
    x31 text,
    x55 text
);

INSERT INTO obs_65f29658e096ca1485bf683f65fdbc9f05ec3c5d (cartodb_id, the_geom,
the_geom_webmercator, geoid, x10, x2, x31, x55) VALUES (2150, NULL, NULL, '36047048500', 'Wealthy, urban without Kids', '8', '15', '1');

CREATE SCHEMA IF NOT EXISTS observatory;
ALTER TABLE obs_65f29658e096ca1485bf683f65fdbc9f05ec3c5d  SET SCHEMA observatory;
