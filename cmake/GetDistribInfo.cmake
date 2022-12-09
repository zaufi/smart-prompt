#[=======================================================================[.rst:
GetDistribInfo
--------------

Get a distribution codename according LSB spec or vendor specific files
(for Linux) or use voluntary strings (for Windows).

Variables
^^^^^^^^^

Set the following variables:

.. cmake:variable:: DISTRIB_ID

    a distribution identifier (like Gentoo or Ubuntu & etc)

.. cmake:variable:: DISTRIB_ARCH

    a distribution target machine

.. cmake:variable:: DISTRIB_CODENAME

    a distribution code name (like *quantal* or *trusty* for Ubuntu)

.. cmake:variable:: DISTRIB_VERSION

    a version string of the dictribution

.. cmake:variable:: DISTRIB_VERSION_MAJOR

    a major version component of the dictribution

.. cmake:variable:: DISTRIB_VERSION_MINOR

    a minor version component of the dictribution (if applicable)

.. cmake:variable:: DISTRIB_VERSION_PATCH

    a patch version component of the dictribution (if applicable)

.. cmake:variable:: DISTRIB_VERSION_TWEAK

    a version tweak component of the dictribution (if applicable)

.. cmake:variable:: DISTRIB_PKG_FMT

    native package manager's format(s) suitable to use w/ :cmake:variable:`CPACK_GENERATOR`

    .. note::

        :cmake:variable:`DISTRIB_PKG_FMT` will not contain plain archive formats!

.. cmake:variable:: DISTRIB_SRC_PKG_FMT

    native format to create tarballs

#]=======================================================================]

#=============================================================================
# Copyright 2012-2019 by Alex Turbov <i.zaufi@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file LICENSE for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of this repository, substitute the full
#  License text for the above reference.)

include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/GetKeyValueFromShellLikeConfig.cmake")

set(DEFAULT_DISTRIB_CODENAME "auto" CACHE STRING "Target distribution codename")
mark_as_advanced(DEFAULT_DISTRIB_CODENAME)

set(DEFAULT_DISTRIB_ID "auto" CACHE STRING "Target distribution")
mark_as_advanced(DEFAULT_DISTRIB_ID)

macro(_try_check_centos _release_file)
    set(DISTRIB_ID "CentOS")
    file(STRINGS ${_release_file} _release_string)
    # NOTE CentOS 6.0 has a word "Linux" in release string
    string(REGEX REPLACE "CentOS (Linux )?release ([0-9\\.]+) .*" "\\2" DISTRIB_VERSION "${_release_string}")
    # Set native packages format
    set(DISTRIB_PKG_FMT "RPM")
    set(DISTRIB_HAS_PACKAGE_MANAGER TRUE)
    # TODO Get more details
endmacro()

macro(_try_check_redhat _release_string)
    if(_release_string MATCHES "Red Hat Enterprise Linux Server")
        set(DISTRIB_ID "RHEL")
        string(
            REGEX REPLACE
                "Red Hat Enterprise Linux Server release ([0-9\\.]+) .*" "\\1"
            DISTRIB_VERSION
            "${_release_string}"
          )
        string(
            REGEX REPLACE
                "Red Hat Enterprise Linux Server release [0-9\\.]+ \((.*)\)" "\\1"
            DISTRIB_CODENAME
            "${_release_string}"
          )
    # Set native packages format
    set(DISTRIB_PKG_FMT "RPM")
    set(DISTRIB_HAS_PACKAGE_MANAGER TRUE)
    endif()
endmacro()

function(_debug msg)
    if(GDI_DEBUG)
        message(STATUS "[GDI] ${msg}")
    endif()
endfunction()

