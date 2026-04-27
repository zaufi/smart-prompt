#!/bin/bash
# SPDX-FileCopyrightText: 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

set -eo pipefail

#
# Print script usage information.
#
function usage()
{
    cat <<'EOF'
Usage: cdui-feed.sh [OPTIONS]

Options:
  -m, --mc-hotlist        Include Midnight Commander hotlist feed
  -r, --recent            Include recent entries feed
  -g, --git-worktrees     Include Git worktrees feed
  -e, --env               Include environment-directory feed
      --ui-hints          Return UI hints for the selected feeds
      --update <dir>      Run plugin update hooks for the selected directory
  -h, --help              Show this help message
EOF
}

declare mc_hotlist=false
declare recent=false
declare git_worktrees=false
declare env_dirs=false
declare ui_hints=false
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
        -e|--env)
            if $update; then
                printf 'cdui-feed.sh: --update conflicts with other options\n' >&2
                usage >&2
                exit 1
            fi
            env_dirs=true
            shift
            ;;
        --ui-hints)
            if $update; then
                printf 'cdui-feed.sh: --update conflicts with other options\n' >&2
                usage >&2
                exit 1
            fi
            ui_hints=true
            shift
            ;;
        --update)
            if $mc_hotlist || $recent || $git_worktrees || $env_dirs || $ui_hints || $update; then
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

declare -r _plugin_dir="$(dirname "$0")"/cdui.d

#
# Source all available CDUI plugin scripts.
#
function _cdui_load_all_plugins()
{
    # shellcheck source=cdui.d/recent-plugin.sh
    . "${_plugin_dir}"/recent-plugin.sh
    # shellcheck source=cdui.d/hotlist-plugin.sh
    . "${_plugin_dir}"/hotlist-plugin.sh
    # shellcheck source=cdui.d/git-worktrees-plugin.sh
    . "${_plugin_dir}"/git-worktrees-plugin.sh
    # shellcheck source=cdui.d/env-plugin.sh
    . "${_plugin_dir}"/env-plugin.sh
}

#
# Check whether a function with the given name exists.
#
# @param $1 -- function name to probe
#
function _cdui_has_function()
{
    [[ $(type -t "$1") == function ]]
}

#
# Call a single plugin endpoint if the matching function is defined.
#
# @param $1 -- plugin name part used in `cdui_<plugin>_<endpoint>`
# @param $2 -- endpoint name suffix
# @param $@ -- optional arguments forwarded to the endpoint function
#
function _cdui_dispatch_plugin()
{
    local -r plugin_name="$1"
    local -r endpoint="$2"
    shift 2

    local -r fn="cdui_${plugin_name}_${endpoint}"
    if _cdui_has_function "${fn}"; then
        "${fn}" "$@"
    fi
}

#
# Call all loaded plugin endpoint functions matching the given suffix.
#
# @param $1 -- endpoint name suffix to match
# @param $@ -- optional arguments forwarded to each matched function
#
function _cdui_dispatch_all()
{
    local -r endpoint="$1"
    shift

    local fn
    while IFS= read -r fn; do
        "${fn}" "$@"
    done < <(
        compgen -A function -- cdui_ \
          | grep -E "^cdui_[[:alnum:]_]+_${endpoint}$" \
          | sort
      )
}

if $update; then
    _cdui_load_all_plugins
    _cdui_dispatch_all post_select_dir "${update_dir}"
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

if $env_dirs; then
    # shellcheck source=cdui.d/env-plugin.sh
    . "${_plugin_dir}"/env-plugin.sh
fi

if ! $recent && ! $mc_hotlist && ! $git_worktrees && ! $env_dirs; then
    exit 0
fi

if $ui_hints; then
    _cdui_dispatch_all get_ui_hint | jq -s 'add // []'
    exit 0
fi

_cdui_dispatch_all get_dirs | jq -s 'add // []'
