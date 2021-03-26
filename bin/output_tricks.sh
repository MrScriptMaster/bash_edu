#!/bin/bash

progress() {
    local bcksp='\b'
    local mult=1
    for n in {0..100}; do
        (($n % $mult == 0)) && bcksp="$bcksp\b" && : $((mult = $mult * 10))
        printf "%d%%" $n
        printf "$bcksp"
        sleep 0.5
    done
}

download() {
    echo -n "Downloading something: "
    progress 2>&1
    printf "Done"
    echo
}

download
