#!/usr/bin/env sh

set -exuo pipefail

mkdir -p $(dirname "build/$1")

printf "$(cat template.html)" "$(head -n1 $1)" "$(comrak "$1" --github-pre-lang --hardbreaks --smart \
    -e strikethrough -e tagfilter -e table -e autolink -e tasklist -e superscript -e footnotes -e description-lists)" \
    > build/$(echo "$1" | sed -e 's/.md//').html
