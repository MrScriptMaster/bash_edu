#!/bin/sh
#
# В этом сценарии используются все синтаксические конструкции, разрешенные оригинальным
# Bourne shell. Этот сценарий приведен для наглядности.
#
# Обратите внимание на шабэнг в первой строке: #!/bin/sh
#
# Метасимволы интерпретатора:
# * ? []                                 Подстановки имен файлов
# < > n> n>> (где n это число)           Перенаправление ввода/вывода
# |                                      Конвейер команд
# 
# Интерпретацию метасимволов можно запретить двойными кавычками.
# 
ls *
ls *[m]?        # Например: README.md
ls *.??         # Например: README.md, script.sh
ls *[1-3].txt   # Например: file1.txt, file2.txt, file3.txt

cat "not-exist-file.txt" 2>&1 | printf "%s" &0
#
# Эхо ввода терминала
#
# В оригинальном Bourne shell у echo нет опций.
#
echo "Hello, World!"
#
# Переменные
#
name="John Doe"
number=45          # ПРИМЕЧАНИЕ: В sh все значения одного типа - строкового. 
                   # Интерпретация их типа является задачей команды.
#
# Глобальные переменные (переменные окружения)
#
GLOBAL_VARIABLE="value"  # ПРИМЕЧАНИЕ: по неформальному соглашению, все переменные окружения
                         # должны иметь имена в верхнем регистре.
export GLOBAL_VARIABLE
#
# Подстановка значения переменной
#
echo $name
echo $number
echo $GLOBAL_VARIABLE
#
# Чтение пользовательского ввода
#
echo "What's your name?"
read name                     # ПРИМЕЧАНИЕ: оригинальная read имеет только одну опцию -r.
#
# Специальные переменные
#
set $0 first second third   # Установка позиционных параметров из сценария
# ПРИМЕЧАНИЕ: позиционные параметры можно сдвигать через shift.
echo $0  # Имя сценария  
echo $1  # Первый позиционный параметр
echo $2  # Второй позиционный параметр
echo $3  # Третий позиционный параметр
# echo $n
echo $*  # Все позиционные параметры одной строкой
echo $#  # Число позиционных параметров
echo $$  # PID процесса
echo $?  # Статус последней команды
#
# Подстановка результата функции
#
today=`date`
echo "Today is $today"
#
# Арифметические вычисления
#
number=`expr $number + $number`
echo $number
#
# Условные конструкции
#
# Вариант, когда условием является код возврата команды
if date
then
    echo "Date command works"
fi
# Вариант, когда условием является выражение
if [ 'abc' = 'abc' ]
then
    echo "Strings are equal"
fi
# Ветвление условной конструкции
if date
then
    echo "First branch"
elif date
then
    echo "Second branch"
fi
#
if [ 'abc' = 'abc' ]
then
    echo "First branch"
elif [ 'def' = 'def' ]
then
    echo "First branch"
fi
#
# Условные операторы встроенной функции test
#
[ 'abc' = 'abc' ]    # Лексикографическое равно
[ 'abc' != 'def' ]   # Лексикографическое не равно
[ 5 -eq 5 ]          # Равенство чисел. Операнды интерпретируются как числа.
[ 5 -ne 5 ]          # Неравенство чисел. Операнды интерпретируются как числа.
[ 5 -gt 4 ]          # Больше. Операнды интерпретируются как числа.
[ 5 -ge 3 ]          # Больше либо равно. Операнды интерпретируются как числа.
[ 3 -lt 5 ]          # Меньше. Операнды интерпретируются как числа.
[ 5 -le 5 ]          # Меньше либо равно. Операнды интерпретируются как числа.
[ ! 'abc' = 'abc' ]  # Логическое отрицание
[ 'abc' = 'abc' -a 'def' = 'def' -a 5 -eq 5 ]  # Конъюнкция
[ 'abc' = 'cde' -o 5 -ne 0 ] # Дизъюнкция
#
# Циклы
#
# ПРИМЕЧАНИЕ: для управления итерациями служат команды
# bread и continue.
#
echo "For:"
for entry in $@
do
    echo $entry
done
#
echo "While:"
while [ x"$1" !=  x"" ]
do
    echo $1
    shift
done
number=3
until [ "$number" -eq "0" ]
do
    echo "$number"
    number=`expr $number - 1`
done
#
# Встроенные проверки в команду test:
#    -d    это директория
#    -f    это файл
#    -r    может быть прочитан текущим пользователем
#    -s    не пустой
#    -w    может быть переписан текущим пользователем
#    -x    может быть исполнен текущим пользователем
#
TEMP_FILE=$(mktemp /tmp/${0##*/}.XXXXXXXX)
chmod 700 $TEMP_FILE
echo "$TEMP_FILE" >> $TEMP_FILE
TEMP_DIR=$(mktemp -u /tmp/${0##*/}.XXXXXXXX)
mkdir $TEMP_DIR
if [ -f $TEMP_FILE -a \
     -r $TEMP_FILE -a \
     -s $TEMP_FILE -a \
     -w $TEMP_FILE -a \
     -x $TEMP_FILE    \
    ]
then
    echo "File $TEMP_FILE is not empty; is readable; is writeable; is executable"
fi
#
if [ -d $TEMP_DIR ]
then
    echo "$TEMP_DIR is directory"
fi
rm -f $TEMP_FILE
rm -rf $TEMP_DIR
#
# Функции
#
some_func() {
    echo "Your work directory is `pwd`"
    echo $@
}
some_func a b c