#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

main() {
    PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}")
    cd $PANE_PATH

    repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

    if [ "$repo" ]; then
        update_interval=$((60 * $(get_tmux_option "@tmux-ci-interval" 5)))
        current_time=$(date "+%s")
        previous_update=$(get_tmux_option "@ci-previous-update-time")
        delta=$((current_time - previous_update))

        if [ -z "$previous_update" ] || [ $delta -ge $update_interval ]; then
            # TODO: try both github and gitlab here, use whichever returns something
            value=$(gh run list --json status --jq '.[].status' --limit 1 | tr -d '\n')
            if [ "$?" -eq 0 ]; then
                $(set_tmux_option "@ci-previous-update-time" "$current_time")
                if [ -z  $value ]; then
                    $(set_tmux_option "@ci-previous-value" "Unknown")
                else
                    $(set_tmux_option "@ci-previous-value" "$value")
                fi
            fi
        fi
    else
        echo "No Pipelines"
        return
    fi
    
    echo -n $(get_tmux_option "@ci-previous-value")
}

main

