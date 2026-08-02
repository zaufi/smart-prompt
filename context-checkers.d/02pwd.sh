#!/bin/bash

# SPDX-FileCopyrightText: 2014 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Append current path segment
#

function _02_show_pwd()
{
    return 0
}

function _show_pwd()
{
    local _dir_stack_size=''
    if [[ "${#DIRSTACK[@]}" -gt 1 ]]; then
        _dir_stack_size="${#DIRSTACK[@]}:"
    fi

    local _pwd_color
    _sp.get_color_param SP_PWD_COLOR sp_color_info _pwd_color

    local _pwd_marks
    local _pwd_empty_dir_color
    if [[ -z $(shopt -s nullglob; echo *) ]]; then
        _sp.get_color_param SP_EMPTY_DIR_COLOR sp_color_debug _pwd_empty_dir_color
        _pwd_marks=${_pwd_empty_dir_color}${SP_EMPTY_DIR_MARK}${sp_reset}
    else
        local _pwd_pair
        local _pwd_key
        local _pwd_glob
        for _pwd_pair in "${SP_MARKS_MAP[@]}"; do
            IFS=': ' read -r _pwd_key _pwd_glob <<<"${_pwd_pair}"
            _pwd_marks+=$([[ -e ${_pwd_glob} ]] && echo "${_pwd_key}")
        done
        for _pwd_pair in "${SP_MARK_PATTERNS_MAP[@]}"; do
            IFS=':' read -r _pwd_key _pwd_glob <<<"${_pwd_pair}"
            # shellcheck disable=SC2086
            _pwd_marks+=$([[ -n $(shopt -s extglob globstar nullglob; echo ${_pwd_glob}) ]] && echo "${_pwd_key}")
        done

        if [[ -n ${_pwd_marks} ]]; then
            _pwd_marks=${SP_OPEN_MARK:-❲}${_pwd_marks}${SP_CLOSE_MARKS:-❳}
        fi
    fi

    printf '%s%s\w%s' "${_pwd_color}" "${_dir_stack_size}" "${_pwd_marks}"
}

SMART_PROMPT_PLUGINS[_02_show_pwd]=_show_pwd
