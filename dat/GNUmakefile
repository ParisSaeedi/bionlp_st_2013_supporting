# Fetch the data for the BioNLP Shared Task 2013
#
# Author:		Pontus Stenetorp	<pontus stenetorp se>
# Version:		2013-02-27

FETCH_CMD=wget

BIONLP_ST_2013_BASE_URL=http://2013.bionlp-st.org/tasks/

TASK_ABBREVS=GE CG PC GRO GRN BB

GE_TRAIN_ARCH_FNAME=BioNLP-ST-2013_GE_train_data_rev2.tar.gz
GE_DEV_ARCH_FNAME=BioNLP-ST-2013_GE_devel_data_rev2.tar.gz
GE_TEST_ARCH_FNAME=

CG_TRAIN_ARCH_FNAME=BioNLP-ST_2013_CG_training_data.tar.gz
CG_DEV_ARCH_FNAME=BioNLP-ST_2013_CG_development_data.tar.gz
CG_TEST_ARCH_FNAME=BioNLP-ST_2013_CG_test_data.tar.gz

PC_TRAIN_ARCH_FNAME=BioNLP-ST_2013_PC_training_data.tar.gz
PC_DEV_ARCH_FNAME=BioNLP-ST_2013_PC_development_data.tar.gz
PC_TEST_ARCH_FNAME=BioNLP-ST_2013_PC_test_data.tar.gz

GRO_TRAIN_ARCH_FNAME=BioNLP-ST_2013_GRO_training_data.tar.gz
GRO_DEV_ARCH_FNAME=BioNLP-ST_2013_GRO_development_data.tar.gz
GRO_TEST_ARCH_FNAME=BioNLP-ST_2013_GRO_test-1.0-a1.tgz

GRN_TRAIN_ARCH_FNAME=BioNLP-ST-2013_Gene_Regulation_Network_train.tar.gz
GRN_DEV_ARCH_FNAME=BioNLP-ST-2013_Gene_Regulation_Network_dev.tar.gz
GRN_TEST_ARCH_FNAME=BioNLP-ST-2013_Gene_Regulation_Network_test.tar.gz

BB_TRAIN_ARCH_FNAME=BioNLP-ST-2013_Bacteria_Biotopes_train.tar.gz
BB_DEV_ARCH_FNAME=BioNLP-ST-2013_Bacteria_Biotopes_dev.tar.gz
BB_TEST_ARCH_FNAME=BioNLP-ST-2013_Bacteria_Biotopes_test.tar.gz

# Generate a listing of all archives
ARCH_FNAMES:=${foreach TASK_ABBREV,${TASK_ABBREVS}, \
	${foreach SUBSET,TRAIN DEV TEST,${${TASK_ABBREV}_${SUBSET}_ARCH_FNAME}}}

.DEFAULT_GOAL=all
all: ${ARCH_FNAMES}

# Gentle macro to generate our fetch targets
define fetch-target
$1:
	${FETCH_CMD} $2/$$@
endef
${foreach ARCH_FNAME,${ARCH_FNAMES}, \
	${eval \
		${call fetch-target,${ARCH_FNAME},${BIONLP_ST_2013_BASE_URL}} \
	} \
}

.PHONY: checksums
checksums: ${ARCH_FNAMES}
	../tls/checksums.sh ./ $^

.PHONY: clean
clean:
	rm -f ${ARCH_FNAMES}
