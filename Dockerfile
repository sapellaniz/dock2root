FROM ubuntu as baseline

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

# Install packages from oficial repos
RUN \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
    # Networking utilities
	dnsutils host iputils-ping net-tools tcpdump \
	curl ftp netcat nmap openvpn telnet wget \
    # Web
	firefox nikto whatweb \
    # Development
	git jq libcurl4-openssl-dev libssl-dev libwww-perl openjdk-8-jdk \
	openjdk-11-jdk python python3 python3-pip python3-venv vim \
    # System management
	cifs-utils htop locate p7zip-full tree unzip sudo \
    # Terminal & Shell
	rlwrap tmux zsh zsh-syntax-highlighting man-db \
    # Cracking & bruteforce
	cewl crunch hydra hashcat \
    # patator dependencies
	libmysqlclient-dev \
    # evil-winrm dependencies
	ruby-full \
    # enum4linux dependencies
	ldap-utils smbclient \
    # john dependencies
	build-essential libssl-dev zlib1g-dev yasm pkg-config \
	libgmp-dev libpcap-dev libbz2-dev \
    # crackmapexec dependencies
	libffi-dev python-dev php libapache2-mod-php && \
	gem install gpp-decrypt addressable \
    # evil-winrm
	evil-winrm \
    # wpscan
	wpscan && \
    # Installing python-pip
	curl -O https://raw.githubusercontent.com/pypa/get-pip/master/get-pip.py &&  \
	python get-pip.py  && \
	echo "PATH=$HOME/.local/bin/:$PATH" >> ~/.bashrc && \
	rm get-pip.py && \
    # Remove apt cache
        apt-get clean autoclean && \
        apt-get autoremove --yes && \
        rm -rf /var/lib/{apt,dpkg,cache,log}/

# Create playerRed
RUN \
	useradd playerRed -G sudo -s /bin/zsh && \
	passwd -d playerRed

# Install go
WORKDIR /tmp
RUN \
        wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O go.tar.gz && \
        tar -C /usr/local -xzf go.tar.gz && \
	rm go.tar.gz

ENV GOROOT "/usr/local/go"
ENV GOPATH "/home/playerRed/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"

# Install python dependences & Config playerRed's home
ADD requirements/ /home/playerRed
RUN chown -R playerRed:playerRed /home/playerRed
RUN \
        pip3 install -r /home/playerRed/requirements_pip3.txt && \
        pip install -r /home/playerRed/requirements_pip.txt && \
	rm /home/playerRed/requirements* && \
	mkdir -p /tools/wordlist /tools/web /tools/cracking /tools/enum/linux \
		/tools/enum/windows /tools/exploits /tools/windows /home/playerRed/htb

# CRACKING
WORKDIR /tools/cracking
RUN \
	# john the ripper
	git clone --depth 1 https://github.com/magnumripper/JohnTheRipper -b bleeding-jumbo john && \
	cd /tools/cracking/john/src && \
	./configure && make -s clean && make -sj4

# ENUMERATION
WORKDIR /tools/enum
RUN \
    # htbenum
	git clone --depth 1 https://github.com/SolomonSklash/htbenum.git && \
	cd /tools/enum/htbenum && \
	chmod +x htbenum.sh && \
        ./htbenum.sh -u && \
	cd /tools/enum && \
    # htbexplorer
	git clone https://github.com/s4vitar/htbExplorer.git && \
    # linux/enum4linux
        git clone --depth 1 https://github.com/portcullislabs/enum4linux.git && \
    # linux/linenum
        wget -O /tools/enum/linux/LinEnum.sh -q 'https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh' && \
    # linux/linPEAS
        wget -O /tools/enum/linux/linpeas.sh -q 'https://raw.githubusercontent.com/carlospolop/privilege-escalation-awesome-scripts-suite/master/linPEAS/linpeas.sh' && \
    # pspy
        wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32 && \
        wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64 && \
        chmod +x pspy* && \
    # windows/crackmapexec
        python3 -m pip install pipx && \
        pipx ensurepath && \
        pipx install crackmapexec && \
    # windows/smbmap
        cd /tools/enum/windows && \
        git clone --depth 1 https://github.com/ShawnDEvans/smbmap.git && \
        cd /tools/enum && \
    # windows/winPEAS
	wget -O /tools/enum/windows/winPEASany.exe -q 'https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/winPEAS/bin/Obfuscated%20Releases/winPEASany.exe' && \
	wget -O /tools/enum/windows/winPEASx64.exe -q 'https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/winPEAS/bin/Obfuscated%20Releases/winPEASx64.exe' && \
	wget -O /tools/enum/windows/winPEASx86.exe -q 'https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/winPEAS/bin/Obfuscated%20Releases/winPEASx86.exe'

