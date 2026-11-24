#!/bin/sh
set -eu

cd "$(dirname "$0")"

if [ "$#" -gt 1 ]; then
    printf 'Usage: %s [professional|education]\n' "$0" >&2
    exit 2
fi

case "${1-}" in
    "") set -- professional education ;;
    computer) set -- professional ;;
    professional|education) ;;
    *) printf 'Usage: %s [professional|education]\n' "$0" >&2; exit 2 ;;
esac

build_dir=$(mktemp -d "$PWD/.build.XXXXXX")
trap 'rm -rf "$build_dir"' EXIT

for variant in "$@"; do
    variant_dir="$build_dir/$variant"
    mkdir "$variant_dir"
    ruby render.rb "$variant" > "$variant_dir/main.tex"
    cp resume.cls "$variant_dir/"
    (
        cd "$variant_dir"
        latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error main.tex
    )
done

for variant in "$@"; do
    mv "$build_dir/$variant/main.pdf" "../assets/cv/CV_wanghao_$variant.pdf"
done
