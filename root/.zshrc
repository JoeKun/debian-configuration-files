# ~/.zshrc: Personal parameters for zsh

#-----------------------------------------------------------
# Personal aliases
#-----------------------------------------------------------

# Frequently used applications
alias integrity_check="( rvm use 2.0.0@integrity_check > /dev/null ; /usr/local/bin/integrity_check )"
alias upgrade="aptitude update && aptitude upgrade && aptitude clean"


#-----------------------------------------------------------
# Welcome message
#-----------------------------------------------------------

echo "Be careful not to break anything!"
echo

