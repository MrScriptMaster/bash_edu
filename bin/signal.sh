#!/bin/bash

demon_routine() {
    local pid_addresser=$1
    [[ -n $pid_addresser ]] || return 1
    local sleep_time=2
    local counter=3
    while [[ $counter -ne 0 ]]; do
        kill -10 $pid_addresser
        sleep $sleep_time
        : $((counter -= 1))
    done
    return 0
}

join_to() {
    local pid=$1
    local delay=0.75
    while [[ -n "$(ps a | awk '{print $1}' | grep $pid)" ]]; do
        sleep $delay
    done
    return 0
}

trap 'echo "Received SIGUSR1"' SIGUSR1

(demon_routine $$) &
join_to $!

exit 0