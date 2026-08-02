#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show status of a git repository
#

function _50_is_git_repo()
{
    git rev-parse --is-inside-work-tree > /dev/null 2>&1
}

function _51_is_git_dir()
{
    _sp.cur_dir_matches '\.git$'
}

function _get_git_branch()
{
    local -n _output="$1"
    local _branch_name=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ -z ${_branch_name} ]]; then
        _branch_name=$(git describe --tags --always | sed -e 's,-\([0-9]\+\)-g.*, +\1,')
    fi
    _output=${_branch_name}
}

function _get_git_worktree_state()
{
    local -r worktree="${1}"

    local gitdir
    gitdir=$(git -C "${worktree}" rev-parse --git-dir 2>/dev/null) \
      || return 1
    local -r gitdir

    # BEGIN Git operations in progress (highest priority)
    if [[ -d "${gitdir}"/rebase-merge || -d "${gitdir}"/rebase-apply ]]; then
        printf rebase
        return
    fi

    if [[ -f "${gitdir}"/MERGE_HEAD ]]; then
        printf merge
        return
    fi

    if [[ -f "${gitdir}"/CHERRY_PICK_HEAD ]]; then
        printf cherry_pick
        return
    fi

    if [[ -f "${gitdir}"/REVERT_HEAD ]]; then
        printf revert
        return
    fi

    if [[ -f "${gitdir}"/BISECT_LOG ]]; then
        printf bisect
        return
    fi
    # END Git operations in progress (highest priority)

    # BEGIN Content state
    local status
    status=$(git -C "${worktree}" status --porcelain 2>/dev/null)
    local -r status

    # Unmerged/conflicting paths.
    if grep -qE '^(DD|AU|UD|UA|DU|AA|UU)' <<< "${status}"; then
        printf conflict
        return
    fi

    # Detached HEAD.
    if ! git -C "${worktree}" symbolic-ref -q HEAD >/dev/null 2>&1; then
        printf detached
        return
    fi

    # Staged changes.
    if grep -qE '^[MADRCUT][[:space:]MADRCUT?]' <<< "${status}"; then
        printf staged
        return
    fi

    # Unstaged changes.
    if grep -qE '^.[MADRCUT]' <<< "${status}"; then
        printf modified
        return
    fi

    # Untracked files.
    if grep -q '^??' <<< "${status}"; then
        printf untracked
        return
    fi

    printf clean
    # END Content state
}

function _get_git_dirty_status()
{
    local -n _output="$1"
    local -r _state=$2

    local _status_color
    case ${_state} in
        # Git operations in progress
        rebase | merge | cherry_pick | revert | bisect | conflict | detached | staged | modified | untracked | clean)
            _sp.get_color_param "SP_GIT_${_state^^}_COLOR" "sp_git_${_state}_color" _status_color
            ;;
        *)
            ;;
    esac
    _output=${_status_color}
}

function _show_git_status()
{
    local _branch
    _get_git_branch _branch

    local -r _state=$(_get_git_worktree_state "${PWD}")
    local _progress
    case ${_state} in
        # Git operations in progress
        rebase | merge | cherry_pick | revert | bisect)
            _progress="❲${_state}❳"
            ;;
        *)
            ;;
    esac

    local _status
    _get_git_dirty_status _status "${_state}"

    local _wt
    if [[ $(git rev-parse --git-path config.worktree) =~ .*/\.git/worktrees/.* ]]; then
        _wt=${SP_VCS_WT_SYMBOL:-\\360\\237\\214\\262}
    fi

    local _wtc=$(git worktree list | wc -l)
    if [[ ${_wtc} -lt 2 ]]; then
        if [[ -n ${_wt} ]]; then
            _wtc="❲${_wt}❳"
        else
            unset _wtc
        fi
    else
        if [[ -n ${_wt} ]]; then
            _wtc="❲${_wt}/${_wtc}❳"
        else
            _wtc="❲${_wtc}${SP_VCS_WT_SYMBOL:-\\360\\237\\214\\262}❳"
        fi
    fi

    local _repo
    if _sp.check_bool "${SP_INDICATE_REPO_TYPE}" -o [[ "${SP_INDICATE_REPO_TYPE[@]}" =~ git ]]; then
        _repo="${SP_REPO_GIT_MARK:-git:}"
    fi

    printf '%s%s%s%s%s%s' \
        "${_status}" \
        "${_repo}" \
        "${SP_VCS_BRANCH_SYMBOL:-\\356\\202\\240:}" \
        "${_branch}" \
        "${_wtc}" \
        "${_progress}"
}

function _show_git_git()
{
    local -r _org=$(git config --local --get remote.origin.url)
    _sp.get_color_param SP_GIT_ORIGIN_COLOR sp_color_info _origin_color
    printf '%s%s' "${_origin_color}" "${_org}"
}

if command -v git &>/dev/null; then
    SMART_PROMPT_PLUGINS[_50_is_git_repo]=_show_git_status
    SMART_PROMPT_PLUGINS[_51_is_git_dir]=_show_git_git
fi
