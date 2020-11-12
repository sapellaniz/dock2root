FROM archlinux/base:latest

# Install packages from oficial repos
RUN \
        pacman -Syu --noconfirm && \
        pacman -S --noconfirm \
	# System
	    base base-devel cifs-utils mlocate  p7zip sudo tree unzip \
	# Terminal & Shell
            bat rlwrap tmux zsh zsh-syntax-highlighting \
	# Networking
	    netcat nmap openvpn tcpdump wget \
	# Dev
	    git go python python-pip ruby vim \
	# Web
	    nikto sqlmap \
	# Cracking
	    hydra hashcat john \
	# Windows
	    impacket

# Config user x
RUN \
        useradd -m -G wheel,storage,power -s /bin/zsh x && \
        echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers && \
        passwd -d x

# Install AUR-helper & packages from AUR
RUN \
	git clone https://aur.archlinux.org/yay-git.git /opt/yay-git && \
	chown -R x:x /opt/yay-git

WORKDIR /opt/yay-git
USER x:x
RUN \
	makepkg -si --noconfirm && \
	yay -S --noconfirm \
	# Cracking
	    crunch \
	# Enum
	    crackmapexec smbmap \
	# Exploits
	    exploit-db-git \
	# Web
	    burpsuite ffuf whatweb xsstrike

# Install ruby gems
RUN sudo gem install evil-winrm wpscan

# Config system language and keyboard layout
RUN \
	echo "es_ES.UTF-8 UTF-8" | sudo tee /etc/locale.gen && \
	sudo locale-gen es_ES.UTF-8 && \
        echo "LANG=es_ES.UTF-8" | sudo tee /etc/locale.conf && \
        echo KEYMAP=es | sudo tee /etc/vconsole.conf

# ENV HOME=/home/x DISPLAY=:0 TERM=xterm-256color
USER root:root
ADD dotfiles /root/dotfiles
ENTRYPOINT /bin/bash /root/dotfiles/start.sh 
