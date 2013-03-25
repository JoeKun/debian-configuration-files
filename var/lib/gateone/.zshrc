# ~/.zshrc: Personal parameters for zsh

#-----------------------------------------------------------
# Welcome message
#-----------------------------------------------------------

NAME="GateOne"

echo
figlet -c -t -f slant "Hello $NAME"
echo


#-----------------------------------------------------------
# Fortune...
#-----------------------------------------------------------

fortune
echo


#-----------------------------------------------------------
# Other little settings
#-----------------------------------------------------------

# When coming from some user's home, I want to arrive in root's home.
for login in root admin joel
do
    if [ "`pwd`" = "`grep "^${login}:x:" /etc/passwd | cut -d : -f 6`" ]
    then
        cd
    fi
done


#-----------------------------------------------------------
# Lines automatically added by some programs
#-----------------------------------------------------------

# Load virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
[[ -s "/etc/bash_completion.d/virtualenvwrapper" ]] && source "/etc/bash_completion.d/virtualenvwrapper"

# Use the gateone virtualenv by default
workon gateone

# Lines configured by zsh-newuser-install

HISTSIZE=1000
SAVEHIST=1000

# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall

zstyle :compinstall filename `echo "$HOME/.zshrc"`

autoload -Uz compinit
compinit

# End of lines added by compinstall

