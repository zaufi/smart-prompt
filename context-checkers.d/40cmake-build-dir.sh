#!/bin/bash
#
# Append CMAKE_BUILD_TYPE and CMAKE_INSTALL_PREFIX to a command prompt
# for build dirs under cmake control.
#
# Copyright (c) 2013-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _40_is_cmake_build_dir()
{
    return $([[ -f CMakeFiles/CMakeDirectoryInformation.cmake ]])
}

function _show_cmake_options()
{
    local _sco__top_build_dir
    if [[ -f CMakeFiles/CMakeDirectoryInformation.cmake ]]; then
        _sco__top_build_dir=$(grep 'CMAKE_RELATIVE_PATH_TOP_BINARY' CMakeFiles/CMakeDirectoryInformation.cmake \
          | sed 's,SET(CMAKE_RELATIVE_PATH_TOP_BINARY\s\+"\(.*\)")$,\1,i')
        if [[ -n ${_sco__top_build_dir} && -f ${_sco__top_build_dir}/CMakeCache.txt ]]; then
            local _sco__build_type=$( \
                sed -ne '/^CMAKE_BUILD_TYPE:.*=.*$/ {s,CMAKE_BUILD_TYPE:.*=,,; p}' \
                "${_sco__top_build_dir}"/CMakeCache.txt \
              )
            local _sco__prefix=$( \
                sed -ne '/^CMAKE_INSTALL_PREFIX:PATH=.*$/ {s,CMAKE_INSTALL_PREFIX:PATH=,,; p}' \
                "${_sco__top_build_dir}"/CMakeCache.txt \
              )
            local _sco__version=$( \
                sed -ne '/^CMAKE_PROJECT_VERSION:STATIC=.*$/ {s,CMAKE_PROJECT_VERSION:STATIC=,,; p}' \
                "${_sco__top_build_dir}"/CMakeCache.txt \
              )
            local _sco__color_build_type
            _get_color_param SP_CMAKE_BUILD_TYPE_COLOR sp_color_notice _sco__color_build_type
            local _sco__color_version
            _get_color_param SP_CMAKE_PROJECT_VERSION_COLOR sp_color_info _sco__color_version
            local _sco__color_install_pfx
            _get_color_param SP_CMAKE_INSTALL_PREFIX_COLOR sp_color_debug _sco__color_install_pfx

            printf "${_sco__build_type:-"${_sco__color_build_type}default"}${sp_seg}${_sco__color_version}${_sco__version}→${_sco__color_install_pfx}${_sco__prefix}"
        else
            local _sco__color_broken_mark
            _get_color_param SP_CMAKE_BROKEN_MARK_COLOR sp_color_alert _sco__color_broken_mark
            local _sco__color_broken_path
            _get_color_param SP_CMAKE_BROKEN_BUILD_DIR_COLOR sp_color_warn _sco__color_broken_path
            printf "${_sco__color_broken_mark}×${_sco__color_broken_path}${_sco__top_build_dir}"
        fi
    fi
}

SMART_PROMPT_PLUGINS[_40_is_cmake_build_dir]=_show_cmake_options
