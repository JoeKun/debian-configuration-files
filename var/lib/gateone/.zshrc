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
# Lines automatically added by some programs
#-----------------------------------------------------------

# Load virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
[[ -s "/etc/bash_completion.d/virtualenvwrapper" ]] && source "/etc/bash_completion.d/virtualenvwrapper"

# Use the gateone virtualenv by default
workon gateone

