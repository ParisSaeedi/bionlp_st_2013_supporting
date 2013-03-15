#!/usr/bin/env sh

# Construct listings for the BioNLP ST 2013 Google Pages homepage. Making
# these manually just hurts.
#
# Author:   Pontus Stenetorp    <pontus stenetorp se>
# Version:  2013-03-12

HOST_URL=http://weaver.nlplab.org/~ninjin/bionlp_st_2013_supporting

flink () {
    echo "<a href=\"${HOST_URL}/$1\" target=\"_blank\">$1</a>"
}

echo `flink 'CHECKSUM.MD5'`
echo `flink 'CHECKSUM.SHA512'`
echo
echo
echo

for FMT in ssplit tok mcccj stanford enju
do
    ARCHS=`find . -maxdepth 1 -name '*.tar.gz' \
        | xargs -n 1 basename \
        | grep ${FMT} \
        | sort`
    for ARCH in ${ARCHS}
    do
        FLINK=`flink ${ARCH}`
        echo '<ul style="">'
        echo "\t<li style=\"\">"
        echo "\t\t<span style=\"font-size: small; line-height: 25px;\">"
        echo "\t\t\t${FLINK}"
        echo '\t\t</span>'
        echo '\t</li>'
        echo '</ul>'
    done
    echo
    echo
    echo
done
