# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt nomatch
unsetopt autocd beep extendedglob notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/nomeon/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

export XDG_CONFIG_HOME="$HOME/.config"

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

fopen() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}') || return
  ${1:-nano} "$file"
}

export PATH="$HOME/.local/bin:$PATH"

export FLYCTL_INSTALL="/home/nomeon/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

eval "$(zoxide init --cmd cd zsh)"
# bun completions
[ -s "/home/nomeon/.bun/_bun" ] && source "/home/nomeon/.bun/_bun"

# Claude issues workaround
ANTHOROPIC_API_KEY=""

ls() {
  eza --icons=auto --group-directories-first "$@"
}

alias ll='eza --icons=auto -a -l --group-directories-first --git'

# Kitten SSH alias
alias kssh='kitten ssh'

# Zed editor
zed() {
  zeditor "$@"
}

# fnm
FNM_PATH="/home/nomeon/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

# Adjust NODE_OPTIONS for better performance with Node.js
export NODE_OPTIONS="--max-old-space-size=4096"

# For Bun package manager
export PATH="/home/nomeon/.bun/bin:$PATH"

export PATH="/home/nomeon/.pixi/bin:$PATH"
