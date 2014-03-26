#!/bin/bash
#
# Show various gentoo related info depending on a current dir
#
# Copyright (c) 2013,2014 Alex Turbov <i.zaufi@gmail.com>
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
    local -i _gssc__count=`rc-status ${_gssc__level} | grep started | wc -l`
    eval "${_gssc__output_var}=\"${_gssc__count}\""
}

function _get_total_services_cnt()
{
    local _gssc__level=${1:--a}
    local _gssc__output_var=$2
    local -i _gssc__count=`rc-status ${_gssc__level} | wc -l`
    eval "${_gssc__output_var}=\"${_gssc__count}\""
}

function _get_total_packages_installed()
{
    local _gtpi__output_var=$1
    local -i _gtpi__count=`ls -1 /var/db/pkg/* | egrep -v '(^|:)$' | wc -l`
    eval "${_gtpi__output_var}=\"${_gtpi__count}\""
}
#END Service functions

#
# Show portage tree timestamp for /usr/portage
#
function _70_is_inside_of_portage_tree_dir()
{
    return `_cur_dir_starts_with /usr/portage`
}
function _show_tree_timestamp()
{
    # Transform UTC date/time into local timezone
    local _stamp=`cat /usr/portage/metadata/timestamp.chk`
    local _local_stamp=`date -d "${_stamp}" +"${sp_time_fmt}"`
    printf "${sp_debug}timestamp: ${_local_stamp}"
}
SMART_PROMPT_PLUGINS[_70_is_inside_of_portage_tree_dir]=_show_tree_timestamp

#
# Show current profile for /etc
#
function _70_is_etc_dir()
{
    return `_is_cur_dir_equals_to /etc`
}
function _show_current_profile()
{
    local _profile
    if [ -L /etc/make.profile ]; then
        _profile="/etc/make.profile"
    elif [ -L /etc/portage/make.profile ]; then
        _profile="/etc/make.profile"
    fi
    if [ -n "${_profile}" ]; then
        _profile=`readlink ${_profile}`
        printf "${sp_debug}profile: %s" `sed 's,.*default/\(.*\),\1,' <<<${_profile}`
    fi
}
SMART_PROMPT_PLUGINS[_70_is_etc_dir]=_show_current_profile

#
# Show current profile and count of configured repositories for /etc/paludis
#
function _75_is_inside_of_paludis_sysconf_dir()
{
    return `_cur_dir_starts_with /etc/paludis`
}
function _show_paludis_info()
{
    _show_current_profile
    local _cave_bin
    if _find_program cave _cave_bin; then
        printf "${sp_seg}${sp_misc}%d reps" `${_cave_bin} print-repositories | wc -l`
    fi
}
SMART_PROMPT_PLUGINS[_75_is_inside_of_paludis_sysconf_dir]=_show_paludis_info

#
# Show count of started services
#
function _75_is_init_d_dir()
{
    return `_is_cur_dir_equals_to /etc/init.d`
}
function _show_started_services()
{
    local _sss__level=${1:--a}
    local _sss__count
    local _sss__total_count
    _get_started_services_cnt ${_sss__level} _sss__count
    _get_total_services_cnt ${_sss__level} _sss__total_count
    printf "${sp_notice}%d/%d started" ${_sss__count} ${_sss__total_count}
}
SMART_PROMPT_PLUGINS[_75_is_init_d_dir]=_show_started_services

function _75_is_inside_of_runlevels_dir()
{
    return `_cur_dir_starts_with /etc/runlevels`
}
function _show_started_services_at_level()
{
    local _level=`basename \`pwd\``
    if [ "${_level}" = "runlevels" ]; then
        _show_started_services
    else
        _show_started_services ${_level}
    fi
}
SMART_PROMPT_PLUGINS[_75_is_inside_of_runlevels_dir]=_show_started_services_at_level

#
# Show network interfaces status
#
function _71_is_etc_conf_d_dir()
{
    return `_is_cur_dir_equals_to /etc/conf.d`
}
SMART_PROMPT_PLUGINS[_71_is_etc_conf_d_dir]='_show_net_ifaces _show_loaded_modules'


#
# Show installed packages count and some details for particular category/package
#
function _72_is_var_db_pkg_dir()
{
    return `_cur_dir_starts_with /var/db/pkg`
}
function _show_installed_packages()
{
    local _sip_installed_cnt
    _get_total_packages_installed _sip_installed_cnt
    case `pwd` in
    /var/db/pkg/*/*)
        local _sip_installed_date=`cat COUNTER`
        _sip_installed_date=`date --date=@${_sip_installed_date} +"${sp_time_fmt}"`
        local _sip_installed_from_repo=`cat REPOSITORY`
        printf "${sp_info}${_sip_installed_date} from ${_sip_installed_from_repo}"
        ;;
    /var/db/pkg/*)
        printf "${sp_notice}%d/%d cat/total pkgs" `ls -1 | wc -l` ${_sip_installed_cnt}
        ;;
    /var/db/pkg)
        printf "${sp_notice}%d pkgs total" ${_sip_installed_cnt}
        ;;
    esac
}
SMART_PROMPT_PLUGINS[_72_is_var_db_pkg_dir]=_show_installed_packages

#
# Show details about packages/sets in a world file
#
function _72_is_var_lib_portage_dir()
{
    return `_is_cur_dir_equals_to /var/lib/portage`
}
function _show_world_details()
{
    local _swd_installed_cnt
    _get_total_packages_installed _swd_installed_cnt
    local _swd_world_contents=`cat /var/lib/portage/world`
    local _swd_pkgs=`egrep -v '(\*|@)' <<<"${_swd_world_contents}" | wc -l`
    local _swd_sets=`egrep '(\*|@)' <<<"${_swd_world_contents}" | wc -l`
    printf "${sp_notice}%d/%d/%d pkgs/sets/total" ${_swd_pkgs} ${_swd_sets} ${_swd_installed_cnt}
}
SMART_PROMPT_PLUGINS[_72_is_var_lib_portage_dir]=_show_world_details
