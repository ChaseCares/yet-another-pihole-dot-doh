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

dig A -4 -p 5153 +short +time=1 +tries=1 one.one.one.one | grep -q '1.1.1.1'
check_rc $? "\tcloudflared DNS IPv4 check"

dig AAAA -6 -p 5153 +short +time=1 +tries=1 one.one.one.one | grep -q '2606:4700:4700::1111'
check_rc $? "\tcloudflared DNS IPv6 check"

# Stubby tests
pgrep -x 'stubby' >/dev/null
check_rc $? "\tstubby DNS check"

dig A -4 -p 5253 @127.2.2.2 +short +time=1 +tries=1 one.one.one.one | grep -q '1.1.1.1'
check_rc $? "\tstubby DNS IPv4 check"

dig AAAA -6 -p 5253 @::1 +short +time=1 +tries=1 one.one.one.one | grep -q '2606:4700:4700::1111'
check_rc $? "\tstubby DNS IPv6 check"

echo_green "All tests passed!"
exit 0
