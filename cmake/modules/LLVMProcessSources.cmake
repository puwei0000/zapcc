include(AddFileDependencies)
include(CMakeParseArguments)

function(llvm_replace_compiler_option var old new)
  # Replaces a compiler option or switch `old' in `var' by `new'.
  # If `old' is not in `var', appends `new' to `var'.
  # Example: llvm_replace_compiler_option(CMAKE_CXX_FLAGS_RELEASE "-O3" "-O2")
  # If the option already is on the variable, don't add it:
  if( "${${var}}" MATCHES "(^| )${new}($| )" )
    set(n "")
  else()
    set(n "${new}")
  endif()
  if( "${${var}}" MATCHES "(^| )${old}($| )" )
    string( REGEX REPLACE "(^| )${old}($| )" " ${n} " ${var} "${${var}}" )
  else()
    set( ${var} "${${var}} ${n}" )
  endif()
  set( ${var} "${${var}}" PARENT_SCOPE )
endfunction(llvm_replace_compiler_option)

macro(add_td_sources srcs)
  file(GLOB tds *.td)
  if( tds )
    source_group("TableGen descriptions" FILES ${tds})
    set_source_files_properties(${tds} PROPERTIES HEADER_FILE_ONLY ON)
    list(APPEND ${srcs} ${tds})
  endif()
endmacro(add_td_sources)

function(add_header_files_for_glob hdrs_out glob)
  file(GLOB hds ${glob})
  set(${hdrs_out} ${hds} PARENT_SCOPE)
endfunction(add_header_files_for_glob)

function(find_all_header_files hdrs_out additional_headerdirs)
  add_header_files_for_glob(hds *.h)
  list(APPEND all_headers ${hds})

  foreach(additional_dir ${additional_headerdirs})
    add_header_files_for_glob(hds "${additional_dir}/*.h")
    list(APPEND all_headers ${hds})
    add_header_files_for_glob(hds "${additional_dir}/*.inc")
    list(APPEND all_headers ${hds})
  endforeach(additional_dir)

  set( ${hdrs_out} ${all_headers} PARENT_SCOPE )
endfunction(find_all_header_files)


function(llvm_process_sources OUT_VAR)
  cmake_parse_arguments(ARG "" "" "ADDITIONAL_HEADERS;ADDITIONAL_HEADER_DIRS" ${ARGN})
  set(sources ${ARG_UNPARSED_ARGUMENTS})
  llvm_check_source_file_list( ${sources} )
  if( LLVM_ENABLE_IDE )
    # This adds .td and .h files to the Visual Studio solution:
    add_td_sources(sources)
    find_all_header_files(hdrs "${ARG_ADDITIONAL_HEADER_DIRS}")
    if (hdrs)
      set_source_files_properties(${hdrs} PROPERTIES HEADER_FILE_ONLY ON)
    endif()
    set_source_files_properties(${ARG_ADDITIONAL_HEADERS} PROPERTIES HEADER_FILE_ONLY ON)
    list(APPEND sources ${ARG_ADDITIONAL_HEADERS} ${hdrs})
  endif()

  set( ${OUT_VAR} ${sources} PARENT_SCOPE )
endfunction(llvm_process_sources)


function(llvm_check_source_file_list)
  cmake_parse_arguments(ARG "" "SOURCE_DIR" "" ${ARGN})
  set(listed ${ARG_UNPARSED_ARGUMENTS})
  if(ARG_SOURCE_DIR)
    file(GLOB globbed
         RELATIVE "${CMAKE_CURRENT_LIST_DIR}"
         "${ARG_SOURCE_DIR}/*.c" "${ARG_SOURCE_DIR}/*.cpp")
  else()
    file(GLOB globbed *.c *.cpp)
  endif()
  foreach(g ${globbed})
    get_filename_component(fn ${g} NAME)
    if(ARG_SOURCE_DIR)
      set(entry "${g}")
    else()
      set(entry "${fn}")
    endif()

    # Don't reject hidden files. Some editors create backups in the
    # same directory as the file.
    if (NOT "${fn}" MATCHES "^\\.")
      list(FIND LLVM_OPTIONAL_SOURCES ${entry} idx)
      if( idx LESS 0 )
        list(FIND listed ${entry} idx)
        if( idx LESS 0 )
          message(SEND_ERROR "Found unknown source file ${g}
Please update ${CMAKE_CURRENT_LIST_FILE}\n")
        endif()
      endif()
    endif()
  endforeach()
endfunction(llvm_check_source_file_list)
