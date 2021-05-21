#!/bin/bash
TEMP_FILE=$(mktemp -u /tmp/${0##*/}.XXXXXXXX)
TEMP_FILE_1=$(mktemp -u /tmp/${0##*/}.XXXXXXXX)
TEMP_FILE_2=$(mktemp -u /tmp/${0##*/}.XXXXXXXX)
trap '{ rm -f "$TEMP_FILE" "$TEMP_FILE_1" "$TEMP_FILE_2"; }' EXIT SIGKILL
echo "line 1" > "$TEMP_FILE"
echo "line 2" >> "$TEMP_FILE"
echo -n "line 3" >> "$TEMP_FILE"
echo -e "line 1\ttab\tline 1" > "$TEMP_FILE_1"
echo "    line 2    " >> "$TEMP_FILE_1"
echo "" >> "$TEMP_FILE_1"
echo -e "\t" >> "$TEMP_FILE_1"
echo "line 5" >> "$TEMP_FILE_1"
echo -n "     " >> "$TEMP_FILE_1"
echo "parameter_1 = value_1" > "$TEMP_FILE_2"
echo "parameter_2 = value1;value2;value3" >> "$TEMP_FILE_2"
echo "parameter_3 = par1:val1;par2:val2;par3:val3" >> "$TEMP_FILE_2"
#
# IFS - Input Field Separaton - является переменной окружения Bash и
# определяет три символа, которые интерпретируются многими командами
# как разделители полей символьного потока. По умолчанию в IFS
# записано три символа в указанном порядке: 0x20 (пробел), 0x09 (табуляция \t) 
# и 0x0a (перевод строки \n).
echo -n "$IFS" | xxd -cols 1
# По умолчанию команда read использует именно \n (вообще она использует просто последний символ) как
# разделитель строк, если переменная не перезаписана. Если переменная
# не определена, то всегда используется 0x20 как разделитель полей для всего.
#
OLD_IFS=$IFS
[[ $OLD_IFS == $IFS ]] && echo "IFS has default value"
ifs_test() {
    # Внимательно следите за переменной IFS, так как бесконтрольное
    # ее измененеи может приводить к ошибкам.
    unset IFS
}
ifs_test
[[ $OLD_IFS == $IFS ]] || echo "IFS has been changed"
IFS=$OLD_IFS
#
# Основная проблема функции read в том, что она опускает последнюю
# строку в файле. Это происходит потому, что функция по умолчанию
# опирается только на третий символ переменной IFS, чтобы отделять
# строки друг от друга, а как известно файлы Unix не имеют
# каких-либо специальных символов в конце файла.
#
echo "---- Original file --------"
cat "$TEMP_FILE" # Команда cat реализована правильно, поэтому она выведет файл с точностью до
                 # последнего символа.
echo # В файле нет перевода строки в последней строке.
# Демонстрация пропуска последней строки.
echo "---- Omission last line ---"
while read -r line; do
    printf "%s\n" "$line"
done < "$TEMP_FILE"
# Решить эту проблему можно несколькими путями.
# 
# Первый способ заключается в проверке переменной, в которую read пишет результат.
# Так, с большой вероятностью последняя строка будет не пустой.
echo "---- Solution #1 ----------"
while read -r line || [[ -n $line ]]; do
    printf "%s\n" "$line"
done < "$TEMP_FILE"
echo "---- Original file 1 ------"
cat "$TEMP_FILE_1"
echo # В файле нет перевода строки в последней строке.
# Однако, первое решение работает не совсем корректно, если последняя строка
# состоит из пробелов или если есть пробелы и табуляция в начале и в конце строки.
# Если пустые строки объективно нужно игнорировать, то это решение приемлемо.
#
# Интерпретатор Bash удаляет лидирующие и завершающие пробелы и табуляцию, что в общем
# в большинстве ситуаций является полезным. Такое удаление связано с тем,
# что при присваивании переменной значения, интерпретатором неявно обрезаются все
# начальные и конечные символы, записанные в первой и второй позиции переменной IFS.
echo "---- Solution #1 ----------"
while read -r line || [[ -n $line ]]; do
    printf "%s\n" "$line"
done < "$TEMP_FILE_1"
# Можно вызывать grep, чтобы запретить игнорирование пустых строк,
# тогда решение получается более корректное, но все равно отличается от команды cat.
echo "---- Solution #2 ----------"
while read -r line; do
    printf "%s\t(length=%d)\n" "$line" "$(expr length "$line")"
done < <(grep "" "$TEMP_FILE_1")
echo "---------------------------"
# Чтобы полностью повторить вывод команды cat, необходимо передать вывод
# команды grep и временно затереть первые два символа переменной окружения
# IFS. Будьте осторожны при редактировании IFS на нулевом уровне сценария,
# так как весь последующий код будет основан на измененной IFS.
readonly OLD_IFS="$IFS" # Сохраняем старое значение
IFS=$'\n'
echo -n "$IFS" | xxd -cols 1
echo "---- Solution #3 ----------"
while read -r line; do
    printf "%s\t(length=%d)\n" "$line" "$(expr length "$line")"
done < <(grep "" "$TEMP_FILE_1")
[[ $IFS == $OLD_IFS ]] && echo "You won't see this line."
IFS="$OLD_IFS"
# Обратите внимание на следующий прием переопределения IFS. Циклы также копируют
# переменные окружения, поэтому вы можете таким образом переопределить IFS
# локально для цикла.
echo "---- Solution #3 (like the cat) ------"
while IFS=$'\n' read -r line; do
    printf "%s\n" "$line"
done < <(grep "" "$TEMP_FILE_1")
echo "---------------------------"
[[ $IFS == $OLD_IFS ]] && echo "IFS has default value"
# 
# Вы можете реализовать многоуровневый парсинг, меняя в нужный момент IFS. Главное помнить, что
# стандартный поток ввода может читать только один цикл - самый внешний.
echo
echo "---- Configuration --------"
cat "$TEMP_FILE_2"
echo "--- Solution 1 ------------"
while IFS="$' '$'='$'\n'" read -r lhs rhs <&4; do # Меняем IFS: режем пробелы и символы равно и читаем файл построчно
    echo "Parameter: '$lhs'"
    # Парсим строки справа от равно
    while IFS=";" read -r vv1 vv2 vv3; do
        for vvv in $vv1 $vv2 $vv3; do
            echo "  Value: $vvv"
            while IFS=":" read -r lhs1 rhs1; do
                echo "    Sub parameter: $lhs1"
                echo "    Sub value: ${rhs1:-not defined}"
            done <<< $vvv
        done
    done <<< $rhs
done 4< "$TEMP_FILE_2" # Перенаправляем вход в другой поток, чтобы не занимать дескриптор 0
# Более универсальный подход
echo "--- Solution 2 -------------"
while IFS="$' '$'='$'\n'" read -r lhs rhs <&4; do
    echo "Parameter: '$lhs'"
    while [[ -n $rhs ]]; do
        IFS=';' read -r begin tail <<< "$rhs"
        IFS=':' read -r subparpam subvalue <<< "$begin"
        [[ -z $subvalue ]] && echo -n "   Value: "
        [[ -n $subvalue ]] && echo -n "   Sub param: "
        echo "$subparpam"
        [[ -n $subvalue ]] && echo "   Sub value: $subvalue"
        rhs=$tail
    done
done 4< "$TEMP_FILE_2"
echo "----------------------------"
[[ $IFS == $OLD_IFS ]] && echo "IFS has default value"
#
# Однако, как показано ниже, при работе с автоматическими дескрипторами
# такой проблемы не возникает.
#
# Опция -r функции read служит, чтобы запретить интерпретацию
# входящих символов '\'. Опция -r является единственной портируемой
# опцией команды read.
while read line; do
    echo -e "$line"
done <<< "line 1 \n
line 2 
line 3"
# Сравните с (\n будет передана как есть)
while read -r line; do
    echo -e "$line"
done <<< "line 1\n
line 2
line 3
"
#
# Команда read по умолчанию читает стандартный поток ввода. Вы можете пользоваться
# этим, чтобы писать интерпретаторы.
#
interpreter() {
    # Наш интерпретатор понимает две команды put и get_random.
    # Первая работает как echo, вторая печатет случайное число.
    while read -r line; do
        # Мы предполагаем, что за командой всегда следует пробел.
        case "$line" in
            put*)
                echo "${line#*[[:space:]]}"
                ;;
            get_random)
                echo $RANDOM
                ;;
            *)
                [[ -z $line ]] && continue
                echo "Warning: unknown command: ${line%%[[:space:]]*}"
                ;;
        esac
    done
}
# Передаем нашей функции ввод через автоматический канал.
interpreter <<< \
"put \"Hello, World!\"
get_random
unknown command
put \"Good bye!\""
