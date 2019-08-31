#!/bin/bash
#
# Append schroot name if `schroot` detected or `/etc/debian_chroot` exists
#
# Copyright (c) 2014-2019 Alex Turbov <i.zaufi@gmail.com>
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

function _show_debian_chroot()
{
    _get_color_param SP_CHROOT_NAME sp_color_warn _sdc__chroot_name
    if [[ -n ${SCHROOT_CHROOT_NAME} ]]; then
        printf "${_sdc__chroot_name}${SCHROOT_CHROOT_NAME}"
    else
        printf "${_sdc__chroot_name}$(< /etc/debian_chroot)"
    fi
}
SMART_PROMPT_PLUGINS[_00_is_under_schroot]=_show_debian_chroot
