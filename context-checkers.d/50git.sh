#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show status of a git repository
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _50_is_git_repo()
{
    git rev-parse --is-inside-work-tree > /dev/null 2>&1
}

function _51_is_git_dir()
{
    _cur_dir_matches '\.git$'
}

function _get_git_branch()
{
    local _ggb__output_var=$1
    local _ggb__branch=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ -z ${_ggb__branch} ]]; then
        _ggb__branch=$(git describe --tags | sed -e 's,-\([0-9]\+\)-g.*, +\1,')
    fi
    eval "${_ggb__output_var}=\"${_ggb__branch}\""
}

function _get_git_dirty_status()
{
    local _ggds__output_var=$1
    local _ggds__status_color
    if [[ -z $(git status -s 2> /dev/null) ]]; then
        _get_color_param SP_GIT_GREEN_COLOR sp_color_info _ggds__status_color
    else
        _get_color_param SP_GIT_DIRTY_COLOR sp_color_warn _ggds__status_color
    fi
    eval "${_ggds__output_var}=\"${_ggds__status_color}\""
}

# THANX to https://github.com/twolfson/sexy-bash-prompt/blob/master/.bash_prompt
function _get_git_progress() {
    local _ggp__output_var=$1
    # Detect in-progress actions (e.g. merge, rebase)
    # https://github.com/git/git/blob/v1.9-rc2/wt-status.c#L1199-L1241
    local _ggp__git_dir="$(git rev-parse --git-dir)"

    # git merge
    local __ggp__result
    if [[ -f "${_ggp__git_dir}/MERGE_HEAD" ]]; then
        __ggp__result=merge
    elif [[ -d "${_ggp__git_dir}/rebase-apply" ]]; then
        # git am
        if [[ -f "${_ggp__git_dir}/rebase-apply/applying" ]]; then
            __ggp__result=am
        # git rebase
        else
            __ggp__result=rebase
        fi
    elif [[ -d "${_ggp__git_dir}/rebase-merge" ]]; then
        # git rebase --interactive/--merge
        __ggp__result=rebase
    elif [[ -f "${_ggp__git_dir}/CHERRY_PICK_HEAD" ]]; then
        # git cherry-pick
        __ggp__result=cherry-pick
    fi
    if [[ -f "${_ggp__git_dir}/BISECT_LOG" ]]; then
        # git bisect
        __ggp__result=bisect
    fi
    if [[ -f "${_ggp__git_dir}/REVERT_HEAD" ]]; then
        # git revert --no-commit
        __ggp__result=revert
    fi
    if [[ -n "${__ggp__result}" ]]; then
        eval "${_ggp__output_var}='❲${__ggp__result}❳'"
    fi
}

function _show_git_status()
{
    local _sgs__branch
    _get_git_branch _sgs__branch
    local _sgs__status
    _get_git_dirty_status _sgs__status
    local _sgs__progress
    _get_git_progress _sgs__progress

    local _sgs__wt
    if [[ $(git rev-parse --git-path config.worktree) =~ .*/\.git/worktrees/.* ]]; then
        _sgs__wt=${SP_VCS_WT_SYMBOL:-\\360\\237\\214\\262}
    fi

    local _sgs__wtc=$(git worktree list | wc -l)
    if [[ ${_sgs__wtc} -lt 2 ]]; then
        unset _sgs__wtc
    else
        _sgs__wtc="❲${_sgs__wtc}${SP_VCS_WT_SYMBOL:-\\360\\237\\214\\262}❳"
    fi

    local _sgs__repo
    if _sp_check_bool "${SP_INDICATE_REPO_TYPE}" -o [[ "${SP_INDICATE_REPO_TYPE[@]}" =~ git ]]; then
        _sgs__repo='git:'
    fi

    printf '%s%s%s%s%s%s%s' \
        "${_sgs__status}" \
        "${_sgs__repo}" \
        "${_sgs__wt}" \
        "${SP_VCS_BRANCH_SYMBOL:-\\356\\202\\240:}" \
        "${_sgs__branch}" \
        "${_sgs__wtc}" \
        "${_sgs__progress}"
}

function _show_git_git()
{
    local _sgg__org=$(git config --local --get remote.origin.url)
    _get_color_param SP_GIT_ORIGIN_COLOR sp_color_info _sgg__origin_color
    printf '%s%s' "${_sgg__origin_color}" "${_sgg__org}"
}

SMART_PROMPT_PLUGINS[_50_is_git_repo]=_show_git_status
SMART_PROMPT_PLUGINS[_51_is_git_dir]=_show_git_git
