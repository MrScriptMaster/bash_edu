#!/bin/bash
#
# Здесь мы рассмотрим подстановки. Подстановкой (expansion)
# называется раскрытие значения выражения с возможным применением к нему
# дополнительных действий, которые зависят от типа подстановки.
# Подстановка выполняется интерпретатором по мере необходимости ("лениво").
# Bash и другие подобные оболочки могут выполнять над подстановкой
# неявные действия, например, перед подстановкой значения переменной, Bash выполняет
# неявное разбиение слов по разделителю IFS, если она (подстановка) не закавычена.
#
# ПОДСТАНОВКА ЗНАЧЕНИЙ ПЕРЕМЕННЫХ
# -------------------------------
# Самый известный тип подстановки. Заключается в подстановке значения переменной
# в месте обращения к ее значению. Подстановка в Bash отличается от того, что в других языках
# высокого уровня принято называть обращением к переменной. Если обращение в других языках
# осуществляется в контексте некоторого выражения, то подстановка в Bash это буквальная подстановка
# того, что хранится в памяти для этой переменной в указанное место сценария.
VARIABLE="value with spaces"
printf $VARIABLE ; echo  # На примере команды printf вы можете убедиться, что без двойных кавычек 
                         # Bash неявно разбивает значение по пробелам. В данном случае
						 # печатается только "value" из-за особенностей команды printf.
for word in $VARIABLE; do  # Цикл состоит из трех итераций, потому что подстановка была
	echo $word             # разбита по пробелам.
done
ANOTHER_VAR=$VARIABLE    # При подстановке во время присваивания, справа от равно ничего не теряется.
printf "$ANOTHER_VAR"    # Тем не менее, если переменная потенциально может хранить пробелы, а разбитие по пробелам
echo                     # не желательно, подстановку нужно закавычивать.

# Подстановки не создают переменные в памяти интерпретатора
[[ -z $EMPTYNESS ]] && echo "At this point EMPTYNESS is not exists in memory. (0)"
$EMPTYNESS      # Пустые подстановки ничего не создают и не портят.
[[ -z $EMPTYNESS ]] && echo "At this point EMPTYNESS is not exists in memory. (1)"
# Но первое явное присваивание заставит интерпретатор выделить память под значение.
EMPTYNESS="value"
[[ -z $EMPTYNESS ]] && echo "At this point EMPTYNESS is not exists in memory. (2)"
unset EMPTYNESS    # Освободит память от значения физически. Это не то же самое, что EMPTYNESS="".
[[ -z $EMPTYNESS ]] && echo "At this point EMPTYNESS is not exists in memory. (3)"
# Пустые переменные никогда не расходуют память физически. Говорят, что она "хранит" NULL.
declare EMPTYNESS=
EMPTYNESS_1=
[[ -z $EMPTYNESS && -z $EMPTYNESS_1 ]] && echo "At this point EMPTYNESS is not exists in memory. (4)"
# Даже если есть подстановка пустой NULL-переменной, в памяти ее нет.
$EMPTYNESS
[[ -z $EMPTYNESS ]] && echo "At this point EMPTYNESS is not exists in memory. (5)"
#
# Оболочка может применить к подстановке сложное действие, используя синтаксис фигурных скобок.
# Это намного ускорит вашу работу. К сожалению, не все такие действия переносимы: большинство являются башизмами.
# Следующие операции с подстановками поддерживаются по меньшей мере в Bash 4.x и выше.
# 
# Простые подстановки
unset -v EMPTYNESS
echo "${EMPTYNESS-"Value is NULL"}" # Если переменная слева никогда не была объявлена
                                    # или хранит NULL, то подставится значение справа
								    # иначе подставится значение $EMPTYNESS.
EMPTYNESS=""
echo "${EMPTYNESS:-"Value NULL or empty"}" # Работает аналогично, но кроме NULL
                                           # также еще берется в расчет пустота.
