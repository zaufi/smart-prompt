#!/bin/bash
#
# Show various gentoo related info depending on a current dir
#
# Copyright (c) 2013-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

#BEGIN Service functions
function _get_total_packages_installed()
{
    local _gtpi__output_var=$1
    local -i _gtpi__count=$(ls -1 /var/db/pkg/* | egrep -v '(^|:)$' | wc -l)
    eval "${_gtpi__output_var}=\"${_gtpi__count}\""
}
#END Service functions

#
# Show current profile and count of configured repositories for /etc/paludis
#
function _75_is_inside_of_paludis_sysconf_dir()
{
    return $(_cur_dir_starts_with /etc/paludis)
}
function _show_paludis_info()
{
    _show_current_profile
    local _cave_bin
    if _find_program cave _cave_bin; then
        printf "${sp_seg}${sp_misc}%d reps" $(${_cave_bin} print-repositories | wc -l)
    fi
}
SMART_PROMPT_PLUGINS[_75_is_inside_of_paludis_sysconf_dir]=_show_paludis_info

#
# Show network interfaces status
#
function _71_is_etc_conf_d_dir()
{
    return $(_is_cur_dir_equals_to /etc/conf.d)
}
SMART_PROMPT_PLUGINS[_71_is_etc_conf_d_dir]='_show_net_ifaces _show_loaded_modules'

#
# Show installed packages count and some details for particular category/package
#
function _72_is_var_db_pkg_dir()
{
    return $(_cur_dir_starts_with /var/db/pkg)
}
function _show_installed_packages()
{
    local _sip_installed_cnt
    _get_total_packages_installed _sip_installed_cnt
    case "${PWD}" in
        /var/db/pkg/*/*)
            local _sip_installed_date=$(< COUNTER)
            _sip_installed_date=$(date --date=@${_sip_installed_date} +"${sp_time_fmt}")
            local _sip_installed_from_repo=$(< REPOSITORY)
            printf "${sp_info}${_sip_installed_date} from ${_sip_installed_from_repo}"
            ;;
        /var/db/pkg/*)
            local -r _sip_pkgs_in_cat=( $(shopt -s nullglob; echo *) )
            printf "${sp_notice}%d/%d cat/total pkgs" ${#_sip_pkgs_in_cat[@]}  ${_sip_installed_cnt}
            ;;
        /var/db/pkg)
            printf "${sp_notice}%d pkgs total" ${_sip_installed_cnt}
            ;;
    esac
}
SMART_PROMPT_PLUGINS[_72_is_var_db_pkg_dir]=_show_installed_packages
