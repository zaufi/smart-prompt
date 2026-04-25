#!/bin/bash

# SPDX-FileCopyrightText: 2014 - 2024 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

#
# This is the `quick_cd` module of SmartPrompt.
#
#
# Select a directory from a hotlist using `sk`
# It uses the `hotlist` file from Midnight Commander by default
#
# TODO Add functions to edit (add/remove) hotlist entries
#
function quick_cd()
{
    local -r hl="${SMART_PROMPT_HOTLIST:-${XDG_CONFIG_HOME:-${HOME}/.config}/mc/hotlist}"
    if [[ ! -r ${hl} ]]; then
      echo "* No hotlist file exists yet, or read permission has not been granted *" > /dev/stderr
      return 1
    fi

    local -a entries=()
    local max_dir_width=0
    local line
    while read -r line; do
        if [[ ${line} =~ (sh|ftp):// ]]; then
            continue
        elif [[ ! ${line} =~ ENTRY ]]; then
            continue
        fi

        local item
        # shellcheck disable=SC2001
        item=$(sed 's,\s*ENTRY "\([^"]\+\).*",\1,' <<< "${line}")

        local dir
        # shellcheck disable=SC2001
        dir=$(sed 's,.*URL "\([^"]\+\)".*,\1,' <<< "${line}")

        entries+=("${dir}"$'\t'"${item}")
        if (( ${#dir} > max_dir_width )); then
            max_dir_width=${#dir}
        fi
    done < "${hl}"

    if (( ${#entries[@]} == 0 )); then
        return 0
    fi

    local -a items=()
    local entry
    for entry in "${entries[@]}"; do
        local dir=${entry%%$'\t'*}
        local item=${entry#*$'\t'}
        printf -v item "%-${max_dir_width}s  %s" "${dir}" "${item}"
        items+=("${dir}"$'\t'"${item}")
    done

    local screen_height=${LINES:-0}
    if (( screen_height <= 0 )); then
        screen_height=$(tput lines 2>/dev/null)
    fi
    if (( screen_height <= 0 )); then
        screen_height=24
    fi

    local widget_height=$(( ${#items[@]} + 5 ))
    if (( widget_height > screen_height )); then
        widget_height=${screen_height}
    fi

    local -a cmd=(
        sk
        --border=rounded
        --tac
        --height="${widget_height}"
        --delimiter=$'\t'
        --prompt='📁 Select a directory to jump into〉'
    )
    if [[ -n ${SMART_PROMPT_QCD_NOTAGS} ]]; then
        cmd+=(--with-nth=2)
    else
        cmd+=(--with-nth=2)
    fi

    local selected
    selected=$(printf '%s\n' "${items[@]}" | "${cmd[@]}")

    local -r selected_dir=${selected%%$'\t'*}
    if [[ -n ${selected_dir} ]]; then
        pushd "${selected_dir}" >/dev/null 2>&1 || return
    fi
}
