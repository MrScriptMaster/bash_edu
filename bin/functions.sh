#!/bin/bash

##### ФУНКЦИИ #####

printf "##### FUNCTIONS #####\n"
# ------ Проблема ключевого слова function ------
# Такой синтаксис был в Ksh. Его поддерживают все оболочки, которые
# унаследовали синтаксис Ksh, в том числе и Bash.
# Не используйте этот синтаксис, если вам нужны POSIX-совместимые
# сценарии.

# НЕ РЕКОМЕНДУЕТСЯ НО ДОПУСТИМО, так как плохо переносимо
# Здесь фигурные скобки это часть синтаксиса, т.е. они обязательны.
function ksh_style { echo "Called $FUNCNAME function"; }
ksh_style

# ПОРТИРУЕМО для POSIX-совместимых оболочек и для Sh-совместимых оболочек.
# Здесь скобки это блок кода, так как инструкция не является COMPOUND командой (см. след. пример).
posix_style_1() { echo "Called $FUNCNAME function"; }
posix_style_1

posix_style_2() for i in 1 2 3; do echo $i; done
posix_style_2

# Последнее перенаправление относится ко всей функции, а не к циклу.
# Оно сработает, когда функция будет вызвана
posix_style_3_1() for i in 1 2 3; do echo $i; done 2>&1
posix_style_3_1

# Эта функция эквивалента posix_style_3_1.
posix_style_3_2() { for i in 4 5 6; do echo $i; done } 2>&1
posix_style_3_2

# НЕ РЕКОМЕНДУЕТСЯ
# Смешанный стиль воспринимается Bash одинаково с вышеприведенными, но не гарантируется, что он будет
# так же одинаково интерпретироваться в других оболочках.
function mesh_style() { echo "Called $FUNCNAME function"; }
mesh_style

# ------ Интересные способы использования функций ------

# Функции можно вкладывать
echo "PID: $$"
outer() {
    echo "Called $FUNCNAME function. PID: $$";
    inner() {
        echo "Called $FUNCNAME function";       
    }
}
# Пока функция outer() не вызовется хотя бы один раз, то функции inner()
# не существует.
inner || true    # ОШИБКА: функция inner не объявлена
outer            # Теперь функция inner() объявлена, так как парсер прошел по телу outer().
inner

# Таким образом у вас есть некоторый простор для метапрограммирования в Bash.
if [[ $? -eq 0 ]]; then
    call_me() { echo "Called $FUNCNAME function: realization 1"; }
else
    call_me() { echo "Called $FUNCNAME function: realization 2"; }
fi
# Какая реализация будет вызывана?
call_me
#
# Функцию можно деинициализировать в любой момент.
unset -f call_me
call_me || true   # ОШИБКА: функции больше не существует.
#
# Запросить все объявленные функции можно с помощью declare.
echo "All defined functions:"
OLDIFS=$IFS
IFS='{'
for funcname in $(declare -f); do
    found=$(echo "$funcname" | grep "^.*()[[:space:]]*")
    [[ -z $found ]] || echo "$found"
done
IFS=$OLDIFS
unset OLDIFS
#
# Если функция объявлена, то declare -f <function_name> вернет ее объявление.
echo "Should be empty: $(declare -f call_me)"
echo "$(declare -f outer)"