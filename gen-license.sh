#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${TEMPLATES_DIR:-$SCRIPT_DIR/templates}"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/config.sh}"

usage() {
  cat <<'EOF'
Usage:
  gen-license.sh <license-id> [options]

Options:
  -o, --output <file>   Output filename (default: LICENSE)
  -t, --templates <dir> Templates directory (default: ./templates next to script)
  -c, --config <file>   Config file path (default: ./config.sh next to script)
      --dry-run         Print to stdout instead of writing file
  -l, --list            List available templates
  -h, --help            Show help

Template variables supported:
  {{YEAR}} {{FULL_NAME}} {{EMAIL}} {{ORGANIZATION}}

Examples:
  ./gen-license.sh mit
  ./gen-license.sh apache-2.0 -o LICENSE.md
  ./gen-license.sh mit --dry-run
EOF
}

list_templates() {
  if [[ ! -d "$TEMPLATES_DIR" ]]; then
    echo "Templates dir not found: $TEMPLATES_DIR" >&2
    exit 1
  fi

  # Show filenames without extension
  find "$TEMPLATES_DIR" -maxdepth 1 -type f -name '*.txt' -printf '%f\n' \
    | sed 's/\.txt$//' \
    | sort
}

die() {
  echo "Error: $*" >&2
  exit 1
}

LICENSE_ID="${1:-}"
shift || true

OUTPUT_FILE="LICENSE"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output) OUTPUT_FILE="${2:-}"; shift 2;;
    -t|--templates) TEMPLATES_DIR="${2:-}"; shift 2;;
    -c|--config) CONFIG_FILE="${2:-}"; shift 2;;
    --dry-run) DRY_RUN=1; shift;;
    -l|--list) list_templates; exit 0;;
    -h|--help) usage; exit 0;;
    *) die "Unknown option: $1";;
  esac
done

[[ -n "$LICENSE_ID" ]] || { usage; exit 1; }

TEMPLATE_FILE="$TEMPLATES_DIR/$LICENSE_ID"
[[ -f "$TEMPLATE_FILE" ]] || die "Template not found: $TEMPLATE_FILE (use --list)"

[[ -f "$CONFIG_FILE" ]] || die "Config not found: $CONFIG_FILE"

# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${FULL_NAME:?Set FULL_NAME in config.sh}"
YEAR="${YEAR:-$(date +%Y)}"
EMAIL="${EMAIL:-}"
ORGANIZATION="${ORGANIZATION:-}"

render() {
  # sed escaping: replace \, &, | (delimiter), and newlines (strip)
  esc() { printf '%s' "$1" | sed -e 's/[\/&|\\]/\\&/g' -e ':a;N;$!ba;s/\n/\\n/g'; }

  sed \
    -e "s|{{YEAR}}|$(esc "$YEAR")|g" \
    -e "s|{{FULL_NAME}}|$(esc "$FULL_NAME")|g" \
    -e "s|{{EMAIL}}|$(esc "$EMAIL")|g" \
    -e "s|{{ORGANIZATION}}|$(esc "$ORGANIZATION")|g" \
    "$TEMPLATE_FILE"
}

if [[ "$DRY_RUN" -eq 1 ]]; then
  render
else
  if [[ -e "$OUTPUT_FILE" ]]; then
    die "Output file already exists: $OUTPUT_FILE (remove it or choose --output)"
  fi
  render > "$OUTPUT_FILE"
  echo "Wrote $OUTPUT_FILE from template '$LICENSE_ID' using config '$CONFIG_FILE'"
fi
