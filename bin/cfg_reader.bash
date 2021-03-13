
################################################################################
##
## Read config files in format:
##
## --------------------------------------------
## |# Comments are allowed
## |parameter_name=value_of_parameter    # Comments are allowed here
## |+= appended_value_1                  # ATTENTION: Space between += and value is required
## |+= appended_value_2
## |next_parameter=value
## --------------------------------------------
##
## Known issues:
##   * 0.9 *
##       - Spaces are not allowed around '='. Otherwise a value will be cutted.
##       - One space is required after '+='.  Otherwise a value will be cutted.
##   
################################################################################

[ ! -z "$_LIB_CFG_READER_PREFIX" -a ! -z "$_LIB_CFG_READER_VERSION" ] \
    && { echo "Error: ${BASH_SOURCE##*/}:${BASH_LINENO[1]}: double library importing."; exit 129; }

readonly _LIB_CFG_READER_PREFIX='cfg'
readonly _LIB_CFG_READER_VERSION='0.9'

declare -ri __CFG_TRUE=0
declare -ri __CFG_FALSE=1

declare -a __CFG_FILE=()
declare -i __CFG_ITERATOR=0

readonly __CFG_PREFIX_PARAMETER='p'
readonly __CFG_PREFIX_APPENDED='a'
__CFG_DELIMETER=':'

cfg_read_file_new() {
    local file_path="$1"
    local line lhs rhs
    local is_in_param=$__CFG_FALSE
    [[ -s $file_path ]] || return $__CFG_FALSE
    while IFS= read -r line <&4 || [[ -n $line ]]; do
        line=${line//[$'\r']}
        while IFS='=' read -r lhs rhs; do
            lhs="${lhs#"${lhs%%[![:space:]]*}"}"
            lhs="${lhs%"${lhs##*[![:space:]]}"}"
            if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then       
                rhs="${rhs%%\#*}"
                rhs="${rhs%%*( )}"
                if [[ $rhs =~ \".*\" ]]; then
                    rhs="${rhs%\"*}"
                    rhs="${rhs#\"*}"
                else
                    rhs="${rhs#"${rhs%%[![:space:]]*}"}"
                    rhs="${rhs%"${rhs##*[![:space:]]}"}"
                fi
                __CFG_FILE+=("${__CFG_PREFIX_PARAMETER}${__CFG_DELIMETER}${lhs}")
                __CFG_FILE+=("${__CFG_PREFIX_APPENDED}${__CFG_DELIMETER}${rhs}")
            else
                is_in_param=$__CFG_FALSE
            fi
        done <<< "$line"
    done 4< "$file_path"
    return $__CFG_TRUE
}

cfg_read_file() {
    local file_path="$1"
    local line lhs rhs lhs1
    local op_append='+'
    local is_in_param=$__CFG_FALSE
    [[ -s $file_path ]] || return $__CFG_FALSE
    while IFS= read -r line <&4; do
        line=${line//[$'\r']}
        while IFS=' ' read -r lhs rhs; do
            if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
                lhs1="${lhs%%=*}"
                rhs="${rhs%%\#*}"
                rhs="${rhs%%*( )}"
                rhs="${rhs%\"*}"
                rhs="${rhs#\"*}"
                rhs="${rhs#"${rhs%%[![:space:]]*}"}"
                rhs="${rhs%"${rhs##*[![:space:]]}"}"
                case "$lhs1" in 
                    "$op_append")
                        [[ $is_in_param -eq $__CFG_TRUE ]] \
                            && __CFG_FILE+=("${__CFG_PREFIX_APPENDED}${__CFG_DELIMETER}${rhs}")
                        ;;
                    *)
                        is_in_param=$__CFG_TRUE
                        __CFG_FILE+=("${__CFG_PREFIX_PARAMETER}${__CFG_DELIMETER}${lhs1}")
                        __CFG_FILE+=("${__CFG_PREFIX_APPENDED}${__CFG_DELIMETER}${lhs##*=}")
                        ;;
                esac
            else
                is_in_param=$__CFG_FALSE
            fi
        done <<< "$line"
    done 4< "$file_path"
    return $__CFG_TRUE
}

cfg_get_next_parameter() {
    [[ $# -eq 1 ]] || return $__CFG_FALSE
    local index
    for (( index=${__CFG_ITERATOR}; index < ${#__CFG_FILE[*]}; index++ )); do
        if [[ ${__CFG_FILE[$index]%%${__CFG_DELIMETER}*} == ${__CFG_PREFIX_PARAMETER} ]]; then
            printf -v "$1" "${__CFG_FILE[$index]#*${__CFG_DELIMETER}}"
            : $(( __CFG_ITERATOR++ ))
            return $__CFG_TRUE
        fi
        : $(( __CFG_ITERATOR++ ))
    done
    return $__CFG_FALSE
}

cfg_get_next() {
    [[ $# -eq 1 ]] || return $__CFG_FALSE
    local index
    for (( index=${__CFG_ITERATOR}; index < ${#__CFG_FILE[*]}; index++ )); do
        if [[ ${__CFG_FILE[$index]%%${__CFG_DELIMETER}*} == ${__CFG_PREFIX_APPENDED} ]]; then
            printf -v "$1" "${__CFG_FILE[$index]#*${__CFG_DELIMETER}}"
            : $(( __CFG_ITERATOR++ ))
            return $__CFG_TRUE
        elif  [[ ${__CFG_FILE[$index]%%${__CFG_DELIMETER}*} == ${__CFG_PREFIX_PARAMETER} ]]; then
            return $__CFG_FALSE
        fi
        : $(( __CFG_ITERATOR++ ))
    done
    return $__CFG_FALSE
}

cfg_clean_up() {
    __CFG_FILE=()
    __CFG_ITERATOR=0
    return $__CFG_TRUE
}

#cfg_read_file 'etc/updates.cfg'
#str=""
#while cfg_get_next_parameter parameter; do
#    str="$parameter="
#    while cfg_get_next value; do
#        str="$str$value,"
#    done
#    echo "$str"
#done