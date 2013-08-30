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
    local _ggb__output_var=$1
    local _ggb__branch=`git branch 2> /dev/null | grep '^\*\s\+' | sed 's,^\*\s\+\(.*\)$,\1,'`
    eval "${_ggb__output_var}=\"${_ggb__branch}\""
}

function _get_git_dirty_status()
{
    local _ggds__output_var=$1
    local _ggds__status_color
    if [ -z "`git status -s`" ]; then
        _eval_color_string "${SP_VCS_CLEAN:-bright-green}" _ggds__status_color
    else
        _eval_color_string "${SP_VCS_MODIFIED:-yellow}" _ggds__status_color
    fi
    eval "${_ggds__output_var}=\"${_ggds__status_color}\""
}

function _is_git_repo()
{
    return `git status -s 2>/dev/null`
}

function _show_git_status()
{
    local _sgs__branch
    _get_git_branch _sgs__branch
    local _sgs__status
    _get_git_dirty_status _sgs__status

    printf "${_sgs__status}git:${_sgs__branch}"
}

SMART_PROMPT_PLUGINS[_is_git_repo]=_show_git_status
