#!/bin/bash
#
# This is a `quick_cd` module of the SmartPrompt.
#
# Smart Prompt @SP_VERSION@
# Copyright (c) 2014 Alex Turbov <i.zaufi@gmail.com>
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
    local hl=${SMART_PROMPT_HOTLIST:-~/.config/mc/hotlist}
    test -r ${hl} || { echo "* No hotlist file exists yet or read permission is not granted *" > /dev/stderr && exit 1; }

    local dirs=`cat -n "${hl}" \
      | grep 'ENTRY' \
      | grep -v 'sh://' \
      | grep -v 'ftp://' \
      | sed 's,\(.*\)ENTRY "\(.*\)" URL "\(.*\)",\1\3,g' \
      `

    local dirnum=`dialog --keep-tite \
        --begin 0 2 \
        --output-fd 1 \
        --colors \
        --menu ' \ZbHot dirs to go\Zn' 0 0 0 \
        ${dirs} \
      `

    if [ -n "${dirnum}" ]; then
        pushd `head -n ${dirnum} "${hl}" | tail -n 1 | sed 's,.*URL "\(.*\)".*,\1,'`
    fi
}
