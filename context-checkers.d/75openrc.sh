#!/bin/bash
#
# Show various OpenRC related info depending on a current dir
#
# Copyright (c) 2013-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

#BEGIN Service functions
function _get_started_services_cnt()
{
    local _gssc__level=${1:--a}
    local _gssc__output_var=$2
    local -i _gssc__count=$(rc-status ${_gssc__level} | grep started | wc -l)
    eval "${_gssc__output_var}=\"${_gssc__count}\""
}

function _get_total_services_cnt()
{
    local _gssc__level=${1:--a}
    local _gssc__output_var=$2
    local -i _gssc__count=$(rc-status ${_gssc__level} | wc -l)
    eval "${_gssc__output_var}=\"${_gssc__count}\""
}
#END Service functions

#
# Show count of started services
#
function _75_is_init_d_dir()
{
    return $(_is_cur_dir_equals_to /etc/init.d)
}
function _show_started_services()
{
    local _sss__level=${1:--a}
    local _sss__count
    local _sss__total_count
    _get_started_services_cnt ${_sss__level} _sss__count
    _get_total_services_cnt ${_sss__level} _sss__total_count
    local _sss__services_color
    _get_color_param SP_OPENRC_SERVICES_COLOR sp_color_notice _sss__services_color
    printf "${_sss__services_color}%d/%d started" ${_sss__count} ${_sss__total_count}
}
SMART_PROMPT_PLUGINS[_75_is_init_d_dir]=_show_started_services

function _75_is_inside_of_runlevels_dir()
{
    return $(_cur_dir_starts_with /etc/runlevels)
}
function _show_started_services_at_level()
{
    local _level=${PWD##*/}
    if [[ ${_level} = runlevels ]]; then
        _show_started_services
    else
        _show_started_services ${_level}
    fi
}
SMART_PROMPT_PLUGINS[_75_is_inside_of_runlevels_dir]=_show_started_services_at_level

#
# Show network interfaces status and loaded modules
#
function _81_is_etc_conf_d_dir()
{
    return $(_is_cur_dir_equals_to /etc/conf.d)
}
SMART_PROMPT_PLUGINS[_81_is_etc_conf_d_dir]='_show_net_ifaces _show_loaded_modules'
