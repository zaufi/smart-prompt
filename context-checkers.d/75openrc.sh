#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show various OpenRC-related details depending on the current directory
#

#BEGIN Service functions
function _get_started_services_cnt()
{
    local -r _level=${1:--a}
    local -n _output="$2"
    local -ir _started_count=$(rc-status "${_level}" | grep -c started)
    _output=${_started_count}
}

function _get_total_services_cnt()
{
    local -r _level=${1:--a}
    local -n _output="$2"
    local -ir _service_count=$(rc-status "${_level}" | wc -l)
    _output=${_service_count}
}
#END Service functions

#
# Show count of started services
#
function _75_is_init_d_dir()
{
    _sp.is_cur_dir_equals_to /etc/init.d
}
function _show_started_services()
{
    local -r _level=${1:--a}
    local _count
    local _total_count
    _get_started_services_cnt "${_level}" _count
    _get_total_services_cnt "${_level}" _total_count
    local _services_color
    _sp.get_color_param SP_OPENRC_SERVICES_COLOR sp_color_notice _services_color
    printf '%s%d/%d started' "${_services_color}" "${_count}" "${_total_count}"
}
SMART_PROMPT_PLUGINS[_75_is_init_d_dir]=_show_started_services

function _75_is_inside_of_runlevels_dir()
{
    _sp.cur_dir_starts_with /etc/runlevels
}
function _show_started_services_at_level()
{
    local -r _level=${PWD##*/}
    if [[ ${_level} == 'runlevels' ]]; then
        _show_started_services
    else
        _show_started_services "${_level}"
    fi
}
SMART_PROMPT_PLUGINS[_75_is_inside_of_runlevels_dir]=_show_started_services_at_level

#
# Show network interface status and loaded modules
#
function _81_is_etc_conf_d_dir()
{
    _sp.is_cur_dir_equals_to /etc/conf.d
}
SMART_PROMPT_PLUGINS[_81_is_etc_conf_d_dir]='_show_net_ifaces _show_loaded_modules'