EMPTYNESS="Not empty"
echo "${EMPTYNESS-"Value is NULL"}"
echo "${EMPTYNESS:-"Value NULL or empty"}"
# Следующие подстановки работают аналогично вышеприведенным, но раскрываемое 
# значение автоматически присваивается переменной, тогда как вышеприведенные
# просто раскрываются в позиции.
unset -v EMPTYNESS
: ${EMPTYNESS="Value"}
echo "EMPTYNESS=$EMPTYNESS"
EMPTYNESS=""
: ${EMPTYNESS:="Value 1"}
echo "EMPTYNESS=$EMPTYNESS"
# Следующие подстановки обычно используются для реализации всяких
# предупреждений.
EMPTYNESS=""
echo "${EMPTYNESS+"Actually, EMPTYNESS is not NULL."}"
EMPTYNESS="text"
echo "${EMPTYNESS:+"Actually, EMPTYNESS is not empty."}"
# Следующие подстановки обычно используются, чтобы выводить ошибки
# о не инициализированных переменных.
# Работает как {:-} и {-}, но в случае не инициализации или пустоты выводит
# предупреждение на терминал, при этом исполнение останавливается. Вы можете
# использовать конвейер, как показано а следующем примере, чтобы обходить это.
unset -v EMPTYNESS
: ${EMPTYNESS?"is NULL"} | true
EMPTYNESS=""
: ${EMPTYNESS:?"is EMPTY"} | true
#
# Работа с регистром слов
#
TEST_STR="sOmE_Text@123"
echo "(Original test)" ${TEST_STR}
echo "(To upper case)" ${TEST_STR^^}                        # Bash 4.x и выше
echo "(To upper case for first letter)" ${TEST_STR^}        # Bash 4.x и выше
echo "(To lower case)" ${TEST_STR,,}                        # Bash 4.x и выше
TEST_STR_1=${TEST_STR^^}
echo "(To lower case for first letter)" ${TEST_STR_1,}   # Bash 4.x и выше
echo "(Reverse case for every letter)" ${TEST_STR~~}     # Bash 4.x и выше
echo "(Reverse case for first letter)" ${TEST_STR~}      # Bash 4.x и выше
#
# Для массивов также все прекрасно работает.
declare -a array=(val1 Val2 vAL3 VAL4 VaL5 vAl6)
echo "${array[@]} original"
echo "${array[@]^^} ^^"
echo "${array[@]^} ^"
echo "${array[@],,} ,,"
echo "${array[@],} ,"
echo "${array[@]~~} ~~"
echo "${array[@]~} ~"
#
# Работа с подстроками
#
echo "Display all variables with PREFIX='TEST': ${!TEST*}"
echo "Display all variables with PREFIX='TEST': ${!TEST@}"
echo "Number of letters in TEST_STR: ${#TEST_STR}"
echo "Substring (from 0 symbol get 5 symbols): ${TEST_STR:0:5}"
echo "Display string from 4th symbol: ${TEST_STR:3}"
# Вы можете использовать отрицательные числа, чтобы проходить строку
# с правого края.
echo "Cut off 3 symbols from right edge: ${TEST_STR:0:-3}" # Отсечь три символа справа
# В следующем примере мы захватываем три последних символа через отступ на три
# символа от правого края. Обратите нимание, что пробел перед минусом обязательный.
echo "Display last 3 symbols: ${TEST_STR: -3:3}"
echo "Display last 3 symbols: ${TEST_STR:(-3):3}"
echo "Array size ${#array[@]}"
echo "Size of the second element of the array ${#array[1]}"
# 
# Следующие подстановки удобны при удалении префиксов и суффиксов по шаблону
SOME_PATH="/very/long/path/to/archive.tar.gz"
echo "(Original path)  $SOME_PATH"
echo "(Full path to archive) ${SOME_PATH%/*}"
echo "(File name) ${SOME_PATH##*/}"
echo "(Full path without extensions) ${SOME_PATH%%.*}"
echo "(Full path without gz-extension) ${SOME_PATH%.*}"
echo "(Most outer extension) ${SOME_PATH##*.}"
echo "(All extensions) ${SOME_PATH#*.}"
echo "(Replace gz by bz2) ${SOME_PATH%.gz}.bz2"
#
# Замена и удаление подстрок в подстановках
TEST_STR="Very long long string with spaces."
echo "(Original string) $TEST_STR" 
echo "(Replace 'long' by 'short') ${TEST_STR//long/short}"  # Заменить все вхождения 
echo "(Replace 'long' by 'short') ${TEST_STR/long/short}"   # Заменить только первое вхождение 
echo "(Remove 'long' from the text) ${TEST_STR//long }"     # Удалить все вхождения 
echo "(Remove 'long' from the text) ${TEST_STR/long }"      # Удалить только первое вхождение
#
# ПОДСТАНОВКА РЕЗУЛЬТАТА КОМАНДЫ
# ------------------------------
# Подстановка результата команды позволяет подставить вывод терминала вызываемой команды в текущую оболочку.
# При этом вызываемая команда, чей результат мы хотим подставить, будет вызывана в отдельной оболочке.
$(echo "echo "Hello, world!"")  # В данном примере результат команды echo, чей результат мы подставляем,
                                # будет буквально подставлен в эту позицию.
								# Получается, что вызываемая echo печатает другую echo для родительской оболочки.

# В предыдущем примере желательно, чтобы Bash разбил результат по пробелам. В следующем примере запрет этого
# приводит к ошибке.
"$(echo "echo "Hello, world!"")" # Оболочка, интерпретируя подстановку буквально, будет искать команду с
                                 # именем 'echo Hello, world!' (одним словом без кавычек).
