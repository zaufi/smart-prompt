#!/bin/bash
#
# Show various system info depending on a current (system) dir
#
# Copyright (c) 2013-2017 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#


#
# Reusable helper functions to display various info
#

# Append 'NN modules loaded' segment
function _show_loaded_modules()
{
    printf "${sp_debug}%d modules loaded" $(( $(lsmod | wc -l) - 1 ))
}

# Append segment w/ current uptime
# TODO Make sure /proc is available
function _show_uptime()
{
    local _seconds=$(sed 's,\([0-9]\+\)\..*,\1,' /proc/uptime)
    local _uptime
    _seconds_to_duration ${_seconds} _uptime

    printf "${sp_misc}${_uptime}"
}

# Add segment w/ current kernel name
function _show_kernel()
{
    local _kernel=$(uname -r)
    printf "${sp_debug}${_kernel}"
}

# Add segment w/ network interfaces
function _show_net_ifaces()
{
    local _sni__iface
    local _sni__result
    local _sni__ip_bin
    if _find_program ip _sni__ip_bin; then
        local _sni_delim
        for _sni__item in /sys/class/net/*; do
            local _sni__iface=${_sni__item##*/}
            if [[ ${_sni__iface} != lo ]]; then
                local _sni_stat=$(< ${_sni__item}/carrier)
                case "${_sni_stat}" in
                    1*)
                        # TODO What about IPv6 address? Or IPv6 only hosts?
                        local _sni__addr=$(${_sni__ip_bin} addr show ${_sni__iface} \
                          | grep 'inet ' \
                          | sed 's,\s\+inet \([^ ]\+\).*,\1,')
                          _sni__result+="${_sni_delim}${sp_info}${_sni__iface}: ${_sni__addr}"
                        ;;
                    0*)
                        _sni__result+="${_sni_delim}${sp_alert}${_sni__iface}"
                        ;;
                esac
                _sni_delim="${sp_seg}"
            fi
        done
        printf "${_sni__result}"
    fi
}

#
# Show "link to: <dirname>" if current dir is a symlink
#
function _60_is_linked_dir()
{
    return $(readlink -q "${PWD}" >/dev/null)
}
function _show_dir_link()
{
    local _link_to=$(readlink "${PWD}")
    printf "${sp_debug}-> ${_link_to}"
}
SMART_PROMPT_PLUGINS[_60_is_linked_dir]=_show_dir_link


#
# Append "empty dir" segment for, surprise, empty dirs ;)
#
# NOTE W/ priority 99 it will be close to the prompt end
#
function _99_is_empty_dir()
{
    local -a _content=( $(shopt -s nullglob; echo *) )
    return $([[ -z ${_content} ]])
}
function _show_empty_mark()
{
    printf "${sp_debug}empty dir"
}
SMART_PROMPT_PLUGINS[_99_is_empty_dir]=_show_empty_mark


#
# Show current kernel name and uptime for /boot dir
#
function _61_is_boot_dir()
{
    return $(_cur_dir_starts_with /boot)
}
SMART_PROMPT_PLUGINS[_61_is_boot_dir]='_show_kernel _show_uptime'


#
# Show uptime for /run
#
function _61_is_run_dir()
{
    return $(_is_cur_dir_equals_to /run)
}
SMART_PROMPT_PLUGINS[_61_is_run_dir]=_show_uptime


#
# Show user/all processes and load average for /proc
#
function _61_is_proc_dir()
{
    return $(_cur_dir_starts_with /proc)
}
function _show_processes_and_load()
{
    local _load=$(cut -d ' ' -f 1,2,3 /proc/loadavg)
    local _psax_wc_l=$(ps ax --no-headers | wc -l)
    local _psu_wc_l=$(ps -u $USER --no-headers | wc -l)
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
    return $(_cur_dir_starts_with /usr/src/linux)
}
# TODO Show kernel's build time?
function _show_kernel_config()
{
    local _configured
    if [[ -f .config ]]; then
        _configured="${sp_misc}cfg: $(grep '^[^#]\+=m' .config | wc -l) modules"
    else
        _configured="${sp_warn}no .config"
    fi
    printf "${_configured}"
}
SMART_PROMPT_PLUGINS[_65_is_in_usr_src_linux_dir]=_show_kernel_config


#
# Show current kernel and loaded modules count for /modules
#
function _64_is_lib_modules_dir()
{
    return $(_is_cur_dir_equals_to /lib/modules)
}
SMART_PROMPT_PLUGINS[_64_is_lib_modules_dir]=_show_kernel

