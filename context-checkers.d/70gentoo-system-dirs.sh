#!/bin/bash
#
# Show various gentoo related info depending on a current dir
#
# Copyright (c) 2013 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _70_is_inside_of_portage_tree_dir()
{
    local _cur=`pwd | grep '/usr/portage'`
    return `test -n "${_cur}"`
}

function _show_tree_timestamp()
{
    local _misc_color
    _eval_color_string "${SP_MISC:-dark-grey}" _misc_color

    # Transform UTC date/time into local timezone
    local _stamp=`cat /usr/portage/metadata/timestamp.chk`
    local _local_stamp=`date -d "${_stamp}" +"${SP_TIME_FMT:-%H:%M %d/%m}"`
    printf "${_misc_color}timestamp: ${_local_stamp}${sp_path}"
}

SMART_PROMPT_PLUGINS[_70_is_inside_of_portage_tree_dir]=_show_tree_timestamp
