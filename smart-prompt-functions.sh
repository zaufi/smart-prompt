#!/bin/bash

# SPDX-FileCopyrightText: 2013 - 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Functions that can be used by context checkers
#

if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
    printf '%s\n' 'smart-prompt requires Bash 4.3 or newer' >&2
    return 1
fi


#
# Check if given boolean value is `true`
#
function _sp.check_bool()
{
    case "${1,,}" in
        1|y|yes|on|true)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

#
# Check whether smart-prompt has been asked to show debug output
#
function _sp.is_debug()
{
    _sp.check_bool "${SP_DEBUG}"
}

#
# Parse RGB color string.
#
# @param $1 -- input string to parse
# @param $2 -- prefix of variables to assign results. Output can be read
#              from `<prefix>_r`, `<prefix>_g` and `<prefix>_b`
#
function _sp.parse_rgb()
{
    local -r _input="$1"
    local -r _prefix=$2

    local -n _r="${_prefix}_r"
    local -n _g="${_prefix}_g"
    local -n _b="${_prefix}_b"

    if [[ ${_input} =~ rgb\(\ *([0-9]+)\ *,\ *([0-9]+)\ *,\ *([0-9]+)\ *\) ]]; then
        _r=${BASH_REMATCH[1]}
        _g=${BASH_REMATCH[2]}
        _b=${BASH_REMATCH[3]}
        return 0
    fi

    logger -t 'smart-prompt' "Invalid color specification '${_input}'"
    return 1
}

