#!/bin/bash

# Не используйте команду test в новых сценариях, потому что такая практика сейчас
# считается устаревшей. Для переносимых сценариев используйте только [ ].

sentence="Be liberal in what you accept, and conservative in what you send"
checkme="Be liberal in what you accept, and conservative in what you send"

# Внутри оператора [[ переменные никогда не разбиваются по разделителю, поэтому
# их можно не закавычивать.
if [[ $sentence == $checkme ]]; then
  echo "Matched...!"
else
  echo "Sorry, no match :-("
fi

# Но для оператора [ все переменные обязательно нужно закавычивать, чтобы избежать
# разбивания значения переменной по разделителю (см. ошибку ниже).
if [ "$sentence" == "$checkme" ]; then
  echo "Matched...!"
else
  echo "Sorry, no match :-("
fi

# ОШИБКА: без закавычивания переменные будут разбиты по разделителю и 
# и переданы команде [ как множество аргументов, которые будут неправильно интерпретированы.
if [ $sentence == $checkme ]; then
  echo "Matched...!"
else
  echo "Sorry, no match :-("
fi

# Помните, что для [ и [[ операторы сравнения реализуют лексикографическое сравнение.
[[ "abcd" == "efgh" ]] || echo "FALSE condition"   # В данном случае ни один символ не совпадает в сравниваемых
                                                   # строках, поэтому не равны (условие ЛОЖНО).
[[ "abcd" > "abd" ]] || echo "FALSE condition"     # Лексикографически 'abd' > 'abcd', потому что 'd' > 'c', поэтому условие ЛОЖНО.
[[ 'abd'  > 'abcd' ]] && echo "TRUE condition"     # Подтверждение предыдущего утверждения.
[ "abcd" \> "add" ] || echo "FALSE condition"
[ "add"  \< "abcd" ] || echo "FALSE condition"

# Для сравнения чисел в операторах [[ и [ всегда используйте
#   -gt  больше
#   -ge  больше или равно
#   -lt  меньше
#   -le  меньше или равно
#   -eq  равно
#   -ne  не равно
[[ 5 -eq 5 ]] && echo "TRUE condition"
[[ 4 -ne 3 ]] && echo "TRUE condition"
[[ 5 -ge 4 ]] && echo "TRUE condition"
[[ 3 -lt 2 ]] || echo "FALSE condition"

# С-подобный синтаксис для чисел можно использовать внутри оператора (( )).
# Кроме того, используйте этот оператор вместо 'let', когда это возможно.
(( 5 == 5 )) && echo "TRUE condition"
(( 4 > 3 )) && echo "TRUE condition"
(( 21 >= 25 )) || echo "FALSE condition"
(( "abcd" == "efgh" )) || echo "FALSE condition"   # ОШИБКА: строки так сравнивать нельзя. Используйте [[ или [.

# Главный смысл [[ , [ и (( )) это объединение сложных условий в единую проверку.
[[ "abcd" == "abcd" && 5 -eq 5 ]] && echo "TRUE condition"
[[ 2 -eq 1 || 3 -eq 3 ]] && echo "TRUE condition"
(( 2+2 == 4 && 2 != 3 )) && echo "TRUE condition"
[ "abcd" == "abcd" -a 5 -eq 5 ] && echo "TRUE condition"
[ 2 -eq 3 -o 1 -lt 2 -o 3 -eq 3 ] && echo "TRUE condition"

