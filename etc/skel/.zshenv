# ~/.zshenv: Personal environment variables for zsh

# Add RVM to PATH for scripting
if [[ -d "$HOME/.rvm/bin" ]]
then
    export PATH="$PATH:$HOME/.rvm/bin"
fi

# RVM autocompletion
if [[ -d "$HOME/.rvm/src/rvm/scripts/zsh/Completion" ]]
then
    fpath=($fpath $HOME/.rvm/src/rvm/scripts/zsh/Completion)
fi

