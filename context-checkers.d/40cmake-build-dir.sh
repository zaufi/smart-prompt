#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Append `CMAKE_BUILD_TYPE` and `CMAKE_INSTALL_PREFIX` to the command prompt
# for build directories under CMake control.
#

function _40_is_cmake_build_dir()
{
    [[ -f CMakeFiles/CMakeDirectoryInformation.cmake ]]
}

function _show_cmake_options()
{
    local _top_build_dir
    if [[ -f CMakeFiles/CMakeDirectoryInformation.cmake ]]; then
        _top_build_dir=$(grep 'CMAKE_RELATIVE_PATH_TOP_BINARY' CMakeFiles/CMakeDirectoryInformation.cmake \
          | sed 's,SET(CMAKE_RELATIVE_PATH_TOP_BINARY\s\+"\(.*\)")$,\1,i')
        local -r _top_build_dir
        if [[ -n ${_top_build_dir} && -f ${_top_build_dir}/CMakeCache.txt ]]; then
            local -r _build_type=$( \
                sed -ne '/^CMAKE_BUILD_TYPE:.*=.*$/ {s,CMAKE_BUILD_TYPE:.*=,,; p}' \
                "${_top_build_dir}"/CMakeCache.txt \
              )
            local -r _prefix=$( \
                sed -ne '/^CMAKE_INSTALL_PREFIX:PATH=.*$/ {s,CMAKE_INSTALL_PREFIX:PATH=,,; p}' \
                "${_top_build_dir}"/CMakeCache.txt \
              )
            local -r _version=$( \
                sed -ne '/^CMAKE_PROJECT_VERSION:STATIC=.*$/ {s,CMAKE_PROJECT_VERSION:STATIC=,,; p}' \
                "${_top_build_dir}"/CMakeCache.txt \
              )
            local _color_build_type
            local -r _build_type_color_var="SP_CMAKE_${_build_type^^}_BUILD_TYPE_COLOR"
            if [[ -n ${!_build_type_color_var} ]]; then
                _sp.get_color_param "${_build_type_color_var}" sp_color_notice _color_build_type
            else
                _sp.get_color_param SP_CMAKE_BUILD_TYPE_COLOR sp_color_notice _color_build_type
            fi
            local _color_version
            _sp.get_color_param SP_CMAKE_PROJECT_VERSION_COLOR sp_color_info _color_version
            local _color_install_pfx
            _sp.get_color_param SP_CMAKE_INSTALL_PREFIX_COLOR sp_color_debug _color_install_pfx

            printf '%s%s%s%s%s→%s%s' \
                "${_color_build_type}" \
                "${_build_type:-default}" \
                "${sp_seg}" \
                "${_color_version}" \
                "${_version}" \
                "${_color_install_pfx}" \
                "${_prefix}"
        else
            local _color_broken_mark
            _sp.get_color_param SP_CMAKE_BROKEN_MARK_COLOR sp_color_alert _color_broken_mark
            local _color_broken_path
            _sp.get_color_param SP_CMAKE_BROKEN_BUILD_DIR_COLOR sp_color_warn _color_broken_path
            printf '%s×%s%s' "${_color_broken_mark}" "${_color_broken_path}" "${_top_build_dir}"
        fi
    fi
}

SMART_PROMPT_PLUGINS[_40_is_cmake_build_dir]=_show_cmake_options
