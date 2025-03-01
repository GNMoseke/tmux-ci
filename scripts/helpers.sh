#!/usr/bin/env bash

# This script is copied from https://github.com/ilya-manin/tmux-weather/tree/master
# Check it out, it's a great plugin!

PATH="/usr/local/bin:$PATH:/usr/sbin"

get_tmux_option() {
  local option_name="$1"
  local default_value="$2"
  local option_value=$(tmux show-option -gqv $option_name)

  if [ -z "$option_value" ]; then
    echo -n $default_value
  else
    echo -n $option_value
  fi
}

set_tmux_option() {
  local option_name="$1"
  local option_value="$2"
  $(tmux set-option -gq $option_name "$option_value")
}

