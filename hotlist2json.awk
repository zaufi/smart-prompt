#!/usr/bin/env gawk -f
#
# SPDX-FileCopyrightText: 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: CC0-1.0
#
# Convert Midnight Commander's hotlist file to JSON.
# Usage: gawk -f hotlist2json.awk ~/.config/mc/hotlist
#

function json_escape(s,    t) {
    t = s
    gsub(/\\/, "\\\\", t)
    gsub(/"/, "\\\"", t)
    gsub(/\t/, "\\t", t)
    gsub(/\r/, "\\r", t)
    gsub(/\n/, "\\n", t)
    gsub(/\f/, "\\f", t)
    gsub(/\b/, "\\b", t)
    return t
}

function is_file_url(u) {
    # Keep only local absolute paths.
    # Drop VFS-style URLs like /sh://host/path.
    return (u ~ /^\// && u !~ /^\/[[:alpha:]][[:alnum:].+-]*:\/\//)
}

BEGIN {
    print "["
    first = 1
}

match($0, /^[[:space:]]*ENTRY[[:space:]]+"(([^"\\]|\\.)*)"[[:space:]]+URL[[:space:]]+"(([^"\\]|\\.)*)"[[:space:]]*$/, m) {
    entry = m[1]
    url = m[3]

    if (!is_file_url(url))
        next

    if (!first) print ","
    printf "  {\"entry\":\"%s\",\"url\":\"%s\"}", json_escape(entry), json_escape(url)
    first = 0
}

END {
    print ""
    print "]"
}
