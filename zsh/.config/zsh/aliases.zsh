alias bt='bluetoothctl'
alias c.='codium . >/dev/null 2>&1'
alias c='codium >/dev/null 2>&1'
alias cat='bat -pp'
alias d='cd ~/dotfiles/'
alias dev='pnpm run dev --host'
alias fd='fd -HI -E Desktop'
alias gc='git clone'
alias gp='git pull'
alias hx='helix'
alias i='paru -S'
alias lg='lazygit'
alias ll='eza -a --icons --group-directories-first -s ext --long'
alias ls='eza -a --icons --group-directories-first -s ext'
alias lsblk='lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINT,FSUSE% | rg -v SWAP'
alias lt='eza -T -L=2 -a --icons --group-directories-first'
alias mirrors='curl -s "https://archlinux.org/mirrorlist/?country=BY&country=DE&country=LV&country=LT&country=NL&country=PL&country=RU&protocol=http&protocol=https&ip_version=4&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 -m 0.2 -'
alias mkdir='mkdir -p'
alias n='cd ~/projects/newtonlabs'
alias p='cd ~/projects'
alias pipreqs='pipreqs --force && sort -u requirements.txt -o requirements.txt'
alias r='paru -Rs'
alias rg='rg --hidden --no-ignore --no-messages'
alias rmf='rm -rf'
alias ssh_butterbot='ssh root@192.168.31.75'
alias ssh_deb_server='ssh igor@192.168.31.104'
alias ssh_printer='ssh igor@192.168.31.94'
alias ssh_racknerd='ssh user@172.245.180.243'
alias stow='stow --no-folding -Rv'
alias sudoe='sudoedit'
alias udiskmount='udisksctl mount -b'
alias v='nvim'
alias wgdown='basename /proc/sys/net/ipv4/conf/*vpn | xargs sudo wg-quick down'
alias wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
alias wgup='sudo wg-quick up'
