--
-- PostgreSQL database dump
--

--
-- Name: obs_tag; Type: TABLE; Schema: observatory; Owner: cartodb_user_d377e55d-4326-4faf-97c7-503535e81667; Tablespace: 
--

CREATE TABLE obs_tag (
    cartodb_id integer NOT NULL,
    the_geom public.geometry(Geometry,4326),
    the_geom_webmercator public.geometry(Geometry,3857),
    id text,
    name text,
    type text,
    description text,
    version double precision
);

--
-- Data for Name: obs_tag; Type: TABLE DATA; Schema: observatory; Owner: cartodb_user_d377e55d-4326-4faf-97c7-503535e81667
--

COPY obs_tag (cartodb_id, the_geom, the_geom_webmercator, id, name, type, description, version) FROM stdin;
1	\N	\N	"us.census.acs".demographics	US American Community Survey Demographics	catalog	Standard Demographic Data from the US American Community Survey	0
2	\N	\N	"us.census.segments".families_with_young_children	Families with young children (Under 6 years old)	segment		0
3	\N	\N	"us.census.segments".middle_aged_men	Middle Aged Men (45 to 64 years old)	segment		0
4	\N	\N	"es.ine".demographics	Demographics of Spain	catalog	Demographics of Spain from the INE Census	0
5	\N	\N	"tags".transportation	Transportation	catalog	How do people move from place to place?	1
6	\N	\N	"tags".language	Language	catalog	What languages do people speak?	1
7	\N	\N	"tags".housing	Housing	catalog	What type of housing exists and how do people live in it?	1
8	\N	\N	"tags".denominator	Denominator	catalog	Use these to provide a baseline for comparison between different areas.	1
9	\N	\N	"tags".race_age_gender	Race, Age and Gender	catalog	Basic demographic breakdowns.	1
10	\N	\N	"tags".boundary	Boundaries	catalog	Use these to provide regions for sound comparison and analysis.	1
11	\N	\N	"tags".income_education_employment	Income, Education and Employment	catalog		1
12	\N	\N	"tags".population	Population	catalog		1
\.

--
-- PostgreSQL database dump complete
--

CREATE SCHEMA IF NOT EXISTS observatory;
ALTER TABLE obs_tag SET SCHEMA observatory;
