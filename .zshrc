# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/moses/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
export PS1='[%B%F{red}%n%f%b@%m:%F{blue}%d%f]%# '
