#!/bin/bash

[ ! -z "$_LIB_THR_PREFIX" -a ! -z "$_LIB_THR_VERSION" ] &&
    {
        echo "Error: ${BASH_SOURCE##*/}:${BASH_LINENO[1]}: double library importing."
        exit 129
    }

readonly _LIB_THR_PREFIX='thr'
readonly _LIB_THR_VERSION='0.9'

# Compatible with Bash 4 only.
[[ -n "$BASHPID" ]] ||
    {
        echo "Error: ${BASH_SOURCE##*/}:${BASH_LINENO[1]}: Library '$_LIB_THR_PREFIX-$_LIB_THR_VERSION' is not supported by your Bash: $BASH_VERSION."
        exit 129
    }

declare -a __THR_SPAWNED_SWARM=()
_THR_PIPE='jghjYGa8.pipe'
readonly _THR_PIPE_PREFIX="/tmp"
readonly _THR_PIPE_PATH="$_THR_PIPE_PREFIX/$_THR_PIPE"
readonly _IN_PIPE_PREFIX="$_THR_PIPE_PREFIX/in_pipe"

thr_last_in_swarm() {
    [[ ${#__THR_SPAWNED_SWARM[@]} -eq '0' ]] && printf "" && return 1
    printf "${__THR_SPAWNED_SWARM[${#__THR_SPAWNED_SWARM[@]}-1]}"
    return 0
}

thr_kill_swarm() {
    [[ ${#__THR_SPAWNED_SWARM[@]} -ne '0' ]] || return 1
    kill -9 ${__THR_SPAWNED_SWARM[@]} 2>&1 >/dev/null
}

thr_add_to_swarm() {
    __thr_swarm_queue() {
        local routine_name=$1
        local feedback_pipe=$2
        (__thr_swarm_run "$@") &
        [[ $? -eq '0' ]] || return 1
        if [[ $! -ne '0' ]]; then
            while :; do
                local line
                if read line <$feedback_pipe; then
                    __THR_SPAWNED_SWARM+=($line)
                    break
                fi
            done
            return 0
        fi
        return 1
    }
    __thr_swarm_run() {
        local routine_name=$1
        shift
        local pipe=$1
        shift
        [[ -p $pipe ]] || return 16
        echo "$BASHPID" >$pipe
        $routine_name "$@"
    }
    [[ $# -ne 0 ]] || return 1
    local rc
    local routine="$1"
    shift
    local pipe="$_THR_PIPE_PATH"
    if [[ ! -p $pipe ]]; then
        mkfifo "$pipe"
        rc=$?
    fi
    [[ $rc -eq '0' ]] && __thr_swarm_queue "$routine" "$pipe" "$@"
}

thr_join_to_swarm() {
    local delay=0.75
    local counter=0
    local is_empty='false'
    [[ -n $(declare -f "__thr_join_to_swarm_before") ]] && __thr_join_to_swarm_before
    while [[ ${#__THR_SPAWNED_SWARM[@]} -ne "0" ]]; do
        counter=0
        [[ -n $(declare -f "__thr_join_to_swarm_before_before") ]] && __thr_join_to_swarm_before_before
        for task in "${__THR_SPAWNED_SWARM[@]}"; do
            if [[ -n "$(ps -e --sort cmd --format pid | awk '{print $1}' | grep "^${task}$")" ]]; then
                [[ -n $(declare -f "__thr_join_to_swarm_event") ]] && __thr_join_to_swarm_event "$task" 'tick'
            else
                [[ -n $(declare -f "__thr_join_to_swarm_event") ]] && __thr_join_to_swarm_event "$task" 'stop'
                unset "__THR_SPAWNED_SWARM[$counter]"
            fi
            # Known Issue
            [[ $counter -eq 0 && ! -n ${__THR_SPAWNED_SWARM[$counter]} ]] && is_empty='true' && break
            : $((counter += 1))
        done
        [[ $is_empty == 'true' ]] && break
        [[ -n $(declare -f "__thr_join_to_swarm_after_after") ]] && __thr_join_to_swarm_after_after
        sleep $delay
    done
    [[ -n $(declare -f "__thr_join_to_swarm_after") ]] && __thr_join_to_swarm_after
    __THR_SPAWNED_SWARM=()
    return 0
}

#
# IMPORTANT: Use 'thr_join_to_*' functions only for subshells.
#
# Example:
#        thr_join_to_1 "$!"
#
thr_join_to_1() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    local line
    local line_length
    tput civis
    while [[ -n "$(ps a | awk '{print $1}' | grep $pid)" ]]; do
        local temp=${spinstr#?}
        printf -v line " [%c]  " "$spinstr"
        line_length=${#line}
        printf "%s" "$line"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf -v line '%*s' ${line_length}
        line=${line// /'\b'}
        printf "$line"
    done
    tput el
    tput cnorm
}

thr_join_to_2() {
    local pid=$1
    local custom_line=${2:-}
    local delay=0.75
    local spinstr='|/-\'
    local time_line
    local line
    local line_length
    tput civis
    while [[ -n "$(ps a | awk '{print $1}' | grep $pid)" ]]; do
        local temp=${spinstr#?}
        time_line=$(date +%X)
        printf -v line ' %s (%c)  %s' "${time_line}" "$spinstr" "$custom_line"
        line_length=${#line}
        printf "%s" "${line}"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf -v line '%*s' ${line_length}
        line=${line// /'\b'}
        printf "$line"
    done
    tput el
    tput cnorm
}

#
# Read pipe and wait for data.
#
# IMPORTANT: This is blocking operation.
#
thr_wait4data() {
    local reading_pipe=$1
    [[ -p $reading_pipe ]] || {
        echo -n ""
        return 1
    }
    local line
    while :; do
        if read line <$reading_pipe; then
            break
        fi
    done
    echo -n "$line"
    return 0
}

thr_prepare_pipes() {
    mkfifo "$_IN_PIPE_PREFIX.${BASHPID}"
}

thr_remove_pipes() {
    rm -f "$_IN_PIPE_PREFIX.${BASHPID}"
}

thr_send_to_pipe() {
    local pipe=$1
    local message=$2
    [[ -p $pipe ]] || return 1
    [[ -n $message ]] || return 2
    echo "$message" >$pipe
    return 0
}
