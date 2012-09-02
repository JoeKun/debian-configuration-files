# ~/.zlogin: Personal login commands for zsh.

# This file is sourced only for login shells. It should contain commands
# that should be executed only in login shells. It should be used to set
# the  terminal type  and run  a series  of external  commands (fortune,
# msgs, from, etc.)

# Global Order: zshenv, zprofile, zshrc, zlogin

#-----------------------------------------------------------
# Welcome message
#-----------------------------------------------------------

echo
figlet -t -c 'Hello Root!'
echo
echo "Be careful with what you are about to do today!"
echo