#
# СКОБОЧНЫЕ ПОДСТАНОВКИ
# ---------------------
# Скобочные подстановки обычно используются для генерации всевозможных списков,
# особенно, если у элементов есть закономерности. Также эти подстановки используются 
# для генерации аргументов для команд.
# Эти подстановки легко распознать по фигурным скобкам с правилом генерации
# внутри них.
eval echo {element1,element2,element3,element4}    # Список из четырех элементов
eval echo {0..9}                                   # Числовой диапазон 1
eval echo {00..09}                                 # Числовой диапазон 2
eval echo {23..30}                                 # Числовой диапазон 3
eval echo 1.{0..9}                                 # Числовой диапазон 4
eval echo {a..z}                                   # Буквенный диапазон 1
eval echo --{A..F}--                               # Буквенный диапазон 2 (с суффиксами и префиксами)
eval echo {A..Z}{0..9}                             # Комбинация из дипазонов
eval echo {{A..Z},{a..z},{0..9}}                   # Вложенный диапазон
eval echo {john,bill}{0..3}.tar.{bz2,gz}           # Комплексный пример
# В Bash 4 появилась возможность усложнить диапазон за счет инкремента
eval echo {0..20..2}                               # Вывести четные числа от 0 до 20
# Также в Bash 4 по-умному интерпретируется первый префикс
eval echo {0000..20..2}                            # Вывести четные числа от 0 до 20
#
# ТИЛЬДА-ПОДСТАНОВКИ
# ------------------
# Тильда-подстановки используются для подстановки путей к каталогам относительно
# залогинившегося пользователя.
echo "My home directory is" ~            # Подставится домашний каталог текущего пользователя
echo "Current workdir is" ~+             # Подставится текущий рабочий каталог
echo "Previous workdir is" ~-            # Подставится предыдущий рабочий каталог (предпоследний cd ...)
echo "Root workdir is" ~root             # Рабочий каталог пользователя root
echo "Path to 'my_docs' dir is" ~/my_docs   # Путь к директории относительно рабочего каталога текущего пользователя
#
# МАСКРИУЮЩИЕ ПОДСТАНОВКИ (GLOBBING)
# ----------------------------------
# Эти подстановки используются, чтобы обобщить имена файлов. Например, в следующей 
# команде 
#     rm -rf ./*.log
# символ '*' является маскирующей подстановкой. Здесь она обобщает множество имен
# файлов с расширением '.log'. Вопреки распространенному заблуждению, маскирующая
# подстановка поддерживается командной оболочкой, а не самой командой. Команда всегда
# получает только раскрывшийся результат.
# В Bash 4 маскирующими подстановками можно управлять через утилиту 'shopt'.
# Подробнее читайте в
#      man 7 glob
#
# Следующий цикл выведет все файлы с расширением *.sh, которые находятся
# в рабочей директории данного сценария.
for file in *.sh; do
	echo "$file"
done
# В Bash используется 3 класса подстановок:
#      - (звездочка)  *    Означает серию видимых символов, включая пробелы.
#      - (вопрос)     ?    Означает один видимый символ или пробел.
#      - (класс)     [ ]   В целом похож на класс в регулярных выражениях.
echo "Shell script list: " *.sh                 # Вывести все файлы сценариев
echo "File list: " *.[a-z][a-z][a-z]            # Вывести все файлы с расширениями из трех букв
echo "File list: " *.[^y][a-z][a-z]             # Вывести все файлы с расширениями из трех букв, но чтобы
                                                # первой буквой не была 'y' (например yml).
#
# ЧАСТЫЕ ОШИБКИ С ПОДСТАНОВКАМИ
# -----------------------------
# При передаче аргументов в функцию через подстановку, всегда их закавычивайте, кроме случаев, когда
# разбитие вам действительно нужно.
demo() {
	echo ">>> Called $FUNCNAME"
	local i=0
	for arg; do
		echo "$((++i)) $arg"
	done
}
demo "$VARIABLE" $ANOTHER_VAR    # Значение ANOTHER_VAR будет разбито по пробелам. В итоге, если вы ожидаете
                                 # два аргумента, то на самом деле их будет 4:
								 # demo "value with spaces" value with spaces
								 #      ^^^^^^^^^^^^^^^^^^^
								 #        первый аргумент

result=$(demo $VARIABLE $ANOTHER_VAR)  # Не забывайте также ставить кавычки для аргументов вызываемой команды.
echo "----------"
printf "$result\n"  # Вызываемой команде будет передано 6 аргументов.
echo "----------"

# Разные реализации echo.
# В разных оболочках следующая строка может выводиться обрезанной, а может нет.
# Все зависит от реализации echo в оболочке. ВСЕГДА закавычивайте строковые значения с пробелами.
echo $VARIABLE    # НЕ ПЕРЕНОСИМО (иногда echo эмулирует printf)
echo "$VARIABLE"  # ПРАВИЛЬНО