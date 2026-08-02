#!/bin/bash

# SPDX-FileCopyrightText: 2016 - 2026 Alex Turbov <i.zaufi@gmail.com>
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
    local _segment
    local _color
    if [[ -n ${VIRTUAL_ENV} ]]; then
        _sp.get_color_param SP_VENV_COLOR sp_color_notice _color
        local _ve_path=$(realpath --relative-to="${PWD}" "${VIRTUAL_ENV}")
        if [[ ${#VIRTUAL_ENV} -lt ${#_ve_path} ]]; then
            _ve_path="${VIRTUAL_ENV}"
        fi
        _segment="${_color}${SP_VIRTUALENV_MARK:-🐍:}${_ve_path}"
    fi
    printf '%s' "${_segment}"
}

SMART_PROMPT_PLUGINS[_80_check_virtualenv]=_show_virtualenv
