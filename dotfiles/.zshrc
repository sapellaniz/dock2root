# Enable colors and change prompt
autoload -U colors && colors
PS1='%B%F{red}[%f%(?.%F{green}.%F{red})%?%f%F{red}][%f%F{yellow}%n%f%F{green}@%f%F{blue}%m%f %F{magenta}%~%f%F{red}]%f#%b'

# History in cache directory:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files

# key bindings
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char


# Functions
function xallPorts(){
    nmap -Pn -p- --open -T5 -v -n $1 -oG allPorts
}
function xtop5000Ports(){
    nmap -Pn --top-ports 5000 --open -T5 -v -n $1 -oG top5000
}
function xtargeted(){
    nmap -Pn -sC -sV -p $2 $1 -oN targeted
}
function extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
}

# Load aliases and shortcuts.
alias cp='cp -vi'
alias mv='mv -vi'
alias rm='rm -v'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
