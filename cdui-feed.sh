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
      --update <dir>      Run plugin update hooks for the selected directory
  -h, --help              Show this help message
EOF
}

declare mc_hotlist=false
declare recent=false
declare git_worktrees=false
declare update=false
declare update_dir=

while (($# > 0)); do
    case "$1" in
        -m|--mc-hotlist)
            if $update; then
                printf 'cdui-feed.sh: --update conflicts with other options\n' >&2
                usage >&2
                exit 1
            fi
            mc_hotlist=true
            shift
            ;;
        -r|--recent)
            if $update; then
                printf 'cdui-feed.sh: --update conflicts with other options\n' >&2
                usage >&2
                exit 1
            fi
            recent=true
            shift
            ;;
        -g|--git-worktrees)
            if $update; then
                printf 'cdui-feed.sh: --update conflicts with other options\n' >&2
                usage >&2
                exit 1
            fi
            git_worktrees=true
            shift
            ;;
        --update)
            if $mc_hotlist || $recent || $git_worktrees || $update; then
                printf 'cdui-feed.sh: --update conflicts with other options\n' >&2
                usage >&2
                exit 1
            fi
            if (($# < 2)); then
                printf 'cdui-feed.sh: missing argument for --update\n' >&2
                usage >&2
                exit 1
            fi
            update=true
            update_dir=$2
            shift 2
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

if $update && [[ -z ${update_dir} ]]; then
    printf 'cdui-feed.sh: missing argument for --update\n' >&2
    usage >&2
    exit 1
fi

if (($# > 0)); then
    printf 'cdui-feed.sh: unexpected argument: %s\n' "$1" >&2
    usage >&2
    exit 1
fi

declare -a _CDUI_PLUGIN_ENTRIES=()
export _CDUI_PLUGIN_ENTRIES
declare -a _CDUI_PLUGIN_UPDATE_ENTRIES=()
export _CDUI_PLUGIN_UPDATE_ENTRIES

declare -r _plugin_dir="$(dirname "$0")"/cdui.d

function _cdui_load_all_plugins()
{
    # shellcheck source=cdui.d/recent-plugin.sh
    . "${_plugin_dir}"/recent-plugin.sh
    # shellcheck source=cdui.d/hotlist-plugin.sh
    . "${_plugin_dir}"/hotlist-plugin.sh
    # shellcheck source=cdui.d/git-worktrees-plugin.sh
    . "${_plugin_dir}"/git-worktrees-plugin.sh
}

if $update; then
    _cdui_load_all_plugins

    if [[ ${#_CDUI_PLUGIN_UPDATE_ENTRIES[@]} -eq 0 ]]; then
        exit 0
    fi

    for _plugin in "${_CDUI_PLUGIN_UPDATE_ENTRIES[@]}"; do
        "${_plugin}" "${update_dir}"
    done
    exit 0
fi

if $recent; then
    # shellcheck source=cdui.d/recent-plugin.sh
    . "${_plugin_dir}"/recent-plugin.sh
fi

if $mc_hotlist; then
    # shellcheck source=cdui.d/hotlist-plugin.sh
    . "${_plugin_dir}"/hotlist-plugin.sh
fi

if $git_worktrees; then
    # shellcheck source=cdui.d/git-worktrees-plugin.sh
    . "${_plugin_dir}"/git-worktrees-plugin.sh
fi

if [[ ${#_CDUI_PLUGIN_ENTRIES[@]} -eq 0 ]]; then
    exit 0
fi

for _plugin in "${_CDUI_PLUGIN_ENTRIES[@]}"; do
    ${_plugin}
done | jq -s add
