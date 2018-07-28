#!/bin/bash
#
# Show various systemd related info depending on a current dir
#
# Copyright (c) 2013-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

#BEGIN Service functions
function _systemd_get_default_target()
{
    local _sgdt__target=$(systemctl get-default)
    local _sgdt__output_var=$1
    eval "${_sgdt__output_var}=${_sgdt__target/.target/}"
}
#END Service functions

#
# Show count of started services
#
function _75_is_systemd_dir()
{
    return $(_cur_dir_starts_with /etc/systemd || _cur_dir_matches '/usr/(.*/)?lib/systemd')
}
function _systemd_show_default_target()
{
    local _sdt__target
    _systemd_get_default_target _sdt__target
    printf "${sp_notice}%s" ${_sdt__target}
}
SMART_PROMPT_PLUGINS[_75_is_systemd_dir]=_systemd_show_default_target
