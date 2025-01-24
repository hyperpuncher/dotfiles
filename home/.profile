export GPG_TTY=$TTY
export BROWSER=brave-beta
export EDITOR=nvim
export PAGER='moar -style dracula -no-linenumbers'
export MANPAGER='nvim +Man!'
export TERM=xterm-256color
export VISUAL=nvim
export BAT_THEME="Dracula"

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export ANDROID_HOME="$XDG_DATA_HOME/android"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export WINEPREFIX="$XDG_DATA_HOME/wine"

export PATH=$PATH:$HOME/dotfiles/scripts:$HOME/.local/bin:$CARGO_HOME/bin:$PNPM_HOME:$XDG_DATA_HOME/npm/bin:$GOPATH/bin

export SOPS_AGE_RECIPIENTS=age1tnkh972ad6ddm6grzmjjnlcq90247r36ywq220y3ytnkw9aqwcsqzwxxu4

export http_proxy=socks5://127.0.0.1:10808
export https_proxy=$http_proxy
