
# Copyright (c) 2012 Stefan Eilemann <Stefan.Eilemann@epfl.ch>

# write in-source FindPackages.cmake
function(USE_EXTERNAL_DEPS NAME)
  string(TOUPPER ${NAME} UPPER_NAME)
  set(_depsIn "${CMAKE_CURRENT_BINARY_DIR}/${NAME}FindPackages.cmake")
  set(_depsOut "${${UPPER_NAME}_SOURCE}/CMake/FindPackages.cmake")
  set(_scriptdir ${CMAKE_CURRENT_BINARY_DIR}/${NAME})

  file(WRITE ${_depsIn} "# generated by UseExternal.cmake, do not edit.\n")
  foreach(_dep ${${UPPER_NAME}_DEPENDS})
    string(TOUPPER ${_dep} _DEP)
    if(NOT "${${_DEP}_VERSION}" STREQUAL "")
      file(APPEND ${_depsIn}
        "find_package(${_dep} ${${_DEP}_VERSION})\n"
        "if(${_dep}_FOUND)\n"
        "  set(${_dep}_name ${_dep})\n"
        "elseif(${_DEP}_FOUND)\n"
        "  set(${_dep}_name ${_DEP})\n"
        "endif()\n"
        "if(${_dep}_name)\n"
        "  link_directories(\${\${${_dep}_name}_LIBRARY_DIRS})\n"
        "  include_directories(\${\${${_dep}_name}_INCLUDE_DIRS})\n"
        "endif()\n\n"
        )
    endif()
  endforeach()

  file(WRITE ${_scriptdir}/writeDeps.cmake
    "list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake)\n"
    "include(UpdateFile)\n"
    "update_file(${_depsIn} ${_depsOut})")

  ExternalProject_Add_Step(${NAME} FindPackages
    COMMENT "Updating ${_depsOut}"
    COMMAND ${CMAKE_COMMAND} -DBUILDYARD:PATH=${CMAKE_SOURCE_DIR}
            -P ${_scriptdir}/writeDeps.cmake
    DEPENDEES configure DEPENDERS build ALWAYS 1
    )
endfunction()
