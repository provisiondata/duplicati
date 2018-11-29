function quit_on_error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error in $0 line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error in $0 line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}

set -eE
trap 'quit_on_error $LINENO' ERR

function load_mono () {
    echo "travis_fold:start:pull_mono"
    image="$CACHE_DIR/mono.tar"
    echo ls -al "$CACHE_DIR"
    ls -al "$CACHE_DIR"
    if [[ -f "$image" ]] && $CACHE_MONO; then
      echo "loading previously cached docker image"
      docker load <  "$image"
    else
      docker pull mono
      if $CACHE_MONO; then
        docker save mono > "$CACHE_DIR"/mono.tar
      fi
    fi
    echo "travis_fold:end:pull_mono"
}

function build_in_docker () {
    mono_docker "./BuildTools/scripts/travis/build/install.sh $FORWARD_OPTS"
    mono_docker "./BuildTools/scripts/travis/build/build.sh $FORWARD_OPTS"
}

function clean_cache () {
  sudo rsync -a --delete "$REPO_DIR" "$CACHE_DIR"
  rm -rf "$CACHE_DIR"/mono.tar
}

function copy_repo_to_cache () {
  sudo rsync -a "$REPO_DIR"/ "$CACHE_DIR"
}

function copy_cache_to_test_dir () {
  sudo rsync -a "$CACHE_DIR"/ "$TEST_DIR"
}

function restore_build_to_cache () {
  . "${SCRIPT_DIR}/../build/wrapper.sh" --redirect
}

function mono_docker () {
  docker run -v "${WORKING_DIR}:/duplicati" mono /bin/bash -c "cd /duplicati;$1"
}

function set_working_dir_to_test_dir () {
  WORKING_DIR=$TEST_DIR
}

function set_working_dir_to_cache_dir () {
  WORKING_DIR=$CACHE_DIR
}

function parse_options () {
  QUIET=false
  FORWARD_OPTS=""
  CACHE_MONO=false
  while true ; do
      case "$1" in
      --cache_mono)
        CACHE_MONO=true
        ;;
      --repodir)
        REPO_DIR=$2
        shift
        ;;
      --testdir)
        TEST_DIR=$2
        shift
        ;;
      --cache)
        CACHE_DIR=$2
        shift
        ;;
    	--quiet)
        IF_QUIET_SUPPRESS_OUTPUT=" > /dev/null"
        FORWARD_OPTS="$FORWARD_OPTS --$1"
    		;;
      --data)
        TEST_DATA=$2
        shift
        ;;
      --categories)
        TEST_CATEGORIES=$2
        shift
        ;;
      --* | -* )
        echo "unknown option $1, please use --help."
        exit 1
        ;;
      * )
        break
        ;;
      esac
      shift
  done
}

# duplicati root is relative to the stage dirs
DUPLICATI_ROOT="$( cd "$(dirname "$0")" ; pwd -P )/../../../../"