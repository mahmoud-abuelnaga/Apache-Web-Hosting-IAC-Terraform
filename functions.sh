#!/bin/bash
print_error() {
    local msg="$1"
    echo "error: $msg" >&2   
}

print_header() {
    local msg="$1"
    printf "\n##### %s #####\n" "$msg"
}

die() {
    local msg="$1"
    local exit_code="${2:-1}"
    if [ -z "$msg" ]; then
        print_error "invalid function call: die() requires a message"
        exit 1
    fi

    print_error "$msg"
    exit "$exit_code"
}

print_msg() {
    local msg="$1"
    printf "\n==> %s\n" "$msg"
}
