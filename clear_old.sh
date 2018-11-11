#!/bin/bash

if [ -z $1 ]
then
    echo "Usage: $0 <directory> <number_of_days>" 1>&2
    exit 1
else
    echo "Delete all files in '$1' older than '$2' days"
    find $1 -mtime +$2 -exec rm -- '{}' \;
fi
