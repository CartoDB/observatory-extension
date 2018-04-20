#!/bin/bash

# echo commands
set -x

# exit on error
set -e

dpkg -l | grep postgresql

# Add the PDGD repository
apt-key adv --keyserver keys.gnupg.net --recv-keys 7FCC7D46ACCC4CF8
add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main"
apt-get update

# Remove those all PgSQL versions except the one we're testing
PGSQL_VERSIONS=(9.2 9.3 9.4 9.5 9.6 10)
/etc/init.d/postgresql stop # stop travis default instance
for V in "${PGSQL_VERSIONS[@]}"; do
    if [ "$V" != "$PGSQL_VERSION" ]; then
        apt-get -y remove --purge postgresql-${V} postgresql-client-${V} postgresql-contrib-${V} postgresql-${V}-postgis-2.3-scripts
    else
        apt-get -y remove --purge postgresql-${V}-postgis-2.3-scripts
    fi
done

apt-get -y autoremove

# Install PostgreSQL
apt-get -y install postgresql-${PGSQL_VERSION} postgresql-${PGSQL_VERSION}-postgis-${POSTGIS_VERSION} postgresql-server-dev-${PGSQL_VERSION}

# Configure it to accept local connections from postgres
echo -e "# TYPE  DATABASE        USER            ADDRESS                 METHOD \nlocal   all             postgres                                trust\nlocal   all             all                                     trust\nhost    all             all             127.0.0.1/32            trust" > /etc/postgresql/${PGSQL_VERSION}/main/pg_hba.conf

# Restart PostgreSQL
/etc/init.d/postgresql restart ${PGSQL_VERSION}

dpkg -l | grep postgresql
