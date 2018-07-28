#!/bin/bash
#
# Append schroot name if `schroot` detected
#
# Copyright (c) 2014-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _00_is_under_schroot()
{
    return $([[ -n ${SCHROOT_CHROOT_NAME} || -f /etc/debian_chroot ]])
}

function _show_schroot()
{
    if [[ -n ${SCHROOT_CHROOT_NAME} ]]; then
        printf "${sp_warn}${SCHROOT_CHROOT_NAME}"
    else
        printf "${sp_warn}$(< /etc/debian_chroot)"
    fi
}
SMART_PROMPT_PLUGINS[_00_is_under_schroot]=_show_schroot

#
# Show configured schroot environments
#
function _62_is_etc_schroot_dir()
{
    return $(_cur_dir_starts_with /etc/schroot)
}
function _show_schroot_config()
{
    local _ssc_schroot_bin
    if _find_program schroot _ssc_schroot_bin; then
        local _ssc_total=$(${_ssc_schroot_bin} -l | wc -l)
        local _ssc_active=$(${_ssc_schroot_bin} --all-sessions -l 2>/dev/null | wc -l)
        printf "${sp_notice}%d/%d active/total" ${_ssc_active} ${_ssc_total}
    fi
}
SMART_PROMPT_PLUGINS[_62_is_etc_schroot_dir]=_show_schroot_config
