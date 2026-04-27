#!/bin/bash
#
# SPDX-FileCopyrightText: 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later
#

declare -Ag _CDUI_RECENT_DIRS_STATS=()

#
# Get the number of recent directories to keep in the JSON cache.
#
function _cdui_recent_dirs_count()
{
    if [[ ${SP_CDUI_RECENT_DIRS_COUNT:-} =~ ^[0-9]+$ ]]; then
        echo "${SP_CDUI_RECENT_DIRS_COUNT}"
        return 0
    fi

    echo 10
}

#
# Return the JSON cache file path with top recent directories.
#
function _cdui_recent_cache_file()
{
    echo "$(cdui_cache_dir)"/recent-dirs.json
}

#
# Return the bash cache file path with recent-directory usage statistics.
#
function _cdui_recent_stats_file()
{
    echo "$(cdui_cache_dir)"/recent-dirs.bash
}

#
# Load recent-directory usage statistics from the bash cache file.
#
function _cdui_load_recent_dirs_stats()
{
    local -r stats_file=$(_cdui_recent_stats_file)

    _CDUI_RECENT_DIRS_STATS=()
    if [[ -r ${stats_file} ]]; then
        # shellcheck source=/dev/null
        . "${stats_file}"
    fi
}

#
# Save recent-directory usage statistics to the bash cache file.
#
function _cdui_save_recent_dirs_stats()
{
    mkdir -p -- "$(cdui_cache_dir)"

    local -r stats_file=$(_cdui_recent_stats_file)
    local tmp_file
    tmp_file=$(mktemp "${stats_file}.XXXXXX") || return 1

    local declaration
    declaration=$(declare -p _CDUI_RECENT_DIRS_STATS) || {
        rm -f -- "${tmp_file}"
        return 1
    }
    printf '%s\n' "${declaration/declare -A/declare -gA}" > "${tmp_file}" || {
        rm -f -- "${tmp_file}"
        return 1
    }
    mv -f -- "${tmp_file}" "${stats_file}"
}

#
# Rebuild the JSON cache with the configured number of most used recent directories.
#
function _cdui_refresh_recent_dirs_cache()
{

    mkdir -p -- "$(cdui_cache_dir)"

    local -r cache_file=$(_cdui_recent_cache_file)
    local -r recent_dirs_count=$(_cdui_recent_dirs_count)
    local tmp_file
    tmp_file=$(mktemp "${cache_file}.XXXXXX") || return 1

    {
        for _dir in "${!_CDUI_RECENT_DIRS_STATS[@]}"; do
            read -r _count _timestamp <<< "${_CDUI_RECENT_DIRS_STATS["${_dir}"]}"
            printf '%s\t%s\t%s\n' "${_count:-0}" "${_timestamp:-0}" "${_dir}"
        done
    } | sort -t $'\t' -k1,1nr -k2,2nr \
      | head -n "${recent_dirs_count}" \
      | jq -R -s '
            split("\n")
          | map(select(length > 0))
          | map(split("\t"))
          | map({entry: .[1], url: .[2]})
        ' > "${tmp_file}" || {
            rm -f -- "${tmp_file}"
            return 1
        }

    mv -f -- "${tmp_file}" "${cache_file}"
}

#
# Return the recent directories list as a JSON array for the CDUI feed.
#
function cdui_recent_get_dirs()
{
    local -r cache_file=$(_cdui_recent_cache_file)

    if [[ ! -r ${cache_file} ]]; then
        _cdui_load_recent_dirs_stats
        _cdui_refresh_recent_dirs_cache || {
            printf '[]\n'
            return 0
        }
    fi

    jq '. | map(. + {origin: "🔁"})' "${cache_file}"
}

#
# Update usage statistics for a selected directory.
#
# @param $1 -- directory name to update in the recent-directory cache
#
function cdui_recent_post_select_dir()
{
    local -r dir_name="$1"

    if [[ -z ${dir_name} || ! -d ${dir_name} ]]; then
        return 0
    fi

    _cdui_load_recent_dirs_stats

    local -i count=0
    local _timestamp
    if [[ -n ${_CDUI_RECENT_DIRS_STATS["${dir_name}"]+x} ]]; then
        read -r count _timestamp <<< "${_CDUI_RECENT_DIRS_STATS["${dir_name}"]}"
    fi

    _CDUI_RECENT_DIRS_STATS["${dir_name}"]="$((count + 1)) $(date +%s)"
    _cdui_save_recent_dirs_stats || return 1
    _cdui_refresh_recent_dirs_cache
}
