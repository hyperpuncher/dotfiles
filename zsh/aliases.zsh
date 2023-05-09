alias ls="exa -a --icons --group-directories-first -s ext"
alias lt="exa -T -L=2 -a --icons --group-directories-first"
alias ll="exa -a --icons --group-directories-first -s ext --long"
alias stow="stow --no-folding -t /home/igor"
alias n="n -dHi"
alias archive="tar -caf"
alias untar="tar -xaf"
alias mkdir="mkdir -p"
alias cat="bat -p"
alias wgup="sudo wg-quick up"
alias wgdown="sudo wg-quick down"
alias rmf="rm -rf"
alias lava="lavat -c yellow -R1 -k red"
alias upscale="realesrgan-ncnn-vulkan -n realesrgan-x4plus"
alias pipup="pip install -U pip && pip list --outdated | awk 'NR > 2 {print $1}' | xargs pip install -U"
alias pipreqs="pipreqs --force && sort -u requirements.txt -o requirements.txt"
alias procsme="procs | rg igor | wc -l"