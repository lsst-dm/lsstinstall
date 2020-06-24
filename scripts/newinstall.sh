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


fail() {
  local code=${2:-1}
  [[ -n $1 ]] && n8l::print_error "$1"
  # shellcheck disable=SC2086
  exit $code
}


main() {

  # check if conda is not already available
  if which conda > /dev/null; then
    fail "The conda executable is available in your path. Please use it to deploy lsstinstall."
  fi

  # check if MINICONDA_PATH do not exist
  if [ -d ""${MINICONDA_PATH} ]; then
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
      n8l::fail "Cannot install miniconda: unsupported platform $(uname -s)"
      ;;
  esac

  curl -sSL https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-${ana_platform}.sh -o /tmp/miniconda.sh
  bash /tmp/miniconda.sh -bfp ${MINICONDA_PATH}
  rm -rf /tmp/miniconda.sh

  source "${MINICONDA_PATH}/etc/profile.d/conda.sh"

  # deploy lsst install
  conda activate
  # as soon as lsstinstall will be available in conda-forge, this has to be updated.
  conda install lsstinstall -c gcomoretto

}


#
# support being sourced as a lib or executed
#
if ! am_I_sourced; then
  main "$@"
fi
