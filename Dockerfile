FROM ubuntu as baseline

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

# Install packages
RUN \
	apt-get update && \
	apt-get install -y \
    # Networking utilities
	dnsutils host iputils-ping net-tools squid tcpdump \
	curl ftp netcat nikto nmap openvpn telnet wget \
    # Development
	git jq libcurl4-openssl-dev libssl-dev libwww-perl \
	openjdk-8-jdk python python3 python3-pip vim \
    # System management
	cifs-utils htop locate p7zip-full tree unzip sudo \
    # Terminal & Shell
	rlwrap tmux zsh zsh-syntax-highlighting \
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
	apt-get update && \
    # Installing python-pip
	curl -O https://raw.githubusercontent.com/pypa/get-pip/master/get-pip.py &&  \
	python get-pip.py  && \
	echo "PATH=$HOME/.local/bin/:$PATH" >> ~/.bashrc && \
	rm get-pip.py

# Install python dependencies
ADD requirements/ /tmp
#COPY requirements_pip3.txt /tmp
#COPY requirements_pip.txt /tmp
RUN \
	pip3 install -r /tmp/requirements_pip3.txt && \
	pip install -r /tmp/requirements_pip.txt

# Install go
WORKDIR /tmp
RUN \
	wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O go.tar.gz && \
	tar -C /usr/local -xzf go.tar.gz

ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"

# WORDLISTS
RUN mkdir -p /tools/wordlist
WORKDIR /tools/wordlist
RUN \
    # Download SecLists
        git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
    # Download Rockyou
        curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt

# RECON
RUN mkdir /tools/web
WORKDIR /tools/web
RUN \
    # Install ffuf
	go get github.com/ffuf/ffuf && \
    # Download sqlmap
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap && \
    # Download XSStrike
	git clone --depth 1 https://github.com/s0md3v/XSStrike.git && \
	chmod +x XSStrike/xsstrike.py

# CRACKING
RUN mkdir /tools/cracking
WORKDIR /tools/cracking

    # Install john the ripper
RUN git clone --depth 1 https://github.com/magnumripper/JohnTheRipper -b bleeding-jumbo john
WORKDIR /tools/cracking/john/src
RUN ./configure && make -s clean && make -sj4

# ENUMERATION
RUN mkdir /tools/enum
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
	pip3 install termcolor && \
    # Download pspy
	wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32 && \
	wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64 && \
	chmod +x pspy* && \
    # HTBexplorer
	git clone https://github.com/s4vitar/htbExplorer.git

# Exploits
RUN \
    # Install searchsploit
    git clone --depth 1 https://github.com/offensive-security/exploitdb.git /opt/exploitdb && \
    sed 's|path_array+=(.*)|path_array+=("/opt/exploitdb")|g' /opt/exploitdb/.searchsploit_rc > ~/.searchsploit_rc

# WINDOWS
RUN mkdir /tools/windows
WORKDIR /tools/windows
RUN \
    # Download crackmapexec
	git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec && \
    # Install impacket
	git clone https://github.com/SecureAuthCorp/impacket.git
WORKDIR /tools/windows/impacket
RUN pip install . 
WORKDIR /tools/windows
RUN \
    # Download powersploit
	git clone --depth 1 https://github.com/PowerShellMafia/PowerSploit.git && \
    # Download Mimikatz
	wget --quiet https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20200816/mimikatz_trunk.zip -O mimikatz.zip && \
	unzip mimikatz.zip -d mimikatz && \
	rm mimikatz.zip

# SIMLINKS
RUN \
	ln -sf /tools/web/sqlmap/sqlmap.py /usr/local/bin/sqlmap && \
	ln -sf /tools/web/XSStrike/xsstrike.py /usr/local/bin/xsstrike && \
	ln -sf /tools/cracking/john/run/john /usr/local/bin/john && \
	ln -sf /tools/enum/smbmap/smbmap.py /usr/local/bin/smbmap && \
	ln -sf /tools/enum/htbExplorer/htbExplorer /usr/local/bin/htbexplorer && \
	ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit && \
	ln -sf /tools/enum/enum4linux/enum4linux.pl /usr/local/bin/enum4linux

# SERVICES
RUN \
    # Squid
        echo "http_access allow all" >> /etc/squid/squid.conf && \
        sed -i 's/http_access deny all/#http_access deny all/g' /etc/squid/squid.conf

# OS TUNNING
RUN useradd playerRed -G sudo -s /bin/zsh
ADD dotfiles/ /home/playerRed/

RUN \
    # Update locate db
	updatedb && \
    # Modify sudoers
	echo '%sudo ALL=(ALL) NOPASSWD: /usr/sbin/squid, /usr/sbin/openvpn, /usr/bin/updatedb, /usr/bin/locate' >> /etc/sudoers && \
    # start.sh
	chmod +x /home/playerRed/.start.sh && \
	chown playerRed /home/playerRed/.*

# Change workdir
USER playerRed
WORKDIR /home/playerRed
ENTRYPOINT /home/playerRed/.start.sh
