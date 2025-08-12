
setup() {
    # Setup temporary directory
    NSWI177_TEMP_BASE="$( mktemp -d -p "${TMPDIR:-/tmp}" nswi177-bats-XXXXXXXXXX )"
    NSWI177_TEMP="${NSWI177_TEMP_BASE}/data"
    mkdir "${NSWI177_TEMP}"
}

# Override the standard fail function to always print one empty line
# That makes reading the error message much much easier.
fail() {
    {
        echo ""
        if (( $# > 0 )); then
            echo "$@"
        else
            cat -
        fi
    } >&2
    return 1
}

launch() {
    status="0"
    if [[ -z "${timeout:-}" ]]; then
        timeout=5m
    fi
    rm -f "${NSWI177_TEMP_BASE:?}/fifo-stdout" "${NSWI177_TEMP_BASE:?}/fifo-stderr"
    mkfifo "${NSWI177_TEMP_BASE:?}/fifo-stdout"
    mkfifo "${NSWI177_TEMP_BASE:?}/fifo-stderr"
    ( cat "${NSWI177_TEMP_BASE:?}/fifo-stdout" > "${NSWI177_TEMP_BASE:?}/stdout" ) &
    ( cat "${NSWI177_TEMP_BASE:?}/fifo-stderr" > "${NSWI177_TEMP_BASE:?}/stderr" ) &
    timeout -k 30 "${timeout}" "$@" >"${NSWI177_TEMP_BASE:?}/fifo-stdout" 2>"${NSWI177_TEMP_BASE:?}/fifo-stderr" || status="$?"
    wait
    if [[ ${status} -eq 124 ]]; then
        if [[ -z "${command:-}" ]]; then
            fail "Command $* timed-out after ${timeout}."
        else
            fail "Command ${command} timed-out after ${timeout}."
        fi
    fi
    # shellcheck disable=SC2034
    output="$( cat "${NSWI177_TEMP_BASE:?}/stdout" )"
    # shellcheck disable=SC2034
    erroroutput="$( cat "${NSWI177_TEMP_BASE:?}/stderr" )"
}

mark_dump() {
    echo "---"
    cat "$@"
    echo "---"
}

dump_lines() {
    echo
    echo "$1"
    echo "$2" | mark_dump
}

explain_invocation_failed() {
    local message="$1"
    local expected_output="$2"
    local template_content="$3"
    local input_content="$4"
    local data_content="${5:-}"

    (
        echo "$message"
        echo
        dump_lines "Expected output" "$expected_output"
        dump_lines "Actual output" "$output"
        dump_lines "Standard error output" "$erroroutput"
        echo
        echo "Program exit code: $status"
        dump_lines "Template" "$template_content"
        dump_lines "Input" "$input_content"
        if [[ -n "$data_content" ]]; then
            dump_lines "JSON data" "$data_content"
        fi
    ) | fail
}

check_templater_works() {
    local expected_output="$1"
    local template_content="$2"
    local input_content="$3"
    local data_content="${4:-}"
    local -a args

    echo "$template_content" > "${NSWI177_TEMP}/template.j2"
    args+=("--template" "${NSWI177_TEMP}/template.j2")

    if [ -n "$data_content" ]; then
        echo "$data_content" > "${NSWI177_TEMP}/data.json"
        args+=("--data" "${NSWI177_TEMP}/data.json")
    fi

    echo "$input_content" > "${NSWI177_TEMP}/input.txt"
    args+=("${NSWI177_TEMP}/input.txt")

    launch nswi177-jinja-templater "${args[@]}"

    if [[ ${status} -ne 0 ]]; then
        explain_invocation_failed "Program terminated with non-zero exit code." "$@"
    fi

    if [[ "$output" != "$expected_output" ]]; then
        explain_invocation_failed "Program produced unexpected output" "$@"
    fi
}

