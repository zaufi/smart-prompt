#!/bin/bash
#
# Append schroot name if `schroot` detected
#
# Copyright (c) 2014 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _00_is_under_schroot()
{
    return `test -n "${SCHROOT_CHROOT_NAME}"`
}

function _show_schroot()
{
    printf "${sp_warn}${SCHROOT_CHROOT_NAME}"
}

SMART_PROMPT_PLUGINS[_00_is_under_schroot]=_show_schroot
