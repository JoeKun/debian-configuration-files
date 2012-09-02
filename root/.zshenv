# ~/.zshenv: Personal environment variables for zsh

# RVM autocompletion
if [[ -d "/usr/local/rvm/src/rvm/scripts/zsh/Completion" ]]
then
    fpath=($fpath /usr/local/rvm/src/rvm/scripts/zsh/Completion)
fi

