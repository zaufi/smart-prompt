# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).


## [Unreleased]

### Added

- Add options `USE_GIT` and `USE_SVN` with default value `AUTO` to enforce
  install corresponding checker, even if no program has found;
- Add option `USE_GENTOO` with default value `AUTO` to install Gentoo
  specific checkers.

### Changed

- Review code and use `[[` more extensively. Also replace backticks with `$()`.
  Speed up a little: avoid some calls to external programs;
- CMake options changed from `USE_xxx` to `WITH_xxx`.

[Unreleased]: https://github.com/zaufi/smart-prompt/compare/version-1.4.0...HEAD
