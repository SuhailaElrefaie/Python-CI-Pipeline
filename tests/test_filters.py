
import pytest

import nswi177.templater as tpl

@pytest.mark.parametrize("input_str,expected", [
    ("alpha", "alpha"),
    ("bravo charlie", "bravo+charlie"),
    (
        "special characters: ! @ # $ % ^ & * { } [ ] / ( )",
        "special+characters%3A+%21+%40+%23+%24+%25+%5E+%26+%2A+%7B+%7D+%5B+%5D+%2F+%28+%29"
    ),
])
def test_filter_url_escape_query_param(input_str, expected):
    assert tpl.jinja_filter_url_escape_query_param(input_str) == expected

