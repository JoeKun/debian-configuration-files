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
    echo "Be careful with what you are about to do now!"
    echo
fi


#-----------------------------------------------------------
# Lines automatically added by some programs
#-----------------------------------------------------------

# Load RVM into a shell session *as a function*
[[ -s "/usr/local/rvm/scripts/rvm" ]] && source "/usr/local/rvm/scripts/rvm"

# Lines configured by zsh-newuser-install

HISTSIZE=1000
SAVEHIST=1000

# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall

zstyle :compinstall filename `echo "$HOME/.zshrc"`

autoload -Uz compinit
compinit

# End of lines added by compinstall

