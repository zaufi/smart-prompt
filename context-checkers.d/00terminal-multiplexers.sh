#!/bin/bash
#
# Detect working under terminal multiplexers.
# Supports `tmux` and `screen`
#
# Copyright (c) 2015 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _01_is_under_terminal_multiplexer()
{
    return `test -n "${TMUX_PANE}" -o -n "${STY}" -o "${TERM}" = 'screen'`
}

function _show_terminal_multiplexer()
{
    local _mltplxr;
    if [ -n "${TMUX_PANE}" ]; then
        _mltplxr="tmux[`[[ "${TMUX}" =~ .*,([0-9]+),.* ]] && echo "${BASH_REMATCH[1]}"`]"
    elif [ -n "${STY}" ]; then
        _mltplxr="screen[`[[ "${STY}" =~ ([^\.]+)\..* ]] && echo "${BASH_REMATCH[1]}"`]"
    else
        _mltplxr='screen(?)'
    fi
    printf "${sp_warn}${_mltplxr}"
}

SMART_PROMPT_PLUGINS[_01_is_under_terminal_multiplexer]=_show_terminal_multiplexer
