#!/bin/bash

docker run -e PGHOST=localhost -e PGPORT=5432 -v `pwd`:/srv --entrypoint="/bin/bash" ${1} /srv/scripts/ci/run_tests_docker.sh && \
    docker ps --filter status=dead --filter status=exited -aq | xargs docker rm -v
