# ~/.bashrc: bash directives for GateOne

# Load virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
[[ -s "/etc/bash_completion.d/virtualenvwrapper" ]] && source "/etc/bash_completion.d/virtualenvwrapper"

# Use the gateone virtualenv by default
workon gateone

