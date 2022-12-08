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
    local -r hl="${SMART_PROMPT_HOTLIST:-~/.config/mc/hotlist}"
    if [[ ! -r ${hl} ]]; then
      echo "* No hotlist file exists yet or read permission is not granted *" > /dev/stderr
      exit 1
    fi

    local -r dirs=$(grep 'ENTRY' "${hl}" \
      | grep -v 'sh://' \
      | grep -v 'ftp://' \
      | sed 's,.*URL "\(.*\)",\1,g' \
      )
    # shellcheck disable=SC2086
    local -r selected_dir=$(dialog --keep-tite \
        --begin 0 2 \
        --output-fd 1 \
        --colors \
        --no-items \
        --menu ' \ZbHot dirs to go\Zn' 0 0 0 \
        ${dirs} \
      )

    if [[ -n ${selected_dir} ]]; then
        pushd "${selected_dir}" >/dev/null 2>&1 || return
    fi
}
