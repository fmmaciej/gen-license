# README

## Usage

### Installation

```bash
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
```

### Gen-license

```bash
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
```
