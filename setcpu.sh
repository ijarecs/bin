#!/bin/bash
function main_menu
{
    sudo clear
    cursetting=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    getspd=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    curspd=$(echo $getspd 1000000 | awk '{printf $1 / $2}')
    echo ""
    echo ""
    echo "-----------------CPU Settings---------------------"
    echo "1. Allow software to set CPU speed (UserSpace) setting."
    echo "2. Set CPU to Minimum (Powersave) setting."
    echo "3. Set CPU to Low (Conservative) setting."
    echo "4. Set CPU to Medium (OnDemand) setting."
    echo "5. Set CPU to High (Performance) setting."
    echo "6. View CPUID info string."
    echo "7. View Temperature sensor info string."
    echo "8. Exit."
    echo "--------------------------------------------------"
    echo "        Current CPU Setting - "$cursetting;
    echo "        Current CPU Speed - "$curspd"GHz";
    choice=9
    echo ""
    echo -e "Please enter your choice: \c"
}

function press_enter
{
    echo ""
    echo -n "Press Enter to continue."
    read
    main_menu
}    

main_menu
while [ $choice -eq 9 ]; do
read choice

if [ $choice -eq 1 ]; then
    echo userspace | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor;
    main_menu
    else
if [ $choice -eq 2 ]; then
    echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor;
    main_menu
    else
if [ $choice -eq 3 ]; then
    echo conservative | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor;
    main_menu
    else
if [ $choice -eq 4 ]; then
    echo ondemand | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor;
    main_menu
    else
if [ $choice -eq 5 ]; then
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor;
    main_menu
    else
if [ $choice -eq 6 ]; then
    echo ""
    echo ""
    echo ""
    cpuid;
    press_enter
    else
if [ $choice -eq 7 ]; then
    echo ""
    echo ""
    echo ""
    sensors;
    press_enter
    else
if [ $choice -eq 8 ]; then
    exit;
    else
    echo -e "Please enter the NUMBER of your choice: \c"
    choice=9
fi
fi
fi
fi
fi
fi
fi
fi
done
