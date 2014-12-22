#!/bin/bash
#
# Show status of a subversion repository
#
# Copyright (c) 2013 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _52_is_svn_repo()
{
    return `svn info 1>/dev/null 2>/dev/null`
}

function _get_svn_branch()
{
    local _gsb__output_var=$1
    local _gsb__url=`svn info | grep '^URL' | sed 's,URL:\s*,,'`
    local _gsb__branch=`sed -e 's,.*/branches/\([^/]\+\).*,\1,' -e 't end' -e 'd' -e ':end' <<<${_gsb__url}`
    if [ -z "${_gsb__branch}" ]; then
        _gsb__branch=`sed -e 's,.*/\(trunk\).*,\1,' -e 't end' -e 'd' -e ':end' <<<${_gsb__url}`
        if [ -n "$_gsb__branch" ]; then
            eval "${_gsb__output_var}=\"${_gsb__branch}\""
        fi
    fi
}

# TODO Dectect conflicts
function _get_svn_dirty_status()
{
    local _gsds__output_var=$1
    local _gsds__wrk_root=`svn info \
      | grep 'Working Copy Root Path' \
      | sed 's,Working Copy Root Path:\s*\(.*\)$,\1,'`
    local _gsds__status_color
    if [ -z "`svn status -q \"${_gsds__wrk_root}\" 2>/dev/null`" ]; then
        _gsds__status_color="${sp_info}"
    else
        _gsds__status_color="${sp_warn}"
    fi
    eval "${_gsds__output_var}=\"${_gsds__status_color}\""
}

function _show_svn_status()
{
    local _sss__branch
    _get_svn_branch _sss__branch
    local _sss__status
    _get_svn_dirty_status _sss__status

    printf "${_sss__status}svn:${_sss__branch}"
}

SMART_PROMPT_PLUGINS[_52_is_svn_repo]=_show_svn_status