DECLARED_VAR=
DECLARED_AND_NOT_EMPTY_VAR="12345abc 456"
declare -a NOT_EMPTY_ARRAY=('one' 'two' 'three')
declare -a NOT_NULL_ARRAY=()
declare -a NULL_ARRAY=
# Следующие частности нужно просто запомнить
[[ ! -z "$BASH_VERSION" ]] && echo "You are using Bash $BASH_VERSION"
[ true ] ; echo "[ true ] returned $? - true is TRUE"  
[ false ] ; echo "[ false ] returned $? - false is not FALSE"
[ 0 ] ; echo "[ 0 ] returned $? - Zero is TRUE"  
[ 1 ] ; echo "[ 1 ] returned $? - Not zero is often TRUE, but may be FALSE in another shell (BE CAREFUL)"  
[ -1 ] ; echo "[ -1 ] returned $? - Minus 1 is TRUE"  
[ ] ; echo "[  ] returned $? - NULL is FALSE"
[ a_word ] ; echo "[ a_word ] returned $? - Random word is TRUE"
[ $DECLARED_VAR ] ; echo "[ \$DECLARED_VAR ] returned $? - Empty variable is FALSE"
[ "$DECLARED_VAR" ] ; echo "[ \"\$DECLARED_VAR\" ] returned $? - Empty variable is FALSE"
# Примечание: Если в значении переменной есть пробелы, то ее всегда нужно закавычивать внутри [ ].
[ "$DECLARED_AND_NOT_EMPTY_VAR" ] ; echo "[ \"\$DECLARED_AND_NOT_EMPTY_VAR\" ] returned $? - No empty variable is TRUE"
[ "$NoT_InItIaLiZeD" ] ; echo "[ \"\$NoT_InItIaLiZeD\" ] returned $? - Not initiaized variable is always NULL and FALSE"
[ "$NOT_EMPTY_ARRAY" ] ; echo "[ \"\$NOT_EMPTY_ARRAY\" ] returned $? - Not empty array is TRUE"
[ "$NOT_NULL_ARRAY" ] ; echo "[ \"\$NOT_NULL_ARRAY\" ] returned $? - Not null but empty array is FALSE"
[ "$NULL_ARRAY" ] ; echo "[ \"\$NULL_ARRAY\" ] returned $? - Null array is FALSE"
[[ true ]] ; echo "[[ true ]] returned $? - true is TRUE"  
[[ false ]] ; echo "[[ false ]] returned $? - false is not FALSE"
[[ 0 ]] ; echo "[[ 0 ]] returned $? - Zero is TRUE"  
[[ 1 ]] ; echo "[[ 1 ]] returned $? - Not zero is often TRUE, but may be FALSE in another shell (BE CAREFUL)"
[[ -1 ]]; echo "[[ -1 ]] returned $? - Minus 1 is TRUE"
#[[ ]]  # ATTENTION: It's not valid
[[ a_word ]] ; echo "[[ a_word ]] returned $? - Random word is TRUE"
[[ $DECLARED_VAR ]] ; echo "[[ \$DECLARED_VAR ]] returned $? - Empty variable is FALSE"
[[ $DECLARED_AND_NOT_EMPTY_VAR ]] ; echo "[[ \$DECLARED_AND_NOT_EMPTY_VAR ]] returned $? - No empty variable is TRUE"
[[ $NoT_InItIaLiZeD ]] ; echo "[[ \$NoT_InItIaLiZeD ]] returned $? - Not initiaized variable is always NULL and FALSE"
[[ "$NOT_EMPTY_ARRAY" ]] ; echo "[[ \"\$NOT_EMPTY_ARRAY\" ]] returned $? - Not empty array is TRUE"
[[ "$NOT_NULL_ARRAY" ]] ; echo "[[ \"\$NOT_NULL_ARRAY\" ]] returned $? - Not null but empty array is FALSE"
[[ "$NULL_ARRAY" ]] ; echo "[[ \"\$NULL_ARRAY\" ]] returned $? - Null array is FALSE"
(( 0 )) ; echo "(( 0 )) returned $? - Zero is FALSE"
(( 1 )) ; echo "(( 1 )) returned $? - Not zero is TRUE"
(( -1 )); echo "(( -1 )) returned $? - Minus 1 is TRUE"
((  ))  ; echo "(( )) returned $? - NULL is FALSE"  
(( true )) ; echo "(( true )) returned $? - true is FALSE"  
(( false )) ; echo "(( false )) returned $? - false is FALSE"  

# Оператор (( )) возвращает результат в зависимости от выражения. Если внутри производится
# сравнивание, то результат зависит от логических операторов. Если вычисляется число, то результат
# зависит от того нулевой там результат или не нулевой.
(( 2 > 1 ))  && echo "(( 2 > 1 )) - It's true"
(( 10 - 6 )) && echo "(( 10 - 6 )) - It's true, because 4 > 0"
(( 10 - 10 )) || echo "(( 10 - 10 )) - It's false, because the result is 0"
(( 2 / 0 )) 2> /dev/null || echo "Division by 0 is always FALSE ($?)"

