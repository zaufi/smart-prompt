#!/bin/bash
#
# Show status of a git repository
#
# Copyright (c) 2013 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _get_git_branch()
{
    local _get_git_branch__output_var=$1
    local _get_git_branch__branch=`git branch 2> /dev/null | grep '^\*\s\+' | sed 's,^\*\s\+\(.*\)$,\1,'`
    eval "${_get_git_branch__output_var}=\"${_get_git_branch__branch}\""
}

function _get_git_dirty_status()
{
    local _get_git_dirty_status__output_var=$1
    local _get_git_dirty_status__status_color
    if [ -z "`git status -s`" ]; then
        _eval_color_string "${SP_VCS_CLEAN:-bright-green}" _get_git_dirty_status__status_color
    else
        _eval_color_string "${SP_VCS_MODIFIED:-yellow}" _get_git_dirty_status__status_color
    fi
    eval "${_get_git_dirty_status__output_var}=\"${_get_git_dirty_status__status_color}\""
}

function _is_git_repo()
{
    if `git status -s 2>/dev/null`; then
        return 0
    fi
    return 1
}

function _show_git_status()
{
    local _show_git_status__branch
    _get_git_branch _show_git_status__branch
    local _show_git_status__status
    _get_git_dirty_status _show_git_status__status

    printf "${_show_git_status__status}git:${_show_git_status__branch}${sp_path}"
}

SMART_PROMPT_PLUGINS[_is_git_repo]=_show_git_status
