#!/usr/bin/env bash
#
DUMMY_FUNCTION='dummy'
#
# В этом примере мы реализуем автодополнение для несуществующей команды dummy.
# Вот ее синтаксис:
# 
# dummy -+- work ----<  /- export -- <string> -- (--src) -- <source-dir> -- (--file) -- <history-file> --<
#        +- history ----+- import -- <string> -- (-o) -- <output-file> --<
#        |           
#        \- help ----+- work -+--+--<
#                    |- history--|
#                    \- help ----/
#
#
__command_compl() {
    COMPREPLY=()  # Эта переменная используется только если вы регистрируете метод через опцию -F.
    
    local options_level1="work history help"
    local options_history="import export"
    local options_help="work history help"
    local options_import="--src --file"
    
    local current="${COMP_WORDS[COMP_CWORD]}"  # Последнее введенное словов в строке команды

    # На практике удобнее всего определить переменные так:
    # 
    #  local cur_word prev_word
    #  cur_word="${COMP_WORDS[COMP_CWORD]}"
    #  prev_word="${COMP_WORDS[COMP_CWORD-1]}"
    #

    # Автодополнение первого уровня
    if [[ ${COMP_CWORD} == 1 ]]; then
        #
        # Команда compgen генерирует список возможных вариантов на основе того, что пользователь
        # уже написал. Команда сравнивает ввод с вариантами, которые здесь представлены в виде списка
        # после опции -W и формирует новый список с подходящими варинтами для этого ввода. Аргумент '--'
        # подсказывает compgen, где заканчивается список вариантов.
        # Сгенерированные варианты помещаются в специальный массив COMPREPLY, который оболочка выводит,
        # когда вы нажимаете Tab.
        # Когда ввод пользователя однозначно сопоставляется, то возвращается один вариант.
        #
        COMPREPLY=( $(compgen -W "${options_level1}" -- ${current}) )
        return 0
    fi
    # Когда индекс больше единицы, это значит, что пользователь ввел по меньшей мере один аргумент команды.
    case "${COMP_WORDS[1]}" in
        # опция без продолжения
        work)
            COMPREPLY=()
            return 0
            ;;
        # Опция с конечным числом вариантов
        help)
            COMPREPLY=( $(compgen -W "${options_help}" -- ${current}) )
            return 0
            ;;
        # Опция с большим числом синтаксических ответвлений
        history)
            [[ ${COMP_CWORD} == 2 ]] \
                && COMPREPLY=( $(compgen -W "${options_history}" -- ${current}) ) \
                && return 0
            [[ ${COMP_CWORD} == 3 ]] \
                && COMPREPLY=( $(compgen -W "$(ls ~)" -- ${current}) ) \
                && return 0
            case "${COMP_WORDS[2]}" in
                import)
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        --src)
                            COMPREPLY=( $(compgen -d -- ${current}) )
                            return 0
                            ;;
                        --file)
                            COMPREPLY=( $(compgen -f -- ${current}) )
                            return 0
                            ;;
                        *)
                            COMPREPLY=( $(compgen -W "${options_import}" -- ${current}) )
                            return 0
                            ;;
                    esac
                    ;;
                export)
                    [[ ${COMP_WORDS[COMP_CWORD-1]} == "-o" ]] \
                        && COMPREPLY=( $(compgen -f -- ${current}) ) \
                        && return 0
                    COMPREPLY=( $(compgen -W "-o" -- ${current}) )
                    return 0
                    ;;
                *)  ;;
            esac
    esac
    return 0
}
# 
# Чтобы этот пример начал работать, вы должны имортировать этот код в текущий сеанс командной
# оболочки. В самом простом случае вы должны просто написать
#
#    source bash_completion.bash
#    # или
#    . bash_completion.bash
#
# тогда функция complete зарегистрирует в Bash окружении один из обработчиков для нашей 
# несуществующей команды dummy.
# В более сложном случае, когда эта регистрация должна происходить каждый раз при запуске
# оболочки, вы должны разместить подобный сценарий например в /usr/share/bash-completion
# и делать импорт из конфигурационного файла /etc/bash_completion. Однако, если вы например
# пишете автодополнение для какой-то консольной команды, то более удобным способом импортрирования является
# размещение сценария в каталоге /etc/bash_completion.d/, так как это позволит вам 
# написать некоторую логику, независящую от реализации.
# 
# Для одной команды можно определить только один вариант автодополнения, поэтому каждый
# последующий вызов complete перезатрет предыдущий. Мы приводим несколько вариантов только для примера.
# 
complete -r $DUMMY_FUNCTION  2>/dev/null            # Чтобы удалить автодополнение для команды, используйте флаг -r.
complete -W "never now tomorrow" $DUMMY_FUNCTION    # Статическое автодополнение: мы просто перечисляем все возможные варианты, которые
                                                    # могут следовать за командой, т.е. "dummy [never|now|tomorrow]".
complete -C 'printf "hello"' $DUMMY_FUNCTION        # Дополняет команду выводом команды, записанной в аргументе -C.
complete -A user $DUMMY_FUNCTION                    # Вы можете использовать специальную опцию -A для формирования списка дополнений,
                                                    # которые предоставляет оболочка. Например, опция user сформирует список из всех
                                                    # зарегистрированных в системе пользователей.
complete -F $(typeset -f __command_compl) $DUMMY_FUNCTION   # Динамическое автодополнение на основе функции, т.е. вся логика автодополнения определена в функции.
                                                            # ПРИМЕЧАНИЕ: команда в таком виде приведена здесь только для примера. Если вы импортируете
                                                            # сценарий через /etc/bash_completion.d/, то достаточно написать только имя функции
                                                            #     complete -F __command_compl dummy
complete -p $DUMMY_FUNCTION                         # Чтобы посмотреть какая подстановка применяется к команде на текущий момент, 
                                                    # используйте флаг -p.
unset DUMMY_FUNCTION
