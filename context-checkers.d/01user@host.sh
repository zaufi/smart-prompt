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
        _optional_ssh_warn="${sp_alert}ssh://"
    fi
    local _sudo_user
    if [[ -n ${SUDO_USER} ]]; then
        _sudo_user="<${SUDO_USER}>"
    fi
    printf "${_optional_ssh_warn}${sp_user}"'\\u'"${_sudo_user}"'@\\h'
}

SMART_PROMPT_PLUGINS[_01_show_user_and_host]=_show_user_and_host
