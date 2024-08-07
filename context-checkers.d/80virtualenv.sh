#!/bin/bash

# SPDX-FileCopyrightText: 2016 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Check if we are inside a `virtualenv`
#

function _80_check_virtualenv()
{
    [[ -n ${VIRTUAL_ENV} ]]
}

function _show_virtualenv()
{
    local _svenv_segment
    local _svenv__color
    if [[ -n ${VIRTUAL_ENV} ]]; then
        _get_color_param SP_VENV_COLOR sp_color_notice _svenv__color
        local _svenv_ve_path=$(realpath --relative-to="${PWD}" "${VIRTUAL_ENV}")
        if [[ ${#VIRTUAL_ENV} -lt ${#_svenv_ve_path} ]]; then
            _svenv_ve_path="${VIRTUAL_ENV}"
        fi
        _svenv_segment="${_svenv__color}${SP_VIRTUALENV_MARK:-🐍:}${_svenv_ve_path}"
    fi
    printf '%s' "${_svenv_segment}"
}

SMART_PROMPT_PLUGINS[_80_check_virtualenv]=_show_virtualenv
