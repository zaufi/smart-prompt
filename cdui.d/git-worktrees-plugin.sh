#!/bin/bash
#
# SPDX-FileCopyrightText: 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later
#

#
# Return a single Git worktree entry as a JSON array for the CDUI feed.
#
# @param $1 -- entry label to show
# @param $2 -- optional worktree path used as the entry URL
#
function _cdui_git_worktrees_entry()
{
    local -r _entry="$1"
    local -r _url="${2:-}"
    local _colored_entry="${_entry}"

    if [[ -z ${_url} && ${_entry} != *$'\e['* ]]; then
        _cdui_git_worktrees_init_colors
        _colored_entry="${_CDUI_GIT_WORKTREES_ALERT_COLOR}${_entry}${_CDUI_GIT_WORKTREES_RESET_COLOR}"
    fi

    jq -cn --arg entry "${_colored_entry}" --arg url "${_url}" --arg origin "󰊢" \
        '[{entry: $entry, url: $url, origin: $origin}]'
}

#
# Initialize ANSI color variables used by the Git worktrees plugin.
#
function _cdui_git_worktrees_init_colors()
{
    if ! declare -F _eval_ansi_color_string >/dev/null; then
        local -r _script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local -r _parent_dir="$(dirname "${_script_dir}")"
        # shellcheck source=smart-prompt-functions.sh
        . "${_parent_dir}/smart-prompt-functions.sh"
    fi

    if [[ -z ${_CDUI_GIT_WORKTREES_GREEN_COLOR+x} ]]; then
        declare -g _CDUI_GIT_WORKTREES_GREEN_COLOR
        _eval_ansi_color_string "${SP_GIT_GREEN_COLOR:-bright-green}" _CDUI_GIT_WORKTREES_GREEN_COLOR
    fi

    if [[ -z ${_CDUI_GIT_WORKTREES_DIRTY_COLOR+x} ]]; then
        declare -g _CDUI_GIT_WORKTREES_DIRTY_COLOR
        _eval_ansi_color_string "${SP_GIT_DIRTY_COLOR:-yellow}" _CDUI_GIT_WORKTREES_DIRTY_COLOR
    fi

    if [[ -z ${_CDUI_GIT_WORKTREES_ALERT_COLOR+x} ]]; then
        declare -g _CDUI_GIT_WORKTREES_ALERT_COLOR
        _eval_ansi_color_string "${SP_COLOR_ALERT:-red}" _CDUI_GIT_WORKTREES_ALERT_COLOR
    fi

    if [[ -z ${_CDUI_GIT_WORKTREES_RESET_COLOR+x} ]]; then
        declare -g _CDUI_GIT_WORKTREES_RESET_COLOR
        _eval_ansi_color_string 'reset' _CDUI_GIT_WORKTREES_RESET_COLOR
    fi
}

#
# Colorize a branch name based on the cleanliness of the worktree.
#
# @param $1 -- branch name to render
# @param $2 -- worktree path used to inspect git status
#
function _cdui_git_worktrees_colorize_branch()
{
    local -r _branch="$1"
    local -r _worktree="$2"

    local _branch_color
    if [[ -z $(git -C "${_worktree}" status --short 2>/dev/null) ]]; then
        _branch_color=${_CDUI_GIT_WORKTREES_GREEN_COLOR}
    else
        _branch_color=${_CDUI_GIT_WORKTREES_DIRTY_COLOR}
    fi

    printf '%s%s%s' "${_branch_color}" "${_branch}" "${_CDUI_GIT_WORKTREES_RESET_COLOR}"
}

#
# Return the Git worktrees list as a JSON array for the CDUI feed.
#
function cdui_git_worktrees_get_dirs()
{
    local _porcelain
    if ! _porcelain=$(git worktree list --porcelain 2>/dev/null); then
        _cdui_git_worktrees_entry 'failure on list working trees in this repository'
        return 0
    fi

    _cdui_git_worktrees_init_colors

    local _path=
    local _branch=
    local -a _items=()

    #
    # Append the current parsed worktree record to the result list.
    #
    function _cdui_append_git_worktree()
    {
        if [[ -n ${_path} && -n ${_branch} ]]; then
            local _branch_name=${_branch#refs/heads/}
            _items+=( "$(_cdui_git_worktrees_entry \
                "$(_cdui_git_worktrees_colorize_branch "${_branch_name}" "${_path}")" \
                "${_path}"
            )" )
        fi
    }

    while IFS= read -r _line; do
        if [[ -z ${_line} ]]; then
            _cdui_append_git_worktree
            _path=
            _branch=
            continue
        fi

        case "${_line}" in
            worktree\ *)
                _path=${_line#worktree }
                ;;
            branch\ *)
                _branch=${_line#branch }
                ;;
        esac
    done <<< "${_porcelain}"

    _cdui_append_git_worktree

    printf '%s\n' "${_items[@]}" | jq -s add
}

#
# Return the UI hint metadata for the Git worktrees feed.
#
function cdui_git_worktrees_get_ui_hint()
{
    if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]; then
        jq -cn --argjson order "${CDUI_PLUGIN_GIT_WORKTREES_ORDER:-3}" '
          [
            {
              hotkey: "CTRL-G",
              text: "Git work trees ",
              cli_option: "--git-worktrees",
              order: $order
            }
          ]
        '
    else
        printf '[]\n'
    fi
}
