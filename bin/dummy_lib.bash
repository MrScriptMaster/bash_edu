################################################################################
## Библиотека пустышка
################################################################################
[ ! -z "$_LIB_DUMMY_PREFIX" -a ! -z "$_LIB_DUMMY_VERSION" ] && { echo "Error: ${BASH_SOURCE##*/}:${BASH_LINENO[1]}: double library importing."; exit 129; }
readonly _LIB_DUMMY_PREFIX='_dummy'
readonly _LIB_DUMMY_VERSION='0.9'
#
__test() {
    return 0
} 
__test || { echo "Error: Self test failure in \"$BASH_SOURCE\""; exit 128; }
unset -f __test