#!/bin/bash

# SPDX-FileCopyrightText: 2014 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

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
    local _mark="${SP_DOCKER_MARK:-🐳:}"
    if [[ ${SP_DOCKER_MARK} == 'none' ]]; then
        _mark=""
    fi
    printf '%s%s%s' "${_sdc__chroot_name}" "${_mark}" "$(< /etc/debian_chroot)"
}

SMART_PROMPT_PLUGINS[_00_is_under_docker]=_show_docker_debian_chroot
