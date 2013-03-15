# Fetch and set-up our selection of external tools.
#
# Author:		Pontus Stenetorp	<pontus stenetorp se>
# Version:		2013-02-27


### Global constants
FETCH_CMD=wget

### Enju
ENJU_BASE=enju-2.4.2
ENJU_DNAME=${ENJU_BASE}
ENJU_BIN_PATH=${ENJU_DNAME}/bin/enju
ENJU_ARCH_FNAME=${ENJU_BASE}-ubuntu8-i386.tar.gz
ENJU_BASE_URL=http://www.nactem.ac.uk/tsujii/downloads/files/enju

enju: ${ENJU_BIN_PATH}

${ENJU_BIN_PATH}: ${ENJU_ARCH_FNAME}
	tar -m -x -z -f $<
	ln -s -f ${ENJU_DNAME} enju

# Pull a Grace Hopper
${ENJU_ARCH_FNAME}:
	${FETCH_CMD} ${ENJU_BASE_URL}/$@


### McCCJ
BLLIP_BASE=bllip-parser
BLLIP_HASH=48a000055c2018ad56370503608490786486a691
BLLIP_ARCH_FNAME=${BLLIP_HASH}.tar.gz
BLLIP_DNAME=${BLLIP_BASE}-${BLLIP_HASH}
BLLIP_MAKEFILE_PATH=${BLLIP_DNAME}/Makefile
BLLIP_FIRST_PATH=${BLLIP_DNAME}/first-stage/PARSE/parseIt
BLLIP_BASE_URL=https://github.com/BLLIP/bllip-parser

MCCCJ_MODEL_ARCH_FNAME=bioparsingmodel-rel1.tar.gz
MCCCJ_DNAME=biomodel
MCCCJ_FEATURES_PATH=${MCCCJ_DNAME}/reranker/features.gz
MCCCJ_BASE_URL=http://bllip.cs.brown.edu/download

mcccj: bllip-bin mcccj-model

mcccj-model: ${MCCCJ_FEATURES_PATH}

${MCCCJ_FEATURES_PATH}: ${MCCCJ_MODEL_ARCH_FNAME}
	tar -m -x -z -f $<

${MCCCJ_MODEL_ARCH_FNAME}:
	${FETCH_CMD} ${MCCCJ_BASE_URL}/$@

bllip-bin: ${BLLIP_FIRST_PATH}

${BLLIP_FIRST_PATH}: ${BLLIP_MAKEFILE_PATH}
	cd ${BLLIP_DNAME} && make

# Note: The symlink is to make access easier for other scripts
${BLLIP_MAKEFILE_PATH}: ${BLLIP_ARCH_FNAME}
	tar -m -x -z -f $<
	ln -s -f ${BLLIP_DNAME} ${BLLIP_BASE}

${BLLIP_ARCH_FNAME}:
	${FETCH_CMD} ${BLLIP_BASE_URL}/archive/$@


### Stanford
STANFORD_BASE=stanford-parser-2012-11-12
STANFORD_DNAME=${STANFORD_BASE}
STANFORD_ARCH_FNAME=${STANFORD_BASE}.zip
STANFORD_JAR_PATH=${STANFORD_DNAME}/stanford-parser.jar
STANFORD_BASE_URL=http://nlp.stanford.edu/software

stanford: ${STANFORD_JAR_PATH}

# Note: Touching the extracted files to put the timestamps after the archive.
# 	Roughly equivalent to -m for tar, couldn't find a similar flag for unzip.
${STANFORD_JAR_PATH}: ${STANFORD_ARCH_FNAME}
	unzip $<
	find ${STANFORD_DNAME} -type f | xargs touch
	ln -s -f ${STANFORD_DNAME} stanford-parser

${STANFORD_ARCH_FNAME}:
	${FETCH_CMD} ${STANFORD_BASE_URL}/$@

### Genia Sentence Splitter
GENIASS_BASE=geniass
GENIASS_HASH=f6a41ef03b49a289d73c5f0ef53f347b0b7701d5
GENIASS_ARCH_FNAME=${GENIASS_HASH}.tar.gz
GENIASS_DNAME=${GENIASS_BASE}-${GENIASS_HASH}
GENIASS_MAKEFILE_PATH=${GENIASS_DNAME}/Makefile
GENIASS_SH_PATH=${GENIASS_DNAME}/run_geniass.sh
GENIASS_BASE_URL=https://github.com/ninjin/geniass

geniass: ${GENIASS_SH_PATH}

${GENIASS_SH_PATH}: ${GENIASS_MAKEFILE_PATH}
	cd ${GENIASS_DNAME} && make

# Note: The symlink is to make access easier for other scripts
${GENIASS_MAKEFILE_PATH}: ${GENIASS_ARCH_FNAME}
	tar -m -x -z -f $<
	ln -s -f ${GENIASS_DNAME} ${GENIASS_BASE}

${GENIASS_ARCH_FNAME}:
	${FETCH_CMD} ${GENIASS_BASE_URL}/archive/$@


### Remaining targets
.DEFAULT_GOAL=all
all: enju mcccj stanford geniass

.PHONY: checksums
checksums: ${BLLIP_ARCH_FNAME} ${MCCCJ_MODEL_ARCH_FNAME} ${ENJU_ARCH_FNAME} \
		${STANFORD_ARCH_FNAME}
	../checksums.sh ./ $^

.PHONY: clean
clean:
	rm -r -f ${BLLIP_DNAME} ${BLLIP_ARCH_FNAME}
	rm -r -f ${MCCCJ_DNAME} ${MCCCJ_MODEL_ARCH_FNAME}
	rm -r -f ${ENJU_DNAME} ${ENJU_ARCH_FNAME}
	rm -r -f ${STANFORD_DNAME} ${STANFORD_ARCH_FNAME}
	rm -r -f ${GENIASS_DNAME} ${GENIASS_ARCH_FNAME}
	rm -f `find . -maxdepth 1 -type l`
