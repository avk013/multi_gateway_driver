#!/bin/bash
gw_list=0
numb=0
#gateways перечень наших шлюзов
gwa=(192.168.1.1	192.168.2.1	192.168.3.1	192.168.4.1	192.168.5.1)
gw_weight=(3	2	5	1	4)
gw_command="ip route add default"
#echo ${gwa[@]}
for i in "${gwa[@]}"; 
do 
#echo "$i";
ipm=${i:0:12};
#ищем через какой интерфей должны бегать пакеты
infs=`sudo ip route | grep "kernel scope link src ${i:0:12}"| awk '{print $3}'`; 
# проверяем не пусто ли в результате 
if [ -n "$infs" ]; then
#echo $infs;
#ping -I $infs 1.1.1.1 -c 3;
sudo route add -net 1.1.1.1 netmask 255.255.255.255 gw $i;
echo route add -net 1.1.1.1 netmask 255.255.255.255 gw $i;
ping 1.1.1.1 -c 3
if [ $? -eq 0 ]
then 
gw_command="$gw_command nexthop via $i dev $infs weight ${gw_weight[$num]}";
numb=$((numb+1));
fi
sudo route del -net 1.1.1.1 netmask 255.255.255.255 gw $i;
fi
num=$((num+1));
done
#узнаем сколько сейчас активных шлюзов (считаем строки ответа)
gw_list=`sudo ip route | grep nexthop | wc -l`;
echo $gw_list;

echo $numb


if [ "$gw_list" -ne "$numb" ]
then
eval "sudo ip route del 0/0"
eval "sudo ip route flush cache"
eval "sudo $gw_command"
fi


echo $gw_command;