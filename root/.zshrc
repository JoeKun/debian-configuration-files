# ~/.zshrc: Personal parameters for zsh

#-----------------------------------------------------------
# Personal aliases
#-----------------------------------------------------------

# Frequently used applications
alias upgrade='aptitude update && aptitude upgrade && aptitude clean'


#-----------------------------------------------------------
# Welcome message
#-----------------------------------------------------------

# These lines generate a specific message to print when becoming root with the "su" command.
if [[ ! -o login ]]
then
    echo
    figlet -c -t 'Hey Root!'
    echo
    echo "Be careful not to break anything!"
    echo
fi

