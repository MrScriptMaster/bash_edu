#!/bin/bash
# 
# Для любого дочернего процесса bash резервирует три первых дескриптора:
#   0 - STDIN - стандартный поток ввода, к которому обычно подключается клавиатура.
#   1 - STDOUT - стандартный буферизируемый поток вывода, к котрому подключается
#                устройство терминала.
#   2 - STDERR - стандартный не буферизируемый поток ошибок, к которому также подключается
#                устройство терминала.
# 
# Внутри сценария со стандартными потоками мы можем работать через операторы
# перенаправления:
#    [0]|i<&j     перенаправляет ввод с дескриптора j на дескриптор i.
#    [1]|i>&j     перенаправляет вывод с указанного дескриптора i на дескриптор j.
#    [1]|i>>&j    перенаправляет вывод с указанного дескриптора i на дескриптор j,
#                 но в режиме дописывания.
#        &>&j     перенаправляет STDOUT и STDERR в дескриптор j.
#
# Варианты '>' и ': >' работают как touch, но '>' работает не во всех оболочках.
#
# Команда read читает STDIN
read -r line < <(echo "Test")
echo "$line"
# 
# Перенаправляем вывод в дескриптор STDOUT.
ls -l >&1
# Перенаправляем вывод в дескриптор STDERR.
ls -l >&2
# 
# Все варианты перенаправления выше делают это только для указанной команды, т.е.
# временно. Чтобы перенаправлять ввод/вывод на все время, используется команда exec.
#
TEMPFILE=tempfile.txt
exec 7>&1   # Связываем 7 дескриптор с STDOUT, чтобы потом восстановить
exec 8>&2   # Связываем 8 дескриптор с STDERR, чтобы потом восстановить
# Перенаправляем STDOUT и STDERR в файл "tempfile.txt" на все время
exec 2>&1 1> $TEMPFILE
echo "You should not see this message on the terminal"
# 
# Перенаправляем на STDIN содержимое файла на все время
exec 6<&0    # Перенаправляем STDIN на 6 дескриптор, чтобы потом восстановить
exec 0< $TEMPFILE
COUNTER=4
while read line; do
    # ВНИМАНИЕ: данный прием создает бесконечную петлю, так
    # как ранее вывод был направлен в тот же файл.
    # Мы должны предусмотреть выход из петли.
    echo $line
    (( COUNTER=$COUNTER - 1 ))
    [[ $COUNTER -ne 0 ]] || break
done
#
# [0]|n<&-    Закрыть дескриптор n входного файла
# [1]|n>&-    Закрыть дескриптор n выходного файла
#
#
exec <&6 6<&-  # Восстанавливаем STDIN из 6 дескриптора и закрываем его
exec 1>&7 7>&- # Восстанавливаем STDOUT из 7 дескриптора и закрываем его
exec 2>&8 8>&- # Восстанавливаем STDERR из 8 дескриптора и закрываем его
#
# Теперь все стандартные дескрипторы восстановлены.
echo "Hello"
cat $TEMPFILE
#
# Дочерние процессы наследуют открытые дескрипторы, поэтому и работают
# конвейеры. Если в дочернем процессе они не нужны, то их нужно закрыть
# в родительском процессе.
exec 3>&1    # Связываем 3 дескриптор с STDOUT, чтобы потом восстановить.
# Закрываем дескриптор 3 для grep, но не для ls, поэтому вывода
# grep мы не увидим.
ls -l 2>&1 >&3 3>&- | grep whatever 3>&-
exec 1>&3 3>&- # Восстанавливаем STDOUT
#
echo "Hello again"
#
# В сценариях можно открывать произвольные дескрипторы и связывать с ними
# файлы для нужд сценария.
#
exec 3<>$TEMPFILE  # Открываем файл на чтение и на запись и связываем его с дескриптором 3
echo "This line goes to 3 descriptor" >&3
read line <&3      # Читаем файл через 3 дескриптор
echo "Read: $line"
exec 3>&-     # Закрываем дескриптор
echo "-------------------"
# В этот момент в файле возможна мешанина, так как буферы сбрасываются в файл
# не синхронно
cat $TEMPFILE
#
rm -f $TEMPFILE