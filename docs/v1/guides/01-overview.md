## Overview

For Enterprise account plans, the [Data Observatory](https://carto.com/data) provides access to a searchable catalog of advanced location data, such as census block, population segments, boundaries and so on. A set of SQL functions allow you to augment your own data and broaden your analysis by discovering boundaries and measures of data from this catalog.

This section describes the Data Observatory functions and the type of data that it returns.

### Functions Overview

There are several functions for accessing different categories of data into your visualizations. You can discover and retrieve data by requesting OBS functions from the Data Observatory. These Data Observatory functions are designed for specific, targeted methods of data analysis. The response for these functions are classified into two primary types of data results; measures and boundaries.

- Boundaries are the geospatial boundaries you need to map or aggregate your data. Examples include Country Borders, Zip Code Tabulation Areas, and Counties

- Measures are the various dimensions of information that CARTO can tell you about a place. Examples include, Population, Household Income, and Median Age

Depending on the OBS function, you will get one, or both, types of data in your result. See [Measures and Boundary Data](#measures-and-boundary-results) for details about available data.

#### Measures Functions

Use location-based measures to analyze your data by accessing population and industry measurements at point locations, or within a region or polygon. These include variables for demographic, economic, and other types of information.

- See [Measures Functions]({{ site.dataobservatory_docs }}/reference/#measures-functions) for specific OBS functions
- Returns Measures data results

#### Boundary Functions

Use global boundaries to analyze your data by accessing multi-scaled geometries for visualizations. Examples include US Block Groups and Census Tracts. These enable you to aggregate your data into geometric polygons. You can also use your own data to query specific boundaries.

- See [Boundary Functions]({{ site.dataobservatory_docs }}/reference/#boundary-functions) for specific OBS functions
- Returns Boundary data results

#### Discovery Functions

Discovery Functions provide easier ways for you to find Measures and Boundaries of interest in the Data Observatory. The Discovery functions allow you to perform targeted searches for Measures, or use your own data to discover what is available at a given location. As this is a **retrieval tool** of the Data Observatory, the query results do not change your table. The response back displays one or more identifiers as matches to your search criteria. Each unique identifier can _then_ be used as part of other OBS functions to access any of the other Data Observatory functions.

- See [Discovery Functions]({{ site.dataobservatory_docs }}/reference/#discovery-functions) for specific OBS functions
- Returns Boundary or Measures matches for your data

### Measures and Boundary Results

The response from the Data Observatory functions are classified as either Measures or Boundary. Depending on your OBS function, you will get one, or both, types of data in your result.

#### Measures Data

Measures provide details about local populations, markets, industries and other dimensions. You can search for available Measures using the Discovery functions, or by viewing the Data Catalog. Measures can be requested for Point locations, or can be summarized for Polygons (regions). In general, Point location requests will return raw aggregate values (e.g. Median Rent), or will provide amounts per square kilometer (e.g. Population). The total square kilometers of the area searched will be returned, allowing you to get raw counts, if needed. Alternatively, if you search over a polygon, raw counts will be returned.

The following table indicates where Measures data results are available. Measures can include raw measures and when indicated, can provide geometries.

Data Category | Examples | Type of Data Response | Availability
--- | ---
Housing | Vacant Housing Units, Median Rent, Units for Sale, Mortgage Count | Point measurement, Area measurement, With Geo Border | United States
Income | Median Household Income, Gini Index | Point measurement, Area measurement, With Geo Border | United States
Education | Students Enrolled in School, Population Completed H.S | Point measurement, Area measurement, With Geo Border | United States
Languages | Speaks Spanish at Home, Speaks only English at Home | Point measurement, Area measurement, With Geo Border | United States
Employment | Workers over the Age of 16 | Point measurement, Area measurement, With Geo Border | United States
Jobs and Workforce | Origin-Destination of Workforce, Job Wages by job type | Point measurement, Area measurement, With Geo Border | United States
Transportation | Commuters by Public Transportation, Work at Home | Point measurement, Area measurement, With Geo Border | United States
Race, Age and Gender | Asian Population, Median Age, Job wages by race | Point measurement, Area measurement, With Geo Border | United States, Spain
Population | Population per Square Kilometer | Point measurement, Area measurement | United States, Spain

#### Boundary Data

The following table indicates where Boundary data results are available.

Boundary Name | Availability
--- | ---
Countries | Global
First-level administrative subdivisions | Global
Second-level administrative subdivisions | United States
Zip Code Tabulation Areas (ZCTA) | United States
Congressional Districts | United States
Digital Marketing Areas | United States
Census Public Use Microdata Areas | United States
Census Tracts |United States
Census Block Groups | United States
US Census Blocks | United States
Disputed Areas | Global
Marine Area | Global
Oceans | Global
Continents | Global
Timezones | Global

##### Water Clipping Levels

Many geometries come with various degrees of water accuracy (how closely they follow features such as coastlines). Water clipping refers to how the level of accuracy is returned by the Data Observatory. Data results can either include no clip (no water areas are clipped in the geometry), or high clip (coastlines and inland waterways are clipped out of the final geometry). For example, US Census data might only show coastlines as a straight border line, and not as an inland water area. To find out which levels of water clipping are available for Boundary layers, refer to the [Data Catalog](https://cartodb.github.io/bigmetadata/index.html).

**Note:** While high clip water levels may be better for some kinds of maps and analysis, this type of data consumes more account storage space and may be subject to quota limitations.

For details about how to access any of this data, see [Accessing the Data Observatory]({{ site.dataobservatory_docs }}/guides/accesssing-the-data-observatory/).
