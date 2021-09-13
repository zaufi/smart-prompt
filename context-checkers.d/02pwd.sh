#!/bin/bash
#
# Append current path segment
#
# Copyright (c) 2014-2021 Alex Turbov <i.zaufi@gmail.com>
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

    local _sp__pwd_marks
    if [[ -z $(shopt -s nullglob; echo *) ]]; then
        _get_color_param SP_EMPTY_DIR_COLOR sp_color_debug _sp__pwd_empty_dir_color
        _sp__pwd_marks=${_sp__pwd_empty_dir_color}${SP_EMPTY_DIR_MARK}${sp_reset}
    else
        local _sp__pwd_pair
        local _sp__pwd_key
        local _sp__pwd_glob
        for _sp__pwd_pair in "${SP_MARKS_MAP[@]}"; do
            IFS=': ' read -r _sp__pwd_key _sp__pwd_glob <<<${_sp__pwd_pair}
            _sp__pwd_marks+=$([[ -e ${_sp__pwd_glob} ]] && echo ${_sp__pwd_key})
        done
        for _sp__pwd_pair in "${SP_MARK_PATTERNS_MAP[@]}"; do
            IFS=':' read -r _sp__pwd_key _sp__pwd_glob <<<${_sp__pwd_pair}
            _sp__pwd_marks+=$([[ -n $(shopt -s extglob globstar nullglob; echo ${_sp__pwd_glob}) ]] && echo ${_sp__pwd_key})
        done

        if [[ -n ${_sp__pwd_marks} ]]; then
            _sp__pwd_marks=${SP_OPEN_MARK:-❲}${_sp__pwd_marks}${SP_CLOSE_MARKS:-❳}
        fi
    fi

    printf "${_sp__pwd_color}${_sp__dir_stack_size}\\w${_sp__pwd_marks}"
}

SMART_PROMPT_PLUGINS[_02_show_pwd]=_show_pwd
