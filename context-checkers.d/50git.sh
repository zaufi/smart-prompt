#!/bin/bash
#
# Show status of a git repository
#
# Copyright (c) 2013-2017 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _50_is_git_repo()
{
    return $(git status -s 1>/dev/null 2>&1)
}

function _get_git_branch()
{
    local _ggb__output_var=$1
    local _ggb__branch=$(git symbolic-ref --short HEAD 2> /dev/null)
    eval "${_ggb__output_var}=\"${_ggb__branch}\""
}

function _get_git_dirty_status()
{
    local _ggds__output_var=$1
    local _ggds__status_color
    if [[ -z $(git status -s) ]]; then
        _ggds__status_color="${sp_info}"
    else
        _ggds__status_color="${sp_warn}"
    fi
    eval "${_ggds__output_var}=\"${_ggds__status_color}\""
}

function _show_git_status()
{
    local _sgs__branch
    _get_git_branch _sgs__branch
    local _sgs__status
    _get_git_dirty_status _sgs__status

    printf "${_sgs__status}git:${_sgs__branch}"
}

SMART_PROMPT_PLUGINS[_50_is_git_repo]=_show_git_status
