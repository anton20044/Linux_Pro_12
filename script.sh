#!/bin/bash


echo -e "PID \t TTY \t STAT \t TIME \t COMMAND \n "

for dir in $(ls -la /proc | awk '{print $9}'| grep [0-9] | sort -n)
do
   if [[ $dir != '.' || $dir != '..' ]]
     then
        tmp=""
        tmp_status=""
        tmp_terminal=""
        tmp_time1=""
        tmp_time2=""
        tmp_time_all=""
        tmp_time3=""
        time_it=""
        hour=""
        hour_it=""
        min_it=""
        min=""
        #Определяем cmd
        if [[ -f /proc/$dir/cmdline ]]
        then
           tmp=$(tr -d '\0' </proc/$dir/cmdline)
           if [[ -z $tmp ]]
           then
             tmp=[$(cat /proc/$dir/comm)]
           fi
        fi
        #Определяем состояние процесса
        if [[ -f /proc/$dir/status ]]
        then
           tmp_status=$(grep 'State:' /proc/$dir/status | awk '{print $2}')
        else
           if [[ -f /proc/$dir/stat ]]
           then
              tmp_status=$(cat  /proc/$dir/stat | awk '{print $3}')
           else
              tmp_status='S'
           fi
        fi
        #Терминал
        if [[ -d /proc/$dir/fd ]]
        then
           tmp_terminal=$(ls -la /proc/$dir/fd | grep /dev/[t,p] | awk '{print $11}' | uniq | cut -c6-16 | head -n1)
        fi
        if [[ -z $tmp_terminal ]]
        then
           tmp_terminal="?"
        fi
        #Время работы процесса
        if [[ -f /proc/$dir/status ]]
        then
           tmp_time1=$(cat  /proc/$dir/stat | awk '{print $14}')
           tmp_time2=$(cat  /proc/$dir/stat | awk '{print $15}')
           tmp_time_all=$(($tmp_time1+$tmp_time2))
           tmp_time3=$(($tmp_time_all/100))
           if [[ `expr length $tmp_time3` == 1 ]]
              then
                time_it="00:0"$tmp_time3
           elif [[ `expr length $tmp_time3` == 2 && $tmp_time3 -lt 60 ]]
              then
                time_it="00:"$tmp_time3
           elif [[ `expr length $tmp_time3` -ge 2 && $tmp_time3 -ge 60 ]]
              then
                hour=$(($tmp_time3/60))
                min=$(($tmp_time3%60))
                #Форматируем часы
                if [[ `expr length $hour` -lt 10 ]]
                   then
                      hour_it="0"$hour
                else hour_it="$hour"
                fi
                #Форматируем минуты
                if [[ `expr length $min` -lt 10 ]]
                   then
                      min_it="0"$min
                else min_it=$min
                fi
                time_it="$hour_it:$min_it"

           else  time_it="00:00"
           fi
        else time_it="00:00"
        fi
        #Вывод
        echo -e "$dir \t $tmp_terminal \t $tmp_status \t $time_it \t $tmp"
   fi
done
