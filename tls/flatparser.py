#!/usr/bin/env python

'''
Fake flat parses, because some parsers prefers to crash or puke out non-sense
    instead of giving a flat parse. Accepts both sequences of tokens and
    existing PTB-style parses.

Note: It would be nice to not fake the PoS-tags if we are given raw tokens,
    but for now we simply assign everything as NN.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2012-05-17
'''

from argparse import ArgumentParser, FileType
from itertools import izip, repeat, tee
from re import compile as re_compile
from sys import stdin, stdout

from ptbesc import (escape as ptb_escape,
        escape_quotes_tokens as ptb_escape_quotes_tokens)

### Constants
# Sentence head tag by parser
HEAD_BY_PARSER = {
    'enju': 'TOP',
    'bllip': 'S1',
    'stanford': 'ROOT',
    }
PTB_TOK_TAG_REGEX=re_compile(r'\((?P<tag>[^()]+) (?P<token>[^()]+)\)')
PTB_HEAD_REGEX=re_compile(r'^\((?P<head>[^ ]*) ')
# Some special cases for our very naive tagger.
# Note: I believe the list below is exhaustive, if there is anything missing
#   do send me a note.
TAG_BY_TOK = {
        '.': '.',
        ',': ',',
        ':': ':',
        ';': ':',
        '``': '``',
        "''": "''",
        "`": '``',
        # The quote handling below is at least consistent with Enju, Stanford
        #   for example makes sure there are no internal tokens with
        #   unescaped quotes.
        '"': "``",
        # The quote handling below is consistent with Enju.
        "'": '``',
        '(': '-LRB-',
        ')': '-RRB-',
        '[': '-LRB-',
        ']': '-RRB-',
        '}': '-LRB-',
        '{': '-RRB-',
        # The question mark handling below is consistent with Stanford and
        #   McCCJ, but not with Enju that assigns it a PoS-tag instead.
        '?': '.',
        # The exclamation mark handling below is consistent with Stanford, but
        #   not Enju for the same reason as above.
        '!': '.',
        '$': '$',
    }
# Generate a mapping from each escaped version of a token to the same tag
for token, escaped_token in set((t, ptb_escape(t), )
        for t in TAG_BY_TOK if ptb_escape(t) != t):
    TAG_BY_TOK[escaped_token] = TAG_BY_TOK[token]
###

def flattagger(tokens):
    for token in tokens:
        try:
            tag = TAG_BY_TOK[token]
        except KeyError:
            # Go for the majority-class PoS-tag.
            tag = 'NN'
        yield tag

def _argparser():
    argparser = ArgumentParser("Flat parses, because sometimes you just don't "
            'know what else to do')
    argparser.add_argument('-p', '--parser',
            choices=sorted(k for k in HEAD_BY_PARSER), default='stanford',
            help='parser to fake the behaviour of (default: stanford)')
    argparser.add_argument('-d', '--do-not-escape', action='store_true',
            help="don't apply PTB escaping to the tokens")
    argparser.add_argument('-r', '--re-parse', action='store_true',
            help='interpret input as an existing PTB parse and transform it into '
            'a flat parse (implies -d and disables -p)')
    argparser.add_argument('-t', '--override-tags', action='store_true',
            help='when converting an existing parse override existing tags '
            '(implies -r)')
    argparser.add_argument('-i', '--input', default=stdin, type=FileType('r'),
            help='input source (default: stdin)')
    argparser.add_argument('-o', '--output', default=stdout, type=FileType('w'),
            help='output target (default: stdout)')
    return argparser

def main(args):
    argp = _argparser().parse_args(args[1:])

    if argp.re_parse:
        escape = False
    else:
        escape = not argp.do_not_escape

    if argp.override_tags:
        re_parse = True
    else:
        re_parse = argp.re_parse

    for line in (l.rstrip('\n') for l in argp.input):
        if re_parse:
            head = PTB_HEAD_REGEX.match(line).groupdict()['head']
            gdicts_tag, gdicts_tok = tee((m.groupdict()
                for m in PTB_TOK_TAG_REGEX.finditer(line)), 2)
            tokens = (d['token'] for d in gdicts_tok)
            if not argp.override_tags:
                tags = (d['tag'] for d in gdicts_tag)
            else:
                tags = flattagger(d['token'] for d in gdicts_tag)
        else:
            head = HEAD_BY_PARSER[argp.parser]
            soup = line.split()
            tokens, tokens_to_tag = tee((
                ptb_escape(t, preserve_quotes=True) if escape else t
                for t in (ptb_escape_quotes_tokens(soup) if escape else soup)),
                2)
            tags = flattagger(tokens_to_tag)

        argp.output.write('({} (S {}))\n'.format(head,
            ' '.join('({} {})'.format(tag, token)
                for tag, token in izip(tags, tokens))))
    return 0

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))
