<!--
SPDX-FileCopyrightText: 2024 Alex Turbov <i.zaufi@gmail.com>
SPDX-License-Identifier: GPL-3.0-or-later
-->

# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).


## [Unreleased]

### Added

- Add options `USE_GIT` and `USE_SVN` with default value `AUTO` to enforce
  install corresponding checker, even if no program has found.
- Colorize CMake build types. One can set `SP_CMAKE_<UPCASE_NAME>_BUILD_TYPE_COLOR`
  to desired color. If not set, default `SP_CMAKE_BUILD_TYPE_COLOR` will be used.
- Detect JS project dir and extract package name and version from `package.json`.
- Add `SP_MARKS_MAP` and `SP_MARK_PATTERNS_MAP` to append _indicators_ to the path
  segment based on files (patterns) present in the current directory.

### Changed

- Review code and use `[[` more extensively. Also replace backticks with `$()`.
  Speed up a little: avoid some calls to external programs.
- CMake options changed from `USE_xxx` to `WITH_xxx`.
- Use unicode symbols for VCS branch and Python virtual env.
- Use XDG specification to get the user configs.
- CLI binding to search for running process learned to use pipe instead of
  shell variables and can highlight found substring.

[Unreleased]: https://github.com/zaufi/smart-prompt/compare/ddefc56...HEAD
