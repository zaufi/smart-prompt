#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show various Paludis-related details depending on the current directory
#

#
# Show the current profile and the count of configured repositories for `/etc/paludis`
#
function _70_is_inside_of_paludis_sysconf_dir()
{
    _sp.cur_dir_starts_with /etc/paludis
}
function _show_paludis_info()
{
    local _cave_bin
    if _sp.find_program cave _cave_bin; then
        local _repos_color
        _sp.get_color_param SP_PALUDIS_REPOS_COLOR sp_color_misc _repos_color
        printf "%s%d repos" "${_repos_color}" "$("${_cave_bin}" print-repositories | wc -l)"
    fi
}
SMART_PROMPT_PLUGINS[_70_is_inside_of_paludis_sysconf_dir]=_show_paludis_info
