#!/bin/bash
#
# Append schroot name if `schroot` detected
#
# Copyright (c) 2014-2016 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _00_is_under_schroot()
{
    return `test -n "${SCHROOT_CHROOT_NAME}" -o -f /etc/debian_chroot`
}

function _show_schroot()
{
    if [ -f /etc/debian_chroot ]; then
        printf "${sp_warn}`cat /etc/debian_chroot`"
    else
        printf "${sp_warn}${SCHROOT_CHROOT_NAME}"
    fi
}

SMART_PROMPT_PLUGINS[_00_is_under_schroot]=_show_schroot
