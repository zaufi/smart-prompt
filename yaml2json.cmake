# SPDX-FileCopyrightText: 2026 Alex Turbov <i.zaufi@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later

if(NOT DEFINED INPUT_FILE)
    message(FATAL_ERROR "INPUT_FILE is not set")
endif()

if(NOT DEFINED OUTPUT_FILE)
    message(FATAL_ERROR "OUTPUT_FILE is not set")
endif()

if(NOT DEFINED YQ_EXECUTABLE)
    message(FATAL_ERROR "YQ_EXECUTABLE is not set")
endif()

foreach(_var INPUT_FILE OUTPUT_FILE YQ_EXECUTABLE)
    string(REGEX REPLACE "^\"(.*)\"$" "\\1" ${_var} "${${_var}}")
endforeach()

execute_process(
    COMMAND "${YQ_EXECUTABLE}" --output-format=json "." "${INPUT_FILE}"
    OUTPUT_FILE "${OUTPUT_FILE}"
    ERROR_VARIABLE _error
    RESULT_VARIABLE _result
  )

if(NOT _result EQUAL 0)
    message(FATAL_ERROR "Failed to convert ${INPUT_FILE} to JSON with yq: ${_error}")
endif()
