#---------------------------------------------------------
# Section: Initialize CMake
#---------------------------------------------------------
cmake_minimum_required(VERSION 3.14)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

project(
    smart-prompt VERSION 1.5.0
    DESCRIPTION "The fancy bash prompt and some other helpful things"
    HOMEPAGE_URL "https://github.com/zaufi/smart-prompt"
    LANGUAGES NONE
  )

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(GetDistribInfo)

function(auto_option NAME DESCRIPTION)
    if(DEFINED ARGV2)
        set(_init ${ARGV2})
    else()
        set(_init AUTO)
    endif()
    set(${NAME} ${_init} CACHE STRING "${DESCRIPTION}")
    set_property(CACHE ${NAME} PROPERTY STRINGS AUTO ON OFF)
endfunction()

# Setup package options
auto_option(WITH_DOCKER "Include readline macros for Docker")
auto_option(WITH_GIT "Add support for git")
auto_option(WITH_OPENRC "Add support for OpenRC")
auto_option(WITH_PALUDIS "Add support for Paludis (Gentoo and Exherbo)")
auto_option(WITH_PORTAGE "Add support for Portage (Gentoo)")
auto_option(WITH_SVN "Add support for subversion")
auto_option(WITH_SCHROOT "Add support for schroot")
auto_option(WITH_SYSTEMD "Add support for systemd")

if(WITH_GIT)
    if(NOT WITH_GIT STREQUAL AUTO)
        set(_req REQUIRED)
    endif()
    find_package(Git ${_req})
    if(Git_FOUND)
        set(WITH_GIT ON)
    else()
        set(WITH_GIT OFF)
    endif()
    unset(_req)
endif()

if(WITH_SVN)
    if(NOT WITH_SVN STREQUAL AUTO)
        set(_req REQUIRED)
    endif()
    find_package(Subversion ${_req})
    if(Subversion_FOUND)
        set(WITH_SVN ON)
    else()
        set(WITH_SVN OFF)
    endif()
    unset(_req)
endif()

if(WITH_DOCKER)
    find_program(DOCKER_EXECUTABLE docker DOC "Docker executable")
    if(NOT DOCKER_EXECUTABLE)
        if(NOT WITH_DOCKER STREQUAL AUTO)
            message(
                WARNING
                "Docker support has been requested, but `docker` executable not found."
                "Make sure you have it installed after this package."
              )
        else()
            set(WITH_DOCKER OFF)
        endif()
    endif()
endif()

if(WITH_PALUDIS)
    find_program(CAVE_EXECUTABLE cave DOC "Paludis client executable")
    if(NOT CAVE_EXECUTABLE AND NOT EXISTS "/etc/paludis/bashrc")
        if(NOT WITH_PALUDIS STREQUAL AUTO)
            message(
                WARNING
                "Paludis support has been requested, but `cave` executable and configuration not found."
                "Make sure you have it installed after this package."
              )
        else()
            set(WITH_PALUDIS OFF)
        endif()
    endif()
endif()

if(WITH_PORTAGE)
    find_program(EMERGE_EXECUTABLE emerge DOC "Portage executable")
    if(NOT EMERGE_EXECUTABLE AND NOT EXISTS "/etc/portage/make.conf")
        if(NOT WITH_PORTAGE STREQUAL AUTO)
            message(
                WARNING
                "Portage support has been requested, but `emerge` executable and configuration not found."
                "Make sure you have it installed after this package."
              )
        else()
            set(WITH_PORTAGE OFF)
        endif()
    endif()
endif()

if(WITH_OPENRC)
    if(NOT EXISTS "/etc/rc.conf")
        if(NOT WITH_OPENRC STREQUAL AUTO)
            message(
                WARNING
                "Openrc support has been requested, but seems it doesn't installed."
                "Make sure you have it installed after this package."
              )
        else()
            set(WITH_OPENRC OFF)
        endif()
    endif()
endif()

if(WITH_SCHROOT)
    find_program(SCHROOT_EXECUTABLE schroot DOC "Secure chroot executable")
    if(NOT SCHROOT_EXECUTABLE)
        if(NOT WITH_SCHROOT STREQUAL AUTO)
            message(
                WARNING
                "Schroot support has been requested, but `schroot` executable not found."
                "Make sure you have it installed after this package."
              )
        else()
            set(WITH_SCHROOT OFF)
        endif()
    endif()
endif()

if(WITH_SYSTEMD)
    find_program(SYSTEMCTL_EXECUTABLE cave DOC "systemctl executable")
    if(NOT SYSTEMCTL_EXECUTABLE)
        if(NOT WITH_SYSTEMD STREQUAL AUTO)
            message(
                WARNING
                "Systemd support has been requested, but `systemclt` executable and configuration not found."
                "Make sure you have it installed after this package."
              )
        else()
            set(WITH_SYSTEMD OFF)
        endif()
    endif()
endif()


# Report options
message(STATUS "WITH_DOCKER=${WITH_DOCKER}")
message(STATUS "WITH_GIT=${WITH_GIT}")
message(STATUS "WITH_OPENRC=${WITH_OPENRC}")
message(STATUS "WITH_PALUDIS=${WITH_PALUDIS}")
message(STATUS "WITH_PORTAGE=${WITH_PORTAGE}")
message(STATUS "WITH_SVN=${WITH_SVN}")
message(STATUS "WITH_SCHROOT=${WITH_SCHROOT}")
message(STATUS "WITH_SYSTEMD=${WITH_SYSTEMD}")

