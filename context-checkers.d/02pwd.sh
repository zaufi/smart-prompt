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
    local _sp__dir_stack_size=''
    if [[ ${#DIRSTACK[@]} > 1 ]]; then
        _sp__dir_stack_size="${#DIRSTACK[@]}:"
    fi

    local _sp__pwd_color
    _get_color_param SP_PWD_COLOR sp_color_info _sp__pwd_color

    local _sp__pwd_empty_dir_mark
    if [[ -z $(shopt -s nullglob; echo *) ]]; then
        _get_color_param SP_EMPTY_DIR_COLOR sp_color_debug _sp__pwd_color
        _sp__pwd_empty_dir_mark=${SP_EMPTY_DIR_MARK}
    fi
    printf "${_sp__pwd_color}${_sp__dir_stack_size}\\w${_sp__pwd_empty_dir_mark}"
}

SMART_PROMPT_PLUGINS[_02_show_pwd]=_show_pwd
