#!/usr/bin/env bats

load "common"

@test "Basic Markdown" {
    check_templater_works \
        "<p>Hello, <strong>World</strong></p>" \
        "{{ content|md2html }}" \
        "Hello, **World**"
}

@test "Make HTML from dynamically built content" {
    check_templater_works \
        '<ul>
<li><a href="https://d3s.mff.cuni.cz/teaching/nswi177/">Introduction to Linux (NSWI177)</a></li>
<li><a href="https://d3s.mff.cuni.cz/teaching/nswi200/">Operating Systems (NSWI200)</a></li>
</ul>' \
        '{%- set listing -%}
{%- for course in data -%}
 * [{{ course.name }} ({{ course.code }})]({{ course.homepage }}){{ NL }}
{%- endfor %}
{%- endset -%}
{{ listing | md2html }}' \
        '' \
        '[
  {
     "name": "Introduction to Linux",
     "code": "NSWI177",
     "homepage": "https://d3s.mff.cuni.cz/teaching/nswi177/"
  },
  {
     "name": "Operating Systems",
     "code": "NSWI200",
     "homepage": "https://d3s.mff.cuni.cz/teaching/nswi200/"
  }
]'
}

@test "Inline Markdown" {
    check_templater_works \
        "<p><em>Hello</em>, <strong>World</strong></p>" \
        '{{ content|md2html }}' \
        "_Hello_, **World**"
}

@test "Multiple paragraphs" {
    check_templater_works \
        '<p>First paragraph.</p>
<p>Second paragraph.</p>
<p>Third paragraph with <strong>emphasis</strong>.</p>' \
        '{{ content|md2html }}' \
        'First paragraph.

Second paragraph.

Third paragraph with **emphasis**.'
}
