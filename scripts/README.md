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

    (venv) OBS_HOSTNAME=<hostname.cartodb.com> OBS_API_KEY=foobar OBS_META_HOSTNAME=<meta hostname> OBS_META_API_KEY=<meta api_key> nosetests scripts/autotest.py
