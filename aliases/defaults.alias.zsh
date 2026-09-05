# OVERRIDE DEFAULT COMMANDS 

# make parent directories
alias mkdir="mkdir -pv"
alias vi=vim
alias svi='sudo vi'
alias vis='vim "+set si"'
alias edit='vim'

# top is atop, just like vi is vim
alias top='atop'

## set some other defaults ##
alias df='df -H'
alias du='du -ch'

# Resume wget by default
## this one saved by butt so many times ##
alias wget='wget -c'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

#### ADDS SAFETY NETS
# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root'

# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias autogpt="python $HOME/www/x/Auto-GPT/scripts/main.py"
alias gpt="autogpt"