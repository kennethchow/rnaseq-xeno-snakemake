#!/bin/bash

# Check for correct usage
if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
    printf "Usage: %s data_dir\n" "$0"
    exit 1
fi

# Create necessary directories
directories=("logs" "results" "rawdata" "benchmarks")
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir "$dir" || { printf "Error: Could not create directory '%s'.\n" "$dir"; exit 1; }
    fi
done

# Change to rawdata directory
cd rawdata || { printf "Error: Could not change to 'rawdata' directory.\n"; exit 1; }

# Create symbolic links to .fq.gz files
fq_files=("$1"/*.fq.gz)
if [ ${#fq_files[@]} -eq 0 ]; then
    printf "Error: No .fq.gz files found in directory '%s'.\n" "$1"
    exit 1
fi

ln -s "${fq_files[@]}" . || { printf "Error: Could not create symbolic links in 'rawdata' directory.\n"; exit 1; }

# Move back to the parent directory
cd .. || { printf "Error: Could not change back to the parent directory.\n"; exit 1; }

# Save the list of samples to a file named samples
ls rawdata >> samples