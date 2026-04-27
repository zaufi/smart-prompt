#!/bin/bash
# SPDX-FileCopyrightText: 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

function usage()
{
    cat <<'EOF'
Usage: cdui-feed.sh [OPTIONS]

Options:
  -m, --mc-hotlist        Include Midnight Commander hotlist feed
  -r, --recent            Include recent entries feed
  -g, --git-worktrees     Include Git worktrees feed
  -h, --help              Show this help message
EOF
}

declare mc_hotlist=false
declare recent=false
declare git_worktrees=false

while (($# > 0)); do
    case "$1" in
        -m|--mc-hotlist)
            mc_hotlist=true
            shift
            ;;
        -r|--recent)
            recent=true
            shift
            ;;
        -g|--git-worktrees)
            git_worktrees=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            printf 'cdui-feed.sh: unknown option: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
        *)
            printf 'cdui-feed.sh: unexpected argument: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if (($# > 0)); then
    printf 'cdui-feed.sh: unexpected argument: %s\n' "$1" >&2
    usage >&2
    exit 1
fi

declare -a _CDUI_PLUGIN_ENTRIES=()
export _CDUI_PLUGIN_ENTRIES

if $mc_hotlist; then
    . "$(dirname "$0")"/cdui.d/hotlist-plugin.sh
fi

if $recent; then
    . "$(dirname "$0")"/cdui.d/recent-plugin.sh
fi

if $git_worktrees; then
    . "$(dirname "$0")"/cdui.d/git-worktrees-plugin.sh
fi

if [[ ${#_CDUI_PLUGIN_ENTRIES[@]} -eq 0 ]]; then
    exit 0
fi

for _plugin in "${_CDUI_PLUGIN_ENTRIES[@]}"; do
    ${_plugin}
done | jq -s add
