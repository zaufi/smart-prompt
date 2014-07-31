#---------------------------------------------------------
# Section: Initialize CMake
#---------------------------------------------------------
cmake_minimum_required(VERSION 2.8)

# NOTE This project do not use C compiler actually,
# but unfortunately it can't be configured w/ NONE
# as a languages set, cuz GNUInstallDirs wants at
# least one...
project(smart-prompt NONE)

set(SP_MAJOR 1)
set(SP_MINOR 2)
set(SP_PATCH 2)
set(SP_VERSION ${SP_MAJOR}.${SP_MINOR}.${SP_PATCH})

# Setup package pathes
# TODO Add caching and docs
set(SP_PREFIX      "${CMAKE_INSTALL_PREFIX}")
set(SP_DATAROOTDIR "${CMAKE_INSTALL_PREFIX}/share")
set(SP_LIBEXECDIR  "${CMAKE_INSTALL_PREFIX}/libexec/${PROJECT_NAME}")
set(SP_DOCDIR      "${SP_DATAROOTDIR}/doc/${PROJECT_NAME}")

if(${SP_PREFIX} STREQUAL "/usr")
  set(SP_SYSCONFDIR "/etc")
else()
  set(SP_SYSCONFDIR "${CMAKE_INSTALL_PREFIX}/etc")
endif()

message(STATUS "SP_PREFIX=${CMAKE_INSTALL_PREFIX}")
message(STATUS "SP_SYSCONFDIR=${SP_SYSCONFDIR}")
message(STATUS "SP_DATAROOTDIR=${SP_DATAROOTDIR}")
message(STATUS "SP_DOCDIR=${SP_DOCDIR}")
message(STATUS "SP_LIBEXECDIR=${SP_LIBEXECDIR}")

if(NOT DISABLE_GIT)
    find_package(Git)
endif()

if(NOT DISABLE_SVN)
    find_package(Subversion)
endif()

#---------------------------------------------------------
# Section: "Build" related statements
#---------------------------------------------------------

set(SP_CONTEXT_CHECKERS_DIR "${SP_LIBEXECDIR}/context-checkers.d")
set(SMART_PROMPT_CONFIG ${SP_SYSCONFDIR}/${PROJECT_NAME}.conf)

configure_file(${PROJECT_NAME}.sh.in ${PROJECT_NAME}.sh @ONLY)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

#---------------------------------------------------------
# Section: Install project files
#---------------------------------------------------------

set(
    SP_CHECKERS_SRC
    context-checkers.d/40cmake-build-dir.sh
    context-checkers.d/60system-dirs.sh
  )

if(GIT_FOUND)
    list(APPEND SP_CHECKERS_SRC context-checkers.d/50git.sh)
endif()

if(Subversion_FOUND)
    list(APPEND SP_CHECKERS_SRC context-checkers.d/52svn.sh)
endif()

if(EXISTS /etc/gentoo-release)
    list(APPEND SP_CHECKERS_SRC context-checkers.d/70gentoo-system-dirs.sh)
endif()

install(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.sh quick-cd.sh DESTINATION ${SP_SYSCONFDIR}/profile.d)
install(FILES ${PROJECT_NAME}-functions.sh DESTINATION ${SP_LIBEXECDIR})
install(FILES ${SP_CHECKERS_SRC} DESTINATION ${SP_CONTEXT_CHECKERS_DIR})
install(FILES ${PROJECT_NAME}.conf ${PROJECT_NAME}.inputrc DESTINATION ${SP_SYSCONFDIR})
install(FILES LICENSE README.md DESTINATION ${SP_DOCDIR})

#---------------------------------------------------------
# Section: Configure package options
#---------------------------------------------------------

# CPack version numbers for release tarball name.
set(CPACK_PACKAGE_VERSION_MAJOR ${SP_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${SP_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${SP_PATCH})
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/LICENSE)
set(
    CPACK_PACKAGE_DESCRIPTION_SUMMARY
    "Smart prompt: easy way to show various context info in a command prompt"
  )
set(CPACK_PACKAGE_VENDOR "Alex Turbov")
set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/README.md)
set(CPACK_SOURCE_PACKAGE_FILE_NAME ${PROJECT_NAME}-${SP_VERSION})
set(CPACK_SET_DESTDIR ON)

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
include(CPack)
