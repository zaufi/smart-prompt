#!/bin/bash
#
# This is a `quick_cd` module of the SmartPrompt.
#
# Copyright (c) 2014-2022 Alex Turbov <i.zaufi@gmail.com>
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#

#
# Select a dir to go from a hot list using `dialog`
# It uses a `hotlist` file from Midnight Commander by default
#
# TODO Add functions to edit (add/remove) hot list entries
#
function quick_cd()
{
    local -r hl="${SMART_PROMPT_HOTLIST:-${XDG_CONFIG_HOME:-${HOME}/.config}/mc/hotlist}"
    if [[ ! -r ${hl} ]]; then
      echo "* No hotlist file exists yet or read permission is not granted *" > /dev/stderr
      return 1
    fi

    local -a cmd=( \
        dialog \
            --keep-tite \
            ${SMART_PROMPT_QCD_NOTAGS:+--no-tags} \
            --output-fd 1 \
            --colors \
            --begin 0 2 \
            --menu ' \ZbHot dirs to go\Zn' 0 0 0 \
      )
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

        cmd+=("${dir}")
        cmd+=("${item}")
    done < "${hl}"

    # shellcheck disable=SC2086
    local -r selected_dir=$("${cmd[@]}")

    if [[ -n ${selected_dir} ]]; then
        pushd "${selected_dir}" >/dev/null 2>&1 || return
    fi
}
