#!/bin/bash

set -Eeo pipefail

expect() {
  local title="$1"
  local is="$2"
  local should="$3"

  echo -e "$title"

  if [[ "$is" != "$should" ]]; then
     echo -e "    expected(${should})"
     echo -e "    got(${is})"
     exit 1
  fi
}

case $MODE in
prepare-only)
  echo -e "*** testing lsstinstall prepare-only more ***"
  ./bin/lsstinstall -p -t d_2020_04_13 lsst_distrib
  ;;
help)
  echo -e "*** testing lsstinstall help ***"
  ./bin/lsstinstall -h
  ;;
*)
  echo "unknown MODE: $MODE"
  exit 1
  ;;
esac

# vim: tabstop=2 shiftwidth=2 expandtab
