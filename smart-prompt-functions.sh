#!/bin/bash
#
# Functions that can be used by context checkers
#
# Copyright (c) 2013 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

#
# Expand string w/ color names into a string suitable to `printf'
#
# @param $1 -- string w/ color names (like 'bright-red itallic')
# @param $2 -- name of the variable to assign result
#
function _eval_color_string
{
    local -A _colors
    _colors['black']='\[\e[30m\]'
    _colors['red']='\[\e[31m\]'
    _colors['green']='\[\e[32\]'
    _colors['brown']='\[\e[33m\]'
    _colors['blue']='\[\e[34m\]'
    _colors['magenta']='\[\e[35m\]'
    _colors['cyan']='\[\e[36m\]'
    _colors['grey']='\[\e[37m\]'

    _colors['dark-grey']='\[\e[30;1m\]'
    _colors['bright-red']='\[\e[31;1m\]'
    _colors['bright-green']='\[\e[32;1m\]'
    _colors['yellow']='\[\e[33;1m\]'
    _colors['bright-blue']='\[\e[34;1m\]'
    _colors['bright-magenta']='\[\e[35;1m\]'
    _colors['bright-cyan']='\[\e[36;1m\]'
    _colors['white']='\[\e[37;1m\]'

    _colors['reset']='\[\e[0m\]'
    _colors['bold']='\[\e[1m\]'
    _colors['itallic']='\[\e[3m\]'
    _colors['underscore']='\[\e[4m\]'
    _colors['reverse']='\[\e[7m\]'

    local colors_str=$1
    local output_var=$2

    local _result_str
    for c in ${colors_str}; do
        _result_str="${_result_str}\${_colors[${c}]}"
    done
    eval "${output_var}=${_result_str}"
}

#
# Transform seconds count to human readable duration
#
# @param $1 -- input seconds count
# @param $2 -- name of the variable to assign result
#
function _seconds_to_duration()
{
    local -i _seconds=$1
    local _output_var=$2

    local -i _d=$(( ${_seconds} / (3600 * 24) ))
    local -i _h=$(( (${_seconds} % (3600 * 24)) / 3600 ))
    local -i _m=$(( ((${_seconds} % (3600 * 24)) % 3600) / 60 ))

    local _result
    if [[ ${_d} != 0 ]]; then
        _result=`printf "%d days, %02d:%02d" ${_d} ${_h} ${_m}`
    else
        _result=`printf "%02d:%02d" ${_h} ${_m}`
    fi
    eval "${_output_var}=\"${_result}\""
}

# Check if current dir name starts w/ a given prefix
#
# @param $1 -- dirname to match
#
function _cur_dir_starts_with()
{
    local _cdsw__cur=`pwd | grep "^${1}"`
    return `test -n "${_cdsw__cur}"`
}

# Check if current dir name equals to a given one
#
# @param $1 -- dirname to check against
#
function _is_cur_dir_equals_to()
{
    local _cdsw__cur=`pwd`
    return `test "${_cdsw__cur}" = "${1}"`
}
