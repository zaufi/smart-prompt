#!/bin/bash

# SPDX-FileCopyrightText: 2018 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Append CMAKE_BUILD_TYPE and CMAKE_INSTALL_PREFIX to a command prompt
# for build dirs under cmake control.
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _41_is_nodejs_project_dir()
{
    [[ -f package.json ]]
}

function _show_package_details()
{
    if _find_program jq _spd__jq_bin; then
        local _spd__name_version=$(${_spd__jq_bin} -r '.name+"@"+.version' package.json)
        if [[ -n ${_spd__name_version} && ${_spd__name_version} != '@' ]]; then
            local _spd__color_name
            _get_color_param SP_JS_PKG_NAME_VERSION sp_color_notice _spd__color_name
            printf '%s%s' "${_spd__color_name}" "${_spd__name_version}"
        else
            # NOTE Smth wrong w/ this package...
            # (broken JSON, not a JS package at all & so on...)
            local _spd__color_bad_package_json
            _get_color_param SP_JS_BAD_PACKAGE_JSON sp_color_debug _spd__color_bad_package_json
            printf '%sbad package.json' "${_spd__color_bad_package_json}"
        fi
    fi
}

SMART_PROMPT_PLUGINS[_41_is_nodejs_project_dir]=_show_package_details
