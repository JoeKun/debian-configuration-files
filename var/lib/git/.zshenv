# ~/.zshenv: Personal environment variables for zsh

# Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.rvm/bin"

# RVM autocompletion
if [[ -d "$HOME/.rvm/src/rvm/scripts/zsh/Completion" ]]
then
    fpath=($fpath $HOME/.rvm/src/rvm/scripts/zsh/Completion)
fi

