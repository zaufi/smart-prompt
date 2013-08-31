#!/bin/bash
#
# Show various system info depending on a current (system) dir
#
# Copyright (c) 2013 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _is_boot_or_run_dir()
{
    local _cur=`pwd`
    return `test "${_cur}" = '/boot' -o "${_cur}" = '/run'`
}

function _is_proc_dir()
{
    local _cur=`pwd`
    return `test "${_cur}" = '/proc'`
}

# Check if current directory is /usr/src/linux and latter is a symbolic link
function _is_usr_src_linux_dir()
{
    local _cur=`pwd`
    return `test "${_cur}" = '/usr/src/linux' -a -L "${_cur}"`
}

function _is_linked_dir()
{
    return `readlink -q \`pwd\` >/dev/null`
}

function _is_empty_dir()
{
    local _content=`ls`
    return `test -z "${_content}"`
}

function _seconds_to_duration()
{
    local _std__seconds=$1
    local _std__output_var=$2

    local _std__d=$(( ${_std__seconds} / (3600 * 24) ))
    local _std__h=$(( (${_std__seconds} % (3600 * 24)) / 3600 ))
    local _std__m=$(( ((${_std__seconds} % (3600 * 24)) % 3600) / 60 ))

    local _std__result
    if [[ ${_std__d} != 0 ]]; then
        _std__result=`printf "%d days, %02d:%02d" ${_std__d} ${_std__h} ${_std__m}`
    else
        _std__result=`printf "%02d:%02d" ${_std__h} ${_std__m}`
    fi
    eval "${_std__output_var}=\"${_std__result}\""
}

# TODO Make sure /proc is available
function _show_kernel_and_uptime()
{
    local _skau__kernel=`uname -r`
    local _skau__seconds=`sed 's,\([0-9]\+\)\..*,\1,' /proc/uptime`
    local _skau__uptime
    _seconds_to_duration ${_skau__seconds} _skau__uptime

    local _skau__kernel_color
    _eval_color_string "${SP_KERNEL:-dark-grey}" _skau__kernel_color
    local _skau__uptime_color
    _eval_color_string "${SP_UPTIME:-white}" _skau__uptime_color

    printf "${_skau__kernel_color}${_skau__kernel}${sp_path}:${_skau__uptime_color}${_skau__uptime}"
}

function _show_processes_and_load()
{
    local _spal_load=`cat /proc/loadavg | cut -d ' ' -f 1,2,3`
    local _spal_psax_wc_l=`ps ax --no-headers | wc -l`
    local _spal_psu_wc_l=`ps -u $USER --no-headers | wc -l`
    local _spal_all_processes=$(( ${_spal_psax_wc_l} - 2))
    local _spal_user_processes=$(( ${_spal_psu_wc_l} - 2))

    local _spal_misc_color
    _eval_color_string "${SP_MISC:-dark-grey}" _spal_misc_color

    printf "${_spal_misc_color}${_spal_user_processes}/${_spal_all_processes}${sp_path}|${_spal_misc_color}${_spal_load}"
}

function _show_kernel_link()
{
    local _skl_link_to=`readlink \`pwd\``

    local _skl_kernel_color
    _eval_color_string "${SP_KERNEL:-dark-grey}" _skl_kernel_color

    printf "${_skl_kernel_color}link to: ../${_skl_link_to}${sp_path}"
}

function _show_dir_link()
{
    local _link_to=`readlink \`pwd\``

    local _misc_color
    _eval_color_string "${SP_MISC:-dark-grey}" _misc_color

    printf "${_misc_color}link to: ${_link_to}${sp_path}"
}

function _show_empty_mark()
{
    local _misc_color
    _eval_color_string "${SP_MISC:-dark-grey}" _misc_color

    printf "${_misc_color}empty dir${sp_path}"
}

SMART_PROMPT_PLUGINS[_is_boot_or_run_dir]=_show_kernel_and_uptime
SMART_PROMPT_PLUGINS[_is_proc_dir]=_show_processes_and_load
SMART_PROMPT_PLUGINS[_is_usr_src_linux_dir]=_show_kernel_link
SMART_PROMPT_PLUGINS[_is_linked_dir]=_show_dir_link
SMART_PROMPT_PLUGINS[_is_empty_dir]=_show_empty_mark
