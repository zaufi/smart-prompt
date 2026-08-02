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
    local -n _ggb__output="$1"
    local _ggb__branch=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ -z ${_ggb__branch} ]]; then
        _ggb__branch=$(git describe --tags --always | sed -e 's,-\([0-9]\+\)-g.*, +\1,')
    fi
    _ggb__output=${_ggb__branch}
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
    local -n _ggds__output="$1"
    local -r _ggds__state=$2

    local _ggds__status_color
    case ${_ggds__state} in
        # Git operations in progress
        rebase | merge | cherry_pick | revert | bisect | conflict | detached | staged | modified | untracked | clean)
            _sp.get_color_param "SP_GIT_${_ggds__state^^}_COLOR" "sp_git_${_ggds__state}_color" _ggds__status_color
            ;;
        *)
            ;;
    esac
    _ggds__output=${_ggds__status_color}
}

function _show_git_status()
{
    local _sgs__branch
    _get_git_branch _sgs__branch

    local -r _sgs__state=$(_get_git_worktree_state "${PWD}")
    local _sgs__progress
    case ${_sgs__state} in
        # Git operations in progress
        rebase | merge | cherry_pick | revert | bisect)
            _sgs__progress="❲${_sgs__state}❳"
            ;;
        *)
            ;;
    esac

    local _sgs__status
    _get_git_dirty_status _sgs__status "${_sgs__state}"

    local _sgs__wt
    if [[ $(git rev-parse --git-path config.worktree) =~ .*/\.git/worktrees/.* ]]; then
        _sgs__wt=${SP_VCS_WT_SYMBOL:-\\360\\237\\214\\262}
    fi

    local _sgs__wtc=$(git worktree list | wc -l)
    if [[ ${_sgs__wtc} -lt 2 ]]; then
        if [[ -n ${_sgs__wt} ]]; then
            _sgs__wtc="❲${_sgs__wt}❳"
        else
            unset _sgs__wtc
        fi
    else
        if [[ -n ${_sgs__wt} ]]; then
            _sgs__wtc="❲${_sgs__wt}/${_sgs__wtc}❳"
        else
            _sgs__wtc="❲${_sgs__wtc}${SP_VCS_WT_SYMBOL:-\\360\\237\\214\\262}❳"
        fi
    fi

    local _sgs__repo
    if _sp.check_bool "${SP_INDICATE_REPO_TYPE}" -o [[ "${SP_INDICATE_REPO_TYPE[@]}" =~ git ]]; then
        _sgs__repo="${SP_REPO_GIT_MARK:-git:}"
    fi

    printf '%s%s%s%s%s%s' \
        "${_sgs__status}" \
        "${_sgs__repo}" \
        "${SP_VCS_BRANCH_SYMBOL:-\\356\\202\\240:}" \
        "${_sgs__branch}" \
        "${_sgs__wtc}" \
        "${_sgs__progress}"
}

function _show_git_git()
{
    local -r _sgg__org=$(git config --local --get remote.origin.url)
    _sp.get_color_param SP_GIT_ORIGIN_COLOR sp_color_info _sgg__origin_color
    printf '%s%s' "${_sgg__origin_color}" "${_sgg__org}"
}

if command -v git &>/dev/null; then
    SMART_PROMPT_PLUGINS[_50_is_git_repo]=_show_git_status
    SMART_PROMPT_PLUGINS[_51_is_git_dir]=_show_git_git
fi
