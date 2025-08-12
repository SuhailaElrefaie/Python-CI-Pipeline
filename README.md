Simple Jinja-based templater
============================

This is a trivial [Jinja](https://jinja.palletsprojects.com/en/3.1.x/) templater.

You can specify a template, input file that will be available as
`content` variable and also a JSON data file with extra variables.

Example invocation
------------------

Example data are available in the `examples/` subdirectory.

The content file contains the following:

    Our courses
    ===========

    Below is a list of (almost) all of our courses.


The JSON data file contains meta information about the courses.

    [
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
    ]


And the template looks like this:

    {{ content }}

    {%- for course in data -%}
     * [{{ course.name }} ({{ course.code }})]({{ course.homepage }}) {{ NL }}
    {%- endfor %}

We can invoke the templater like this on the above files.

    env PYTHONPATH=src python3 -m nswi177.templater \
        --template examples/courses.md.j2 --data examples/courses.json examples/courses.txt

This will render the template into the following output:

    Our courses
    ===========

    Below is a list of (almost) all of our courses.

    * [Introduction to Linux (NSWI177)](https://d3s.mff.cuni.cz/teaching/nswi177/)
    * [Operating Systems (NSWI200)](https://d3s.mff.cuni.cz/teaching/nswi200/)


Development and testing
-----------------------

To run the provided Python (unit) tests execute the following:

    env PYTHONPATH=src python3 -m pytest -vv tests/

Higher level tests (checking the whole application) are written in BATS and can
be run like this:

    bats tests/*.bats

