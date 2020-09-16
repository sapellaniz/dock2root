#!/bin/zsh
sudo /usr/bin/updatedb
sudo /usr/sbin/openvpn $(sudo /usr/bin/locate .ovpn) >/dev/null &
sudo /usr/sbin/squid &>/dev/null &
sleep 0.5
clear
echo '\n    /\e[91m$$$$$$$\e[0m   /\e[91m$$$$$$\e[0m  /\e[91m$$$$$$$\e[0m       '
echo '   | \e[91m$$\e[0m__  \e[91m$$\e[0m /\e[91m$$\e[0m__  \e[91m$$\e[0m| \e[91m$$\e[0m__  \e[91$$\e[0m\e[91m$$\e[0m       \t\e[1m\e[92m[+] Dock2rooT ready!\e[0m'
echo '   | \e[91m$$\e[0m  \ \e[91m$$\e[0m|__/  \ \e[91m$$\e[0m| \e[91m$$\e[0m  \ \e[91$$\e[0m\e[91m$$\e[0m      '
echo '   | \e[91m$$\e[0m  | \e[91m$$\e[0m  /\e[91m$$$$$$\e[0m/| \e[91m$$$$$$$\e[0m/\t\t\e[33mDocker with steroids\e[0m'
echo '   | \e[91m$$\e[0m  | \e[91m$$\e[0m /\e[91m$$\e[0m____/ | \e[91m$$\e[0m__  \e[91$$\e[0m\e[91m$$\e[0m     \t\t\t \e[33mfor\e[0m'
echo '   | \e[91m$$\e[0m  | \e[91m$$\e[0m| \e[91m$$\e[0m      | \e[91m$$\e[0m  \ \e[91$$\e[0m\e[91m$$\e[0m\t\t    \e[33mHack The Box\e[0m'
echo '   | \e[91m$$$$$$$\e[0m/| \e[91m$$$$$$$$\e[0m| \e[91m$$\e[0m  | \e[91m$$\e[0m      '
echo '   |_______/ |________/|__/  |__/    \e[33mhttps://gitlab.com/sapellaniz/dock2root\e[0m'
echo '\nUser playerRed has no password, please set it now!\n'
passwd
tmux
