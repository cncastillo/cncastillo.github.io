#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."

mkdir -p assets/teaching _syllabus/build
ruby scripts/render-syllabus.rb > _syllabus/build/syllabus.md
"${PANDOC:-pandoc}" _syllabus/build/syllabus.md --from=markdown \
  --template=_syllabus/template.typ --lua-filter=_syllabus/syllabus.lua \
  --pdf-engine="${TYPST:-typst}" --pdf-engine-opt=--root --pdf-engine-opt="$PWD" \
  --pdf-engine-opt=--font-path --pdf-engine-opt="$PWD/assets/fonts/latin-modern" \
  --pdf-engine-opt=--ignore-system-fonts \
  --output=assets/teaching/bios-214-syllabus.pdf
