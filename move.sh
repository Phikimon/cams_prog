#!/bin/bash

if [ -z $1 ]
then
    echo "Usage: $0 <number_of_days> <src_dir> <dst_dir>" 1>&2
    exit 1
else
    echo "Move all files in '$2' older than '$1' days to the '$3'"
    find $2 -mmin $1 -exec mv -- '{}' $3 \;
fi
