#!/bin/bash

# SPDX-FileCopyrightText: 2015 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Detect working under terminal multiplexers.
# Supports `tmux` and `screen`
#

function _01_is_under_terminal_multiplexer()
{
    [[ -n ${TMUX_PANE} || -n ${STY} || ${TERM} == 'screen' ]]
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
    printf '%s%s' "${sp_color_warn}" "${_multiplexer}"
}

SMART_PROMPT_PLUGINS[_01_is_under_terminal_multiplexer]=_show_terminal_multiplexer
