#!/usr/bin/env bash
set -euo pipefail

course_root=$(cd "${1:?Usage: bash scripts/preview-bios-214.sh /path/to/bios-214}" && pwd)
materials="$course_root/_site"
cd "$(dirname "$0")/.."

if [[ ! -f "$materials/lecture/index.html" || ! -f "$materials/lab/index.html" ]]; then
  printf 'Render the course materials first, from the bios-214 checkout:\n  julia +1.10 --project=export export/build.jl\n' >&2
  exit 1
fi

mkdir -p _site/bios-214
rsync -a --delete "$materials/" _site/bios-214/
exec bundle exec jekyll serve --host 127.0.0.1 --port 4108
