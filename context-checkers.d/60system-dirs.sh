#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show various system details depending on the current system directory
#


#
# Reusable helper functions for displaying various details
#

# Append an `NN modules loaded` segment
function _show_loaded_modules()
{
    local _modules_cnt_color
    _sp.get_color_param SP_KERNEL_MODULES_COUNT_COLOR sp_color_debug _modules_cnt_color
    printf '%s%d modules loaded' "${_modules_cnt_color}" "$(lsmod | grep -c '[A-Za-z0-9_]\+\s\+[0-9]\+')"
}

# Append a segment with the current uptime
# TODO Make sure /proc is available
function _show_uptime()
{
    local -r _seconds=$(sed 's,\([0-9]\+\)\..*,\1,' /proc/uptime)
    local _uptime
    _sp.seconds_to_duration "${_seconds}" _uptime

    local _uptime_color
    _sp.get_color_param SP_UPTIME_COLOR sp_color_debug _uptime_color
    printf '%s%s' "${_uptime_color}" "${_uptime}"
}

# Add a segment with the current kernel name
function _show_kernel()
{
    local _running_kernel_color
    _sp.get_color_param SP_CURRENT_KERNEL_COLOR sp_color_debug _running_kernel_color
    printf '%s%s' "${_running_kernel_color}" "$(uname -r)"
}

# Add a segment with network interfaces
function _show_net_ifaces()
{
    local _iface
    local _result
    local _ip_bin
    if _sp.find_program ip _ip_bin; then
        local _delim
        for _item in /sys/class/net/*; do
            local _iface=${_item##*/}
            if [[ ${SP_NET_IFACE_DISPLAY[*]:-eth0 wlan0} =~ ${_iface} ]]; then
                local _stat=$(< "${_item}"/carrier)
                case "${_stat}" in
                    1*)
                        # TODO What about IPv6 address? Or IPv6 only hosts?
                        local -r _addr=$("${_ip_bin}" addr show "${_iface}" \
                          | sed -ne '/inet / {s,\s\+inet \([^ ]\+\).*,\1,;p}' \
                          )
                        local _active_iface_color
                        _sp.get_color_param SP_ACTIVE_NET_IFACE_COLOR sp_color_info _active_iface_color
                          _result+="${_delim}${_active_iface_color}${_iface}: ${_addr}"
                        ;;
                    0*)
                        local _inactive_iface_color
                        _sp.get_color_param SP_INACTIVE_NET_IFACE_COLOR sp_color_alert _inactive_iface_color
                        _result+="${_delim}${_inactive_iface_color}${_iface}"
                        ;;
                esac
                _delim="${sp_seg}"
            fi
        done
        [[ -n ${_result} ]] && printf '%s' "${_result}"
    fi
}

#
# Show `link to: <dirname>` if the current directory is a symlink
#
function _60_is_linked_dir()
{
    readlink -q "${PWD}" >/dev/null
}
function _show_dir_link()
{
    local -r _link_to=$(readlink "${PWD}")
    local _link_color
    _sp.get_color_param SP_LINKED_DIR_COLOR sp_color_debug _link_color
    printf '%s→%s' "${_link_color}" "${_link_to}"
}
SMART_PROMPT_PLUGINS[_60_is_linked_dir]=_show_dir_link


#
# Show the current kernel name and uptime for the `/boot` directory
#
function _61_is_boot_dir()
{
    _sp.cur_dir_starts_with /boot
}
SMART_PROMPT_PLUGINS[_61_is_boot_dir]='_show_kernel _show_uptime'


#
# Show uptime for `/run`
#
function _61_is_run_dir()
{
    _sp.is_cur_dir_equals_to /run
}
SMART_PROMPT_PLUGINS[_61_is_run_dir]=_show_uptime


#
# Show user/all process counts and the load average for `/proc`
#
function _61_is_proc_dir()
{
    _sp.cur_dir_starts_with /proc
}
function _show_processes_and_load()
{
    local -r _load=$(cut -d ' ' -f 1,2,3 /proc/loadavg)
    local -r _psax_wc_l=$(ps ax --no-headers | wc -l)
    local -r _psu_wc_l=$(ps -u "${USER}" --no-headers | wc -l)
    local -ir _all_processes=${_psax_wc_l}
    local -ir _user_processes=${_psu_wc_l}

    local _processes_color
    _sp.get_color_param SP_PROCESSES_COUNT_COLOR sp_color_debug _processes_color
    local _load_stat_color
    _sp.get_color_param SP_LOAD_STAT_COLOR sp_color_debug _load_stat_color
    printf '%s%s/%s%s%s%s' \
        "${_processes_color}" \
        "${_user_processes}" \
        "${_all_processes}" \
        "${sp_seg}" \
        "${_load_stat_color}" \
        "${_load}"
}
SMART_PROMPT_PLUGINS[_61_is_proc_dir]=_show_processes_and_load


#
# Show some configuration stats for the selected kernel source directory
#
function _65_is_in_usr_src_linux_dir()
{
    [[ ${PWD} == /usr/src/linux ||
       ${PWD} == /usr/src/linux/* ||
       ${PWD} == /usr/src/linux-* ||
       ${PWD} == /usr/src/linux-*/* ]]
}
# TODO Show kernel's build time?
function _show_kernel_config()
{
    local _configured
    if [[ -f .config ]]; then
        local _config_color
        _sp.get_color_param SP_KERNEL_CONFIG_STAT_COLOR sp_color_misc _config_color
        _configured="${_config_color}cfg: $(grep -c '^[^#]\+=m' .config) modules"
    else
        local _no_config_color
        _sp.get_color_param SP_KERNEL_NO_CONFIG_COLOR sp_color_warn _no_config_color
        _configured="${_no_config_color}no .config"
    fi
    printf '%s' "${_configured}"
}
SMART_PROMPT_PLUGINS[_65_is_in_usr_src_linux_dir]=_show_kernel_config


