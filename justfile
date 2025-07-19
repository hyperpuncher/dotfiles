# List of all commands
default:
	just -l

# Bootstrap
bootstrap: essential ssh paru stow mirrors soft greetd misc

# Essentials packages
essential:
	sudo pacman -S neovim age zsh stow rustup openssh ccache pigz pbzip2 pacman-contrib foot greetd-tuigreet

# Decrypt & install SSH key
ssh:
	echo "Decrypting ssh keys"
	mkdir -p ~/.ssh
	age -d -o ~/.ssh/id_ed25519 ./ssh/.ssh/id_ed25519.age

# Build & install AUR helper paru
paru:
	echo "Installing paru"
	rustup default stable
	git clone https://aur.archlinux.org/paru.git /tmp/paru
	makepkg --noconfirm -si -D /tmp/paru

# Dotfile deployment via GNU stow
stow:
	echo "Linking configs"
	stow --no-folding -Rv \
	alacritty \
	applications \
	btop \
	darkman \
	dunst \
	foot \
	git \
	glow \
	gtk \
	home \
	hyprland \
	icons \
	jamesdsp \
	mangohud \
	mpv \
	mumble \
	npm \
	nvim \
	opencode \
	pacman \
	paru \
	pipewire \
	pulse \
	rofi \
	spotify \
	ssh \
	tmux \
	waybar \
	wireplumber \
	zsh

# Update mirror list & refresh DB
mirrors:
	echo "Updating mirrors"
	curl -s "https://archlinux.org/mirrorlist/?country=BY&country=DE&country=LV&country=LT&country=NL&country=PL&country=RU&protocol=http&protocol=https&ip_version=4&use_mirror_status=on" \
	| sed -e 's/^#Server/Server/' -e '/^#/d' \
	| rankmirrors -n 5 -m 0.2 - \
	| sudo tee /etc/pacman.d/mirrorlist
	paru -Sy

# Install all packages listed in ./soft
soft:
	echo "Installing soft"
	paru -S $(cat soft)

# Greeter configuration & systemd enable
greetd:
	sudo systemctl enable greetd.service
	sudo sed -i 's/^command.*/command = "tuigreet --window-padding 2 --asterisks --remember --remember-session --time --width 50 --cmd Hyprland"/' /etc/greetd/config.toml
	sudo chmod -R go+r /etc/greetd
	sudo sed -i '6i auth optional pam_gnome_keyring.so' /etc/pam.d/greetd
	sudo sed -i '$$a session optional pam_gnome_keyring.so auto_start' /etc/pam.d/greetd

# Miscellaneous tweaks
misc:
	sudo localectl set-locale LC_TIME=en_IE.UTF-8
	chsh -s /usr/bin/zsh
	sudo ln -sf /usr/share/fontconfig/conf.avail/10-hinting-none.conf /etc/fonts/conf.d/
	sudo usermod -aG video $(whoami)
