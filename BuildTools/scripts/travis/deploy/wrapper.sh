#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

function start_in_docker() {
    docker run -v "${CACHE_DIR}:/duplicati" mono /bin/bash -c "cd /duplicati;./BuildTools/scripts/release.sh"
}

parse_options "$@"
load_mono

if $BUILD
then
    build_binaries
fi

start_in_docker