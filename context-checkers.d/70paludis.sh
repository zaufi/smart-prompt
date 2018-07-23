#!/bin/bash
#
# Show various gentoo related info depending on a current dir
#
# Copyright (c) 2013-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

#
# Show current profile and count of configured repositories for /etc/paludis
#
function _70_is_inside_of_paludis_sysconf_dir()
{
    return $(_cur_dir_starts_with /etc/paludis)
}
function _show_paludis_info()
{
    local _cave_bin
    if _find_program cave _cave_bin; then
        printf "${sp_seg}${sp_misc}%d reps" $(${_cave_bin} print-repositories | wc -l)
    fi
}
SMART_PROMPT_PLUGINS[_70_is_inside_of_paludis_sysconf_dir]=_show_paludis_info
