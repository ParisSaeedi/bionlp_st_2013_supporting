#!/usr/bin/env python

'''
PennTreebank (PTB) escaping.

Note: Remember that for PTB `unescape(escape(s)) == s` doesn't always hold. An
    example of this would be the string "''". If you want these guarantees you
    will have to align the output towards the original text.

Author:     Pontus Stenetorp    <pontus stenetorp se>
Version:    2011-09-12
'''

### Constants
# From: To
PTB_ESCAPES = {
    '(': '-LRB-',
    ')': '-RRB-',
    '[': '-LSB-',
    ']': '-RSB-',
    '{': '-LCB-',
    '}': '-RCB-',
    '/': '\/',
    '*': '\*',
    }
###

def escape(s, preserve_quotes=False):
    r = s
    for _from, to in PTB_ESCAPES.iteritems():
        r = r.replace(_from, to)
    if not preserve_quotes:
        r = _escape_quotes(r)
    return r

def __escape_quotes(s, in_quotes=False):
    curr_pos = 0
    r = []
    while curr_pos < len(s):
        next_quote = s.find('"', curr_pos)
        if next_quote == -1:
            r.append(s[curr_pos:])
            break
        r.append(s[curr_pos:next_quote])
        if in_quotes:
            r.append("''")
        else:
            r.append('``')
        in_quotes = not in_quotes
        curr_pos = next_quote + 1
    return (''.join(r), in_quotes, )

def _escape_quotes(s):
    r, in_quotes = __escape_quotes(s)
    return r

# Takes an iterator over tokens instead of a string
def escape_quotes_tokens(ts):
    in_quotes = False
    for t in ts:
        r, in_quotes = __escape_quotes(t, in_quotes=in_quotes)
        yield r

def unescape(s, preserve_quotes=False):
    r = s
    for to, _from in PTB_ESCAPES.iteritems():
        r = r.replace(_from, to)
    if not preserve_quotes:
        r = _unescape_quotes(r)
    return r

def _unescape_quotes(s):
    r = s
    for _from in ("''", '``', ):
        r = r.replace(_from, '"')
    return r

def main(args):
    from argparse import ArgumentParser
    from sys import stdin, stdout

    argparser = ArgumentParser('Escape and unescape characters PTB-style')
    argparser.add_argument('-u', '--unescape', action='store_true',
            help='unescape instead of escaping the input')
    argp = argparser.parse_args(args[1:])

    for line in (l.rstrip('\n') for l in stdin):
        if argp.unescape:
            r = unescape(line)
        else:
            r = escape(line)
        stdout.write(r)
        stdout.write('\n')

if __name__ == '__main__':
    from sys import argv
    exit(main(argv))

