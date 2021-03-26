#!/bin/bash

producer() {
    for entry in {one,two,three}; do
        echo $entry >$1
    done
}

consumer() {
    while read -r line; do
        echo "consumer: $line"
    done
}

if mkfifo /tmp/pipe; then
    producer "/tmp/pipe" &
    consumer <"/tmp/pipe"
    # Это аналогично следующей записи, с той разницей, что в ней
    # канал неименованный.
    for e in {1,2,3}; do echo $e; done | consumer
else
    echo "Cannot create a FIFO pipe"
fi

rm -f /tmp/pipe
