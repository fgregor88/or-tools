INCLUDE(FindPackageHandleStandardArgs)

FOREACH(COIN_PROJECT CoinUtils Osi Clp Cgl Cbc)
    SET(${COIN_PROJECT}_ROOT_DIR "" CACHE PATH "Path to Coin-OR ${COIN_PROJECT}")
    IF(WIN32)
        FIND_PATH(${COIN_PROJECT}_INCLUDE_DIR ${COIN_PROJECT}Config.h PATHS ${${COIN_PROJECT}_ROOT_DIR}/src/windows PATH_SUFFIXES coin ${COIN_PROJECT}/coin)
    ELSE()
        FIND_PATH(${COIN_PROJECT}_INCLUDE_DIR ${COIN_PROJECT}Config.h PATHS ${${COIN_PROJECT}_ROOT_DIR} PATH_SUFFIXES coin ${COIN_PROJECT}/coin)
    ENDIF()
ENDFOREACH()

IF(Cbc_INCLUDE_DIR)
    SET(_Cbc_COMMON_HEADER ${Cbc_INCLUDE_DIR}/CbcConfig.h)
    SET(Cbc_VERSION "")
    SET(Cbc_LIB_VERSION "")

    FILE(STRINGS ${_Cbc_COMMON_HEADER} _Cbc_COMMON_H_CONTENTS REGEX "#define[ \t]+CBC_VERSION[ \t]+")

    IF(_Cbc_COMMON_H_CONTENTS MATCHES "#define[ \t]+CBC_VERSION[ \t]+\"([0-9.]+)\"")
        SET(Cbc_LIB_VERSION "${CMAKE_MATCH_1}")
    ENDIF()

    SET(Cbc_VERSION "${Cbc_LIB_VERSION}")
ENDIF()

IF(MSVC)
    FIND_LIBRARY(Cbc_LIBRARY_RELEASE libCbc_static PATHS ${Cbc_ROOT_DIR} PATH_SUFFIXES Release)
    FIND_LIBRARY(Cbc_LIBRARY_DEBUG libCbc_static PATHS ${Cbc_ROOT_DIR} PATH_SUFFIXES Debug)
    SET(Cbc_LIBRARY OPTIMIZED ${Cbc_LIBRARY_RELEASE} DEBUG ${Cbc_LIBRARY_DEBUG})

    FIND_LIBRARY(Cbc_Solver_LIBRARY_RELEASE libCbcSolver_static PATHS ${Cbc_ROOT_DIR} PATH_SUFFIXES Release)
    FIND_LIBRARY(Cbc_solver_LIBRARY_DEBUG libCbcSolver_static PATHS ${Cbc_ROOT_DIR} PATH_SUFFIXES Debug)
    SET(Cbc_Solver__LIBRARY OPTIMIZED ${Cbc_Solver__LIBRARY_RELEASE} DEBUG ${Cbc_Solver__LIBRARY_DEBUG})
ELSE()
    FIND_LIBRARY(Cbc_LIBRARY NAMES Cbc libCBC PATHS ${Cbc_ROOT_DIR} PATH_SUFFIXES lib lib64)
    FIND_LIBRARY(Cbc_Solver_LIBRARY NAMES CbcSolver libCbcSolver PATHS ${Cbc_ROOT_DIR} PATH_SUFFIXES lib lib64)
ENDIF()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Cbc
    REQUIRED_VARS Cbc_INCLUDE_DIR Cbc_LIBRARY Cbc_Solver_LIBRARY
    VERSION_VAR Cbc_VERSION)

IF(Cbc_FOUND)
    SET(Cbc_INCLUDE_DIRS ${Cbc_INCLUDE_DIR})
    FOREACH(COIN_PROJECT CoinUtils Osi Clp Cgl)
        LIST(APPEND Cbc_INCLUDE_DIRS ${${COIN_PROJECT}_INCLUDE_DIR})
    ENDFOREACH()

    SET(Cbc_LIBRARIES "${Cbc_LIBRARY};${Cbc_Solver_LIBRARY}")
    MARK_AS_ADVANCED(Cbc_ROOT_DIR Cbc_LIBRARY_RELEASE Cbc_LIBRARY_DEBUG Cbc_LIBRARY Cbc_INCLUDE_DIR)
ENDIF()
