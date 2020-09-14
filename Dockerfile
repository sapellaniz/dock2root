FROM ubuntu as baseline

RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
    
# Install packages
RUN \
    apt-get update && \
    apt-get install -y \
    host \
    htop \
    dnsutils \
    net-tools \
    tcpdump \
    telnet \
    cifs-utils \
    rlwrap \
    iputils-ping \
    git \
    zsh \
    tmux \
    curl \
    unzip \
    p7zip-full \
    locate \
    tree \
    openvpn \
    vim \
    wget \
    ftp \
    squid \
    python3 \
    python \
    python3-pip \
    jq \
    libcurl4-openssl-dev \
    libssl-dev \
    nmap \
    nikto \
    netcat \
    cewl \
    crunch \
    hydra \
    hashcat \
    libwww-perl \
    openjdk-8-jdk \
    # patator dependencies
    libmysqlclient-dev \
    # evil-winrm dependencies
    ruby-full \
    # enum4linux dependencies
    ldap-utils \
    smbclient \
    # john dependencies
    build-essential \
    libssl-dev \
    zlib1g-dev  \
    yasm \
    pkg-config \
    libgmp-dev \
    libpcap-dev \
    libbz2-dev \
    # crackmapexec dependencies
    libffi-dev \
    python-dev && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y php \
    libapache2-mod-php && \
    gem install \
    gpp-decrypt \
    addressable \
    wpscan \
    # Install evil-winrm
    evil-winrm && \
    apt-get update

# Installing python-pip
RUN curl -O https://raw.githubusercontent.com/pypa/get-pip/master/get-pip.py &&  \
    python get-pip.py  && \
    echo "PATH=$HOME/.local/bin/:$PATH" >> ~/.bashrc && \
    rm get-pip.py

FROM baseline as builder
# SERVICES

# Squid configuration
RUN
    echo "http_access allow all" >> /etc/squid/squid.conf && \
    sed -i 's/http_access deny all/#http_access deny all/g' /etc/squid/squid.conf
# OS TOOLS

# Install python dependencies
COPY requirements_pip3.txt /tmp
COPY requirements_pip.txt /tmp
RUN \
    pip3 install -r /tmp/requirements_pip3.txt && \
    pip install -r /tmp/requirements_pip.txt

# DEVELOPER TOOLS

# Install go
WORKDIR /tmp
RUN \
    wget -q https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz 
    
ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"

# RECON
FROM builder as builder2
WORKDIR /tools/recon

# Install ffuf
RUN \
    go get github.com/ffuf/ffuf

# BUILDER WORDLIST
FROM baseline as wordlist
RUN mkdir /temp
WORKDIR /temp

# Download wordlist
RUN \
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
    curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt && \

# WORDLIST
FROM builder2 as builder3
COPY --from=wordlist /temp/ /tools/wordlist/

# BUILDER OWASP
FROM baseline as owasp
RUN mkdir /temp
WORKDIR /temp

# Install sqlmap
RUN \
    git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap && \
# Download XSStrike
    git clone --depth 1 https://github.com/s0md3v/XSStrike.git && \


# CRACKING
RUN mkdir -p /tools/cracking
WORKDIR /tools/cracking

# Install john the ripper
RUN git clone --depth 1 https://github.com/magnumripper/JohnTheRipper -b bleeding-jumbo john
WORKDIR /tools/cracking/john/src
RUN ./configure && make -s clean && make -sj4

# BUILDER OS ENUMERATION
FROM baseline as osEnumeration
RUN mkdir /temp
WORKDIR /temp

# Download htbenum
RUN git clone --depth 1 https://github.com/SolomonSklash/htbenum.git
WORKDIR /temp/htbenum
RUN \
    chmod +x htbenum.sh && \
    ./htbenum.sh -u

# Download enum4linux
WORKDIR /temp
RUN \
    git clone --depth 1 https://github.com/portcullislabs/enum4linux.git && \
# Download PEASS - Privilege Escalation Awesome Scripts SUITE
    mkdir -p /temo/peass


# Install smbmap
WORKDIR /temp
RUN \
    git clone --depth 1 https://github.com/ShawnDEvans/smbmap.git && \
# Download pspy
    mkdir -p /temp/pspy

WORKDIR /temp/pspy
RUN \
    wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32 && \
    wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64 && \
    chmod +x *

# EXPLOITS
FROM builder7 as builder8
COPY --from=exploits /temp/ /tools/exploits/
WORKDIR /tools/exploits

# Install searchsploit
RUN \
    git clone --depth 1 https://github.com/offensive-security/exploitdb.git /opt/exploitdb && \
    sed 's|path_array+=(.*)|path_array+=("/opt/exploitdb")|g' /opt/exploitdb/.searchsploit_rc > ~/.searchsploit_rc && \
    ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit && \
# Install metasploit
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall && \
    msfupdate

# BUILDER WINDOWS
FROM baseline as windows
RUN mkdir /temp
WORKDIR /temp

# Download crackmapexec
RUN \
    git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec && \
# Download powersploit
    git clone --depth 1 https://github.com/PowerShellMafia/PowerSploit.git && \
# Download Pass-the-Hash
    git clone --depth 1 https://github.com/byt3bl33d3r/pth-toolkit.git && \
# Download Mimikatz
    wget --quiet https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20200816/mimikatz_trunk.zip -O mimikatz.zip && \
    unzip mimikatz.zip -d mimikatz && \
    rm mimikatz.zip

# WINDOWS
FROM builder8 as builder9
RUN mkdir -p /tools/windows
COPY --from=windows /temp/ /tools/windows/


# OS TUNNING

COPY zshrc /root/.zshrc
COPY tmux.conf /root/.tmuz.conf

# Create or update a database used by locate
RUN \
    updatedb

# Change workdir
WORKDIR /