#
# Show the current kernel and the loaded module count for `/lib/modules`
#
function _64_is_lib_modules_dir()
{
    _sp.is_cur_dir_equals_to /lib/modules
}
SMART_PROMPT_PLUGINS[_64_is_lib_modules_dir]=_show_kernel

function _65_may_show_modules_loaded()
{
    _64_is_lib_modules_dir || _sp.is_cur_dir_equals_to /etc/modprobe.d || _sp.cur_dir_starts_with /etc/udev
}
SMART_PROMPT_PLUGINS[_65_may_show_modules_loaded]=_show_loaded_modules


#
# Show the count of mounted block devices and connected USB devices for the `/dev` directory
#
function _61_may_show_mount_info()
{
    _sp.cur_dir_starts_with /dev || _sp.cur_dir_starts_with /run/media/"${USER}" || _sp.is_cur_dir_equals_to /mnt
}
function _show_some_dev_and_mount_info()
{
    local _mount_info_color
    _sp.get_color_param SP_BLOCK_DEVS_COUNT_COLOR sp_color_debug _mount_info_color
    printf '%s%d blk.devs' \
        "${_mount_info_color}" \
        "$(/bin/mount | grep -c '^/dev/')"

    local _lsusb_bin
    if _sp.find_program lsusb _lsusb_bin; then
        local _mount_info_usb_color
        _sp.get_color_param SP_USB_DEVS_COUNT_COLOR sp_color_debug _mount_info_usb_color
        # TODO Refactor this!
        # shellcheck disable=SC2126
        printf '%s%s%d usb devs' \
            "${sp_seg}" \
            "${_mount_info_usb_color}" \
            "$("${_lsusb_bin}" | grep -iv 'hub$' | wc -l)"
    fi
}
SMART_PROMPT_PLUGINS[_61_may_show_mount_info]=_show_some_dev_and_mount_info


#
# Show the total number of fonts known to the system
#
function _61_is_one_of_fonts_dir()
{
    _sp.cur_dir_starts_with /etc/fonts \
      || _sp.cur_dir_starts_with /usr/share/fonts \
      || _sp.cur_dir_starts_with "${XDG_DATA_HOME:-${HOME}/.local}"/fonts \
      || _sp.cur_dir_starts_with "${HOME}"/.fonts
}
function _show_fonts_info()
{
    local _fc_list_bin
    local _fc_cat_bin
    if _sp.find_program fc-list _fc_list_bin; then
        local _fc_color
        _sp.get_color_param SP_FONTS_COUNT_COLOR sp_color_misc _fc_color
        local -ir _total="$("${_fc_list_bin}" 2>/dev/null | wc -l)"
            if _sp.cur_dir_starts_with /etc/fonts; then
            printf '%s%s %d' "${_fc_color}" "${SP_FONT_DIR_MARK:-fonts:}" "${_total}"
        else
            # TODO Refactor this!
            # shellcheck disable=SC2126
            printf '%s%s %d/%d' \
                "${_fc_color}" \
                "${SP_FONT_DIR_MARK:-fonts:}" \
                "$("${_fc_list_bin}" 2>/dev/null | grep "${PWD}" | wc -l)" \
                "${_total}"
        fi
    fi
}
SMART_PROMPT_PLUGINS[_61_is_one_of_fonts_dir]=_show_fonts_info

#
# Show network interface status for networking-related directories in `/etc`
#
function _65_may_show_net_ifaces_status()
{
    if _sp.cur_dir_starts_with /etc/wpa_supplicant \
      || _sp.cur_dir_starts_with /etc/NetworkManager \
      || _sp.is_cur_dir_equals_to /var/lib/dhcpcd \
      || _sp.is_cur_dir_equals_to /sys/class/net; then
        local _cur_iface
        for _cur_iface in /sys/class/net/*; do
            [[ ${SP_NET_IFACE_DISPLAY[*]:-eth0 wlan0} =~ ${_cur_iface##*/} ]] && return 0
        done
    fi
    return 1
}
SMART_PROMPT_PLUGINS[_65_may_show_net_ifaces_status]=_show_net_ifaces

#
# Show logged-in users
#
function _61_is_home_dir()
{
    _sp.is_cur_dir_equals_to /home
}
function _show_logged_users()
{
    local -a _users
    readarray -t _users < <(who | cut -d ' ' -f 1 | sort -nr | uniq -c)
    local -ar _users
    local _users_color
    _sp.get_color_param SP_LOGGED_USERS_COUNT_COLOR sp_color_misc _users_color
    local _delim=${_users_color}
    local _user
    local _logged_users
    for _user in "${_users[@]}"; do
        _logged_users+="${_delim}${_user}"
        _delim=','
    done
    printf '%s' "${_logged_users}"
}
SMART_PROMPT_PLUGINS[_61_is_home_dir]=_show_logged_users

#
# Show details about installed bash completions
#
# TODO This code is for "static" completions and won't work
# with the modern `bash-completions` package.
#
function _62_is_etc_bash_completion_dir()
{
    _sp.is_cur_dir_equals_to /etc/bash_completion.d
}
function _show_bash_completions_config()
{
    # shellcheck disable=SC2207
    local -ar _active=( $(shopt -s nullglob; echo *) )
    local _count_color
    _sp.get_color_param SP_BASH_COMPLETIONS_COUNT_COLOR sp_color_notice _count_color
    printf '%s%d installed' "${_count_color}" "${#_active[@]}"
}
SMART_PROMPT_PLUGINS[_62_is_etc_bash_completion_dir]=_show_bash_completions_config
