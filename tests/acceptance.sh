#!/bin/bash

set -Eeo pipefail

case $MODE in
prepare-only)
  echo -e "*** testing lsstinstall prepare-only mode ***"
  ./bin/lsstinstall -p -t w_2020_32 lsst_distrib
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
