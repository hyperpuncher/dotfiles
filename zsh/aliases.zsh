alias archive='tar -caf'
alias bt='bluetoothctl'
alias cat='bat -p'
alias cd..='cd ..'
alias fd='fd -H'
alias i='paru -S'
alias killp='ps x -o pid,cmd | fzf -e | awk "{print \$1}" | xargs kill'
alias lava='lavat -c yellow -R1 -k red'
alias lg='lazygit'
alias ll='exa -a --icons --group-directories-first -s ext --long'
alias ls='exa -a --icons --group-directories-first -s ext'
alias lt='exa -T -L=2 -a --icons --group-directories-first'
alias mkdir='mkdir -p'
alias pipreqs='pipreqs --force && sort -u requirements.txt -o requirements.txt'
alias pipup='pip install -U pip && pip list --outdated | awk "NR > 2 {print \$1}" | xargs pip install -U'
alias procsme='procs | rg igor | wc -l'
alias proj='cd "/home/igor/projects/$(command ls ~/projects | fzf)" && nvim .'
alias r='paru -Rs'
alias rmf='rm -rf'
alias ssh_butterbot='ssh root@192.168.31.75'
alias ssh_proxmox='ssh igor@192.168.31.104'
alias stow='stow --no-folding -t /home/igor'
alias untar='tar -xaf'
alias upscale='realesrgan-ncnn-vulkan -n realesrgan-x4plus'
alias v='nvim'
alias wgdown='sudo wg-quick down'
alias wgup='sudo wg-quick up'
