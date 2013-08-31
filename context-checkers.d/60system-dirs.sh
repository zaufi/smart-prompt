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

#
# Show "link to: <dirname>" if current dir is a symlink
#
function _60_is_linked_dir()
{
    return `readlink -q \`pwd\` >/dev/null`
}
function _show_dir_link()
{
    local _link_to=`readlink \`pwd\``
    printf "${sp_debug}@-> ${_link_to}"
}
SMART_PROMPT_PLUGINS[_60_is_linked_dir]=_show_dir_link


#
# Append "empty dir" segment for, surprise, empty dirs ;)
#
# NOTE W/ priority 99 it will be close to the prompt end
#
function _99_is_empty_dir()
{
    local _content=`ls`
    return `test -z "${_content}"`
}
function _show_empty_mark()
{
    printf "${sp_debug}empty dir"
}
SMART_PROMPT_PLUGINS[_99_is_empty_dir]=_show_empty_mark


#
# Reusable helper functions to display various info
#

# Append 'NN modules loaded' segment
function _show_loaded_modules()
{
    printf "${sp_debug}%d modules loaded" $(( `lsmod | wc -l` - 1 ))
}

# Append segment w/ current uptime
# TODO Make sure /proc is available
function _show_uptime()
{
    local _seconds=`sed 's,\([0-9]\+\)\..*,\1,' /proc/uptime`
    local _uptime
    _seconds_to_duration ${_seconds} _uptime

    printf "${sp_misc}${_uptime}"
}

# Add segment w/ current kernel name
function _show_kernel()
{
    local _kernel=`uname -r`
    printf "${sp_debug}${_kernel}"
}


#
# Show current kernel name and uptime for /boot dir
#
function _61_is_boot_dir()
{
    return `_cur_dir_starts_with /boot`
}
SMART_PROMPT_PLUGINS[_61_is_boot_dir]='_show_kernel _show_uptime'


#
# Show uptime for /run
#
function _61_is_run_dir()
{
    return `_is_cur_dir_equals_to /run`
}
SMART_PROMPT_PLUGINS[_61_is_run_dir]=_show_uptime


#
# Show user/all processes and load average for /proc
#
function _61_is_proc_dir()
{
    return `_cur_dir_starts_with /proc`
}
function _show_processes_and_load()
{
    local _load=`cat /proc/loadavg | cut -d ' ' -f 1,2,3`
    local _psax_wc_l=`ps ax --no-headers | wc -l`
    local _psu_wc_l=`ps -u $USER --no-headers | wc -l`
    local _all_processes=$(( ${_psax_wc_l} - 2))
    local _user_processes=$(( ${_psu_wc_l} - 2))

    printf "${sp_debug}${_user_processes}/${_all_processes}${sp_seg}${sp_debug}${_load}"
}
SMART_PROMPT_PLUGINS[_61_is_proc_dir]=_show_processes_and_load


#
# Show some configuration stats for selected kernel sources dir
#
function _65_is_in_usr_src_linux_dir()
{
    return `_cur_dir_starts_with /usr/src/linux`
}
# TODO Show kernel's build time?
function _show_kernel_config()
{
    local _configured
    if [ -f .config ]; then
        _configured="${sp_misc}cfg: `grep '^[^#]\+=m' .config | wc -l` modules"
    else
        _configured="${sp_warn}no .config"
    fi
    printf "${_configured}"
}
SMART_PROMPT_PLUGINS[_65_is_in_usr_src_linux_dir]=_show_kernel_config


#
# Show current kernel and loaded modules count for /modules
#
function _65_is_modules_dir()
{
    return `_is_cur_dir_equals_to /lib/modules`
}
SMART_PROMPT_PLUGINS[_65_is_modules_dir]='_show_kernel _show_loaded_modules'


#
#
#
function _61_is_dev_dir()
{
    return `_cur_dir_starts_with /dev || _cur_dir_starts_with /run/media/${USER}`
}
function _show_some_dev_and_mount_info()
{
    printf "${sp_debug}${_devs_mounted}%d blk.devs" `mount | grep '^/dev/' | wc -l`

    local _lsusb_bin=`which lsusb 2>/dev/null`
    if [ -n "${_lsusb_bin}" ]; then
        local -i _usb_devs=`${_lsusb_bin} | grep -iv 'hub$' | wc -l`
        printf "${sp_seg}${sp_debug}${_usb_devs} usb devs"
    fi
}
SMART_PROMPT_PLUGINS[_61_is_dev_dir]=_show_some_dev_and_mount_info
