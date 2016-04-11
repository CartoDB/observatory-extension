# Data Observatory Access

This file is for reference purposes only. It is intended for tracking the Data Observatory API functions that should be displayed from the Docs site. Like all API doc, the golden source of the code will live in this repo. I will pull the list of files below into the docs for the output.

## Documenation

### OBS_GetSegmentationSnapshot

API Example:
https://observatory.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20OBS_GetSegmentationSnapshot(CDB_LatLng(40.760410,-73.964242))

Response:
_Coming soon_


## OBS_GetDemographicSnapshot

The Demographic Snapshot API call enables you to collect demographic details around a point location. For example, you can take the coordinates of a bus stop and find the average population characteristics in that location. If you need help creating coordinates from your addresses, [see our geocoding documentation].

Fields returned include information about income, education, transportation, race, and more. Not all fields will have information for every coordinate queried.


### API Syntax

```html
https://{{account name}}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot({{point geometry}})
```

#### Parameters

**q**: API Query Request
| Parameter  | Description  |  Example  |
|---|:-:|:-:|
| account name  | The name of your CartoDB account where the Data Observatory has been enabled  | example_account  |
| point geometry  |  A WKB point geometry. You can use the helper function, CDB_LatLng to quickly generate one from latitude and longitude | CDB_LatLng(CDB_LatLng(40.760410,-73.964242))  |


### API Example

```html
https://example_account.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot(CDB_LatLng(40.760410,-73.964242))
```

### API Response

[Click to expand](https://gist.github.com/ohasselblad/c9e59a6e8da35728d0d81dfed131ed17)

```json
{
rows: [{
    total_pop: 0.0367277137353356,
    male_pop: 0.0121879169091962,
    female_pop: 0.0245397968261394,
    median_age: 50.4,
    white_pop: 0.0242118708106454,
    black_pop: 0.000710506366903814,
    asian_pop: 0.00923658276974959,
    hispanic_pop: 0.00256875378803687,
    amerindian_pop: 0,
    other_race_pop: 0,
    two_or_more_races_pop: 0,
    not_hispanic_pop: 0.0341589599472988,
    not_us_citizen_pop: null,
    workers_16_and_over: null,
    commuters_by_car_truck_van: null,
    commuters_drove_alone: null,
    commuters_by_carpool: null,
    commuters_by_public_transportation: null,
    commuters_by_bus: null,
    commuters_by_subway_or_elevated: null,
    walked_to_work: null,
    worked_at_home: null,
    children: null,
    households: 0.0218617343662712,
    population_3_years_over: null,
    in_school: null,
    in_grades_1_to_4: null,
    in_grades_5_to_8: null,
    in_grades_9_to_12: null,
    in_undergrad_college: null,
    pop_25_years_over: 0.0324646755339127,
    high_school_diploma: 0.000655852030988136,
    less_one_year_college: 0.00131170406197627,
    one_year_more_college: 0.00109308671831356,
    associates_degree: 0,
    bachelors_degree: 0.0228455124127534,
    masters_degree: 0.003224605819025,
    pop_5_years_over: null,
    speak_only_english_at_home: null,
    speak_spanish_at_home: null,
    pop_determined_poverty_status: null,
    poverty: null,
    median_income: 64583,
    gini_index: 0.4855,
    income_per_capita: 71109,
    housing_units: 0.0390231958437941,
    vacant_housing_units: 0.0171614614775229,
    vacant_housing_units_for_rent: 0,
    vacant_housing_units_for_sale: 0,
    median_rent: 1589,
    percent_income_spent_on_rent: 41.7,
    owner_occupied_housing_units: 0.00803418737960467,
    million_dollar_housing_units: 0.00136635839789195,
    mortgaged_housing_units: 0.00535612491973645,
    pop_15_and_over: null,
    pop_never_married: null,
    pop_now_married: null,
    pop_separated: null,
    pop_widowed: null,
    pop_divorced: null,
    commuters_16_over: 0.0286388720198153,
    commute_less_10_mins: 0.00207686476479576,
    commute_10_14_mins: 0.000710506366903814,
    commute_15_19_mins: 0.00601197695072458,
    commute_20_24_mins: 0.00131170406197627,
    commute_25_29_mins: 0.00114774105422924,
    commute_30_34_mins: 0.00885400241833984,
    commute_35_44_mins: 0.00519216191198941,
    commute_45_59_mins: 0,
    commute_60_more_mins: 0.00333391449085636,
    aggregate_travel_time_to_work: null,
    income_less_10000: 0.00191290175704873,
    income_10000_14999: 0,
    income_15000_19999: 0,
    income_20000_24999: 0.00377114917818178,
    income_25000_29999: 0,
    income_30000_34999: 0.000710506366903814,
    income_35000_39999: 0,
    income_40000_44999: 0,
    income_45000_49999: 0.00300598847536229,
    income_50000_59999: 0.000983778046482204,
    income_60000_74999: 0.000655852030988136,
    income_75000_99999: 0.000874469374650848,
    income_100000_124999: 0.00136635839789195,
    income_125000_149999: 0.00235013644437415,
    income_150000_199999: 0.00333391449085636
    }],
    time: 0.192,
    fields: {
      ...
    }
}
```