# ПРОВЕРКА ПЕРЕМЕННЫХ
# -------------------
# На практике очень часто приходится проверять переменные на пустоту. Любая переменная может
# быть на момент проверки в одном из следующих состояний:
#    - Не инициализирована - ее значение всегда NULL
#    - Инициализирована, но пустая
#    - Инициализирована и не пустая
# Для проверки используются две дуальные друг другу опции:
#    -z  (zero)      Возвращает TRUE, когда строка пустая или NULL - негативная проверка.
#    -n  (non-zero)  Возвращает TRUE, когда строка не NULL и не пустая.
#
# Чтобы понять, что переменная не инициализирована или пустая, всегда используйте
# опцию -z, при которой на это утверждение возвращается TRUE.
[ -z "$_some_var" ] && echo "The string is not initialized or empty"
[ -z "$NOT_EMPTY_ARRAY" ]; echo "[ -z \"\$NOT_EMPTY_ARRAY\" ] returned $?" 
[ -z "$NOT_NULL_ARRAY" ]; echo "[ -z \"\$NOT_NULL_ARRAY\" ] returned $?" 
[ -z "$NULL_ARRAY" ]; echo "[ -z \"\$NULL_ARRAY\" ] returned $?" 
[[ -z $_some_var ]] && echo "The string is not initialized or empty"
[[ -z "$NOT_EMPTY_ARRAY" ]]; echo "[[ -z \"\$NOT_EMPTY_ARRAY\" ]] returned $?" 
[[ -z "$NOT_NULL_ARRAY" ]]; echo "[[ -z \"\$NOT_NULL_ARRAY\" ]] returned $?" 
[[ -z "$NULL_ARRAY" ]]; echo "[[ -z \"\$NULL_ARRAY\" ]] returned $?" 

# Используя опцию -n вы можете проверить строку на пустоту. Если проверка возвращает TRUE,
# то строка не пустая, иначе пустая или не инициализирована.
[ -n "$_some_var" ] || echo "The string is empty or not initialized"
[ -n "$NOT_EMPTY_ARRAY" ]; echo "[ -n \"\$NOT_EMPTY_ARRAY\" ] returned $?" 
[ -n "$NOT_NULL_ARRAY" ]; echo "[ -n \"\$NOT_NULL_ARRAY\" ] returned $?" 
[ -n "$NULL_ARRAY" ]; echo "[ -n \"\$NULL_ARRAY\" ] returned $?" 
[[ -n $_some_var ]] || echo "The string is empty or not initialized"
[[ -n "$NOT_EMPTY_ARRAY" ]]; echo "[[ -n \"\$NOT_EMPTY_ARRAY\" ]] returned $?" 
[[ -n "$NOT_NULL_ARRAY" ]]; echo "[[ -n \"\$NOT_NULL_ARRAY\" ]] returned $?" 
[[ -n "$NULL_ARRAY" ]]; echo "[[ -n \"\$NULL_ARRAY\" ]] returned $?" 

# ВНИМАНИЕ: [ -n ... ] очень коварная проверка, если она используется вместе с конструкцией
# if ... fi или циклах БЕЗ КАВЫЧЕК.
if [ -n $_some_var ]; then
    echo "This is wrong way. You forgot quotation marks."
else
    echo "This is right way."
fi
# НО -z ПОЧЕМУ-ТО РАБОТАЕТ :-)
if [ -z $_some_var ]; then
    echo "This is right way."
else
    echo "This is wrong way. You forgot quotation marks."
fi
# НО ТАК ВСЕГДА РАБОТАЕТ ПРАВИЛЬНО
if [[ -n $_some_var ]]; then
    echo "This is wrong way. You forgot quotation marks."
else
    echo "This is right way."
fi
if [[ -z $_some_var ]]; then
    echo "This is right way."
else
    echo "This is wrong way. You forgot quotation marks."
fi

# ВЫВОД:
#  Как бы там ни было, всегда закавычивайте переменные для [ ].

##### ПОУЧИТЕЛЬНЫЕ ПРИМЕРЫ #####

#
# ХОРОШО ПЕРЕНОСИМЫЙ ВАРИАНТ - переносим между POSIX оболочками и некоторыми не POSIX оболочками.
#

# ----- ПРОВЕРКА НА ПУСТОТУ -----
_some_var=""  # Пустая строка

# ХОРОШО ПЕРЕНОСИМЫЙ ВАРИАНТ (Прим.: Для не инициализированных переменных, результат также будет ПУСТО)
if [ -n "$_some_var" ]; then
    echo "\$_some_var=$_some_var"
