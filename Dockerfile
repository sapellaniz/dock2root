FROM ubuntu as baseline

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

# Install packages
RUN \
	apt-get update && \
	apt-get install -y \
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
	libffi-dev python-dev && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y php \
	libapache2-mod-php && \
	gem install gpp-decrypt addressable wpscan \
    # Install evil-winrm
	evil-winrm && \
    # Installing python-pip
	curl -O https://raw.githubusercontent.com/pypa/get-pip/master/get-pip.py &&  \
	python get-pip.py  && \
	echo "PATH=$HOME/.local/bin/:$PATH" >> ~/.bashrc && \
	rm get-pip.py && \
# SERVICES
    # Config playerRed
	useradd playerRed -G sudo -s /bin/zsh && \
	passwd -d playerRed && \
	mkdir /tools && \
    # Remove apt cache
	apt-get clean autoclean && \
	apt-get autoremove --yes && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/

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
	mkdir -p /tools/wordlist /tools/web /tools/cracking /tools/enum \
		/tools/exploits /tools/windows /home/playerRed/htb

# WORDLISTS
WORKDIR /tools/wordlist
RUN \
    # Download SecLists
        git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
    # Download Rockyou
        curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt

# WEB
WORKDIR /tools/web
RUN \
    # Install ffuf
	go get github.com/ffuf/ffuf && \
    # Install gobuster
	go get github.com/OJ/gobuster && \
    # Download sqlmap
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap && \
    # Download XSStrike
	git clone --depth 1 https://github.com/s0md3v/XSStrike.git && \
	chmod +x XSStrike/xsstrike.py && \
    # Install Burp suite
	wget -O ./burp.jar 'https://portswigger.net/DownloadUpdate.ashx?Product=Free' && \
	chmod +x ./burp.jar && \
	echo "#! /bin/zsh \njava -jar /tools/web/burp.jar > /dev/null 2>&1 & \n" > burpsuite && \
	chmod +x burpsuite

# CRACKING
WORKDIR /tools/cracking

    # Install john the ripper
RUN git clone --depth 1 https://github.com/magnumripper/JohnTheRipper -b bleeding-jumbo john
WORKDIR /tools/cracking/john/src
RUN ./configure && make -s clean && make -sj4

# ENUMERATION
WORKDIR /tools/enum

    # Download htbenum
RUN git clone --depth 1 https://github.com/SolomonSklash/htbenum.git
WORKDIR /tools/enum/htbenum
RUN \
	chmod +x htbenum.sh && \
	./htbenum.sh -u
WORKDIR /tools/enum

RUN \
    # Download enum4linux
	git clone --depth 1 https://github.com/portcullislabs/enum4linux.git && \
    # Download WinPeass
	wget -q https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/winPEAS/bin/Obfuscated%20Releases/winPEASany.exe && \
	wget -q https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/winPEAS/bin/Obfuscated%20Releases/winPEASx64.exe && \
	wget -q https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/raw/master/winPEAS/winPEASexe/winPEAS/bin/Obfuscated%20Releases/winPEASx86.exe && \
    # Install smbmap
	git clone --depth 1 https://github.com/ShawnDEvans/smbmap.git && \
    # Download pspy
	wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32 && \
	wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64 && \
	chmod +x pspy* && \
    # HTBexplorer
	git clone https://github.com/s4vitar/htbExplorer.git
    # Download linenum
        wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
    # Download linpeas
        wget https://raw.githubusercontent.com/carlospolop/privilege-escalation-awesome-scripts-suite/master/linPEAS/linpeas.sh

# Exploits
RUN \
    # Install searchsploit
    git clone --depth 1 https://github.com/offensive-security/exploitdb.git /tools/exploits/exploitdb && \
    sed 's|path_array+=(.*)|path_array+=("/opt/exploitdb")|g' /tools/exploits/exploitdb/.searchsploit_rc > ~/.searchsploit_rc

# WINDOWS
WORKDIR /tools/windows
RUN \
    # Install crackmapexec
	python3 -m pip install pipx && \
	pipx ensurepath && \
	pipx install crackmapexec && \
    # Download powersploit
	git clone --depth 1 https://github.com/PowerShellMafia/PowerSploit.git && \
    # Download Mimikatz
	wget --quiet https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20200816/mimikatz_trunk.zip -O mimikatz.zip && \
	unzip mimikatz.zip -d mimikatz && \
	rm mimikatz.zip && \
    # Install impacket
	git clone https://github.com/SecureAuthCorp/impacket.git
WORKDIR /tools/windows/impacket
RUN pip install .

# SIMLINKS
RUN \
	ln -sf /tools/web/sqlmap/sqlmap.py /usr/local/bin/sqlmap && \
	ln -sf /tools/web/XSStrike/xsstrike.py /usr/local/bin/xsstrike && \
	ln -sf /tools/web/burpsuite /usr/local/bin/burpsuite && \
	ln -sf /tools/cracking/john/run/john /usr/local/bin/john && \
	ln -sf /tools/enum/smbmap/smbmap.py /usr/local/bin/smbmap && \
	ln -sf /tools/enum/htbExplorer/htbExplorer /usr/local/bin/htbexplorer && \
	ln -sf /tools/exploits/exploitdb/searchsploit /usr/local/bin/searchsploit && \
	ln -sf /tools/enum/enum4linux/enum4linux.pl /usr/local/bin/enum4linux && \
	ln -sf /root/.local/bin/cme /usr/local/bin/cme

# Change workdir
ADD dotfiles/ /home/playerRed/
RUN \
	chown -R playerRed:playerRed /home/playerRed && \
	chmod +x /home/playerRed/.start.sh

USER playerRed
ENV DISPLAY=:0
WORKDIR /home/playerRed/htb
ENTRYPOINT /bin/zsh /home/playerRed/.start.sh
