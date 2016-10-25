#!/bin/bash
#
# Check if we are inside a `virtualenv`
#
# Copyright (c) 2016 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _80_check_virtualenv()
{
    return `test -n ${VIRTUAL_ENV}`
}

function _show_virtualenv()
{
    local _svenv_segment
    if [ -n "${VIRTUAL_ENV}" ]; then
        _svenv_segment="${sp_notice}venv:${VIRTUAL_ENV}"
    fi
    printf "${_svenv_segment}"
}

SMART_PROMPT_PLUGINS[_80_check_virtualenv]=_show_virtualenv
