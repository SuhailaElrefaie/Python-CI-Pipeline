#!/usr/bin/env bats

load "common"

@test "Simplest template" {
    check_templater_works \
        "Hello, World" \
        '{{ content }}' \
        "Hello, World"
}

@test "Empty template" {
    check_templater_works \
        "" \
        '' \
        "Hello, World"
}

@test "Trivial JSON data" {
    check_templater_works \
        "# NSWI177 Templating

Hello, World!" \
        '# {{ data.title }}{{ NL }}{{ NL }}{{ content }}' \
        "Hello, World!" \
        '{ "title": "NSWI177 Templating"}'
}

