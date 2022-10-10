# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/igor/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

ENABLE_CORRECTION="true"

setopt histignorealldups

# Aliases
alias ls="exa -a --icons --group-directories-first"
alias lt="exa -T -L=2 -a --icons --group-directories-first"
alias install="sudo dnf install"
alias remove="sudo dnf remove"
alias upgrade="sudo dnf upgrade"
alias stow="stow -t /home/igor"

LS_COLORS="di=38;5;183"

# zsh-syntax-highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#B9FF00',underline
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#B9FF00',underline
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#B9FF00'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF0059'

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
