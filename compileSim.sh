#!/usr/bin/env bash

if test "$#" -ne 1; then
    echo "Usage: "$0" <resultName>"
    exit 1
fi
resName="$1"
gcc -Wall -Werror -Wpedantic -Wextra -O0 -std=c18 \
    main.c physics.c init.c output.c simulation.c \
    -o "$resName" -lm
exit 0