#
# Ok, lets collect come info about this distro...
#
if(NOT DISTRIB_ID)
    if(NOT WIN32)
        _debug("We r not in Windows! Trying `uname`")
        find_program(
            UNAME_EXECUTABLE
            NAMES uname
            DOC "Print certain system information"
          )
        mark_as_advanced(UNAME_EXECUTABLE)
        if(UNAME_EXECUTABLE)
            execute_process(
                COMMAND "${UNAME_EXECUTABLE}" -m
                OUTPUT_VARIABLE DISTRIB_ARCH
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
              )
            # NOTE DISTRIB_ARCH can be overridden (tuned) later
            _debug("`uname -m` returns ${DISTRIB_ARCH}")
        endif()
    endif()

    # Set the same source package format for all distros
    # NOTE Windows will override it
    set(DISTRIB_SRC_PKG_FMT "TXZ")

    # Trying Windows
    if(WIN32)
        _debug("Windows detected. Checking `void*` size")
        set(DISTRIB_ID "Win")
        set(DISTRIB_PKG_FMT "NuGet")
        set(DISTRIB_SRC_PKG_FMT "ZIP")
        set(DISTRIB_VERSION "${CMAKE_SYSTEM_VERSION}")

        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            _debug("  `void*` size is 8")
            set(DISTRIB_ARCH "64")
        elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
            _debug("  `void*` size is 4")
            set(DISTRIB_ARCH "32")
        elseif(NOT CMAKE_SIZEOF_VOID_P)
            _debug("  `void*` size is undefined")
            set(DISTRIB_ARCH "-noarch")
        endif()

    # Trying CentOS distros
    elseif(EXISTS /etc/centos-release)
        # ATTENTION CentOS has a symlink /etc/redhat-release -> /etc/centos-release,
        # so it must be handled before!
        # NOTE /etc/centos-release
        _try_check_centos(/etc/centos-release)

    # Trying RedHat distros
    elseif(EXISTS /etc/redhat-release)

        file(STRINGS /etc/redhat-release _release_string)
        if(_release_string MATCHES "CentOS")
            _try_check_centos(/etc/redhat-release)
        elseif(_release_string MATCHES "Red Hat")
            _try_check_redhat(${_release_string})
        endif()
        # TODO Detect a real RH releases

    elseif(EXISTS /etc/gentoo-release)

        set(DISTRIB_ID "Gentoo")
        set(DISTRIB_PKG_FMT "TXZ")
        # Try to tune DISTRIB_ARCH
        if(DISTRIB_ARCH STREQUAL "x86_64")
            # 64-bit packets usually named amd64 here...
            set(DISTRIB_ARCH "amd64")
        endif()
        # TODO Get more details

    # Trying LSB conformant distros like Ubuntu, RHEL or CentOS w/
    # corresponding package installed. What else?
    elseif(EXISTS /usr/bin/lsb_release)

        # Get DISTRIB_ID
        execute_process(
            COMMAND /usr/bin/lsb_release -i
            OUTPUT_VARIABLE DISTRIB_ID
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
          )
        string(REGEX REPLACE ".+:[\t ]+([A-Za-z]+).*" "\\1" DISTRIB_ID "${DISTRIB_ID}")
        # Get DISTRIB_CODENAME
        execute_process(
            COMMAND /usr/bin/lsb_release -c
            OUTPUT_VARIABLE DISTRIB_CODENAME
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
          )
        string(REGEX REPLACE ".+:[\t ]+(.+)" "\\1" DISTRIB_CODENAME "${DISTRIB_CODENAME}")
        # Get DISTRIB_VERSION
        execute_process(
            COMMAND /usr/bin/lsb_release -r
            OUTPUT_VARIABLE DISTRIB_VERSION
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
          )
        string(REGEX REPLACE ".+:[\t ]+(.+).*" "\\1" DISTRIB_VERSION "${DISTRIB_VERSION}")
        # Set native packages format
        if(DISTRIB_ID STREQUAL "CentOS" OR DISTRIB_ID STREQUAL "RedHat")
            set(DISTRIB_PKG_FMT "RPM")
            set(DISTRIB_HAS_PACKAGE_MANAGER TRUE)
        elseif(DISTRIB_ID STREQUAL "Ubuntu")
            set(DISTRIB_PKG_FMT "DEB")
            set(DISTRIB_HAS_PACKAGE_MANAGER TRUE)
            # Try tune DISTRIB_ARCH
            if(DISTRIB_ARCH STREQUAL "x86_64")
                # 64-bit packets usually named amd64 here...
                set(DISTRIB_ARCH "amd64")
            endif()
        else()
            # TODO Anything else?
            _debug("LSB compliant distro detected, but not fully recognized")
        endif()

    # Trying LSB conformant distros but w/o corresponding package installed.
    elseif(EXISTS /etc/lsb-release)
        get_value_from_config_file(/etc/lsb-release KEY "DISTRIB_ID" OUTPUT_VARIABLE DISTRIB_ID)
        get_value_from_config_file(/etc/lsb-release KEY "DISTRIB_RELEASE" OUTPUT_VARIABLE DISTRIB_VERSION)
        get_value_from_config_file(/etc/lsb-release KEY "DISTRIB_CODENAME" OUTPUT_VARIABLE DISTRIB_CODENAME)
        if(DISTRIB_ID STREQUAL "Ubuntu")
            set(DISTRIB_PKG_FMT "DEB")
            set(DISTRIB_HAS_PACKAGE_MANAGER TRUE)
            # Try tune DISTRIB_ARCH
            if(DISTRIB_ARCH STREQUAL "x86_64")
                # 64-bit packets usually named amd64 here...
                set(DISTRIB_ARCH "amd64")
            endif()
        else()
            # TODO What other distros??
            _debug("/etc/lsb-release exists, but not fully recognized")
        endif()

    else()
        # Try generic way
        if(UNAME_EXECUTABLE)
            # Try to get kernel name
            execute_process(
                COMMAND "${UNAME_EXECUTABLE}" -o
                OUTPUT_VARIABLE DISTRIB_ID
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
              )
            execute_process(
                COMMAND "${UNAME_EXECUTABLE}" -r
                OUTPUT_VARIABLE DISTRIB_VERSION
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
              )
        endif()
        # Try to tune it
        if(DISTRIB_ID STREQUAL "Solaris")
            if(EXISTS /etc/release)
                file(STRINGS /etc/release DISTRIB_CODENAME REGEX "SmartOS")
                if(NOT DISTRIB_CODENAME STREQUAL "")
                    set(DISTRIB_ID "SmartOS")
                    set(DISTRIB_CODENAME "")
                    # NOTE According docs, SmartOS has no version.
                    # It has a timestamp of a base image instead.
                    set(DISTRIB_VERSION "")
                endif()
            endif()
        endif()
    endif()

    if(DISTRIB_ID)
        if(DISTRIB_VERSION)
            string(REPLACE "." ";" DISTRIB_VERSION_LIST "${DISTRIB_VERSION}")
            list(LENGTH DISTRIB_VERSION_LIST DISTRIB_VERSION_LIST_LEN)
            if(DISTRIB_VERSION_LIST_LEN GREATER_EQUAL 1)
                list(POP_FRONT DISTRIB_VERSION_LIST DISTRIB_VERSION_MAJOR)
            endif()
            if(DISTRIB_VERSION_LIST_LEN GREATER_EQUAL 2)
                list(POP_FRONT DISTRIB_VERSION_LIST DISTRIB_VERSION_MINOR)
            endif()
            if(DISTRIB_VERSION_LIST_LEN GREATER_EQUAL 3)
                list(POP_FRONT DISTRIB_VERSION_LIST DISTRIB_VERSION_PATCH)
            endif()
            if(DISTRIB_VERSION_LIST_LEN GREATER_EQUAL 4)
                list(POP_FRONT DISTRIB_VERSION_LIST DISTRIB_VERSION_TWEAK)
            endif()
            unset(DISTRIB_VERSION_LIST)
            unset(DISTRIB_VERSION_LIST_LEN)
        endif()
    endif()
endif()

# X-Chewy-RepoBase: https://raw.githubusercontent.com/mutanabbi/chewy-cmake-rep/master/
# X-Chewy-Path: GetDistribInfo.cmake
# X-Chewy-Version: 3.3.0
# X-Chewy-Description: Get a distribution codename
# X-Chewy-AddonFile: GetKeyValueFromShellLikeConfig.cmake
