#!/bin/bash

readonly WAITING_TIME=10

trap 'tput cnorm' EXIT SIGKILL

spinner() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    tput civis
    while [[ -n "$(ps a | awk '{print $1}' | grep $pid)" ]]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    #tput cnorm
    printf "    \b\b\b\b"
}

spinner_with_timer() {
    local pid=$1
    local custom_line=${2:-}
    local delay=0.75
    local spinstr='|/-\'
    local time_line
    local line
    local line_length
    tput civis
    while [[ -n "$(ps a | awk '{print $1}' | grep $pid)" ]]; do
        local temp=${spinstr#?}
        time_line=$(date +%X)
        printf -v line ' %s (%c)  %s' "${time_line}" "$spinstr" "$custom_line"
        line_length=${#line}
        printf "%s" "${line}"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf -v line '%*s' ${line_length}
        line=${line// /'\b'}
        printf "$line"
    done
    tput el
    #tput cnorm
}

loading_string() {
    local pid=$1
    local first_string=${2:-Loading }
    local delay=0.75
    local counter=0
    local dots='.'
    local line
    local line_length
    tput civis
    while [[ -n "$(ps a | awk '{print $1}' | grep $pid)" ]]; do
        if [[ $counter -lt 3 ]]; then
            dots="$dots."
            : $((counter += 1))
        else
            dots='.'
            counter=0
            tput el
        fi
        printf -v line "%s%s" "$first_string" "$dots"
        line_length=${#line}
        printf "%s" "${line}"
        sleep $delay
        printf -v line '%*s' ${line_length}
        line=${line// /'\b'}
        printf "$line"
    done
    tput el
    #tput cnorm
}

long_process_imitation() {
    echo -n "Doing something important, please wait. "
    sleep $WAITING_TIME
}

(long_process_imitation) &
#spinner $!
#spinner_with_timer $! "Please, wait!"
loading_string $!
echo
