#!/bin/bash

/etc/init.d/postgresql start

cd /srv

make clean-all
make install

cd /srv/src/pg

make test || { cat /srv/src/pg/test/regression.diffs; false; }
