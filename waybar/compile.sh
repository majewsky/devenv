#!/bin/sh
set -euo pipefail
cd "$(readlink -f "$(dirname "$0")")"

# only argument is hostname
MAIN_FILE="$1.json"

ALL_MODULES="$(jq -r '.["modules-left"][], .["modules-center"][], .["modules-right"][]' < "${MAIN_FILE}")"

(
  cat "${MAIN_FILE}"
  for MODULE in ${ALL_MODULES}; do
    if [ -f "modules/${MODULE}.json" ]; then
      echo "{ \"${MODULE}\":"
      cat "modules/${MODULE}.json"
      echo "}"
    fi
  done
) | jq -s add
