# zapccs
if (LLVM_COMPILER_IS_GCC_COMPATIBLE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-common -Woverloaded-virtual -fno-strict-aliasing -pedantic")
endif ()

include_directories(BEFORE
  ${LLVM_BINARY_DIR}/lib/Target/X86
  ${CMAKE_CURRENT_BINARY_DIR}/../clang/include
  ${CMAKE_CURRENT_SOURCE_DIR}/../clang/include
)

set(LLVM_LINK_COMPONENTS
  ${LLVM_TARGETS_TO_BUILD}
  Analysis
  AsmPrinter
  BitWriter
  CodeGen
  Core
  Support
  MC
)

add_clang_tool(zapccs
  CachingCompiler.cpp
  CachingPassManager.cpp
  CommandLine.cpp
  DebugInfoScanner.cpp
  Demangle.cpp
  DemangleGoogle.cpp
  DependencyMap.cpp
  DisableStreamsBuffering.cpp
  FindOption.cpp
  GetExePath.cpp
  GetMemoryUsage.cpp
  Getters.cpp
  raw_colored_svector_ostream.cpp
  ReplaceDeclInMap.cpp
  Server.cpp
  StopWatch.cpp
  StringConst.cpp
  TextFile.cpp
  Unload.cpp
  Unloader.cpp
  UnloaderDI.cpp
  UnloaderIR.cpp
  UnloaderMP.cpp
  UnloadSelector.cpp
  UserReplacer.cpp
  ZapccConfig.cpp
  ZapccsMain.cpp
)

if(UNIX)
  target_link_libraries(zapccs PRIVATE pthread)
endif()

set_target_properties(zapccs PROPERTIES FOLDER "Ceemple")
target_link_libraries(zapccs
  PRIVATE
  clangAST
  clangBasic
  clangCodeGen
  clangDriver
  clangEdit
  clangFrontend
  clangFrontendTool
  clangLex
  clangParse
  clangSema
  clangSerialization
)

add_custom_target (
  copy_config ALL
  COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/zapccs.config ${LLVM_RUNTIME_OUTPUT_INTDIR}
)

add_dependencies(zapccs copy_config)

install(FILES zapccs.config
  DESTINATION bin
  COMPONENT zapccs)