function _65_may_show_modules_loaded()
{
    return $(_64_is_lib_modules_dir || _is_cur_dir_equals_to /etc/modprobe.d || _cur_dir_starts_with /etc/udev)
}
SMART_PROMPT_PLUGINS[_65_may_show_modules_loaded]=_show_loaded_modules


#
# Show count of block devices mounted and USB devices connected for /dev dir
#
function _61_may_show_mount_info()
{
    return $(_cur_dir_starts_with /dev || _cur_dir_starts_with /run/media/${USER} || _is_cur_dir_equals_to /mnt)
}
function _show_some_dev_and_mount_info()
{
    printf "${sp_debug}${_devs_mounted}%d blk.devs" $(/bin/mount | grep '^/dev/' | wc -l)

    local _lsusb_bin
    if _find_program lsusb _lsusb_bin; then
        local -i _usb_devs=$(${_lsusb_bin} | grep -iv 'hub$' | wc -l)
        printf "${sp_seg}${sp_debug}${_usb_devs} usb devs"
    fi
}
SMART_PROMPT_PLUGINS[_61_may_show_mount_info]=_show_some_dev_and_mount_info


#
# Show total fonts known in the system
#
function _61_is_one_of_fonts_dir()
{
    return $(_cur_dir_starts_with /usr/share/fonts \
      || _cur_dir_starts_with /etc/fonts \
      || _cur_dir_starts_with "${HOME}/.fonts"
      )
}
function _show_fonts_info()
{
    local _fc_list_bin
    local _fc_cat_bin
    if _find_program fc-list _fc_list_bin && _find_program fc-cat _fc_cat_bin; then
        if _cur_dir_starts_with /etc/fonts; then
            printf "${sp_misc}fonts: %d" $(${_fc_list_bin} | wc -l)
        else
            printf "${sp_misc}fonts: %d/%d" $(${_fc_cat_bin} . | grep -v '"\.dir"' | wc -l) $(${_fc_list_bin} | wc -l)
        fi
    fi
}
SMART_PROMPT_PLUGINS[_61_is_one_of_fonts_dir]=_show_fonts_info

#
# Show network interfaces status for networking related dirs in /etc
#
function _65_may_show_net_ifaces_status()
{
    return $(_cur_dir_starts_with /etc/wpa_supplicant \
      || _cur_dir_starts_with /etc/NetworkManager \
      || _is_cur_dir_equals_to /var/lib/dhcpcd)
}
SMART_PROMPT_PLUGINS[_65_may_show_net_ifaces_status]=_show_net_ifaces

#
# Show users logged in
#
function _61_is_home_dir()
{
    return $(_is_cur_dir_equals_to /home)
}
function _show_logged_users()
{
    local -a _users
    readarray -t _users < <(who | cut -d ' ' -f 1 | sort -nr | uniq -c | sed 's,^\s*,,')
    local _delim=${sp_misc}
    local _user
    local _logged_users
    for _user in "${_users[@]}"; do
        _logged_users+="${_delim}${_user}"
        _delim=','
    done
    printf "${_logged_users}"
}
SMART_PROMPT_PLUGINS[_61_is_home_dir]=_show_logged_users

#
# Show configured schroot environments
#
function _62_is_etc_schroot_dir()
{
    return $(_cur_dir_starts_with /etc/schroot)
}
function _show_schroot_config()
{
    local _ssc_schroot_bin
    if _find_program schroot _ssc_schroot_bin; then
        local _ssc_total=$(${_ssc_schroot_bin} -l | wc -l)
        local _ssc_active=$(${_ssc_schroot_bin} --all-sessions -l 2>/dev/null | wc -l)
        printf "${sp_notice}%d/%d active/total" ${_ssc_active} ${_ssc_total}
    fi
}
SMART_PROMPT_PLUGINS[_62_is_etc_schroot_dir]=_show_schroot_config

#
# Show installed bash completions details
#
function _62_is_etc_bash_completion_dir()
{
    return $(_is_cur_dir_equals_to /etc/bash_completion.d)
}
function _show_bash_completions_config()
{
    local -a _sbcc_active=( $(shopt -s nullglob; echo *) )
    printf "${sp_notice}%d installed" ${#_sbcc_active[@]}
}
SMART_PROMPT_PLUGINS[_62_is_etc_bash_completion_dir]=_show_bash_completions_config
