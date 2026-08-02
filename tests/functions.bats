#!/usr/bin/env bats

# SPDX-FileCopyrightText: 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

bats_load_library bats-support
bats_load_library bats-assert
bats_load_library bats-file

setup()
{
    logger() { :; }
    # shellcheck source=../smart-prompt-functions.sh
    source "${BATS_TEST_DIRNAME}/../smart-prompt-functions.sh"
}

@test "parse_rgb assigns all components through its prefix" {
    _sp.parse_rgb 'rgb(1, 23, 255)' color

    assert_equal 1 "${color_r}"
    assert_equal 23 "${color_g}"
    assert_equal 255 "${color_b}"
}

@test "parse_hex_color supports six-digit and shorthand forms" {
    _sp.parse_hex_color '#12aBc3' color
    assert_equal 18 "${color_r}"
    assert_equal 171 "${color_g}"
    assert_equal 195 "${color_b}"

    _sp.parse_hex_color '#abc' color
    assert_equal 170 "${color_r}"
    assert_equal 187 "${color_g}"
    assert_equal 204 "${color_b}"
}

@test "color conversion writes prompt-safe ANSI strings" {
    _sp.rgb_to_ansi 1 2 3 color
    assert_equal "\\[\\e[38;5;67m\\]" "${color}"

    _sp.rgb_to_ansi 6 7 8 color
    assert_equal "\\[\\e[38;2;6;7;8m\\]" "${color}"
}

@test "color expansion and ANSI conversion preserve output values" {
    _sp.eval_color_string 'reset bright-red' color
    assert_equal "\\[\\e[0m\\]\\[\\e[91m\\]" "${color}"

    _sp.eval_ansi_color_string 'reset' color
    assert_equal $'\e[0m' "${color}"
}

@test "color parameters use the configured value or fallback" {
    local sp_test_param='bright-blue'
    local sp_test_fallback='fallback'

    _sp.get_color_param sp_test_param sp_test_fallback color
    assert_equal "\\[\\e[0m\\]\\[\\e[94m\\]" "${color}"

    unset sp_test_param
    sp_test_fallback='fallback value'
    _sp.get_color_param sp_test_param sp_test_fallback color
    assert_equal 'fallback value' "${color}"
}

@test "seconds_to_duration formats short and long durations" {
    _sp.seconds_to_duration 3661 duration
    assert_equal '01:01' "${duration}"

    _sp.seconds_to_duration 90061 duration
    assert_equal '1 days, 01:01' "${duration}"
}

@test "find_program assigns an executable path" {
    _sp.find_program bash executable
    assert_file_executable "${executable}"
}

@test "runtime shell files contain no eval calls" {
    run rg -n '\beval\b' \
        "${BATS_TEST_DIRNAME}/../smart-prompt-functions.sh" \
        "${BATS_TEST_DIRNAME}/../context-checkers.d"

    assert_failure 1
}

@test "runtime shell files contain no function-derived local prefixes" {
    run rg -n \
        '_(prbg|phc|r2a|ecs|esc|eacs|gcp|s2d|fp|sp|sdc|sco|spd|ggb|ggds|sgs|sgg|gsb|gsds|sss|sbcc|sdl|sfi|sk|skc|slm|slu|sni|spal|ssdami|su|spi|gtpi|sip|swd|gssc|sdt|svenv|ssc)(__|_)' \
        "${BATS_TEST_DIRNAME}/.."

    assert_failure 1
}
