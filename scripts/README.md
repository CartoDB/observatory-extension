## Automatic tests and utilities

### Installation

Python 2.7 should cover you.  Virtualenv recommended.

    virtualenv venv
    source venv/bin/activate
    pip install -r requirements.txt

### Execution

Currently, we don't have direct access to the metadata end-to-end.  This only
affects the generation of tests.  As a stopgap, we have to define a connection
to the test Observatory account.

Run automated tests against a hostname:

    (venv) OBS_HOSTNAME=<hostname.cartodb.com> OBS_API_KEY=<api_key> OBS_META_HOSTNAME=observatory.cartodb.com OBS_META_API_KEY= nosetests scripts/autotest.py
