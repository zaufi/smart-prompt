#!/bin/bash
#
# Show info about secure chroots
#
# Copyright (c) 2014-2022 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

#
# Show configured schroot environments
#
function _62_is_etc_schroot_dir()
{
    _cur_dir_starts_with /etc/schroot
}
function _show_schroot_config()
{
    local _ssc_schroot_bin
    if _find_program schroot _ssc_schroot_bin; then
        local _ssc_total=$(${_ssc_schroot_bin} -l | wc -l)
        local _ssc_active=$(${_ssc_schroot_bin} --all-sessions -l 2>/dev/null | wc -l)
        printf '%s%d/%d active/total' "${sp_color_notice}" "${_ssc_active}" "${_ssc_total}"
    fi
}
SMART_PROMPT_PLUGINS[_62_is_etc_schroot_dir]=_show_schroot_config
