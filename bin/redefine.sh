#!/bin/bash

f1() {
    echo "${FUNCNAME[0]}"
}

redefine() {
    [[ $# -eq 2 ]] || return 1
    local fname=$1
    local fbody=$2
    unset -f "$fname"
    eval "$fname" "$fbody"
}

redefine1() {
    [[ $# -eq 1 ]] || return 1
    local fname=$1
    local fbody
    while read -r; do
        fbody="${fbody}\n${REPLY}"
    done
    fbody=$(echo -e "$fbody")
    if [[ -n $fbody ]]; then
        unset -f "$fname"
        eval "$fname" "$fbody"
    else
        return 1
    fi
    return 0
}

f1

redefine "f1()" '{ 
    echo "f1_variant1" 
}'

f1

redefine1 "f1()" <<<'{
    echo "f1_variant2"
}'

f1
