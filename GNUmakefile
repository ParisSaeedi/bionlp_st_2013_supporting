# Main Makefile for controlling the generation of the syntactic parses.
#
# Note: You most likely want to set the PROCESSES variable.
#
# Example:
#
#    make VERSION=${VERSION} PROCESSES=${AT_LEAST_A_FEW}
#
# Author:	Pontus Stenetorp	<pontus stenetorp se>
# Version:	2013-02-27

# Preferably, set the version `make VERSION='v1'` when building.
VERSION:=`date -u +%Y-%m-%dT%H%MZ`
PROCESSES=1

DAT_DIR=dat
EXT_DIR=tls/ext
BLD_DIR=bld
WRK_DIR=wrk

.PHONY: data
data:
	cd ${DAT_DIR}	&& make

.PHONY: ext
ext:
	cd ${EXT_DIR} && make

.DEFAULT_GOAL=all
.PHONY: all
all: data ext
	./build.sh ${VERSION} "${PROCESSES}"

.PHONY: clean
clean:
	cd "${DAT_DIR}" && make clean
	cd "${EXT_DIR}" && make clean
	cd "${BLD_DIR}" && make clean
	find "${WRK_DIR}" -mindepth 1 -type d | xargs -r rm -r -f
