#!/bin/bash
#
# Functions that can be used by context checkers
#
# Copyright (c) 2013-2018 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#


#
# Check if given boolean value is `true`
#
function _sp_check_bool()
{
    local -r _scb__val=$1
    [[ ${_scb__val} =~ 1|[Yy]([Ee][Ss])?|[Oo][Nn]|[Tt][Rr][Uu][Ee] ]]
}

#
# Check if smart-prompt has requested to show some debug spam
#
function _sp_is_debug()
{
    _sp_check_bool ${SP_DEBUG}
}

#
# Parse RGB color string.
#
# @param $1 -- input string to parse
# @param $2 -- prefix of variables to assign results. Output can be read
#              from `<prefix>_r`, `<prefix>_g` and `<prefix>_b`
#
function _parse_rgb()
{
    local -r _prbg__input="$1"
    local -r _prbg__prefix=$2

    if [[ ${_prbg__input} =~ rgb\(\ *([0-9]+)\ *,\ *([0-9]+)\ *,\ *([0-9]+)\ *\) ]]; then
        eval "${_prbg__prefix}_r=${BASH_REMATCH[1]}"
        eval "${_prbg__prefix}_g=${BASH_REMATCH[2]}"
        eval "${_prbg__prefix}_b=${BASH_REMATCH[3]}"
        return 0
    fi

    logger -t 'smart-prompt' "Invalid color specification '${_prbg__input}'"
    return 1
}

#
# Parse hex color string.
#
# @param $1 -- input string to parse
# @param $2 -- prefix of variables to assign results. Output can be read
#              from `<prefix>_r`, `<prefix>_g` and `<prefix>_b`
#
function _parse_hex_color()
{
    local -r _phc__input="$1"
    local -r _phc__prefix=$2

    if [[ ${_phc__input} =~ 0x([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2}) ]]; then
        eval "${_phc__prefix}_r=$((0x${BASH_REMATCH[1]}))"
        eval "${_phc__prefix}_g=$((0x${BASH_REMATCH[2]}))"
        eval "${_phc__prefix}_b=$((0x${BASH_REMATCH[3]}))"
        return 0
    fi

    logger -t 'smart-prompt' "Invalid color specification '${_phc__input}'"
    return 1
}

#
# Calculate a color for 256-colors or 16M-colors terminals
#
# @param $1 -- red component
# @param $2 -- green component
# @param $3 -- blue component
# @param $4 -- name of the variable to assign result
#
function _rgb_to_ansi()
{
    local -r _r2a__r=$1
    local -r _r2a__g=$2
    local -r _r2a__b=$3
    local -r _r2a__output_var=$4

    if [[ ${_r2a__r} -le 5 && ${_r2a__g} -le 5 && ${_r2a__b} -le 5 ]]; then
        # 256 colors
        eval "${_r2a__output_var}='\e[38;5;$(( ${_r2a__r} * 36 + ${_r2a__g} * 6 + ${_r2a__b} + 16 ))m'"
    else
        # 16M colors
        eval "${_r2a__output_var}='\e[38;2;${_r2a__r};${_r2a__g};${_r2a__b}m'"
    fi
}

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
    _ecs__colors['italic']='\[\e[3m\]'
    _ecs__colors['underscore']='\[\e[4m\]'
    _ecs__colors['reverse']='\[\e[7m\]'

    local -r _ecs__colors_str=$1
    local -r _ecs__output_var=$2

    local _ecs__result_str
    local _ecs__c
    for _ecs__c in ${_ecs__colors_str}; do
        case ${_ecs__c} in
        rgb*)
            local _esc__r
            local _esc__g
            local _esc__b
            _parse_rgb "${_ecs__c}" _esc_

            if [[ $? = 0 ]]; then
                local _ecs_rgb
                _rgb_to_ansi ${_esc__r} ${_esc__g} ${_esc__b} _ecs_rgb
                _ecs__result_str="${_ecs__result_str}${_ecs_rgb}"
            fi
            ;;
        0x*)
            local _esc__r
            local _esc__g
            local _esc__b
            _parse_hex_color "${_ecs__c}" _esc_

            if [[ $? = 0 ]]; then
                local _ecs_rgb
                _rgb_to_ansi ${_esc__r} ${_esc__g} ${_esc__b} _ecs_rgb
                _ecs__result_str="${_ecs__result_str}${_ecs_rgb}"
            fi
            ;;
        *)
            _ecs__result_str="${_ecs__result_str}\${_ecs__colors[${_ecs__c}]}"
            ;;
        esac
    done
    eval "${_ecs__output_var}=\"${_ecs__result_str}\""
}


#
# Get a value of a color parameter
#
# @param $1 -- parameter name
# @param $2 -- fallback variable w/ default value
# @param $3 -- name of the variable to assign result
#
function _get_color_param()
{
    local -r _gcp__param=$1
    local -r _gcp__fallback=$2
    local -r _gcp__output_var=$3

    if _sp_is_debug; then
        echo -e "\e[1;30mGetting color parameter '${_gcp__param}'\e[38m"
    fi

    if [[ -n ${!_gcp__param} ]]; then
        _eval_color_string "reset ${!_gcp__param}" ${_gcp__output_var}
    else
        eval "${_gcp__output_var}=\"${!_gcp__fallback}\""
    fi
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
        _s2d__result=$(printf "%d days, %02d:%02d" ${_s2d__d} ${_s2d__h} ${_s2d__m})
    else
        _s2d__result=$(printf "%02d:%02d" ${_s2d__h} ${_s2d__m})
    fi
    eval "${_s2d__output_var}=\"${_s2d__result}\""
}

#
# Check if current dir name starts w/ a given prefix
#
# @param $1 -- dirname to match
#
function _cur_dir_starts_with()
{
    return $([[ ${PWD} =~ ^${1} ]])
}

#
# Check if current dir name equals to a given one
#
# @param $1 -- dirname to check against
#
function _is_cur_dir_equals_to()
{
    return $([[ ${PWD} = ${1} ]])
}

#
# Check if current dir matches to a given pattern
#
# @param $1 -- regex pattern to check match
#
function _cur_dir_matches()
{
    return $([[ ${PWD} =~ ${1} ]])
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
    local -r _fp__bin=$(which "${_fp__name}" 2>/dev/null)
    if [[ -n "${_fp__bin}" ]]; then
        eval "${_fp__output_var}=\"${_fp__bin}\""
        return 0
    fi
    return 1
}
