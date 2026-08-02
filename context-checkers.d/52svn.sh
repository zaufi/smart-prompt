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
    local -n _gsb__output="$1"
    local -r _gsb__url=$(svn info | grep '^URL' | sed 's,URL:\s*,,')
    local _gsb__branch=$(sed -e 's,.*/branches/\([^/]\+\).*,\1,' -e 't end' -e 'd' -e ':end' <<<"${_gsb__url}")
    if [[ -z ${_gsb__branch} ]]; then
        _gsb__branch=$(sed -e 's,.*/\(trunk\).*,\1,' -e 't end' -e 'd' -e ':end' <<<"${_gsb__url}")
        if [[ -n ${_gsb__branch} ]]; then
            _gsb__output=${_gsb__branch}
        fi
    else
        _gsb__output=${_gsb__branch}
    fi
}

# TODO Detect conflicts
function _get_svn_dirty_status()
{
    local -n _gsds__output="$1"
    local -r _gsds__work_root=$(svn info \
      | grep 'Working Copy Root Path' \
      | sed 's,Working Copy Root Path:\s*\(.*\)$,\1,')
    local _gsds__status_color
    if [[ -z $(svn status -q "${_gsds__work_root}" 2>/dev/null) ]]; then
        _sp.get_color_param SP_SVN_GREEN_COLOR sp_color_info _gsds__status_color
    else
        _sp.get_color_param SP_SVN_DIRTY_COLOR sp_color_warn _gsds__status_color
    fi
    _gsds__output=${_gsds__status_color}
}

function _show_svn_status()
{
    local _sss__branch
    _get_svn_branch _sss__branch
    local _sss__status
    _get_svn_dirty_status _sss__status

    local _sss__repo
    if _sp.check_bool "${SP_INDICATE_REPO_TYPE}" -o [[ "${SP_INDICATE_REPO_TYPE[@]}" =~ svn ]]; then
        _sss__repo='svn:'
    fi

    printf '%s%s%s%s' "${_sss__status}" "${_sss__repo}" "${SP_VCS_BRANCH_SYMBOL:-\356\202\240:}" "${_sss__branch}"
}

SMART_PROMPT_PLUGINS[_52_is_svn_repo]=_show_svn_status
