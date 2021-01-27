#!/bin/bash
#
# Хорошей практикой является общий комментарий в начале сценария, в котором
# следует описать по крайней мере его назначение. Используйте ширину колонки
# в 80 или 120 символов. Это позволит открывать файл сценария в консольных
# редакторах и на небольших мониторах.
#  
# Опционально можно указать:
#   1. Автора и адрес электронной почты.
#   2. Сведения о лицензии.
#
# -----------------------------
#   СОГЛАШЕНИЕ ПО РАСШИРЕНИЯМ
# -----------------------------
# Используйте расширение *.sh для сценариев. Иногда расширение можно опускать,
# но только в сценариях, обычно, когда они размещаются вместе с бинарными файлами
# других утилит.
# Для библиотек функций используйте всегда расширение либо *.bash, либо *.sh.
#
# ------------------------
#   СОГЛАШЕНИЕ ПО ИМЕНАМ
# ------------------------
# Традиционно имена для глобальных переменных пишутся исключительно в верхнем 
# регистре. Имена должны быть осмысленными (принцип самодокументированности).
# Для POSIX-оболочек все глобальные переменные рекомендуется делать константными,
# если их значения ни разу за сценарий не изменяются. Этим самым вы отражаете
# свои намерения.
# 
# readonly CONST_USR_INCLUDE_PATH='/usr/include'
# 
# В библиотеках функций используйте в именах глобальных переменных символ нижнего
# подчеркивания, чтобы предотвратить возможное пересечение по именам.
# 
# readonly __CONST_USR_INCLUDE_PATH='/usr/include'
# 
# Имена локальных переменных следует писать исключительно в нижнем регистре. 
# 
# Для имен функций существует два подхода. Первый подход похож на тот, что 
# принят в языке C, т.е. имена пишутся исключительно в нижнем регистре.
# Для библиотек рекомендуется использовать подход, взятый у языка С++, когда
# сначала пишется пространство имен, а затем имя функции, например
# 
# Module::function() { ...; }
# 
# Разумеется в языке командной оболочки никаких пространств имен нет, но такой
# подход исключит потенциальное пересечение по именам.
# Также такой подход рекомендуется применять для функций сценариев, которые
# потенциально могли бы быть вынесены в библиотеку.
# 
# Если вы не будете выносить функции в библиотеку, то по крайней мере функции,
# связанные одной темой, следует объединять общим префиксом.
# 
# gl_init() { ...; }
# gl_cleanup() { ...; }
# 
# --------------------------------
#   ОБЩИЙ СТИЛЬ ПРОГРАММИРОВАНИЯ
# --------------------------------
# Стиль для коротких одноразовых сценариев ("однострочечников") может быть
# грубым, ведь скорее всего такой сценарий будет написан на один раз и вкладывать
# много труда в него не разумно.
# Но если сценарий большой и разделяется многими программистами, то следует последовательно
# придерживаться одного стиля (по крайней мере) в пределах файла.
# Общие рекомендации:
#   - Если сценарий имеет опции, то копируйте Unix-style CLI интерфейс
#       [команда] [короткие опции|длинные опции|переключатели] [позиционно-независимые параметры]
#     -- короткие опции или переключатели: -a -b -abc
#     -- короткие опции с аргументами: -а value
#     -- длинные переключатели: --verbose
#     -- длинные опции с аргументом: --file=path/to/file.txt
#   - Имейте usage() функцию, закрепленную за опциями -h или --help, которая
#     печатает короткий синтаксис сценария.
#   - Рекомендуется использовать функциональный подход (см. пример ниже) к программированию.
#     При таком подходе у вас есть функция main(), которую можно написать в любом месте файла, в том
#     числе в его начале.
#     Преимущества:
#       -- обход ограничения отсутствия опережающего определения в языках командных оболочек;
#       -- упрощает рефакторинг кода, так как, как правило, переписывается только несколько
#          изолированных функций, не влияющих на оставшийся код;
#       -- улучшает читаемость кода, так как обычно имена функций и имена переменных
#          самодокументируют код.
#
################################################################################
## ВНИМАНИЕ!
## Следующие примеры не являются правилами. Они просто демонстрируют хорошие
## практики.
################################################################################

#######################################
# Глобальные переменные этого сценария
#######################################
declare -ri SUCCESS=0
readonly VERSION='script-1.0'
readonly _SOURCE_DIR=$(dirname "$(readlink -f ${BASH_SOURCE[0]})")
VERBOSE=0

