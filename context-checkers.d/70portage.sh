#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show various Portage related info depending on a current dir
#

#BEGIN Service functions
function _get_total_packages_installed()
{
    local _gtpi__output_var=$1
    # TODO Refactor this!
    # shellcheck disable=SC2010,SC2012,SC2126
    local -i _gtpi__count=$(ls -1 /var/db/pkg/* | grep -E -v '(^|:)$' | wc -l)
    eval "${_gtpi__output_var}=\"${_gtpi__count}\""
}
#END Service functions

#
# Show portage tree timestamp for /usr/portage
#
function _70_is_inside_of_portage_tree_dir()
{
    _cur_dir_starts_with /usr/portage
}
function _show_tree_timestamp()
{
    # Transform UTC date/time into local timezone
    local _stamp=$(< /usr/portage/metadata/timestamp.chk)
    local _local_stamp=$(date -d "${_stamp}" +"${sp_time_fmt}")
    local _color
    _get_color_param SP_PORTAGE_SYNC_TIME_COLOR sp_color_misc _color
    printf '%stimestamp: %s' "${_color}" "${_local_stamp}"
}
SMART_PROMPT_PLUGINS[_70_is_inside_of_portage_tree_dir]=_show_tree_timestamp

#
# Show current profile for /etc
#
function _70_is_etc_dir()
{
    _is_cur_dir_equals_to /etc
}
function _show_current_profile()
{
    local _profile
    if [[ -L /etc/make.profile ]]; then
        _profile=/etc/make.profile
    elif [[ -L /etc/portage/make.profile ]]; then
        _profile=/etc/portage/make.profile
    fi
    if [[ -n ${_profile} ]]; then
        _profile=$(readlink ${_profile})
        local _color
        _get_color_param SP_PORTAGE_PROFILE_COLOR sp_color_debug _color
        # shellcheck disable=SC2001
        printf '%sprofile: %s' "${_color}" "$(sed 's,.*default/\(.*\),\1,' <<<"${_profile}")"
    fi
}
SMART_PROMPT_PLUGINS[_70_is_etc_dir]=_show_current_profile


#
# Show installed packages count and some details for particular category/package
#
function _72_is_var_db_pkg_dir()
{
    _cur_dir_starts_with /var/db/pkg
}
function _show_installed_packages()
{
    local _sip_installed_cnt
    _get_total_packages_installed _sip_installed_cnt
    case "${PWD}" in
    /var/db/pkg/*/*)
        local _sip_installed_date=$(< COUNTER)
        _sip_installed_date=$(date --date="@${_sip_installed_date}" +"${sp_time_fmt}")
        local _sip_installed_from_repo=$(< REPOSITORY)
        local _sip_repo_color
        _get_color_param SP_PORTAGE_PKG_DETAILS_COLOR sp_color_info _sip_repo_color
        printf '%s%s from %s' "${_sip_repo_color}" "${_sip_installed_date}" "${_sip_installed_from_repo}"
        ;;
    /var/db/pkg/*)
        # TODO Any better way?
        # shellcheck disable=SC2207
        local -r _sip_pkgs_in_cat=( $(shopt -s nullglob; echo *) )
        local _sip_cat_color
        _get_color_param SP_PORTAGE_CATEGORY_DETAILS_COLOR sp_color_notice _sip_cat_color
        printf '%s%d/%d cat/total pkgs' "${_sip_cat_color}" "${#_sip_pkgs_in_cat[@]}" "${_sip_installed_cnt}"
        ;;
    /var/db/pkg)
        local _sip_pkgdb_color
        _get_color_param SP_PORTAGE_PKG_TOTAL_COLOR sp_color_notice _sip_pkgdb_color
        printf '%s%d pkgs total' "${_sip_pkgdb_color}" "${_sip_installed_cnt}"
        ;;
    esac
}
SMART_PROMPT_PLUGINS[_72_is_var_db_pkg_dir]=_show_installed_packages

#
# Show details about packages/sets in a world file
#
function _72_is_var_lib_portage_dir()
{
    _is_cur_dir_equals_to /var/lib/portage
}
function _show_world_details()
{
    local _swd_installed_cnt
    _get_total_packages_installed _swd_installed_cnt
    local _swd_world_contents=$(< /var/lib/portage/world)
    # TODO Refactor this!
    # shellcheck disable=SC2126
    local _swd_pkgs=$(grep -E -v '(\*|@)' <<<"${_swd_world_contents}" | wc -l)
    local _swd_sets=$(grep -E -c '(\*|@)' <<<"${_swd_world_contents}")
    local _sip_pkgdb_color
    _get_color_param SP_PORTAGE_WORLD_COLOR sp_color_notice _sip_pkgdb_color
    printf "%s%d/%d/%d pkgs/sets/total" "${_sip_pkgdb_color}" "${_swd_pkgs}" "${_swd_sets}" "${_swd_installed_cnt}"
}
SMART_PROMPT_PLUGINS[_72_is_var_lib_portage_dir]=_show_world_details
