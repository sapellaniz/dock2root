#!/bin/bash

function banner(){
    clear
    echo '\n    /\e[91m$$$$$$$\e[0m   /\e[91m$$$$$$\e[0m  /\e[91m$$$$$$$\e[0m       '
    echo '   | \e[91m$$\e[0m__  \e[91m$$\e[0m /\e[91m$$\e[0m__  \e[91m$$\e[0m| \e[91m$$\e[0m__  \e[91$$\e[0m\e[91m$$\e[0m       \t\e[1m\e[92m[+] Dock2rooT ready!\e[0m'
    echo '   | \e[91m$$\e[0m  \ \e[91m$$\e[0m|__/  \ \e[91m$$\e[0m| \e[91m$$\e[0m  \ \e[91$$\e[0m\e[91m$$\e[0m      '
    echo '   | \e[91m$$\e[0m  | \e[91m$$\e[0m  /\e[91m$$$$$$\e[0m/| \e[91m$$$$$$$\e[0m/\t\t\e[33mDocker with steroids\e[0m'
    echo '   | \e[91m$$\e[0m  | \e[91m$$\e[0m /\e[91m$$\e[0m____/ | \e[91m$$\e[0m__  \e[91$$\e[0m\e[91m$$\e[0m     \t\t\t \e[33mfor\e[0m'
    echo '   | \e[91m$$\e[0m  | \e[91m$$\e[0m| \e[91m$$\e[0m      | \e[91m$$\e[0m  \ \e[91$$\e[0m\e[91m$$\e[0m\t\t    \e[33mHack The Box\e[0m'
    echo '   | \e[91m$$$$$$$\e[0m/| \e[91m$$$$$$$$\e[0m| \e[91m$$\e[0m  | \e[91m$$\e[0m      '
    echo '   |_______/ |________/|__/  |__/    \e[33mhttps://gitlab.com/sapellaniz/dock2root\e[0m'
}

# Only continue if $user is not empty
while [ -z "$user" ]; do
    banner
    read -p "Username: " user
done

# Update username, group and home
usermod -l $user x
groupmod -n $user x
usermod -d /home/$user -m $user

# Only continue if password is correctly set
while [ -z "$check" ]; do
    banner
    echo "Please set a password for $user"
    passwd $user && check=1
done

# Setup env
mv /root/dotfiles/.* /home/$user 2>/dev/null
chown -R $user:$user /home/$user
su $user
TERM=xterm-256color
DISPLAY=:0
tmux



#sudo /usr/bin/updatedb
#sudo /usr/sbin/openvpn $(sudo /usr/bin/locate .ovpn) >/dev/null &
#sleep 0.5
#tmux
