#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show various systemd related info depending on a current dir
#

#
# Show count of started services
#
function _75_is_systemd_dir()
{
    _cur_dir_starts_with /etc/systemd || _cur_dir_matches '/usr/(.*/)?lib/systemd'
}
function _systemd_show_default_target()
{
    local _sdt__target=$(systemctl get-default)
    # NOTE To capture the exit code of `systemctl is-system-running`
    # declaration and assign are on the different lines.
    local _sdt__state
    _sdt__state=$(systemctl is-system-running)
    local -i _sdt__exit_code=$?

    local _sdt__target_color
    _get_color_param SP_SYSTEMD_TARGET_COLOR sp_color_notice _sdt__target_color

    local _sdt__state_color
    if [[ ${_sdt__exit_code} != 0 ]]; then
        _get_color_param SP_SYSTEMD_STATE_ALERT_COLOR sp_color_alert _sdt__state_color
    else
        _get_color_param SP_SYSTEMD_STATE_OK_COLOR sp_color_info _sdt__state_color
    fi

    printf '%s%s %s%s' "${_sdt__target_color}" "${_sdt__target}" "${_sdt__state_color}" "${_sdt__state}"
}

if command -v systemctl &>/dev/null; then
    SMART_PROMPT_PLUGINS[_75_is_systemd_dir]=_systemd_show_default_target
fi
