#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="$HOME/.local/share/gen-license"

# Defaults
OUTPUT_FILE="LICENSE"
DRY_RUN=0
TEMPLATES_DIR="${TEMPLATES_DIR:-$INSTALL_DIR/templates}"
CONFIG_FILE="${CONFIG_FILE:-$INSTALL_DIR/config.sh}"
LICENSE_ID=""

FULL_NAME=""
YEAR=""
EMAIL=""
ORGANIZATION=""

usage() {
  cat <<'EOF'
Usage:
  gen-license.sh <license-id> [options]

Options:
  -o, --output <file>   Output filename (default: LICENSE)
  -t, --templates <dir> Templates directory (default: ./templates next to script)
  -d, --dry-run         Print to stdout instead of writing file
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

    local f
    for f in "$TEMPLATES_DIR"/*.in; do
        [[ -e "$f" ]] || return 0
        basename "$f" .in
    done | sort
}

die() {
    echo "Error: $*" >&2
    exit 1
}

parse_args() {
    local positional=()

    while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            [[ $# -ge 2 ]] || die "Missing value for $1"
            OUTPUT_FILE="$2"
            shift 2
            ;;

        -t|--templates)
            [[ $# -ge 2 ]] || die "Missing value for $1"
            TEMPLATES_DIR="$2"
            shift 2
            ;;

        -d|--dry-run)
            DRY_RUN=1
            shift
            ;;

        -l|--list)
            list_templates
            exit 0
            ;;

        -h|--help)
            usage
            exit 0
            ;;

        --)
            shift
            positional+=("$@")
            break
            ;;

        -*)
            die "Unknown option: $1"
            ;;

        *)
            positional+=("$1")
            shift
            ;;

    esac
    done

    LICENSE_ID="${positional[0]:-}"
    [[ -n "$LICENSE_ID" ]] || { usage; exit 1; }
    [[ "$LICENSE_ID" != -* ]] || die "Missing <license-id>"
}

load_config() {
    TEMPLATE_FILE="$TEMPLATES_DIR/$LICENSE_ID.in"
    [[ -f "$TEMPLATE_FILE" ]] || die "Template file not found: $TEMPLATE_FILE (use --list)"

    [[ -f "$CONFIG_FILE" ]] || die "Config not found: $CONFIG_FILE"

    # shellcheck disable=SC1090
    source "$CONFIG_FILE"

    : "${FULL_NAME:?Set FULL_NAME in config.sh}"
    YEAR="${YEAR:-$(date +%Y)}"
    EMAIL="${EMAIL:-}"
    ORGANIZATION="${ORGANIZATION:-}"
}

template_path() {
  printf '%s/%s.in' "$TEMPLATES_DIR" "$LICENSE_ID"
}

esc_sed() {
    local s="$1"
    s=${s//$'\n'/ }     # newline -> space
    s=${s//$'\r'/}      # strip CR (Windows)
    s=${s//\\/\\\\}     # \ -> \\
    s=${s//&/\\&}       # & -> \&
    s=${s//|/\\|}       # | -> \|

    printf '%s' "$s"
}

render() {
    local tf
    tf="$(template_path)"
    [[ -f "$tf" ]] || die "Template not found: $tf (use --list)"

    sed \
        -e "s|{{YEAR}}|$(esc_sed "$YEAR")|g" \
        -e "s|{{FULL_NAME}}|$(esc_sed "$FULL_NAME")|g" \
        -e "s|{{EMAIL}}|$(esc_sed "$EMAIL")|g" \
        -e "s|{{ORGANIZATION}}|$(esc_sed "$ORGANIZATION")|g" \
        "$tf"
}


write_output() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    render
    return 0
  fi

  [[ ! -e "$OUTPUT_FILE" ]] || die "Output file already exists: $OUTPUT_FILE (remove it or use --output)"
  render > "$OUTPUT_FILE"
  echo "Wrote $OUTPUT_FILE from template '$LICENSE_ID' using config '$CONFIG_FILE'"
}

main() {
  parse_args "$@"
  load_config
  write_output
}

main "$@"