#######################################
# Обертка для импорта библиотек.
# 
# import [required] <lib-name> ...
# Аргументы:
#     required    Прерывает исполнение, если такой библиотеки нет.
#     <lib-name>  Подключаемые библиотеки, разделенные пробелом.
#######################################
import() {
    [[ $# -ne 0 ]] || return 0
    local is_required=0
    if [[ $1 == 'required' ]]; then
        is_required=1
        shift
    fi
    for lib_name; do
        [[ ! -f $lib_name && $is_required -eq 1 ]] \
            && printf "$FUNCNAME:${BASH_LINENO[0]}: Error: Can't import \"%s\" (not exists)\n" "$lib_name" \
            && exit 254
        [[ -f $lib_name ]] && source "$lib_name"
    done
    return 0
}

#######################################
# Подключение библиотек
# Примечание:
#   Обычно файлы с библиотеками размещают на том же уровне, что и сценарий,
#   либо во вложенных каталогах относительно позиции сценария. Рекомендуется
#   использовать регулярный префикс из позиции BASH_SOURCE для позиционно-независимого
#   включения. Позиция подключения библиотек важна. Обычно библиотеки подключают в 
#   самом начале сценария.
####################################### 
import required "${_SOURCE_DIR}/validation.bash" "${_SOURCE_DIR}/dummy_lib.bash"
import "${_SOURCE_DIR}/not_exists.bash"      # Импорт несуществующей библиотеки (допустимо, но здесь только для примера)
unset -f import
#######################################
# Печатает строку с синтаксисом
#######################################
usage() {
printf "Usage:
    $0 [options] args

    What purpose of this script.

    Options:
        -h
            Display usage information.

        -v
            Display utility version.

        -f <file-path>
            Input file path.

        --verbose
            Enable verbose mode.

        --force
            Force all actions.

        --out-file=<file-path>
            Path to the output file.

        --number=<number>
            Input number.

"
    return 0
}

#######################################
# Обрабатывает флаги
#######################################
FILE_PATH=''
OUT_ARG=''
NUMBER=''
ARG_TAIL=''
IS_FORCED=0
process_flags() {
    # Если вам нужно обрабатывать только короткие флаги,
    # то всегда используйте встроенную команду getopts.
    # Иначе программируйте обработку всех опций вручную.
    # Здесь показаны оба варианта. На практике, если у вас
    # длинных опций много больше коротких, то преимущества
    # getopts не такие значительные.
    local long_opts
    local option
    local exp
    while getopts ':hf:v' flag; do
        case "${flag}" in
            v)  Logger::log -i "Version: ${VERSION}"
                ;;
            f)  FILE_PATH="${OPTARG}"
                ;;
            h)  usage
                die $SUCCESS
                ;;
            \?) 
                option="$(eval echo "\$${OPTIND}")"
                # Известные длинные опции без аргументов
                if [[ "$option" == '--verbose' \
                      || "$option" == '--force' ]]; then
                    long_opts="$option $long_opts"
                    shift
                    continue
                fi
                # Известные длинные опции с аргументами
                if [[ "$option" =~ --out-file=.* \
                        || "$option" =~ --number=.* ]]; then
                    long_opts="$option $long_opts"
                    shift
                    continue
                fi
                if [[ -z $option ]]; then
                    option="-$OPTARG"
                fi
                if [[ $OPTIND -eq $# ]]; then
                    ARG_TAIL="$option"
                    shift
                    continue
                fi
                Handler::error --invalid-option "$option"
                usage
                return 1
                ;;
            :)
                [[ $OPTARG == 'f' ]] && exp='<file-path>'
                Handler::error --required-arg "-$OPTARG" "$exp"
                return 1
                ;;
        esac
    done
    shift $(( OPTIND-1 ))
    [[ ! -z $@ ]] &&  ARG_TAIL="$@"
    process_long_flags $long_opts
    return $?
}

process_long_flags() {
    while [[ -n "$1" ]]; do
        case "$1" in
            --verbose) VERBOSE=1 ;;
            --force) IS_FORCED=1 ;;
            --out-file=*) OUT_ARG="$(printf "%s" "$1" | cut -d'=' -f2)"  ;;
            --number=*) NUMBER="$(printf "%s" "$1" | cut -d'=' -f2)" ;;
        esac
        shift
    done
    return 0
}

#######################################
# Функция main
#######################################
main() {
    local START=$(date +%s.%N)
    process_flags "$@" || die 1
    [[ $VERBOSE -eq 0 ]] || say -i "Verbose is on"
    [[ -n "$FILE_PATH" ]] && say -i "file_path=$FILE_PATH"
    [[ -n "$OUT_ARG" ]] && say -i "out-file=$OUT_ARG"
    [[ $IS_FORCED -eq 0 ]] || say -i "Force is on"
    [[ ! -z $NUMBER ]] && { val_is_dec_number "$NUMBER" || die 1 "Invalid number: $NUMBER"; } \
        && say "(Entered number) /$NUMBER/"
    val_is_not_empty_string "$ARG_TAIL" \
        && say "(Tail of parameter line) /$ARG_TAIL/"
    local END=$(date +%s.%N)
    START="$(printf "~%06.6f" "$(echo "$END - $START" | bc)")"
    say -i "Completed. Duration: $START (s)"
    exit $SUCCESS
}