# Setup package paths
include(GNUInstallDirs)

#---------------------------------------------------------
# Section: "Build" related statements
#---------------------------------------------------------

configure_file(${PROJECT_NAME}.sh.in ${PROJECT_NAME}.sh @ONLY)

#---------------------------------------------------------
# Section: Install project files
#---------------------------------------------------------

install(
    FILES
        "${CMAKE_BINARY_DIR}/${PROJECT_NAME}.sh"
        quick-cd.sh
    DESTINATION "${CMAKE_INSTALL_FULL_SYSCONFDIR}/profile.d"
  )
install(
    FILES "${PROJECT_NAME}-functions.sh"
    DESTINATION "${CMAKE_INSTALL_LIBEXECDIR}/${PROJECT_NAME}"
  )

install(
    FILES
        $<$<BOOL:${WITH_SCHROOT}>:${PROJECT_SOURCE_DIR}/context-checkers.d/00schroot.sh>
        context-checkers.d/00terminal-multiplexers.sh
        context-checkers.d/01user@host.sh
        context-checkers.d/02pwd.sh
        context-checkers.d/40cmake-build-dir.sh
        context-checkers.d/41nodejs-project-dir.sh
        $<$<BOOL:${WITH_GIT}>:${PROJECT_SOURCE_DIR}/context-checkers.d/50git.sh>
        $<$<BOOL:${WITH_SVN}>:${PROJECT_SOURCE_DIR}/context-checkers.d/52svn.sh>
        context-checkers.d/60system-dirs.sh
        $<$<BOOL:${WITH_PALUDIS}>:${PROJECT_SOURCE_DIR}/context-checkers.d/70paludis.sh>
        $<$<BOOL:${WITH_PORTAGE}>:${PROJECT_SOURCE_DIR}/context-checkers.d/70portage.sh>
        $<$<BOOL:${WITH_OPENRC}>:${PROJECT_SOURCE_DIR}/context-checkers.d/75openrc.sh>
        $<$<BOOL:${WITH_SYSTEMD}>:${PROJECT_SOURCE_DIR}/context-checkers.d/75systemd.sh>
        context-checkers.d/80virtualenv.sh
        context-checkers.d/99prev-cmd-exit-code.sh
    DESTINATION "${CMAKE_INSTALL_LIBEXECDIR}/${PROJECT_NAME}/context-checkers.d"
  )
install(
    FILES
        "${PROJECT_NAME}.conf"
        "${PROJECT_NAME}.inputrc"
    DESTINATION "${CMAKE_INSTALL_FULL_SYSCONFDIR}"
  )
install(
    FILES ChangeLog.md LICENSE README.md
    DESTINATION "${CMAKE_INSTALL_DOCDIR}"
  )

#---------------------------------------------------------
# Section: Configure package options
#---------------------------------------------------------

set(CPACK_PACKAGE_RELOCATABLE OFF)
set(CPACK_SET_DESTDIR ON)
set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")

# "Binary" package settings
set(CPACK_GENERATOR ${DISTRIB_PKG_FMT})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_VENDOR "Alex Turbov")
set(CPACK_PACKAGE_CONTACT "i.zaufi@gmail.com")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")

# Source tarball settings
set(CPACK_SOURCE_PACKAGE_FILE_NAME ${PROJECT_NAME}-${PROJECT_VERSION})
set(CPACK_SOURCE_GENERATOR TGZ)

# The following components are regex's to match anywhere (unless anchored)
# in absolute path + filename to find files or directories to be excluded
# from source tarball.
set(CPACK_SOURCE_IGNORE_FILES
    "\\\\.gitignore$"
    "\\\\.kate-swp$"
    "\\\\.tar\\\\.gz$"
    "^.*/\\\\.git.*$"
    "^.*/build/.*$"
  )

# RPM specific settings
set(CPACK_RPM_PACKAGE_GROUP "System Environment/Shells")
set(CPACK_RPM_PACKAGE_RELOCATABLE OFF)
set(CPACK_RPM_PACKAGE_RELEASE_DIST ON)
set(CPACK_RPM_PACKAGE_RELEASE "1")
set(CPACK_RPM_PACKAGE_LICENSE "GPL3")
set(CPACK_RPM_FILE_NAME "RPM-DEFAULT")
set(CPACK_RPM_PACKAGE_ARCHITECTURE "noarch")
set(CPACK_RPM_PACKAGE_REQUIRES "dialog, bash")
set(CPACK_RPM_PACKAGE_DESCRIPTION [[
 **Smart bash Prompt** is a pluggable system to show various
 context information in a command prompt. The initial idea was
 to create an extensible engine to have a dynamically changing
 command prompt instead of a <strike>boring</strike> static one,
 capable of displaying some aux info depending on a particular
 location and/or condition.]])

# DEB specific settings
set(CPACK_DEBIAN_PACKAGE_SECTION "shells")
set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "dialog, bash")
set(
    CPACK_DEBIAN_PACKAGE_DESCRIPTION
    "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}\n${CPACK_RPM_PACKAGE_DESCRIPTION}"
)

include(CPack)