else
    echo "\$_some_var is empty or null"
fi
if [ -z "$_some_var" ]; then
    echo "\$_some_var is empty or null"
else
    echo "\$_some_var=$_some_var"
fi
# ТОЛЬКО ДЛЯ BASH-совместимых оболочек
if [[ -n $_some_var ]]; then
    echo "\$_some_var=$_some_var"
else
    echo "\$_some_var is empty or null"
fi
if [[ -z $_some_var ]]; then
    echo "\$_some_var is empty or null"
else
    echo "\$_some_var=$_some_var"
fi

# ----- РАЗНОЕ -----

TEST_STR="BASH-4.4"
ZERO=0

# СМЕШАННЫЕ ПРОВЕРКИ
# ------------------
# Общее правило: если нужен переносимый вариант, то [[ ]] и (( )) пользоваться нельзя (это башизмы).
#  Тем не менее, POSIX'ом объявлена конструкция $((MATH_EXPR)), которой можно пользоваться
#  для написания переносимых вариантов.
#
# ХОРОШО ПЕРЕНОСИМЫЙ ВАРИАНТ
if [ "$(( $ZERO + 1 ))" -eq 1 ]; then
    echo " 0 + 1 = 1"
fi
# ТОЛЬКО ДЛЯ BASH-совместимых оболочек
if (( $(( $ZERO + 2 )) == 2 )); then
    echo " 0 + 2 = 2"
fi
# ПРИМЕЧАНИЕ:
#  Не запрещается использовать expr, о котором пойдет речь в следующем примере, для расчетов, однако
#  его использование для таких целей сейчас считается устаревшим. Им следует пользоваться, когда
#  псевдокоманды или (( )) недостаточно.
if [ "$(expr 0 + 3)" -eq 3 ]; then
    echo " 0 + 3 = 3"
fi

# ПОЛУЧИТЬ ЧИСЛО СИМВОЛОВ В СТРОКЕ
# --------------------------------
echo "expansion_length \"$TEST_STR\" = ${#TEST_STR}"   # можно, но НЕНАДЕЖНО, особенно, когда есть пробельные символы.
echo "wc_length \"$TEST_STR\" = $(printf "$TEST_STR" | wc -m)" # можно, но МЕДЛЕННО
echo "expr_length \"$TEST_STR\" = $(expr length "$TEST_STR")" # ПЕРЕНОСИМО И РЕКОМЕНДОВАНО
#
# ВЫВОД: рекомендуется использовать expr для всех переносимых реализаций.

# РАБОТА С ПОДСТРОКАМИ
# --------------------
echo "Position of first '4' character in \"$TEST_STR\" is $(expr index "$TEST_STR" 4)"
echo "Substring of \"$TEST_STR\" in range 1-4 is $(expr substr "$TEST_STR" 1 4)"

# СРАВНЕНИЕ С ШАБЛОНОМ
# --------------------
#  К сожалению, ради совместимости приходится жертвовать удобством оператора '=~'.
#  Оператор '=~' появился в Bash 3.0 и является башизмом.
#
#  При сравнении по регулярным выражениям, когда нужна переносимость, используйте expr, awk или sed.
#  В expr используется диалект BRE.
#
# ХОРОШО ПЕРЕНОСИМЫЙ ВАРИАНТ
if [ "$(expr match "$TEST_STR" '^BASH-[4].*$')" -ge 1 ]; then
    echo "It seems that you are using BASH 4.x"
fi
# ТАК ТОЖЕ МОЖНО
if [ "$(expr "$TEST_STR" : '^BASH-[4].*$')" -ge 1 ]; then
    echo "It seems that you are using BASH 4.x"
fi

# ТОЛЬКО ДЛЯ BASH-совместимых оболочек >3.
# Примечание: '=~' использует диалект ERE. 
#   Шаблон НЕ ЗАКАВЫЧИВАЕТСЯ справа от оператора!
if [[ $TEST_STR =~ ^BASH-.*$ ]]; then
    echo "You are using BASH"
fi
PATTERN='^[[:alnum:]]*-[^012]\..*$'
if [[ $TEST_STR =~ $PATTERN ]]; then
    echo "'=~' is supported"
    BASH2="BASH-2.0"
    [[ $BASH2 =~ $PATTERN ]] || echo "In $BASH2 the operator '=~' is not supported"
fi