#!/usr/bin/env bash
#
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Input file not found: $input_file"
    exit 1
fi

mapfile -t tags < "$input_file"

counter=0

for tag in "${tags[@]}"; do
    toot tags_follow "${tag}"
    ((counter++))

    if ((counter % 20 == 0)); then
        echo "Pausing for 5 minutes..."
        sleep 300
    fi
done