#######################################
# Завершает сценарий с указанным кодом
# ошибки.
# Аргументы:
#    [number]    код ошибки.
#                По умолчанию 1.
# 
#    [message]   сообщение перед
#                выходом.
#######################################
die() {
    [[ $# -eq 0 ]] && exit 1
    local exit_code=$1
    local message=$2
    [[ ! -z $message ]] \
        && Logger::log -e "$message"
    exit $exit_code
}

#######################################
# Логгирует сообщение.
# Глобальные переменные:
#    __LOGGER_FORMAT
# Аргументы:
#   [-i|-w|-e] "message"
#    "message"
#
#   -i   Логгирует информационное сообщение
#   -w   Логгирует предупреждение
#   -e   Логгирует ошибку
#
#######################################
[[ -z $__LOGGER_FORMAT ]] && readonly __LOGGER_FORMAT='%d %s [%s]: %s'
Logger::log() {
    [[ $# -ne 0 ]] || return 1
    local flag='-i'
    local message=''
    [[ $# == 1 ]] && message=$1
    [[ $# == 2 ]] && flag=$1
    [[ $# == 2 ]] && message=$2
    case $flag in
        -i|--info) Logger::log_info "$message" ;;
        -w|--warning) Logger::log_warn "$message" ;;
        -e|--error) Logger::log_err "$message" ;;
        *) Logger::log_info "$message" ;;
    esac
    return 0
}

Logger::log_err() {
    >&2 printf "$__LOGGER_FORMAT\n" $$ "$(date --rfc-3339='ns')" 'ERROR' "$1"
}

Logger::log_warn() {
    >&2 printf "$__LOGGER_FORMAT\n" $$ "$(date --rfc-3339='ns')" 'WARNING' "$1"
}

Logger::log_info() {
    printf "$__LOGGER_FORMAT\n" $$ "$(date --rfc-3339='ns')" 'INFO' "$1"
}

#######################################
# Перехватчик ожидаемых ошибок.
# Печатает ошибки в лог.
# Аргументы:
#   --wrong-arg-number <number>    Неверное число аргументов
#   --not-a-number <number>        Не число
#   --invalid-value <actual-value> [<expectations>]
#       Неожиданное значение.
#   --invalid-option <actual-value> [<expectations>]
#       Неожиданное значение.
#######################################
Handler::error() {
    [[ $# -ne 0 ]] || return 1
    local expectations
    local exps
    local wrong_value
    case $1 in
        --required-arg)
            shift
            wrong_value=${1}
            shift
            expectations=${1}
            Logger::log -e "Required argument for \"$wrong_value\": $expectations"
            ;;
        --wrong-arg-number)
            shift
            Logger::log -e "Passed wrong number of arguments (expected $1)"
            ;;
        --not-a-number)
            shift
            Logger::log -e "\"$1\" is not a number"
            ;;
        --invalid-value)
            shift
            wrong_value=${1}
            shift
            expectations=${1}
            exps=
            [[ ! -z $expectations ]] && exps=" (Expectations: \"$expectations\")"
            Logger::log -e "Invalid value: \"$wrong_value\".$exps"
            ;;
        --invalid-option)
            shift
            wrong_value=${1}
            shift
            expectations=${1}
            exps=
            [[ ! -z $expectations ]] && exps=" (Expectations: \"$expectations\")"
            Logger::log -e "Invalid option: \"$wrong_value\".$exps"
            ;;
    esac
    return 0
}

[[ -z $__SAY_FORMAT ]] && __SAY_FORMAT='%s [%s]: %s'
say() {
    [[ $# -ne 0 ]] || return 0
    local flag=''
    local message=''
    [[ $# == 1 ]] && message=$1
    [[ $# == 2 ]] && flag=$1
    [[ $# == 2 ]] && message=$2
    case "$flag" in
        -i|--info)
            printf "$__SAY_FORMAT\n" "$(date --rfc-3339='ns')" 'INFO' "$message"
            ;;
        -w|--warning)
            printf "$__SAY_FORMAT\n" "$(date --rfc-3339='ns')" 'WARNING' "$message"
            ;;
        -e|--error)
            printf "$__SAY_FORMAT\n" "$(date --rfc-3339='ns')" 'ERROR' "$message"
            ;;
        *)
            printf "%s\n" "$message"
            ;;
    esac
    return 0
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"