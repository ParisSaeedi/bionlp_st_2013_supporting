# BioNLP Shared Task 2013 Supporting Resources #

For the BioNLP Shared Task (ST) 2013 the organisers and third-parties provided
the participants with a set of supporting resources in the form of syntatic
parsers and other commonly used pre-processing methods used for
state-of-the-art Information Extraction (IE) systems. This repository contains
the pipeline used to produce the syntactic analyses provided by the
organisers.

The pipeline provides syntactic analyses from:

* The [Brown Laboratory for Linguistic Information Processing (BLLIP)
    Parser][bllip] using [a model trained on biomedical data by David
    McClosky][mcccj].
* The [Enju Parser][enju]
* The [Stanford Parser][stanford]

And provides their outputs in the following formats:

* Penn Treebank-style constituency parses (`.ptb`)
* CoNNL-X-style dependency parses (`.connlx`)
* Stanford-style vanilla (`.sdep`) and collapsed (`.sdepcc`) dependency parses

In addition to the above formats the output is also provided split into
sentences (`.ss`) using the [Genia Sentence Splitter][geniass] (GeniaSS) and
tokenised (`.tok`) using a tokenisation script mimicking the tokenisation used
by the Genia Treebank (GTB).

For details regarding all supporting resourges, please see the [BioNLP ST 2013
supporting resources homepage][bionlp_st_2013_supporting].

[bllip]: https://github.com/BLLIP/bllip-parser
[enju]: http://www.nactem.ac.uk/enju/
[geniass]: https://github.com/ninjin/geniass
[mcccj]: http://nlp.stanford.edu/~mcclosky/biomedical.html
[stanford]: http://nlp.stanford.edu/software/lex-parser.shtml

[bionlp_st_2013_supporting]: http://2013.bionlp-st.org/supporting-resources

## Usage ##

The pipeline largely mimics the [one used for BioNLP ST
2011][bionlp_st_2011_supporting_repo]. We assume that you are running some
sort of \*NIX-based operating system. In the case of the Enju parser the
source code is not publicly available and you will thus most likely have to
download a different binary from the [Enju homepage][enju] if you are not
using a Debian-based Linux distribution.

Make sure that you have a Sun Java installed on your system and install the
`dos2unix` command:

    sudo apt-get install dos2unix

You should now be able to run `make` in the root of the repository and you
will replicate the processing used for BioNLP ST 2013:

    make

Once the processing has been completed you can find the results in the `bld`
directory.

You may also want to consider the `VERSION` and `PROCESSES` variables. The
former marks the resulting archives with a label to make them easier to
identify and the latter allows for more efficient usage of multi-core
machines. For example:

    make VERSION=test PROCESSES=42

[bionlp_st_2011_supporting_repo]: https://github.com/ninjin/bionlp_st_2011_supporting

## In-depth Details ##

### Blank Lines ###

Blank lines in the original text files are removed since a majority of parsers
can't handle them. Keep this in mind if you try to re-align the parses to the
original text.

### Parser/Conversion Failures ###

All of the parsers applied are statistical in nature and will occasionally
fail to provide parses for a given sentence (with the exception of the BLLIP
parser that has an internal infallible fall-back). For these cases we produce
a flat parse instead of dropping the sentence from the output.

Similarly, the conversion tools used to convert from constituency parses to
dependency parses are rule-based and will fail for some sentences produced by
the up-stream statistical parsers. For these conversion failures we convert
the constituency parse into a flat parse and convert the flattened parse into
a dependency parse.

It should be noted that these failures are relatively rare (~0.01%).

### Pointers on Sanity Checking ###

If you want to do some naive error checking for your parser output, see the
lines below.

Naive sentence count sanity for `txt` to `ptb` (requires access to `tok`
files):

    for F in `find "${WORK_DIR}" -name '*.tok'`
    do
        S=`sed '/^$/d' "${F}" | wc -l`
        T=`wc -l "${F}.ptb" | cut -f 1 -d ' '`
        if [ ${S} -ne ${T} ]
        then
            MISMATCH_STR="\"${F}\" (${S}) and \"${F}.ptb\" (${T})"
            echo "ERROR: Sentence count mismatch for ${MISMATCH_STR}" 1>&2
        fi
    done

Naive sentence count sanity for `ptb` to `sdep`:

    for F in `find "${WORK_DIR}" -name '*.sdep'`
    do
        B=`echo "${F}" | sed -e 's|\.[^.]*$||g'`
        S=`cat ${B} | wc -l`
        T=`grep '^root(ROOT-0, ' "${F}" | wc -l`
        if [ ${S} -ne ${T} ]
        then
            MISMATCH_STR=\"${B}\" (${S}) and \"${F}\" (${T})"
            echo "ERROR: Sentence count mismatch for ${MISMATCH_STR}" 1>&2
        fi
    done

For `ptb` to `connlx`, just change the `T` assignment line with the line below
and adjust the `find` arguments accordingly:

    T=`cut -f 8 ${F} | grep ROOT | wc -l`

## Contact ##

For questions regarding the pipeline and its short-comings, please contact:

    Pontus Stenetorp <pontus stenetorp se>

For questions regarding the datasets and the shared task itself, please
contact:

    BioNLP ST 2013 Organising Committee <bionlp-st-adm googlegroups com>

## License ##

The majority of the content in this repository is made available under the
[ISC License][isc]. Do note that the external tools (`tls/ext`) use different
licenses and you may want to check the homepage of each tool for details.

[isc]: http://opensource.org/licenses/ISC
