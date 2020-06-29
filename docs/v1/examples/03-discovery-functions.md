
```SQL
SELECT * FROM OBS_Search('home value')
```

```SQL
SELECT * FROM OBS_GetAvailableBoundaries(CDB_LatLng(40.7, -73.9))
```

- Obtain all numerators that are available within a small rectangle.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326))
```

- Obtain all numerators that are available within a small rectangle and are for
the United States only.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states}');
```

- Obtain all numerators that are available within a small rectangle and are
employment related for the United States only.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states, subsection/tags.employment}');
```

- Obtain all numerators that are available within a small rectangle and are
related to both employment and age & gender for the United States only.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states, subsection/tags.employment, subsection/tags.age_gender}');
```

- Obtain all numerators that work with US population (`us.census.acs.B01003001`)
as a denominator.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, 'us.census.acs.B01003001')
WHERE valid_denom IS True;
```

- Obtain all numerators that work with US states (`us.census.tiger.state`)
as a geometry.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, 'us.census.tiger.state')
WHERE valid_geom IS True;
```

- Obtain all numerators available in the timespan `2011 - 2015`.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, NULL, '2011 - 2015')
WHERE valid_timespan IS True;
```

- Obtain all denominators that are available within a small rectangle.

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326));
```

- Obtain all denominators that are available within a small rectangle and are for
the United States only.

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states}');
```

- Obtain all denominators for male population (`us.census.acs.B01001002`).

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, 'us.census.acs.B01001002')
WHERE valid_numer IS True;
```

- Obtain all denominators that work with US states (`us.census.tiger.state`)
as a geometry.

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, 'us.census.tiger.state')
WHERE valid_geom IS True;
```

- Obtain all denominators available in the timespan `2011 - 2015`.

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, NULL, '2011 - 2015')
WHERE valid_timespan IS True;
```

- Obtain all geometries that are available within a small rectangle.

```SQL
SELECT * FROM OBS_GetAvailableGeometries(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326));
```

- Obtain all geometries that are available within a small rectangle and are for
the United States only.

```SQL
SELECT * FROM OBS_GetAvailableGeometries(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states}');
```

- Obtain all geometries that work with total population (`us.census.acs.B01003001`).

```SQL
SELECT * FROM OBS_GetAvailableGeometries(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, 'us.census.acs.B01003001')
WHERE valid_numer IS True;
```

- Obtain all geometries with timespan  `2015`.

```SQL
SELECT * FROM OBS_GetAvailableGeometries(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, NULL, '2015')
WHERE valid_timespan IS True;
```

- Obtain all timespans that are available within a small rectangle.

```SQL
SELECT * FROM OBS_GetAvailableTimespans(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326));
```

- Obtain all timespans for total population (`us.census.acs.B01003001`).

```SQL
SELECT * FROM OBS_GetAvailableTimespans(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, 'us.census.acs.B01003001')
WHERE valid_numer IS True;
```

- Obtain all timespans that work with US states (`us.census.tiger.state`)
as a geometry.

```SQL
SELECT * FROM OBS_GetAvailableTimespans(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, NULL, 'us.census.tiger.state')
WHERE valid_geom IS True;
```