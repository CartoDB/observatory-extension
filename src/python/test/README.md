### Integration/performance tests

Tests here are meant to be run on a box with an Observatory meta/data dump
loaded and ready to be tested against the API.

The local Python needs the requirements in `src/python/requirements.txt`.

In order to find and access the correct database, the `PGUSER`, `PGPASSWORD`,
`PGHOST`, `PGPORT` and `PGDATABASE` env variables should be set.

Tests should be executed as follows:

     nosetests test/autotest.py
     nosetests -s test/perftest.py
