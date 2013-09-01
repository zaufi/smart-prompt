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
    local -A _ecs__colors
    _ecs__colors['black']='\[\e[30m\]'
    _ecs__colors['red']='\[\e[31m\]'
    _ecs__colors['green']='\[\e[32\]'
    _ecs__colors['brown']='\[\e[33m\]'
    _ecs__colors['blue']='\[\e[34m\]'
    _ecs__colors['magenta']='\[\e[35m\]'
    _ecs__colors['cyan']='\[\e[36m\]'
    _ecs__colors['grey']='\[\e[37m\]'

    _ecs__colors['dark-grey']='\[\e[30;1m\]'
    _ecs__colors['bright-red']='\[\e[31;1m\]'
    _ecs__colors['bright-green']='\[\e[32;1m\]'
    _ecs__colors['yellow']='\[\e[33;1m\]'
    _ecs__colors['bright-blue']='\[\e[34;1m\]'
    _ecs__colors['bright-magenta']='\[\e[35;1m\]'
    _ecs__colors['bright-cyan']='\[\e[36;1m\]'
    _ecs__colors['white']='\[\e[37;1m\]'

    _ecs__colors['reset']='\[\e[0m\]'
    _ecs__colors['bold']='\[\e[1m\]'
    _ecs__colors['itallic']='\[\e[3m\]'
    _ecs__colors['underscore']='\[\e[4m\]'
    _ecs__colors['reverse']='\[\e[7m\]'

    local -r _ecs__colors_str=$1
    local -r _ecs__output_var=$2

    local _ecs__result_str
    local _ecs__c
    for _ecs__c in ${_ecs__colors_str}; do
        _ecs__result_str="${_ecs__result_str}\${_ecs__colors[${_ecs__c}]}"
    done
    eval "${_ecs__output_var}=${_ecs__result_str}"
}

#
# Transform seconds count to human readable duration
#
# @param $1 -- input seconds count
# @param $2 -- name of the variable to assign result
#
function _seconds_to_duration()
{
    local -ir _s2d__seconds=$1
    local -r _s2d__output_var=$2

    local -ir _s2d__d=$(( ${_s2d__seconds} / (3600 * 24) ))
    local -ir _s2d__h=$(( (${_s2d__seconds} % (3600 * 24)) / 3600 ))
    local -ir _s2d__m=$(( ((${_s2d__seconds} % (3600 * 24)) % 3600) / 60 ))

    local _s2d__result
    if [[ ${_s2d__d} != 0 ]]; then
        _s2d__result=`printf "%d days, %02d:%02d" ${_s2d__d} ${_s2d__h} ${_s2d__m}`
    else
        _s2d__result=`printf "%02d:%02d" ${_s2d__h} ${_s2d__m}`
    fi
    eval "${_s2d__output_var}=\"${_s2d__result}\""
}

# Check if current dir name starts w/ a given prefix
#
# @param $1 -- dirname to match
#
function _cur_dir_starts_with()
{
    local -r _cdsw__cur=`pwd | grep "^${1}"`
    return `test -n "${_cdsw__cur}"`
}

# Check if current dir name equals to a given one
#
# @param $1 -- dirname to check against
#
function _is_cur_dir_equals_to()
{
    local -r _icdet__cur=`pwd`
    return `test "${_icdet__cur}" = "${1}"`
}

#
# Find a given program in PATHs, set specified variable and return a result code
#
# @param $1 -- a program to find
# @param $2 -- a variable to set to a full path to executable
#
function _find_program()
{
    local -r _fp__name=${1}
    local -r _fp__output_var=${2}
    local -r _fp__bin=`which "${_fp__name}" 2>/dev/null`
    if [ -n "${_fp__bin}" ]; then
        eval "${_fp__output_var}=\"${_fp__bin}\""
        return 0
    fi
    return 1
}
