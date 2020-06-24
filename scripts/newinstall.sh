#!/bin/bash
  
# Please preserve tabs as indenting whitespace at Mario's request
# to keep heredocs nice (--fe)
#
# Bootstrap lsst stack install by:
#       * Installing Miniconda Python distribution, if necessary
#       * Installing lsstinstall
#


LSST_MINICONDA_VERSION=${LSST_MINICONDA_VERSION:-4.7.12}
LSST_MINICONDA_BASE_URL=${LSST_MINICONDA_BASE_URL:-https://repo.continuum.io/miniconda}
MINICONDA_PATH=${MINICONDA_PATH:-${HOME}/miniconda}


print_error() {
  >&2 echo -e "$@"
}


fail() {
  local code=${2:-1}
  [[ -n $1 ]] && print_error "$1"
  # shellcheck disable=SC2086
  exit $code
}


#
# test to see if script is being sourced or executed. Note that this function
# will work correctly when the source is being piped to a shell. `Ie., cat
# newinstall.sh | bash -s`
#
# See: https://stackoverflow.com/a/12396228
#
am_I_sourced() {
  if [ "${FUNCNAME[1]}" = source ]; then
    return 0
  else
    return 1
  fi
}


config_curl() {
  # Prefer system curl; user-installed ones sometimes behave oddly
  if [[ -x /usr/bin/curl ]]; then
    CURL=${CURL:-/usr/bin/curl}
  else
    CURL=${CURL:-curl}
  fi

  # disable curl progress meter unless running under a tty -- this is intended to
  # reduce the amount of console output when running under CI
  CURL_OPTS=('-#')
  if [[ ! -t 1 ]]; then
    CURL_OPTS=('-sS')
  fi

  # curl will exit 0 on 404 without the fail flag
  CURL_OPTS+=('--fail')
}


main() {
  config_curl

  # check if conda is not already available
  if which conda > /dev/null; then
    fail "The conda executable is available in your path. Please use it to deploy lsstinstall."
  fi

  # check if MINICONDA_PATH do not exist
  if [ -d "${MINICONDA_PATH}" ]; then
    fail "It appears you have already a miniconda installation. Please use it to deploy lsstinstall."
  fi

  # Installing miniconda
  case $(uname -s) in
    Linux*)
      ana_platform="Linux-x86_64"
      ;;
    Darwin*)
      ana_platform="MacOSX-x86_64"
      ;;
    *)
      fail "Cannot install miniconda: unsupported platform $(uname -s)"
      ;;
  esac

  miniconda_remote="https://repo.continuum.io/miniconda/Miniconda3-${LSST_MINICONDA_VERSION}-${ana_platform}.sh"
  echo "Getting miniconda from ${miniconda_remote}"
  output_file=/tmp/miniconda.sh
  # curl -sSL "https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-${ana_platform}.sh" -o /tmp/miniconda.sh
  $CURL "${CURL_OPTS[@]}" -# -L "${miniconda_remote}" -o "$output_file"
  # shellcheck disable=SC2181
  if [ "$?" != 0 ]; then
    fail "Error downloading miniconda from the internet."
  fi
  bash /tmp/miniconda.sh -bfp "${MINICONDA_PATH}"
  rm -rf /tmp/miniconda.sh

  # enable conda in shell profile
  conda init

  # deploy lsst install
  conda activate
  # as soon as lsstinstall will be available in conda-forge, this has to be updated.
  conda install  -y lsstinstall -c gcomoretto

}


#
# support being sourced as a lib or executed
#
if ! am_I_sourced; then
  main "$@"
fi
