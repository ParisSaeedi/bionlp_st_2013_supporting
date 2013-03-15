#!/usr/bin/env sh

# Reads file paths on stdin and adds a terminal newline to the files that
#   lacks it, by the Unix definition of a text-file this is required.
#
# Hint: Works great with find.
#
# Author:   Pontus Stenetorp
# Version:  2013-03-10

# Return zero if the data on stdin has a terminal newline and 1 if not.
#
# Partially from:
#
#   http://stackoverflow.com/a/13840749
termnl () {
    tail -n 1 | xxd -p | grep -q '0a$'
    return $?
}

while read FPATH
do
    cat ${FPATH} | termnl
    if [ $? -eq 1 ]
    then
        echo >> ${FPATH}
    fi
done
