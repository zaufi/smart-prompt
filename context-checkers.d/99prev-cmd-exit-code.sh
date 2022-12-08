#!/bin/bash
#
# The most "right" segment (to attract user's attention)
# w/ the exit code of the previous command.
# NOTE Do not show anything for "success" exit code.
#
# Copyright (c) 2019-2022 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _99_check_prev_cmd_exit_code()
{
    [[ ${_sp__prev_cmd_exit_code} -ne 0 ]]
}

function _show_prev_cmd_exit_code()
{
    printf '%s%s' "${sp_color_alert}" "${_sp__prev_cmd_exit_code}"
}

SMART_PROMPT_PLUGINS[_99_check_prev_cmd_exit_code]=_show_prev_cmd_exit_code
