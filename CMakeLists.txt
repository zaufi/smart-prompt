cmake_minimum_required(VERSION 2.8)

# NOTE This project do not use C compiler actually,
# but unfortunately it can't be configured w/ NONE
# as a languages set, cuz GNUInstallDirs wants at
# least one...
project(smart-prompt C)

set(SP_MAJOR 0)
set(SP_MINOR 1)
set(SP_PATCH 0)
set(SP_VERSION ${SP_MAJOR}.${SP_MINOR}.${SP_PATCH})

# Define install destination dirs
include(GNUInstallDirs)

# Setup package pathes
# TODO Add caching and docs
set(SP_PREFIX      "${CMAKE_INSTALL_PREFIX}")
set(SP_DATAROOTDIR "${CMAKE_INSTALL_FULL_DATAROOTDIR}")
set(SP_LIBEXECDIR  "${CMAKE_INSTALL_FULL_LIBEXECDIR}/${PROJECT_NAME}")
set(SP_DOCDIR      "${CMAKE_INSTALL_FULL_DOCDIR}-${SP_VERSION}")

if(${SP_PREFIX} MATCHES "/usr")
  set(SP_SYSCONFDIR "/etc")
else()
  set(SP_SYSCONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
endif()

message(STATUS "PROJECT_NAME=${PROJECT_NAME}")
message(STATUS "SP_PREFIX=${CMAKE_INSTALL_PREFIX}")
message(STATUS "SP_SYSCONFDIR=${SP_SYSCONFDIR}")
message(STATUS "SP_DATAROOTDIR=${SP_DATAROOTDIR}")
message(STATUS "SP_DOCDIR=${SP_DOCDIR}")
message(STATUS "SP_LIBEXECDIR=${SP_LIBEXECDIR}")

set(SP_CONTEXT_CHECKERS_DIR "${SP_LIBEXECDIR}/context-checkers.d")
set(SMART_PROMPT_CONFIG ${SP_SYSCONFDIR}/${PROJECT_NAME}.conf)

configure_file(${PROJECT_NAME}.sh.in ${PROJECT_NAME}.sh @ONLY)

install(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.sh DESTINATION ${SP_SYSCONFDIR}/profile.d)
install(FILES ${PROJECT_NAME}.conf DESTINATION ${SP_SYSCONFDIR})

install(DIRECTORY context-checkers.d DESTINATION ${SP_LIBEXECDIR})
