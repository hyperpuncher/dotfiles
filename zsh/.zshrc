export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt histignorealldups
autoload -U compinit && compinit -u
ENABLE_CORRECTION="true"

# Created by newuser for 5.9
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/dotfiles/zsh/aliases.zsh

source ~/dotfiles/zsh/.zsh-syntax-highlighting-dracula.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export BAT_THEME="Dracula"
export PATH=$PATH:~/.local/bin:~/.cargo/bin
export EDITOR=nvim

export PF_INFO="ascii title os de kernel uptime pkgs memory"

pfetch
source /usr/share/nvm/init-nvm.sh

# autojump-rs config
[[ -s /etc/profile.d/autojump.sh ]] && source /etc/profile.d/autojump.sh

export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:64

newproj() {
    mkdir -p ~/projects/"$1" && cd ~/projects/"$1" && nvim .
}

# pnpm
export PNPM_HOME="/home/igor/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
