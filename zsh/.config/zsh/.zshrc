export BAT_THEME="Dracula"
export PF_INFO="ascii title os de kernel uptime pkgs memory"
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:64

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTORY_IGNORE="(ls|la|cd|cd ..|cd -|cd -|z|z ..|z -|lg)"
HISTSIZE=10000
SAVEHIST=10000

set -o emacs
setopt autocd
setopt correctall
setopt histignorealldups
autoload -U compinit && compinit -u

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/aliases.zsh
source $ZDOTDIR/zsh-syntax-highlighting-dracula.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/p10k.zsh

source /usr/share/nvm/init-nvm.sh

pfetch
eval "$(zoxide init zsh)"
