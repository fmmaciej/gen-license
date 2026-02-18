#!/usr/bin/env bash
set -euo pipefail

APP_NAME="gen-license"
BIN_NAME="gen-license"            # command in ~/.local/bin
ENTRYPOINT_REL="gen-license.sh"   # inside share dir

BIN_DIR="${HOME}/.local/bin"
SHARE_BASE="${HOME}/.local/share"
INSTALL_DIR="${SHARE_BASE}/${APP_NAME}"
LINK_PATH="${BIN_DIR}/${BIN_NAME}"

COPY_ITEMS=(
  "gen-license.sh"
  "config.sh"
  "templates"
  "README.md"
)

usage() {
    cat <<EOF
Usage: install.sh <command> 

Commands:
  install
  uninstall
  status
  help

Installs to:
  ${INSTALL_DIR}

Symlink:
  ${LINK_PATH} -> ${INSTALL_DIR}/${ENTRYPOINT_REL}

EOF
}

die() { echo "Error: $*" >&2; exit 1; }
note() { echo "==> $*"; }

ensure_local_dirs() {
    mkdir -p "$BIN_DIR" "$SHARE_BASE"
}

repo_root() {
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd
}

path_exists_in_repo() {
    local root="$1"
    local rel="$2"
    [[ -e "${root}/${rel}" ]]
}

copy_item() {
    local root="$1"
    local item="$2"
    local dst="$3"

    local src="${root}/${item}"
    [[ -e "$src" ]] || die "Missing in repo: $item"

    # -p -> preserve mode/timestamps (if possible)
    if [[ -d "$src" ]]; then
        cp -Rp "$src" "$dst/"
    else
        cp -p "$src" "$dst/"
    fi
}

make_executable_if_present() {
    local p="$1"
    [[ -f "$p" ]] || return 0

    chmod +x "$p"
}

install_app() {
    ensure_local_dirs

    local root
    root="$(repo_root)"

    local item
    for item in "${COPY_ITEMS[@]}"; do
        path_exists_in_repo "$root" "$item" || die "COPY_ITEMS refers to missing path: $item"
    done

    # temp dir for atomic install
    local tmp
    tmp="$(mktemp -d "${INSTALL_DIR}.tmp.XXXXXX")"
    trap 'rm -rf -- "$tmp"' EXIT

    note "Copying files into temp dir: $tmp"
    for item in "${COPY_ITEMS[@]}"; do
        copy_item "$root" "$item" "$tmp"
    done

    # Ensure entrypoint exists in installed tree
    [[ -f "${tmp}/${ENTRYPOINT_REL}" ]] || die "Entrypoint not found after copy: ${ENTRYPOINT_REL}"
    make_executable_if_present "${tmp}/${ENTRYPOINT_REL}"

    # Swap install dir
    if [[ -d "$INSTALL_DIR" ]]; then
        note "Replacing existing install dir: $INSTALL_DIR"
        rm -rf -- "$INSTALL_DIR"
    fi

    mkdir -p "$(dirname -- "$INSTALL_DIR")"
    mv -- "$tmp" "$INSTALL_DIR"
    trap - EXIT

    # Symlink in ~/.local/bin
    if [[ -L "$LINK_PATH" || -e "$LINK_PATH" ]]; then
        note "Removing existing bin entry: $LINK_PATH"
        rm -f -- "$LINK_PATH"
    fi

    ln -s -- "${INSTALL_DIR}/${ENTRYPOINT_REL}" "$LINK_PATH"

    note "Installed."
    note "Run: $BIN_NAME --help"
}

uninstall_app() {
    ensure_local_dirs

    if [[ -L "$LINK_PATH" || -e "$LINK_PATH" ]]; then
        note "Removing: $LINK_PATH"
        rm -f -- "$LINK_PATH"
    else
        note "No symlink found at: $LINK_PATH"
    fi

    if [[ -d "$INSTALL_DIR" ]]; then
        note "Removing: $INSTALL_DIR"
        rm -rf -- "$INSTALL_DIR"
    else
        note "No install dir found at: $INSTALL_DIR"
    fi

    note "Uninstalled."
}

status_app() {
    ensure_local_dirs

    echo "APP_NAME:     $APP_NAME"
    echo "INSTALL_DIR:  $INSTALL_DIR"
    echo "LINK_PATH:    $LINK_PATH"
    echo

    if [[ -d "$INSTALL_DIR" ]]; then
        echo "Install dir:  present"
    else
        echo "Install dir:  missing"
    fi

    if [[ -L "$LINK_PATH" ]]; then
        echo "Symlink:      present"
        echo " -> $(readlink "$LINK_PATH")"
    elif [[ -e "$LINK_PATH" ]]; then
        echo "Symlink:      NOT a symlink (file exists)"
    else
        echo "Symlink:      missing"
    fi

    if [[ -x "${INSTALL_DIR}/${ENTRYPOINT_REL}" ]]; then
        echo "Entrypoint:   executable"
    elif [[ -f "${INSTALL_DIR}/${ENTRYPOINT_REL}" ]]; then
        echo "Entrypoint:   not executable"
    else
        echo "Entrypoint:   missing"
    fi
}

main() {
    local cmd="${1:-help}"

    case "$cmd" in
        install)
            install_app
            ;;
        uninstall)
            uninstall_app
            ;;
        status)
            status_app
            ;;
        help|-h|--help)
            usage
            ;;
        *)
            die "Unknown command: $cmd"
            ;;
    esac
}

main "$@"