#
# Parse hex color string.
#
# @param $1 -- input string to parse
# @param $2 -- prefix of variables to assign results. Output can be read
#              from `<prefix>_r`, `<prefix>_g` and `<prefix>_b`
#
function _sp.parse_hex_color()
{
    local -r _input="$1"
    local -r _prefix=$2

    local -n _r="${_prefix}_r"
    local -n _g="${_prefix}_g"
    local -n _b="${_prefix}_b"

    if [[ ${_input} =~ ^0x([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$ ]]; then
        _r=$((0x${BASH_REMATCH[1]}))
        _g=$((0x${BASH_REMATCH[2]}))
        _b=$((0x${BASH_REMATCH[3]}))
        return 0
    fi
    if [[ ${_input} =~ ^#([0-9A-Fa-f])([0-9A-Fa-f])([0-9A-Fa-f])$ ]]; then
        _r=$((0x${BASH_REMATCH[1]}${BASH_REMATCH[1]}))
        _g=$((0x${BASH_REMATCH[2]}${BASH_REMATCH[2]}))
        _b=$((0x${BASH_REMATCH[3]}${BASH_REMATCH[3]}))
        return 0
    fi
    if [[ ${_input} =~ ^#([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$ ]]; then
        _r=$((0x${BASH_REMATCH[1]}))
        _g=$((0x${BASH_REMATCH[2]}))
        _b=$((0x${BASH_REMATCH[3]}))
        return 0
    fi

    logger -t 'smart-prompt' "Invalid color specification '${_input}'"
    return 1
}

#
# Calculate a color for 256-color or 16M-color terminals
#
# @param $1 -- red component
# @param $2 -- green component
# @param $3 -- blue component
# @param $4 -- name of the variable to assign result
#
function _sp.rgb_to_ansi()
{
    local -r _r=$1
    local -r _g=$2
    local -r _b=$3
    local -r _output_var=$4

    local -n _output="${_output_var}"

    if [[ ${_r} -le 5 && ${_g} -le 5 && ${_b} -le 5 ]]; then
        # 256 colors
        _output="\\[\\e[38;5;$(( _r * 36 + _g * 6 + _b + 16 ))m\\]"
    else
        # 16M colors
        _output="\\[\\e[38;2;${_r};${_g};${_b}m\\]"
    fi
}

#
# Expand a string with color names into a string suitable for `printf`
#
# @param $1 -- string with color names (like 'bright-red italic')
# @param $2 -- name of the variable to assign result
#
function _sp.eval_color_string
{
    local -A _colors
    _colors['black']='\[\e[30m\]'
    _colors['red']='\[\e[31m\]'
    _colors['green']='\[\e[32m\]'
    _colors['brown']='\[\e[33m\]'
    _colors['blue']='\[\e[34m\]'
    _colors['magenta']='\[\e[35m\]'
    _colors['cyan']='\[\e[36m\]'
    _colors['grey']='\[\e[37m\]'
    _colors['gray']='\[\e[37m\]'

    _colors['dark-grey']='\[\e[90m\]'
    _colors['dark-gray']='\[\e[90m\]'
    _colors['bright-red']='\[\e[91m\]'
    _colors['bright-green']='\[\e[92m\]'
    _colors['yellow']='\[\e[93m\]'
    _colors['bright-blue']='\[\e[94m\]'
    _colors['bright-magenta']='\[\e[95m\]'
    _colors['bright-cyan']='\[\e[96m\]'
    _colors['white']='\[\e[97m\]'

    _colors['reset']='\[\e[0m\]'
    _colors['bold']='\[\e[1m\]'
    _colors['dim']='\[\e[2m\]'
    _colors['italic']='\[\e[3m\]'
    _colors['underscore']='\[\e[4m\]'
    _colors['reverse']='\[\e[7m\]'
    _colors['strike']='\[\e[9m\]'

    local -r _colors_str=$1
    local -r _output_var=$2

    local -n _output="${_output_var}"
    local _color_r
    local _color_g
    local _color_b

    local _result_str
    local _c
    for _c in ${_colors_str}; do
        case ${_c} in
        rgb*)
            if _sp.parse_rgb "${_c}" _color; then
                local _rgb
                _sp.rgb_to_ansi "${_color_r}" "${_color_g}" "${_color_b}" _rgb
                _result_str="${_result_str}${_rgb}"
            fi
            ;;
        0x*|\#*)
            if _sp.parse_hex_color "${_c}" _color; then
                local _rgb
                _sp.rgb_to_ansi "${_color_r}" "${_color_g}" "${_color_b}" _rgb
                _result_str="${_result_str}${_rgb}"
            fi
            ;;
        *)
            _result_str="${_result_str}${_colors[${_c}]-}"
            ;;
        esac
    done
    _output=${_result_str}
}

#
# Expand a string with color names into a raw ANSI escape string.
#
# Unlike `_sp.eval_color_string`, this returns actual escape bytes and strips
# prompt-length markers, so it can be used outside `PS1`.
#
# @param $1 -- string with color names
# @param $2 -- name of the variable to assign result
#
function _sp.eval_ansi_color_string
{
    local -r _colors_str=$1
    local -r _output_var=$2

    local -n _output="${_output_var}"

    local _prompt_escaped
    _sp.eval_color_string "${_colors_str}" _prompt_escaped
    _prompt_escaped=${_prompt_escaped//\\[/}
    _prompt_escaped=${_prompt_escaped//\\]/}

    local -r _result=$(printf '%b' "${_prompt_escaped}")
    _output=${_result}
}


#
# Get a value of a color parameter
#
# @param $1 -- parameter name
# @param $2 -- fallback variable with the default value
# @param $3 -- name of the variable to assign result
#
function _sp.get_color_param()
{
    local -r _param=$1
    local -r _fallback=$2
    local -r _output_var=$3

    local -n _output="${_output_var}"

    if _sp.is_debug; then
        echo -e "\e[1;30mGetting color parameter '${_param}'\e[38m"
    fi

    if [[ -n ${!_param} ]]; then
        _sp.eval_color_string "reset ${!_param}" "${_output_var}"
    else
        _output=${!_fallback}
    fi
}

#
# Transform seconds count to human readable duration
#
# @param $1 -- input seconds count
# @param $2 -- name of the variable to assign result
#
function _sp.seconds_to_duration()
{
    local -ir _seconds=$1
    local -r _output_var=$2

    local -n _output="${_output_var}"

    local -ir _d=$(( _seconds / (3600 * 24) ))
    local -ir _h=$(( (_seconds % (3600 * 24)) / 3600 ))
    local -ir _m=$(( ((_seconds % (3600 * 24)) % 3600) / 60 ))

    local _result
    if [[ ${_d} != 0 ]]; then
        _result=$(printf "%d days, %02d:%02d" ${_d} ${_h} ${_m})
    else
        _result=$(printf "%02d:%02d" ${_h} ${_m})
    fi
    _output=${_result}
}

#
# Check whether the current directory is a given directory or one of its children
#
# @param $1 -- dirname to match
#
function _sp.cur_dir_starts_with()
{
    local _prefix=${1%/}

    if [[ -z ${_prefix} || ${_prefix} == / ]]; then
        [[ ${PWD} == /* ]]
    else
        [[ ${PWD} == "${_prefix}" || ${PWD} == "${_prefix}"/* ]]
    fi
}

#
# Check whether the current directory name equals a given one
#
# @param $1 -- dirname to check against
#
function _sp.is_cur_dir_equals_to()
{
    [[ ${PWD} == "${1}" ]]
}

#
# Check whether the current directory matches a given pattern
#
# @param $1 -- regex pattern to check match
#
function _sp.cur_dir_matches()
{
    [[ ${PWD} =~ ${1} ]]
}

#
# Find a given program in `PATH`, set the specified variable, and return a result code
#
# @param $1 -- a program to find
# @param $2 -- a variable to set to the full path of the executable
#
function _sp.find_program()
{
    local -r _name=${1}
    local -r _output_var=${2}
    local -n _output="${_output_var}"
    local _bin=$(hash -t "${_name}" 2>/dev/null)
    if [[ -z ${_bin} ]]; then
        _bin=$(command -v "${_name}" || return 1)
        if [[ -n ${_bin} ]]; then
            hash -p "${_bin}" "${_name}"
        fi
    fi
    if [[ -n ${_bin} ]]; then
        _output=${_bin}
        return 0
    fi
    return 1
}
