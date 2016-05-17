## Automatic tests and utilities

### Installation

Python 2.7 should cover you.  Virtualenv recommended.

    virtualenv venv
    source venv/bin/activate
    pip install -r requirements.txt

### Execution

Run automated tests against a hostname:

    (venv) OBS_HOSTNAME=<hostname.cartodb.com> OBS_API_KEY=foobar nosetests autotest.py
