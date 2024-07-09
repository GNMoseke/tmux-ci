#!/usr/bin/env bash

# This script is copied and slightly modified from https://github.com/ilya-manin/tmux-weather/tree/master
# Check it out, it's a great plugin!

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/scripts/helpers.sh"

replace_placeholder_in_status_line() {
  local placeholder="\#{$1}"
  local script="#($2)"
  local status_line_side=$3
  local old_status_line=$(get_tmux_option $status_line_side)
  local new_status_line=${old_status_line/$placeholder/$script}

  $(set_tmux_option $status_line_side "$new_status_line")
}

main() {
  local ci_status="$CURRENT_DIR/scripts/ci-status.sh"
  replace_placeholder_in_status_line "ci-status" "$ci_status" "status-right"
}

main
