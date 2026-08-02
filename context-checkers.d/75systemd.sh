#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show various systemd-related details depending on the current directory
#

#
# Show count of started services
#
function _75_is_systemd_dir()
{
    _sp.cur_dir_starts_with /etc/systemd || _sp.cur_dir_matches '/usr/(.*/)?lib/systemd'
}
function _systemd_show_default_target()
{
    local -r _target=$(systemctl get-default)
    # NOTE To capture the exit code of `systemctl is-system-running`
    # declaration and assign are on the different lines.
    local _state
    _state=$(systemctl is-system-running)
    local -r _state
    local -i _exit_code=$?

    local _target_color
    _sp.get_color_param SP_SYSTEMD_TARGET_COLOR sp_color_notice _target_color

    local _state_color
    if [[ ${_exit_code} != 0 ]]; then
        _sp.get_color_param SP_SYSTEMD_STATE_ALERT_COLOR sp_color_alert _state_color
    else
        _sp.get_color_param SP_SYSTEMD_STATE_OK_COLOR sp_color_info _state_color
    fi

    printf '%s%s %s%s' "${_target_color}" "${_target}" "${_state_color}" "${_state}"
}

if command -v systemctl &>/dev/null; then
    SMART_PROMPT_PLUGINS[_75_is_systemd_dir]=_systemd_show_default_target
fi
