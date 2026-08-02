#!/bin/bash

# SPDX-FileCopyrightText: 2018 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Append the package name and version to the command prompt
# for Node.js project directories.
#

function _41_is_nodejs_project_dir()
{
    [[ -f package.json ]]
}

function _show_package_details()
{
    if _sp.find_program jq _jq_bin; then
        local -r _name_version=$(${_jq_bin} -r '.name+"@"+.version' package.json)
        if [[ -n ${_name_version} && ${_name_version} != '@' ]]; then
            local _color_name
            _sp.get_color_param SP_JS_PKG_NAME_VERSION sp_color_notice _color_name
            printf '%s%s' "${_color_name}" "${_name_version}"
        else
            # NOTE Something is wrong with this package:
            # broken JSON, not a JS package at all, and so on.
            local _color_bad_package_json
            _sp.get_color_param SP_JS_BAD_PACKAGE_JSON sp_color_debug _color_bad_package_json
            printf '%sbad package.json' "${_color_bad_package_json}"
        fi
    fi
}

SMART_PROMPT_PLUGINS[_41_is_nodejs_project_dir]=_show_package_details
