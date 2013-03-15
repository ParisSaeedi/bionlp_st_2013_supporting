#!/usr/bin/env sh

# Process input using GeniaSS and a set of post-processing heuristics.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2013-03-11

set -e

SCRIPT_DIR=`dirname "$0"`
TLS_DIR=${SCRIPT_DIR}/../tls
GENIASS_SH_PATH=${TLS_DIR}/ext/geniass/run_geniass.sh
GENIASS_POSTPROC=${TLS_DIR}/geniass-postproc.pl

# Note: I don't know how GeniaSS opens input, but passing
#   `/dev/{input,output}` doesn't seem to work. So, we will hack around it.
TMP_INPUT=`mktemp`
TMP_OUTPUT=`mktemp`
trap 'rm -f "${TMP_INPUT}" "${TMP_OUTPUT}"' EXIT INT TERM HUP
cat > "${TMP_INPUT}"
${GENIASS_SH_PATH} "${TMP_INPUT}" "${TMP_OUTPUT}"
rm -f "${TMP_INPUT}"
cat "${TMP_OUTPUT}" | ${GENIASS_POSTPROC}
rm -f "${TMP_OUTPUT}"
