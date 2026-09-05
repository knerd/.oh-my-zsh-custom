#### SYSTEM SHORTCUTS ####

# Distro-specific - Debian/Ubuntu and friends
alias apt-get='sudo apt-get'
alias updatey='sudo apt-get --yes'

# Update on one command
alias update='sudo apt-get update && sudo apt-get upgrade'

# Tune sudo and su
alias sudo='sudo '
alias root='sudo -i'
alias su='sudo -i'

#### SYSTEM MONITORING ####

# Get system memory
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

# CPU usage
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'

# GPU memory
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'

#### NETWORKING ####

# Debug web server/CDN problems with curl
alias header='curl -I'
alias headerc='curl -I --compress'

# Control output of networking tool called ping
alias ping='ping -c 5'
alias fastping='ping -c 100 -s.2'

# Show open ports
alias ports='netstat -tulanp'

#### CREATE NEW SET OF COMMANDS ####

alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime='now'
alias nowdate='date +"%d-%m-%Y"'

#### PACKAGE MANAGEMENT ####

# Update system packages and dependencies
alias sysupdate='sudo apt-get update && sudo apt-get upgrade'
alias sysupgrade='sudo apt-get dist-upgrade'

# Update NPM and global packages
alias npmuninstall='npm ls -g --depth=0 | awk -F/ "/node_modules/ && !/\/npm$/ {print \$NF}" | xargs npm -g rm'
alias npmuninstallall='sudo rm -rf /usr/local/{lib/node{,/.npm,_modules},bin,share/man}/{npm*,node*,man1/node*}'
alias npmupdate='npm update -g'
alias npmupdatenpms='npmuninstall && npmupdate'

# Update Yarn and global packages
alias yarnuninstall='yarn global remove $(yarn global list | grep "@.*:" | awk -F/ "{print \$NF}")'
alias yarnupdate='yarn global upgrade'
alias yarnupdatenpms='yarnuninstall && yarnupdate'

alias yolo=~/yolo-ai-cmdbot/yolo.py
alias computer=~/yolo-ai-cmdbot/yolo.py #optional

# Local Tunnel No Machine
alias xps="lt --port 4443 --subdomain xp-desktop --local-https --allow-invalid-cert "


# mock pod
alias pod="echo 'mock pod'"