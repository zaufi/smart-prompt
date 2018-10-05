#!/bin/bash
#
# Detect working under terminal multiplexers.
# Supports `tmux` and `screen`
#
# Copyright (c) 2015-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _01_is_under_terminal_multiplexer()
{
    return $([[ -n "${TMUX_PANE}" || -n "${STY}" || "${TERM}" = screen ]])
}

function _show_terminal_multiplexer()
{
    local _multiplexer;
    if [[ -n ${TMUX_PANE} ]]; then
        _multiplexer="tmux[$([[ "${TMUX}" =~ .*,([0-9]+),.* ]] && echo "${BASH_REMATCH[1]}")]"
    elif [[ -n "${STY}" ]]; then
        _multiplexer="screen[$([[ "${STY}" =~ ([^\.]+)\..* ]] && echo "${BASH_REMATCH[1]}")]"
    else
        _multiplexer='screen(?)'
    fi
    printf "${sp_color_warn}${_multiplexer}"
}

SMART_PROMPT_PLUGINS[_01_is_under_terminal_multiplexer]=_show_terminal_multiplexer