# EXPLOITS
WORKDIR /tools/exploits
RUN \
    # searchsploit
    git clone --depth 1 https://github.com/offensive-security/exploitdb.git && \
    sed 's|path_array+=(.*)|path_array+=("/opt/exploitdb")|g' /tools/exploits/exploitdb/.searchsploit_rc > ~/.searchsploit_rc

# WEB
WORKDIR /tools/web
RUN \
    # Burp suite
        wget -O ./burp.jar 'https://portswigger.net/DownloadUpdate.ashx?Product=Free' && \
        chmod +x ./burp.jar && \
        echo "#! /bin/zsh \njava -jar /tools/web/burp.jar > /dev/null 2>&1 & \n" > burpsuite && \
        chmod +x burpsuite && \
    # ffuf
        go get github.com/ffuf/ffuf && \
    # gobuster
        go get github.com/OJ/gobuster && \
    # sqlmap
        git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap && \
    # XSStrike
        git clone --depth 1 https://github.com/s0md3v/XSStrike.git && \
        chmod +x XSStrike/xsstrike.py

# WINDOWS
WORKDIR /tools/windows
RUN \
    # impacket
        git clone https://github.com/SecureAuthCorp/impacket.git && \
	cd /tools/windows/impacket && \
	pip install . && \
	cd /tools/windows && \
    # Mimikatz
        wget --quiet https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20200816/mimikatz_trunk.zip -O mimikatz.zip && \
        unzip mimikatz.zip -d mimikatz && \
        rm mimikatz.zip && \
    # powersploit
	git clone --depth 1 https://github.com/PowerShellMafia/PowerSploit.git

# WORDLISTS
WORKDIR /tools/wordlist
RUN \
    # SecLists
        git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
    # rockyou
        curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt

# SIMLINKS
RUN \
	ln -sf /tools/web/sqlmap/sqlmap.py /usr/local/bin/sqlmap && \
	ln -sf /tools/web/XSStrike/xsstrike.py /usr/local/bin/xsstrike && \
	ln -sf /tools/web/burpsuite /usr/local/bin/burpsuite && \
	ln -sf /tools/cracking/john/run/john /usr/local/bin/john && \
	ln -sf /tools/enum/windows/smbmap/smbmap.py /usr/local/bin/smbmap && \
	ln -sf /tools/enum/htbExplorer/htbExplorer /usr/local/bin/htbexplorer && \
	ln -sf /tools/exploits/exploitdb/searchsploit /usr/local/bin/searchsploit && \
	ln -sf /tools/enum/enum4linux/enum4linux.pl /usr/local/bin/enum4linux && \
	ln -sf /root/.local/bin/cme /usr/local/bin/cme

# Config playerRed environment
ADD dotfiles/ /home/playerRed/
RUN \
	chown -R playerRed:playerRed /home/playerRed && \
	chmod +x /home/playerRed/.start.sh

USER playerRed
ENV DISPLAY=:0
WORKDIR /home/playerRed/htb
ENTRYPOINT /bin/zsh /home/playerRed/.start.sh
