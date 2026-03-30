#!/usr/bin/env bash

if test "$#" -ne 2; then
    echo "Usage: "$0" <file.c> <resultName>"
    exit 1
fi
cFile="$1"
resName="$2"
if [ "$cFile" != *.c ]; then
    echo "Err: Wrong argument format"
    exit 1
fi
gcc -Wall -Werror -Wpedantic -Wextra -o0 -std=c18 ./"$cFile" -o "$resName" -lm >&2
exit 0