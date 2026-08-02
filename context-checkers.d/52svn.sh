#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Show status of a subversion repository
#

function _52_is_svn_repo()
{
    svn info >/dev/null 2>&1
}

function _get_svn_branch()
{
    local -n _output="$1"
    local -r _url=$(svn info | grep '^URL' | sed 's,URL:\s*,,')
    local _branch_name=$(sed -e 's,.*/branches/\([^/]\+\).*,\1,' -e 't end' -e 'd' -e ':end' <<<"${_url}")
    if [[ -z ${_branch_name} ]]; then
        _branch_name=$(sed -e 's,.*/\(trunk\).*,\1,' -e 't end' -e 'd' -e ':end' <<<"${_url}")
        if [[ -n ${_branch_name} ]]; then
            _output=${_branch_name}
        fi
    else
        _output=${_branch_name}
    fi
}

# TODO Detect conflicts
function _get_svn_dirty_status()
{
    local -n _output="$1"
    local -r _work_root=$(svn info \
      | grep 'Working Copy Root Path' \
      | sed 's,Working Copy Root Path:\s*\(.*\)$,\1,')
    local _status_color
    if [[ -z $(svn status -q "${_work_root}" 2>/dev/null) ]]; then
        _sp.get_color_param SP_SVN_GREEN_COLOR sp_color_info _status_color
    else
        _sp.get_color_param SP_SVN_DIRTY_COLOR sp_color_warn _status_color
    fi
    _output=${_status_color}
}

function _show_svn_status()
{
    local _branch
    _get_svn_branch _branch
    local _status
    _get_svn_dirty_status _status

    local _repo
    if _sp.check_bool "${SP_INDICATE_REPO_TYPE}" -o [[ "${SP_INDICATE_REPO_TYPE[@]}" =~ svn ]]; then
        _repo='svn:'
    fi

    printf '%s%s%s%s' "${_status}" "${_repo}" "${SP_VCS_BRANCH_SYMBOL:-\356\202\240:}" "${_branch}"
}

SMART_PROMPT_PLUGINS[_52_is_svn_repo]=_show_svn_status
