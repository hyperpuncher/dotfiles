export BAT_THEME="Dracula"
export PF_INFO="ascii title os de kernel pkgs memory"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTORY_IGNORE="(ls|la|cd|cd ..|cd -|cd -|z|z ..|z -|lg|d)"
HISTSIZE=10000
SAVEHIST=10000

set -o emacs
setopt autocd
setopt histignorealldups
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/zsh-syntax-highlighting-dracula.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source $ZDOTDIR/p10k.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

pfetch
eval "$(zoxide init zsh)"
