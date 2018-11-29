#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

echo -n | openssl s_client -connect scan.coverity.com:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | sudo tee -a /etc/ssl/certs/ca-

function test_in_docker() {
    mono_docker "./BuildTools/scripts/travis/unittest/install.sh;./BuildTools/scripts/travis/unittest/test.sh $TEST_CATEGORIES $TEST_DATA"
}

parse_options "$@"
load_mono
copy_cache_to_test_dir
set_working_dir_to_test_dir
test_in_docker