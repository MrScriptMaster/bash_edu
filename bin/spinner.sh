#!/bin/bash

spinner() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    tput civis
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    tput cnorm
    printf "    \b\b\b\b"
}

long_process_imitation() {
    echo -n "Doing something important, please wait..."
    sleep 10
}

(long_process_imitation) &
spinner $!
echo
