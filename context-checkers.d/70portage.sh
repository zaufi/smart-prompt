#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show various Portage-related details depending on the current directory
#

#BEGIN Service functions
function _get_total_packages_installed()
{
    local -n _output="$1"
    # TODO Refactor this!
    # shellcheck disable=SC2010,SC2012,SC2126
    local -ir _package_count=$(ls -1 /var/db/pkg/* | grep -E -v '(^|:)$' | wc -l)
    _output=${_package_count}
}
#END Service functions

#
# Show the Portage tree timestamp for `/usr/portage`
#
function _70_is_inside_of_portage_tree_dir()
{
    _sp.cur_dir_starts_with /usr/portage
}
function _show_tree_timestamp()
{
    # Transform UTC date/time into local timezone
    local -r _stamp=$(< /usr/portage/metadata/timestamp.chk)
    local -r _local_stamp=$(date -d "${_stamp}" +"${sp_time_fmt}")
    local _color
    _sp.get_color_param SP_PORTAGE_SYNC_TIME_COLOR sp_color_misc _color
    printf '%stimestamp: %s' "${_color}" "${_local_stamp}"
}
SMART_PROMPT_PLUGINS[_70_is_inside_of_portage_tree_dir]=_show_tree_timestamp

#
# Show the current profile for `/etc`
#
function _70_is_etc_dir()
{
    _sp.is_cur_dir_equals_to /etc
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
        _sp.get_color_param SP_PORTAGE_PROFILE_COLOR sp_color_debug _color
        # shellcheck disable=SC2001
        printf '%sprofile: %s' "${_color}" "$(sed 's,.*default/\(.*\),\1,' <<<"${_profile}")"
    fi
}
SMART_PROMPT_PLUGINS[_70_is_etc_dir]=_show_current_profile


#
# Show the installed package count and some details for a particular category/package
#
function _72_is_var_db_pkg_dir()
{
    _sp.cur_dir_starts_with /var/db/pkg
}
function _show_installed_packages()
{
    local _installed_cnt
    _get_total_packages_installed _installed_cnt
    case "${PWD}" in
    /var/db/pkg/*/*)
        local _installed_date=$(< COUNTER)
        _installed_date=$(date --date="@${_installed_date}" +"${sp_time_fmt}")
        local -r _installed_from_repo=$(< REPOSITORY)
        local _repo_color
        _sp.get_color_param SP_PORTAGE_PKG_DETAILS_COLOR sp_color_info _repo_color
        printf '%s%s from %s' "${_repo_color}" "${_installed_date}" "${_installed_from_repo}"
        ;;
    /var/db/pkg/*)
        # TODO Any better way?
        # shellcheck disable=SC2207
        local -r _pkgs_in_cat=( $(shopt -s nullglob; echo *) )
        local _cat_color
        _sp.get_color_param SP_PORTAGE_CATEGORY_DETAILS_COLOR sp_color_notice _cat_color
        printf '%s%d/%d cat/total pkgs' "${_cat_color}" "${#_pkgs_in_cat[@]}" "${_installed_cnt}"
        ;;
    /var/db/pkg)
        local _pkgdb_color
        _sp.get_color_param SP_PORTAGE_PKG_TOTAL_COLOR sp_color_notice _pkgdb_color
        printf '%s%d pkgs total' "${_pkgdb_color}" "${_installed_cnt}"
        ;;
    esac
}
SMART_PROMPT_PLUGINS[_72_is_var_db_pkg_dir]=_show_installed_packages

#
# Show details about packages/sets in the world file
#
function _72_is_var_lib_portage_dir()
{
    _sp.is_cur_dir_equals_to /var/lib/portage
}
function _show_world_details()
{
    local _installed_cnt
    _get_total_packages_installed _installed_cnt
    local -r _world_contents=$(< /var/lib/portage/world)
    # TODO Refactor this!
    # shellcheck disable=SC2126
    local -r _pkgs=$(grep -E -v '(\*|@)' <<<"${_world_contents}" | wc -l)
    local -r _sets=$(grep -E -c '(\*|@)' <<<"${_world_contents}")
    local _pkgdb_color
    _sp.get_color_param SP_PORTAGE_WORLD_COLOR sp_color_notice _pkgdb_color
    printf "%s%d/%d/%d pkgs/sets/total" "${_pkgdb_color}" "${_pkgs}" "${_sets}" "${_installed_cnt}"
}
SMART_PROMPT_PLUGINS[_72_is_var_lib_portage_dir]=_show_world_details
