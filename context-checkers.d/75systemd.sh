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

#
# Show count of started services
#
function _75_is_systemd_dir()
{
    return $(_cur_dir_starts_with /etc/systemd || _cur_dir_matches '/usr/(.*/)?lib/systemd')
}
function _systemd_show_default_target()
{
    local _sdt__target=$(systemctl get-default)
    # NOTE To capture the exit code of `systemctl is-system-running`
    # declaration and assign are on the different lines.
    local _sdt__state
    _sdt__state=$(systemctl is-system-running)
    local _sdt__exit_code=$?

    local _sdt__target_color
    _get_color_param SP_SYSTEMD_TARGET_COLOR sp_color_notice _sdt__target_color

    local _sdt__state_color
    if [[ ${_sdt__exit_code} != 0 ]]; then
        _get_color_param SP_SYSTEMD_STATE_ALERT_COLOR sp_color_alert _sdt__state_color
    else
        _get_color_param SP_SYSTEMD_STATE_OK_COLOR sp_color_info _sdt__state_color
    fi

    printf "${_sdt__target_color}%s ${_sdt__state_color}%s" ${_sdt__target} ${_sdt__state}
}
SMART_PROMPT_PLUGINS[_75_is_systemd_dir]=_systemd_show_default_target
