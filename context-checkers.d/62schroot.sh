#!/bin/bash

# SPDX-FileCopyrightText: 2014 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show information about secure chroots
#

#
# Show configured schroot environments
#
function _62_is_etc_schroot_dir()
{
    _sp.cur_dir_starts_with /etc/schroot
}
function _show_schroot_config()
{
    local _schroot_bin
    if _sp.find_program schroot _schroot_bin; then
        local -r _total=$(${_schroot_bin} -l | wc -l)
        local -r _active=$(${_schroot_bin} --all-sessions -l 2>/dev/null | wc -l)
        printf '%s%d/%d active/total' "${sp_color_notice}" "${_active}" "${_total}"
    fi
}
SMART_PROMPT_PLUGINS[_62_is_etc_schroot_dir]=_show_schroot_config
