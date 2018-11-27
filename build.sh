#!/usr/bin/env sh

set -exuo pipefail

mkdir -p $(dirname "build/$1")

printf "$(cat template.html)" "$(head -n1 $1)" "$(comrak --github-pre-lang --hardbreaks --smart "$1")" \
    > build/$(echo "$1" | sed -e 's/.md//').html
