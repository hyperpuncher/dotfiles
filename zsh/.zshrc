# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'
# zstyle ':z4h:fzf-complete' fzf-bindings tab:repeat

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'yes'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:homelab'   enable 'yes'
zstyle ':z4h:ssh:coolify'   enable 'yes'

zstyle ':z4h:ssh:localhost' enable 'yes'

# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

function spf() {
	export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"

    command spf "$@"

    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}

alias bt='bluetoothctl'
alias drop='dragon-drop -x -a'
alias cat='bat -pp'
alias d='cd ~/dotfiles/'
alias dev='pnpm run dev --host'
alias fd='fd -HI'
alias fzf='fzf --preview "bat --color=always {}" --preview-window=right:60%:wrap'
alias gc='git clone'
alias gp='git pull'
alias i='paru -S'
alias ipa='ip -c -br -4 a'
alias lg='lazygit'
alias ll='eza -a --icons --group-directories-first -s ext --long'
alias ls='eza -a --icons --group-directories-first -s ext'
alias lsblk='lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINTS,FSUSE%'
alias lt='eza -T -L=2 -a --icons --group-directories-first'
alias mkdir='mkdir -p'
alias n='cd ~/Documents/notes/ && v .'
alias p='cd ~/projects'
alias pipreqs='python -m pipreqs.pipreqs --force'
alias r='paru -Rs'
alias rg='rg --hidden --no-ignore --no-messages'
alias rmf='rm -rf'
alias stow='stow --no-folding -Rv'
alias sv='sudoedit'
alias udiskmount='udisksctl mount -b'
alias v='nvim'
alias wgdown='basename /proc/sys/net/ipv4/conf/*vpn | xargs sudo wg-quick down'
alias wgup='sudo wg-quick up'

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt auto_menu  # require an extra TAB press to open the completion menu

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(zoxide init zsh)"
