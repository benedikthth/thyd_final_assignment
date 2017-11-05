cmake_minimum_required(VERSION 3.8)
project(DecafComp)

find_package(FLEX)
FLEX_TARGET(DecafLexer decaf.l ${CMAKE_CURRENT_BINARY_DIR}/../lexer_decaf.cpp)

find_package(BISON)
BISON_TARGET(DecafParser decaf.yy ${CMAKE_CURRENT_BINARY_DIR}/../parser_decaf.cpp)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "-Wall -Wno-deprecated-register")

set(SOURCE_FILES ${BISON_DecafParser_OUTPUTS} ${FLEX_DecafLexer_OUTPUTS} main.cpp ast.h tac.h parser.h bparser.h symbol_table.h)
add_executable(DecafComp ${SOURCE_FILES})