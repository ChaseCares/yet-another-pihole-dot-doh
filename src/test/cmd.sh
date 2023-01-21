#!/usr/bin/env bash

function echo_green() {
    echo -e "\e[32m$1\e[0m"
}

function echo_red() {
    echo -e "\e[31m$1\e[0m"
}

function check_rc() {
    local rc_to_check=$1
    local msg=$2

    if [ "$rc_to_check" -eq 0 ]; then
        echo_green "$msg: Passed."
    else
        echo_red "$msg: Failed with return code $rc_to_check."
        exit "$rc_to_check"
    fi
}

sleep 2s

echo_green "Running tests..."

# Cloudflared tests
pgrep -x 'cloudflared' >/dev/null
check_rc $? "\tcloudflared process check"

dig -p 5153 @127.1.1.1 +short +time=1 +tries=1 one.one.one.one | grep -q '1.1.1.1'
check_rc $? "\tcloudflared DNS check"

# Stubby tests
pgrep -x 'stubby' >/dev/null
check_rc $? "\tstubby DNS check"

dig -p 5253 @127.2.2.2 +short +time=1 +tries=1 one.one.one.one | grep -q '1.1.1.1'
check_rc $? "\tstubby DNS check"

echo_green "All tests passed!"
exit 0
