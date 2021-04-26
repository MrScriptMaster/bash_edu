[ ! -z "$_LIB_GPB_PREFIX" -a ! -z "$_LIB_GPB_VERSION" ] &&
    {
        echo "Error: ${BASH_SOURCE##*/}:${BASH_LINENO[1]}: double library importing."
        exit 129
    }

readonly _LIB_GPB_PREFIX='gpb'
readonly _LIB_GPB_VERSION='0.9'

declare -r GPB_CODE_SAVE_CURSOR="\033[s"
declare -r GPB_CODE_RESTORE_CURSOR="\033[u"
declare -r GPB_CODE_CURSOR_IN_SCROLL_AREA="\033[1A"
declare -r GPB_COLOR_FG="\e[30m"
declare -r GPB_COLOR_BG="\e[42m"
declare -r GPB_COLOR_BG_BLOCKED="\e[43m"
declare -r GPB_RESTORE_FG="\e[39m"
declare -r GPB_RESTORE_BG="\e[49m"
declare -ri GPB_STAT_LENGTH=9
SPINSTR='|/-\'
GPB_IS_BUILT="false"

gpb_setup_scroll_area() {
    [[ $GPB_IS_BUILT == "false" ]] || return
    local lines=$(tput lines)
    let lines=$lines-1
    echo -en "\n"
    echo -en "$GPB_CODE_SAVE_CURSOR"
    echo -en "\033[0;${lines}r"
    echo -en "$GPB_CODE_RESTORE_CURSOR"
    echo -en "$GPB_CODE_CURSOR_IN_SCROLL_AREA"
    gpb_draw_status_line ''
    tput civis
    GPB_IS_BUILT="true"
}

gpb_destroy_scroll_area() {
    [[ $GPB_IS_BUILT == "true" ]] || return
    lines=$(tput lines)
    echo -en "$GPB_CODE_SAVE_CURSOR"
    echo -en "\033[0;${lines}r"
    echo -en "$GPB_CODE_RESTORE_CURSOR"
    echo -en "$GPB_CODE_CURSOR_IN_SCROLL_AREA"
    gpb_clear_status_line
    echo -en "\n\n"
    SPINSTR='|/-\'
    tput cnorm
    GPB_IS_BUILT="false"
}

gpb_clear_status_line() {
    [[ $GPB_IS_BUILT == "true" ]] || return
    local lines=$(tput lines)
    let lines=$lines
    echo -en "$GPB_CODE_SAVE_CURSOR"
    echo -en "\033[${lines};0f"
    tput el
    echo -en "$GPB_CODE_RESTORE_CURSOR"
}

gpb_draw_status_line() {
    [[ $GPB_IS_BUILT == "true" ]] || return
    local text=$1
    local lines=$(tput lines)
    let lines=$lines
    echo -en "$GPB_CODE_SAVE_CURSOR"
    echo -en "\033[${lines};0f"
    tput el
    gpb_print_bar_text "$text"
    echo -en "$GPB_CODE_RESTORE_CURSOR"
}

gpb_print_bar_text() {
    [[ $GPB_IS_BUILT == "true" ]] || return
    local custom_line=$1
    local temp=${SPINSTR#?}
    time_line=$(date +%X)
    printf -v line '%s (%c)  %s' "${time_line}" "$SPINSTR" "$custom_line"
    SPINSTR=$temp${SPINSTR%"$temp"}
    echo -ne "${line}"
}
