#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

parse_options "$@"

clean_cache
copy_repo_to_cache
load_mono
set_working_dir_to_cache_dir
build_in_docker