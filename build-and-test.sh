#!/usr/bin/env bash

function echo_green() {
    echo -e "\e[32m$1\e[0m"
}

function echo_red() {
    echo -e "\e[31m$1\e[0m"
}

function arg_pararser() {
    # Define default values
    docker_name=${docker_name:-"yet-another-pihole-dot-doh"}
    target_arch=${target_arch:-"amd64"}
    docker_tag=${docker_tag:-"testing"}

    pihole_target_tag=${pihole_target_tag:-"latest"}

    clean_up=${clean_up:-"false"}

    # Assign the values given by the user
    while [ $# -gt 0 ]; do
        if [[ $1 == *"--"* ]]; then
            param="${1/--/}"
            declare -g "$param"="$2"
        fi
        shift
    done

    # Print the values
    echo_green "Pararser values:"
    echo_green "\tdocker_name: $docker_name"
    echo_green "\tpihole_target_tag: $pihole_target_tag"
    echo_green "\ttarget_arch: $target_arch"
    echo_green "\tdocker_tag: $docker_tag"
    echo_green "\tclean_up: $clean_up"
}

function clean_up() {
    rm -r ./src/test/config
    rm -r ./src/test/s6
    rm ./src/test/Dockerfile
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

pararser "$@"

cp -r ./src/config ./src/test/
cp -r ./src/s6 ./src/test/

cat ./src/Dockerfile ./src/test/COPY-RUN-CMD >./src/test/Dockerfile

docker build --no-cache --build-arg TAG="$pihole_target_tag" --build-arg TARGETARCH="$target_arch" --tag "$docker_name":"$docker_tag" ./src/test/
check_rc $? "Docker build"

current_timezone=$(cat /etc/timezone)
echo_green "Current timezone: $current_timezone"

docker run -e TZ="$current_timezone" -ti "$docker_name":"$docker_tag"
check_rc $? "Docker run"

if [ "$clean_up" = "true" ]; then
    clean_up
    echo_green "Clean up completed"
fi

echo_green "All testing completed successfully!"
