#!/bin/bash
#
# Append current path segment
#
# Copyright (c) 2014-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _02_show_pwd()
{
    return 0
}

function _show_pwd()
{
    local _dir_stack_size=''
    if [[ ${#DIRSTACK[@]} > 1 ]]; then
        _dir_stack_size="${#DIRSTACK[@]}:"
    fi
    printf "${sp_path}${_dir_stack_size}\\w"
}

SMART_PROMPT_PLUGINS[_02_show_pwd]=_show_pwd
