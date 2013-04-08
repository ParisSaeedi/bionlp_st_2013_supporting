#!/usr/bin/env sh
#
# Parse input using the Stanford Parser with options recommended in 2011 by
#   the maintainers for highest possible parsing performance.
#
# Note: I have been unable to make the December 2012 version return no parse
#   for a sentence, thus we have no error-handling in this file.
#
# Author:       Pontus Stenetorp    <pontus stenetorp se>
# Version:      2013-02-27

set -e

SCRIPT_DIR=`dirname "$0"`
TLS_DIR=${SCRIPT_DIR}/../tls
STANFORD_PARSER_DIR=${TLS_DIR}/ext/stanford-parser
TOKENISE_PATH=${TLS_DIR}/GTB-tokenize.pl

${TOKENISE_PATH} \
    | java -mx8192m -cp "${STANFORD_PARSER_DIR}/*" \
        edu.stanford.nlp.parser.lexparser.LexicalizedParser \
        -sentences newline -tokenized -retainTmpSubcategories \
        -outputFormat oneline \
        -escaper edu.stanford.nlp.process.PTBEscapingProcessor \
        edu/stanford/nlp/models/lexparser/englishFactored.ser.gz -
