#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

determine_ci_status() {
    local host
    host=$(git config --get remote.origin.url)
    case "$host" in 
        *github.com*)
            gh run list --json conclusion --json status --branch "$(git branch --show-current)" --limit 1 \
                --jq 'if .[].status == "completed" then .[].conclusion else .[].status end'
            ;;
        *gitlab.com*)
            glab ci get --output json | jq -r '.status'
            ;;
    esac
}

main() {
    PANE_PATH=$(tmux display-message -p -F "#{pane_current_path}")
    cd "$PANE_PATH"

    repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

    if [ "$repo" ]; then
        update_interval=$((60 * $(get_tmux_option "@tmux-ci-interval" 5)))
        current_time=$(date "+%s")
        previous_update=$(get_tmux_option "@ci-previous-update-time")
        delta=$((current_time - previous_update))

        if [ -z "$previous_update" ] || [ $delta -ge $update_interval ]; then
            local value=$(determine_ci_status | tr -d '\n')
            if [ "$?" -eq 0 ]; then
                $(set_tmux_option "@ci-previous-update-time" "$current_time")
                if [ -z  "$value" ]; then
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

