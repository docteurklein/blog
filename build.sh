#!/usr/bin/env sh

set -exuo pipefail

mkdir -p $(dirname "build/$1")

printf "$(cat template.html)" "$(head -n1 $1)" "$(comrak "$1")" > build/$(echo "$1" | sed -e 's/.md//').html
