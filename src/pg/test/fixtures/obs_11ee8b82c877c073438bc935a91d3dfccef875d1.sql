

CREATE TABLE IF NOT EXISTS obs_11ee8b82c877c073438bc935a91d3dfccef875d1 (
    cartodb_id integer,
    the_geom geometry(Geometry,4326),
    the_geom_webmercator geometry(Geometry,3857),
    geoid text,
    x10 text,
    x2 text,
    x31 text,
    x55 text
);

INSERT INTO obs_11ee8b82c877c073438bc935a91d3dfccef875d1 (cartodb_id, the_geom, the_geom_webmercator, geoid, x10, x2, x31, x55) VALUES (2150, NULL, NULL, '36047048500', 'Wealthy, urban without Kids', '8', '15', '1');

CREATE SCHEMA IF NOT EXISTS observatory;
ALTER TABLE obs_11ee8b82c877c073438bc935a91d3dfccef875d1 SET SCHEMA observatory;
