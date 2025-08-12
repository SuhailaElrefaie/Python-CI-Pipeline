#!/usr/bin/env python3

"""
Trivial Jinja-based templater for the command-line.
"""

import argparse
import io
import json
import os
import re
import sys
import urllib.parse

import jinja2
import markdown

def debug_msg(msg):
    """Trivial logging for our templates."""

    print(f"[NSWI177 templater] {msg}", file=sys.stderr)

def jinja_filter_md2html(text):
    """Jinja filter that converts input string in Markdown to HTML."""

    return markdown.markdown(text)

@jinja2.pass_environment
def jinja_filter_replace_re(env, where, pattern, replacement):
    """Jinja filter to replace string based on a regular expression."""

    result = re.sub(pattern, replacement, where)
    if env.globals['DEBUG']:
        debug_msg((
            f"[RE replace] where='{where}' pattern='{pattern}'"
            f" repl='{replacement}' result='{result}'"
        ))
    return result


def jinja_filter_url_escape_query_param(where):
    """Jinja filter to escape URL query parameter."""

    return urllib.parse.quote_plus(where)

def get_jinja_environment(template_dir, debug):
    """Setup Jinja environment (adds filters and extensions)."""

    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(template_dir),
        autoescape=jinja2.select_autoescape(['html', 'xml']),
        extensions=['jinja2.ext.do', 'jinja2.ext.loopcontrols']
    )

    env.globals['DEBUG'] = debug
    env.filters['md2html'] = jinja_filter_md2html
    env.filters['replacere'] = jinja_filter_replace_re
    env.filters['url_escape_query_param'] = jinja_filter_url_escape_query_param

    return env

def parse_config(argv):
    """Parse command line arguments."""

    args = argparse.ArgumentParser(description='NSWI177 Templater')

    args.add_argument(
        '--debug',
        dest='debug',
        required=False,
        action='store_true',
        help='Print debugging information from templates'
    )
    args.add_argument(
        '--template',
        dest='template',
        required=True,
        metavar='FILENAME.j2',
        help='Jinja2 template file'
    )
    args.add_argument(
        '--data',
        default=None,
        dest='data',
        required=False,
        metavar='FILENAME.json',
        help='Data file'
    )
    args.add_argument(
        'source',
        metavar='FILE',
        help='Input file'
    )

    return args.parse_args(argv)


def main():
    """Program main."""

    config = parse_config(sys.argv[1:])

    template_dir = os.path.dirname(config.template)
    template_basename = os.path.basename(config.template)

    env = get_jinja_environment(template_dir, config.debug)
    template = env.get_template(template_basename)
    variables = {
        'data': {},
        'content': "",
        'NL': "\n",
        'SYMBOLS': {
            'tux': '\U0001F427',
        },
    }

    try:
        with open(config.source, 'rt', encoding='utf8') as inp:
            variables['content'] = inp.read()
    except IOError as err:
        print(f"Failed to open {config.source}: {err}.", file=sys.stderr)
        sys.exit(1)

    if config.data:
        with open(config.data, 'r', encoding='utf8') as inp:
            variables['data'] = json.load(inp)

    # Use \n even on Windows
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, newline='\n')

    result = template.render(variables)

    print(result)


if __name__ == '__main__':
    main()

