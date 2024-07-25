#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show various Paludis related info depending on a current dir
#

#
# Show current profile and count of configured repositories for /etc/paludis
#
function _70_is_inside_of_paludis_sysconf_dir()
{
    _cur_dir_starts_with /etc/paludis
}
function _show_paludis_info()
{
    local _cave_bin
    if _find_program cave _cave_bin; then
        local _spi__repos_color
        _get_color_param SP_PALUDIS_REPOS_COLOR sp_color_misc _spi__repos_color
        printf "%s%d reps" "${_spi__repos_color}" "$("${_cave_bin}" print-repositories | wc -l)"
    fi
}
SMART_PROMPT_PLUGINS[_70_is_inside_of_paludis_sysconf_dir]=_show_paludis_info
