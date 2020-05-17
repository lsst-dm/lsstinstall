#!/bin/bash
# 
#  Rubin Observatory init for Deployment of EUPS top level products
#  
#    Minimum set-up in order to be able to install and use lsstinstall from conda
#     - installing miniconda in home directory
#     - add conda to the PATH using conda init
#     - installing lsstinstall conda package in base environment
#
#############################################################################################


# variables
LSST_PYTHON_VERSION=3
LSST_MINICONDA_VERSION=${LSST_MINICONDA_VERSION:-4.7.12}
LSST_MINICONDA_BASE_URL=${LSST_MINICONDA_BASE_URL:-https://repo.continuum.io/miniconda}
LSST_CONDA_CHANNELS=${LSST_CONDA_CHANNELS:-"conda-forge"}
MINICONDA_PATH=${MINICONDA_PATH:${HOME}/miniconda}  

#  functions ----------------------
print_error() {
  >&2 echo -e "$@"
}


fail() {
  local code=${2:-1}
  [[ -n $1 ]] && print_error "$1"
  # shellcheck disable=SC2086
  exit $code
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


#  main  ----------------------------
config_curl

# test is conda is already installed
CONDA_PATH=`which conda`
if [[ ${CONDA_PATH} != "" ]]; then
  echo "Found conda at ${CONDA_PATH}"
  echo "Please use the existing conda to install lsstinstall in your base environment."
  echo " > conda activate"
  echo " > conda install lsstinstall -c conda-forge"
  exit
fi


# identifying platform
case $(uname -s) in
  Linux*)
    local ana_platform='Linux-x86_64'
    local pkg_postfix='linux-64'
    ;;
  Darwin*)
    local ana_platform='MacOSX-x86_64'
    local pkg_postfix='osx-64'
    ;;
  *)
    fail "Cannot install miniconda: unsupported platform $(uname -s)"
    ;;
esac


# install miniconda
# shellcheck disable=SC2154
miniconda_lock="${MINICONDA_PATH}/.deployed"
test -f "$miniconda_lock" || (
  miniconda_file_name="Miniconda${LSST_PYTHON_VERSION}"
  miniconda_file_name+="-${miniconda_version}-${ana_platform}.sh"

  echo " -> Deploying ${miniconda_file_name}"

  cd "/tmp"
  $CURL "${CURL_OPTS[@]}" -# -L \
    -O "${LSST_MINICONDA_BASE_URL}/${miniconda_file_name}"

  rm -rf "${MINICONDA_PATH}"
  bash "${miniconda_file_name}" -b -p "${MINICONDA_PATH}"

  touch "${miniconda_lock}"
  rm "${miniconda_file_name}"
)


# adding conda to the PATH
# shellcheck disable=SC1090 
. "${MINICONDA_PATH}/etc/profile.d/conda.sh"
conda init


# configure alt conda channel(s)
if [[ -n $LSST_CONDA_CHANNELS ]]; then
  # remove any previously configured non-default channels
  # XXX allowed to fail
  conda config --remove-key channels || true

  for c in $LSST_CONDA_CHANNELS; do
    conda config --add channels "$c"
  done

  # remove the default channels
  conda config --remove channels defaults

  conda config --show
fi


# installing lsstinstall
conda activate
conda install lsstinstall
