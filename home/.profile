export BROWSER=helium-browser
export EDITOR=nvim
export MANPAGER='nvim +Man!'
export PAGER="moor -no-linenumbers"
export VISUAL=nvim
export PLAYWRIGHT_MCP_EXECUTABLE_PATH=/usr/sbin/chromium

# These exports are also used by the paths below and npmrc.
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export ANDROID_AVD_HOME="$XDG_CONFIG_HOME/.android/avd"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgreprc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export NODE_COMPILE_CACHE="$XDG_CACHE_HOME/node"

export PATH="$PATH:$HOME/dotfiles/scripts:$HOME/.local/bin:$CARGO_HOME/bin:$XDG_DATA_HOME/npm/bin:$GOPATH/bin:$XDG_CACHE_HOME/.bun/bin"

export SOPS_AGE_RECIPIENTS=age1tnkh972ad6ddm6grzmjjnlcq90247r36ywq220y3ytnkw9aqwcsqzwxxu4

for dir in \
	"$XDG_CACHE_HOME" \
	"$XDG_CONFIG_HOME" \
	"$XDG_DATA_HOME" \
	"$XDG_STATE_HOME" \
	"$CARGO_HOME" \
	"$GNUPGHOME" \
	"$GOPATH" \
	"$XDG_CONFIG_HOME/gtk-2.0" \
	"$XDG_CONFIG_HOME/npm" \
	"$PARALLEL_HOME" \
	"$XDG_DATA_HOME/pnpm" \
	"$RUSTUP_HOME" \
	"$WINEPREFIX" \
	"$NODE_COMPILE_CACHE"; do
	[ ! -d "$dir" ] && mkdir -p "$dir"
done

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
