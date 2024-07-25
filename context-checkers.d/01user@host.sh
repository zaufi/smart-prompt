#!/bin/bash

# SPDX-FileCopyrightText: 2014 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Append user@host segment
#

function _01_show_user_and_host()
{
    return 0
}

function _show_user_and_host()
{
    local _optional_ssh_warn
    if [[ -n ${SSH_CONNECTION} ]]; then
        _get_color_param SP_SSH_MARK_COLOR sp_color_alert _optional_ssh_warn
        _optional_ssh_warn+="ssh://"
    fi
    local _user_tail
    if [[ -n ${SUDO_USER} ]]; then
        _user_tail="<${SUDO_USER}>"
    fi
    if _sp_check_bool "${SP_SHOW_LOCALHOST:-true}"; then
        _user_tail+='@\h'
    fi
    printf '%s%s\\u%s' "${_optional_ssh_warn}" "${sp_color_user}" "${_user_tail}"
}

SMART_PROMPT_PLUGINS[_01_show_user_and_host]=_show_user_and_host
