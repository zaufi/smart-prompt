#!/bin/bash
#
# Append schroot name if `schroot` detected or `/etc/debian_chroot` exists
#
# Copyright (c) 2014-2022 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _00_is_under_schroot()
{
    [[ -n ${SCHROOT_CHROOT_NAME} || -f /etc/debian_chroot ]]
}

function _show_debian_chroot()
{
    _get_color_param SP_CHROOT_NAME sp_color_warn _sdc__chroot_name
    if [[ -n ${SCHROOT_CHROOT_NAME} ]]; then
        printf '%s%s' "${_sdc__chroot_name}" "${SCHROOT_CHROOT_NAME}"
    else
        printf '%s%s' "${_sdc__chroot_name}" "$(< /etc/debian_chroot)"
    fi
}
SMART_PROMPT_PLUGINS[_00_is_under_schroot]=_show_debian_chroot

#
# Try to display a docker name
#
# NOTE Docker images expected to have their names in the `/etc/debian_chroot` file.
#
function _00_is_under_docker()
{
    [[ -e /.dockerenv && -e /etc/debian_chroot ]]
}

function _show_docker_debian_chroot()
{
    _get_color_param SP_CHROOT_NAME sp_color_warn _sdc__chroot_name
    printf '%s%s%s' "${_sdc__chroot_name}" "${SP_DOCKER_MARK:-🐳:}" "$(< /etc/debian_chroot)"
}
SMART_PROMPT_PLUGINS[_00_is_under_docker]=_show_docker_debian_chroot
