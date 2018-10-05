#!/bin/bash
#
# Append user@host segment
#
# Copyright (c) 2014-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
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
    if _sp_check_bool ${SP_SHOW_LOCALHOST:-true}; then
        _user_tail+='@\\h'
    fi
    printf "${_optional_ssh_warn}${sp_color_user}"'\\u'"${_user_tail}"
}

SMART_PROMPT_PLUGINS[_01_show_user_and_host]=_show_user_and_host
