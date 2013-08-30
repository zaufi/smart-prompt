#!/bin/bash
#
# Append CMAKE_BUILD_TYPE and CMAKE_INSTALL_PREFIX to a command prompt
# for build dirs under cmake control.
#
# Copyright (c) 2013 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

function _is_cmake_build_dir()
{
    return `test -f CMakeFiles/CMakeDirectoryInformation.cmake`
}

function _show_cmake_options()
{
    local _sco__top_build_dir
    if [ -f CMakeFiles/CMakeDirectoryInformation.cmake ]; then
        _sco__top_build_dir=`grep 'CMAKE_RELATIVE_PATH_TOP_BINARY' CMakeFiles/CMakeDirectoryInformation.cmake \
          | sed 's,SET(CMAKE_RELATIVE_PATH_TOP_BINARY\s\+"\(.*\)")$,\1,'`
        if [ -n "${_sco__top_build_dir}" -a -f "${_sco__top_build_dir}"/CMakeCache.txt ]; then
            local _sco__build_type=`grep 'CMAKE_BUILD_TYPE' "${_sco__top_build_dir}"/CMakeCache.txt \
              | sed 's,CMAKE_BUILD_TYPE:STRING=\(.*\),\1,'`
            local _sco__prefix=`grep 'CMAKE_INSTALL_PREFIX' "${_sco__top_build_dir}"/CMakeCache.txt \
              | sed 's,CMAKE_INSTALL_PREFIX:PATH=\(.*\),\1,'`
            local _sco__build_type_color
            _eval_color_string "${SP_CMAKE_BUILD_TYPE:-bright-cyan}" _sco__build_type_color
            local _sco__prefix_color
            _eval_color_string "${SP_CMAKE_INSTALL_PATH:-dark-grey}" _sco__prefix_color
            printf "${_sco__build_type_color}${_sco__build_type}${sp_path}->${_sco__prefix_color}${_sco__prefix}"
        fi
    fi
}

SMART_PROMPT_PLUGINS[_is_cmake_build_dir]=_show_cmake_options
