#!/bin/bash
# shellcheck disable=SC2164,SC2046,SC2086,SC2015,SC1001

usage() {
	if echo "$LANG" | grep -iq "ru"; then
		cat <<EOF
Примеры:  ./install.sh [-h -cfz]
	  ./install.sh			Установить основное (то же, что и ./install -czfpCitP)
	  ./install.sh -UfiC		Установить шрифты, иконки и курсор в $DATADIR/
	  ./install.sh -fUic		Установить шрифты в /local/share/fonts, а иконки и курсор в $DATADIR
	  sudo ./install.sh -cz		Установить zsh/shell конфиг для root пользователя

Основные опции:

  -c, --config		Установить конфиг (zsh и некоторые другие программы)
  -z, --zsh		Установить zsh и использовать его как оболочку по-умолчанию
  -p, --packages	Установить некоторые пакеты (git, vim, lf, lsd, bat, rsync, и т.д.)
  -f, --fonts		Установить шрифты (FiraCode Nerd, JetBrains Nerd, IOS emojis)
  -U, --user-only	Устанавливать шрифты, иконки, курсоры в $HOME !!ЭТУ ОПЦИЮ НУЖНО УКАЗЫВАТЬ ПЕРЕД -f, -C, -i !!
  -C, --cursor		Установить курсор из Plasma 6
  -i, --icons		Установить иконки Tela-circle
  -t, --theme		Установить GTK3 тему в стиле libadwaita
  -P, --pkgmanager	Оптимизиовать $pm

Дополнительные опции:

  -h, --help            Вывести эту помощь и выйти
  -G, --gnome		Штуки для GNOME. Эта опция не будет запущена самостоятельно
  -g, --grub		Установить тему grub из ZorinOS, включить sysrq, savedefault, osprober
  -H, --hyprland	Установить Hyprland. Только для Arch linux
  -E, --gaming		Установить Steam, Bottles, ProtonPlus, mangohud, gamemode, gamescope
  -m, --micro		Испольовать micro в качестве редактора вместо vim и отключить vi-mode в zsh. Эта опция не будет запущена самостоятельно
EOF
	else
		cat <<EOF
Usage:  ./install.sh [-h -cfz]
	./install.sh			Install defaults (equivalent to ./install -czfpCiP)
	./install.sh -UfiC		Install fonts, icons and cursor to $DATADIR/
	./install.sh -fUic		Install fonts to /local/share/fonts, but install icons and cursor to $DATADIR
	sudo ./install.sh -cz		Install zsh/shell config for root user


Default options:

  -c, --config		Install config (shell, zsh and some other programms)
  -z, --zsh		Install zsh and set it as default shell
  -p, --packages	Install some packages (git, vim, lf, lsd, bat, rsync, etc) 
  -f, --fonts		Install fonts (FiraCode Nerd, JetBrains Nerd, IOS emojis)
  -C, --cursor		Install Plasma 6 black breeze cursor
  -i, --icons		Install Tela-circle icons
  -t, --theme		Install libadwaita GTK3 theme
  -P, --pkgmanager	Optimize $pm 

Extra options:

  -h, --help            Display this help and exit
  -U, --user-only	Install fonts, cursor, icons to $HOME !!THIS OPTION MUST BE ENTERED BEFORE -f, -C, -i !!
  -G, --gnome		Some GNOME things
  -g, --grub		Install ZorinOS grub theme, enable sysrq, savedefault, osprober 
  -H, --hyprland	install Hyprland. Arch linux only
  -E, --gaming		Install Steam, Bottles, ProtonPlus, mangohud, gamemode, gamescope
  -m, --micro		Set micro as default editor instead of vim and disable vi-mode in zsh
EOF
	fi
}

flatpaks="com.github.tchx84.Flatseal net.nokyan.Resources"
gamingflatpak="com.valvesoftware.Steam com.usebottles.bottles com.vysp3r.ProtonPlus org.freedesktop.Platform.VulkanLayer.gamescope org.freedesktop.Platform.VulkanLayer.MangoHud org.freedesktop.Platform.VulkanLayer.vkBasalt"
if [ $(command -v pacman) ]; then
	install="sudo pacman -S --needed --noconfirm"
	pm="pacman"
	zsh="zsh sqlite"
	essentials="dash vim git fzf lf lsd bat rsync unzip wget curl base-devel pacman-contrib openssh"
	extrapackages="usbutils tmux glow ripgrep jq wireguard-tools mediainfo neovim yt-dlp pass pass-otp gnome-keyring smartmontools reflector"
	gui="alacritty mpv maim slurp grim tesseract tesseract-data-eng tesseract-data-rus zbar wl-clipboard qpwgraph zathura-pdf-poppler flatpak"
	hyprland="hyprland hyprlock hypridle hyprpicker hyprpaper hyprutils xdg-desktop-portal-gtk xdg-desktop-portal-hyprland waybar dunst cliphist wofi qt6-wayland qt5-wayland polkit-gnome"
	fonts="noto-fonts noto-fonts-cjk"
	gamingrepo="mangohud gamemode gamescope"
elif [ "$TERMUX_VERSION" ]; then
	install="pkg install -y"
	pm="pkg"
	zsh="zsh sqlite"
	essentials="vim git fzf lf lsd bat rsync unzip wget curl which"
	extrapackages="ripgrep jq mediainfo neovim termux-api"
	userinst=true
elif [ $(command -v dnf) ]; then
	install="sudo dnf install -y"
	pm="dnf"
	zsh="zsh sqlite"
	essentials="dash vim git fzf lsd bat rsync unzip wget curl"
	extrapackages="tmux ripgrep jq wireguard-tools mediainfo neovim yt-dlp pass pass-otp smartmontools"
	gui="alacritty mpv maim slurp grim tesseract tesseract-langpack-eng tesseract-langpack-rus zbar wl-clipboard qpwgraph zathura-pdf-poppler"
	gamingrepo="mangohud gamemode gamescope"
elif [ $(command -v epmi) ]; then
	install="epmi"
	pm="epm"
	zsh="zsh sqlite3"
	essentials="dash vim git fzf lf lsd bat rsync unzip wget curl"
	extrapackages="tmux glow ripgrep jq wireguard-tools mediainfo neovim yt-dlp smartmontools"
	gui="alacritty mpv maim slurp grim tesseract tesseract-langpack-eng tesseract-langpack-rus zbar wl-clipboard qpwgraph zathura-pdf-poppler"
	gamingrepo="mangohud gamemode gamescope"
elif [ $(command -v apt) ]; then
	install="sudo apt install -y"
	pm="apt"
	zsh="zsh sqlite3"
	essentials="dash vim git fzf bat rsync unzip wget curl"
	extrapackages="tmux apt-file ripgrep wireguard-tools mediainfo neovim yt-dlp pass pass-extension-otp smartmontools"
	gui="alacritty mpv maim slurp grim tesseract-ocr tesseract-ocr-eng tesseract-ocr-rus zbar-tools wl-clipboard qpwgraph zathura-pdf-poppler flatpak libfuse2t64"
	gamingrepo="mangohud gamemode"
else
	echo "Unable to determine package manager"
fi

[ "$SSH_TTY" ] && gui=""

INSTALLERDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)" && cd "$INSTALLERDIR"
#bak="$(date +\%H\%M\%S\-\%d\%m\%y).bak"
bak="$(date +\%y\%m\%d\-\%H\%M\%S).bak"
BUDIR="backup.$bak"
# BUDIRFP="$(realpath $BUDIR)"
CONFDIR="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}"
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}"
DLDIR="$INSTALLERDIR/extra/downloads"
if [ $(command -v wget2) ]; then
	wget="wget -c --hsts-file=/.cache/wget-hsts"
else
	wget="wget -cq --hsts-file=/.cache/wget-hsts --show-progress"
fi

backupcfg() {
	mkdir -p "$BUDIR"/{config,bin}
	cd "$INSTALLERDIR"/.config
	for f in *; do
		cp -r "$CONFDIR/$f" "../$BUDIR/config/"
	done
	cd "$INSTALLERDIR"/.local/bin
	for f in *; do
		cp -r "$HOME/.local/bin/$f" "../../$BUDIR/bin/"
	done
	cd "$INSTALLERDIR"
	mv -t "$BUDIR/" ~/.bash* ~/.profile ~/.vim* ~/.zshrc ~/.zsh_* ~/.zhistory ~/.zprofile 2>/dev/null
	cp "$CACHEDIR"/zsh/zsh_history "$BUDIR"
}

copycfg() {
	echo "Installing config..."
	mkdir -p "$CONFDIR/git" "$CACHEDIR/zsh" ~/.local/{src,bin}
	[ -d "$CONFDIR/shell" ] && [ -d "$CONFDIR/zsh" ] && read -rsen 1 -p "Reinstall shell config? (y/N) " answ || answ="y"
	if [[ "$answ" == "y" || "$answ" == "Y" ]]; then
		backupcfg 2>/dev/null

		cp -r ./.zshenv "$HOME/"
		cp -r ./.config/* "$CONFDIR/" 2>/dev/null
		cp -r ./.local/* "$HOME/.local/"
		ln -sf "$CONFDIR/lf/lfub" ~/.local/bin/lfub
		[ -f "$CONFDIR/shell/aliasrc-extra" ] || printf "#!/bin/sh\n\n# Extra aliases.\n# This file will not be overwritten when you rerun ./install.sh -c\n# Main file: \$XDG_CONFIG_HOME/shell/aliasrc" >>"$CONFDIR/shell/aliasrc-extra"
		# change distro-specific aliases

		realias "$pm"

		[ ! -f "$CONFDIR/nvim/init.lua" ] && cp -ri ./extra/nvim "$CONFDIR/" # fix vim error in case nvim isn't installed
		[ ! -f "$CONFDIR/shell/bm-dirs" ] && cp ./extra/shell/* "$CONFDIR/shell/"
		sed -i "/typeset -g POWERLEVEL9K_BACKGROUND=/c\  [[ \$SSH_TTY ]] && typeset -g POWERLEVEL9K_BACKGROUND=052 || typeset -g POWERLEVEL9K_BACKGROUND=236" "$CONFDIR/zsh/p10k.zsh"
		# clean ~/ directory
		mkdir -p "$DATADIR"/{icons,fonts,themes} 2>/dev/null
		[ -d ~/.icons ] && mv ~/.icons/* "$DATADIR/icons/" && rmdir ~/.icons
		[ -d ~/.themes ] && mv ~/.themes/* "$DATADIR/themes/" && rmdir ~/.themes
		[ -d ~/.fonts ] && mv ~/.fonts/* "$DATADIR/fonts/" && rmdir ~/.fonts
		[[ -f "$HOME/.gitconfig" && ! -f "$CONFDIR/git/config" ]] && mv ~/.gitconfig "$CONFDIR/git/config" || touch "$CONFDIR/git/config"
		[ "$TERMUX_VERSION" ] && sed -i '/zsh-vi-mode.plugin/ s/^/#/; /ZVM/ s/^/#/' "$CONFDIR/zsh/.zshrc"
		[ -f "$BUDIR/.vimrc" ] && cat ./extra/vimrcAdditions "$BUDIR/.vimrc" >>"$CONFDIR/vim/vimrc" && echo "Your vimrc is now located in ~/.config/vim/vimrc"
	fi
	echo "Done"
}

realias() {
	case $1 in
		pacman) ;;
		dnf)
			sed -e 's/\(alias p="\)[^"]*/\1sudo dnf/' \
				-e 's/\(alias pi="\)[^"]*/\1sudo dnf install/' \
				-e 's/\(alias pu="\)[^"]*/\1sudo dnf update/' \
				-e 's/\(alias puu="\)[^"]*/\1sudo dnf update \&\& sudo dnf upgrade/' \
				-e 's/\(alias prm="\)[^"]*/\1sudo dnf remove/' \
				-e 's/\(alias pcc="\)[^"]*/\1sudo dnf clean all/' \
				-e 's/\(alias psr="\)[^"]*/\1dnf search/' \
				-e 's/\(alias psi="\)[^"]*/\1rpm -qa/' \
				-e 's/\(alias psb="\)[^"]*/\1dnf provides/' \
				-e 's/\(alias ppi="\)[^"]*/\1dnf info/' \
				-i "$CONFDIR/shell/aliasrc"
			;;
		apt)
			if [ $(command -v nala) ]; then
				sed -e '/alias p="/ialias apt="nala"' \
					-e 's/\(alias p="\)[^"]*/\1sudo nala/' \
					-e 's/\(alias pi="\)[^"]*/\1sudo nala install/' \
					-e 's/\(alias pu="\)[^"]*/\1sudo nala update/' \
					-e 's/\(alias puu="\)[^"]*/\1sudo nala upgrade/' \
					-e 's/\(alias prm="\)[^"]*/\1sudo nala remove --purge/' \
					-e 's/\(alias pcc="\)[^"]*/\1sudo nala clean/' \
					-e 's/\(alias psr="\)[^"]*/\1nala search/' \
					-e 's/\(alias psi="\)[^"]*/\1nala list --installed/' \
					-e 's/\(alias psb="\)[^"]*/\1apt-file search/' \
					-e 's/\(alias ppi="\)[^"]*/\1nala show/' \
					-i "$CONFDIR/shell/aliasrc"
			else
				sed -e 's/\(alias p="\)[^"]*/\1sudo apt/' \
					-e 's/\(alias pi="\)[^"]*/\1sudo apt install/' \
					-e 's/\(alias pu="\)[^"]*/\1sudo apt update/' \
					-e 's/\(alias puu="\)[^"]*/\1sudo apt update \&\& sudo apt upgrade/' \
					-e 's/\(alias prm="\)[^"]*/\1sudo apt remove --purge/' \
					-e 's/\(alias pcc="\)[^"]*/\1sudo apt clean/' \
					-e 's/\(alias psr="\)[^"]*/\1apt search/' \
					-e 's/\(alias psi="\)[^"]*/\1apt list --installed/' \
					-e 's/\(alias psb="\)[^"]*/\1apt-file search/' \
					-e 's/\(alias ppi="\)[^"]*/\1apt show/' \
					-i "$CONFDIR/shell/aliasrc"
			fi
			;;
		epm)
			sed -e 's/\(alias p="\)[^"]*/\1epm/' \
				-e 's/\(alias pi="\)[^"]*/\1epm install/' \
				-e 's/\(alias pu="\)[^"]*/\1epm update/' \
				-e 's/\(alias puu="\)[^"]*/\1epm Upgrade/' \
				-e 's/\(alias prm="\)[^"]*/\1epm remove/' \
				-e 's/\(alias pcc="\)[^"]*/\1epm clean/' \
				-e 's/\(alias psr="\)[^"]*/\1epm search/' \
				-e 's/\(alias psi="\)[^"]*/\1epm qp/' \
				-e 's/\(alias psb="\)[^"]*/\1epm sf/' \
				-e 's/\(alias ppi="\)[^"]*/\1epm show/' \
				-i "$CONFDIR/shell/aliasrc"
			;;
		pkg)
			sed -e 's/\(alias p="\)[^"]*/\1pkg/' \
				-e 's/\(alias pi="\)[^"]*/\1pkg install/' \
				-e 's/\(alias pu="\)[^"]*/\1pkg update/' \
				-e 's/\(alias puu="\)[^"]*/\1pkg update \&\& pkg upgrade/' \
				-e 's/\(alias prm="\)[^"]*/\1pkg remove --purge/' \
				-e 's/\(alias pcc="\)[^"]*/\1pkg clean/' \
				-e 's/\(alias psr="\)[^"]*/\1pkg search/' \
				-e 's/\(alias psi="\)[^"]*/\1pkg list-installed/' \
				-e '/alias psb=.*/d' \
				-e 's/\(alias ppi="\)[^"]*/\1pkg show/' \
				-e 's/ --preserve=xattr//' \
				-e 's/ --xattrs//' \
				-e 's/-vvrPlutXUh/-vvrPlutUh/' \
				-i "$CONFDIR/shell/aliasrc"
			;;
		*) echo "Unable to determine package manager" ;;
	esac
}

# Install zsh if not installed
installzsh() {
	[ ! $(command -v zsh) ] && echo "zsh not found. Installing..." && $install $zsh
	[ ! $(command -v chsh) ] && $install util-linux-user # Fedora moment XD
	if [ $(echo "$SHELL" | xargs basename) != "zsh" ]; then
		echo "Changing shell to zsh"
		currentuser="$USER"
		sudo chsh -s "$(command -v zsh)" "$currentuser" &&
			echo "Done. You need to relog" && sleep 2
	else
		echo "zsh is already installed. Skipping"
	fi
}

# Install packages and dependencies
installpkgs() {
	echo "Installing Packages..."
	[[ -z "$KDE_SESSION_VERSION" && $(command -v xdg-mime) ]] && defaultfm="$(xdg-mime query default inode/directory)" # sometimes lf sets as default file manager
	case $pm in
		pacman)
			$install $essentials $extrapackages $gui
			if [ ! $(command -v yay) ]; then
				cd "$DLDIR" && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si
				cd "$INSTALLERDIR"
			fi
			sudo pacman -Fy
			#sudo cp ./extra/hooks/dashtobinsh.hook /usr/share/libalpm/hooks/ # Breaks some system scripts
			#sudo ln -sfT dash /bin/sh			# Breaks some system scripts
			;;
		dnf)
			$install $essentials $extrapackages $gui
			echo "Installing codecs"
			$install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
			$install lame\* --exclude=lame-devel
			sudo dnf group upgrade -y --with-optional Multimedia
			;;
		apt)
			$install $essentials $extrapackages $gui
			sudo apt-file update
			[ ! "$SSH_TTY" ] && flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
			if [ ! $(command -v lsd) ]; then
				cd "$DLDIR"
				$wget https://github.com/lsd-rs/lsd/releases/latest/download/lsd_1.1.5_amd64.deb && sudo apt install -y ./lsd_1.1.5_amd64.deb
				cd "$INSTALLERDIR"
			fi
			;;
		epm)
			$install $essentials $extrapackages $gui
			;;
		pkg) $install $essentials $extrapackages ;;
		*) echo "Unable to determine package manager" ;;
	esac

	if [[ ! $(command -v blobdrop) && ! "$SSH_TTY" ]]; then
		cd "$DLDIR"
		$wget https://github.com/vimpostor/blobdrop/releases/latest/download/blobdrop-x86_64.AppImage && mv blobdrop-x86_64.AppImage ~/.local/bin/blobdrop
		chmod +x ~/.local/bin/blobdrop
		cd "$INSTALLERDIR"
	fi
	if [ ! $(command -v lf) ]; then
		cd "$DLDIR"
		$wget https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz
		tar -xf lf-linux-amd64.tar.gz
		if [ -f ./lf ]; then
			[ "$userinst" == true ] && mv -r ./lf ~/.local/bin/lf || sudo mv ./lf /usr/bin/lf
		fi
		cd "$INSTALLERDIR"
	fi

	[ ! "$SSH_TTY" ] && flatpak install $flatpaks
	if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
		flatpak install io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager
	fi

	[[ -z $KDE_SESSION_VERSION && -x $(command -v xdg-mime) ]] && xdg-mime default $defaultfm inode/directory
	cd "$INSTALLERDIR"
	# Download nvim spellcheck files
	if [ ! -f "$DATADIR/nvim/site/spell/ru.utf-8.spl" ]; then
		mkdir -p "$DATADIR/nvim/site/spell"
		curl 'http://ftp.vim.org/pub/vim/runtime/spell/ru.utf-8.spl' -o "$DATADIR/nvim/site/spell/ru.utf-8.spl"
	fi
	echo "Done"
}

installfonts() {
	echo "Installing Fonts..."
	mkdir -p "$CONFDIR/fontconfig"
	mkdir -p "$DATADIR/fonts"
	cd "$DLDIR"
	[ ! $(command -v unzip) ] && $install unzip

	nerdfonts=(NerdFontsSymbolsOnly FiraCode JetBrainsMono)
	for nerdfont in "${nerdfonts[@]}"; do
		if ! fc-list | grep -iq "$nerdfont"; then
			$wget "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$nerdfont.zip"
			[ ! -d "./$nerdfont" ] && unzip -q "./$nerdfont.zip" -d "./$nerdfont" || continue
			[ "$userinst" == true ] && cp -r "./$nerdfont" "$DATADIR/fonts/" || sudo cp -r "./$nerdfont" /usr/share/fonts/
			fontinstalled=true
		else
			echo "$nerdfont is already installed"
		fi
	done

	if ! fc-list | grep -iq applecoloremoji; then
		## these are also cool: https://github.com/13rac1/twemoji-color-font
		## will require fontconfig tweaking tho, as now apple emojis are forced
		$wget https://github.com/samuelngs/apple-emoji-linux/releases/latest/download/AppleColorEmoji.ttf
		[ "$userinst" == true ] && cp -r ./AppleColorEmoji.ttf "$DATADIR/fonts/" || sudo cp -r ./AppleColorEmoji.ttf /usr/share/fonts/
		fontinstalled=true
	else
		echo "AppleColorEmoji is already installed"
	fi

	if ! fc-list | grep -iq inter; then
		$wget https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
		[ ! -d "./Inter" ] && unzip -q ./Inter-4.1.zip -d ./Inter
		if [ "$userinst" == true ]; then
			mkdir -p "$DATADIR/fonts/Inter"
			cp ./Inter/{Inter.ttc,InterVariable-Italic.ttf,InterVariable.ttf} "$DATADIR/fonts/Inter"
		else
			sudo mkdir -p "/usr/share/fonts/Inter"
			sudo cp ./Inter/{Inter.ttc,InterVariable-Italic.ttf,InterVariable.ttf} /usr/share/fonts/Inter/
		fi
		fontinstalled=true
	else
		echo "Inter is already installed"
	fi

	[ "$fonts" ] && $install $fonts
	[ "$fontinstalled" ] && echo "Updating font cache..." && fc-cache -f
	cd "$INSTALLERDIR"
	flatpak override --user --filesystem=xdg-config/fontconfig:ro
	echo "Done"
	echo "You can find more compatible fonts at https://nerdfonts.com" && sleep 2
}

installcursor() {
	echo "Installing Cursor..."
	mkdir -p "$DATADIR/icons"
	[ "$userinst" == true ] && cp -r ./extra/cursor/Bruh "$DATADIR/icons/" || sudo cp -r ./extra/cursor/Bruh /usr/share/icons/
	gsettings set org.gnome.desktop.interface cursor-theme "Bruh"
	#[[ -n $CINNAMONVARIABLE ]] && dconf write /org/cinnamon/desktop/interface/cursor-theme "'Bruh'" # Untested
	echo "Done"
}

installicons() {
	echo "Installing Icons..."
	[ ! -f "$DLDIR/master.zip" ] && $wget https://github.com/vinceliuice/Tela-circle-icon-theme/archive/refs/heads/master.zip -P "$DLDIR"/
	[ ! -d "$DLDIR/Tela-circle-icon-theme-master" ] && unzip -q "$DLDIR/master.zip" -d "$DLDIR"/
	if [ -d "$DLDIR/Tela-circle-icon-theme-master" ]; then
		cd "$DLDIR/Tela-circle-icon-theme-master"
		[ "$userinst" == true ] && ./install.sh || sudo ./install.sh
		gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark"
		#[[ -n $CINNAMONVARIABLE ]] && dconf write /org/cinnamon/desktop/interface/icon-theme "'Tela-circle-dark'" # Untested
	else
		echo "Something went wrong"
	fi
	cd "$INSTALLERDIR"
	echo "Done"
}

installtheme() {
	echo "Installing Theme"
	mkdir -p "$DATADIR/themes"
	cd "$DLDIR"
	$wget https://github.com/lassekongo83/adw-gtk3/releases/download/v5.6/adw-gtk3v5.6.tar.xz
	mkdir -p adw
	tar -xf adw-gtk3v5.6.tar.xz --directory=./adw
	if [ -d "./adw/adw-gtk3" ]; then
		[ "$userinst" == true ] && cp -r ./adw/{adw-gtk3,adw-gtk3-dark} "$DATADIR/themes/" || sudo cp -r ./adw/{adw-gtk3,adw-gtk3-dark} /usr/share/themes/
		gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	fi
	flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
	cd "$INSTALLERDIR"
	echo "Done"
}

optimizepm() {
	echo "Optimizing $pm..."
	defgeo="RU"
	geo="$(curl -s https://ifconfig.io/all | grep country_code | cut -d' ' -f2)"
	[ ! "$geo" ] && geo="$defgeo"
	case $pm in
		pacman)
			pmcfg="/etc/pacman.conf"
			if [ -f "$pmcfg" ]; then
				echo "Configuring pacman.conf"
				sudo cp -v "$pmcfg" "$pmcfg.$bak"
				sudo sed -i "s/^#Color/Color/; s/^#ParallelDownloads.*/ParallelDownloads = 5/" $pmcfg
			else
				echo "$pmcfg not found"
			fi

			grep -Eiq 'manjaro|cachyos' /etc/os-release && return
			[ ! $(command -v reflector) ] && $install reflector
			pmmirror="/etc/pacman.d/mirrorlist"
			if [ -f "$pmmirror" ]; then
				echo "Generating mirrorlist..."
				echo "Backing up mirrorlist"
				sudo cp -v "$pmmirror" "$pmmirror.$bak"
				echo "Ranking mirrors..."
				reflector -c "$geo" -c "$defgeo" --age 24 --protocol https --sort rate --save "$pmmirror"
				sudo pacman -Syy
			fi
			;;

		dnf)
			pmcfg="/etc/dnf/dnf.conf"
			if [ -f "$pmcfg" ]; then
				sudo cp -v "$pmcfg" "$pmcfg.$bak"
				sudo sed -i "s/^#fastestmirror=.*/fastestmirror=True/" "$pmcfg"
				grep -q "^fastestmirror=" "$pmcfg" || echo "fastestmirror=True" | sudo tee -a "$pmcfg"
				#
				sudo sed -i "s/^#max_parallel_downloads=.*/max_parallel_downloads=5/" "$pmcfg"
				grep -q "^max_parallel_downloads=" "$pmcfg" || echo "max_parallel_downloads=5" | sudo tee -a "$pmcfg"
				#
				sudo sed -i "s/#^defaultyes=.*/defaultyes=True/" "$pmcfg"
				grep -q "^defaultyes=" "$pmcfg" || echo "defaultyes=True" | sudo tee -a "$pmcfg"
				#
				sudo sed -i "s/^#keepcache=.*/keepcache=True/" "$pmcfg"
				grep -q "^keepcache=" "$pmcfg" || echo "keepcache=True" | sudo tee -a "$pmcfg"
			else
				echo "$pmcfg not found"
			fi
			sudo dnf clean all
			$install dnf-automatic
			sudo systemctl enable dnf-automatic.timer
			;;

		apt)
			echo "Installing Nala..."
			[ ! $(command -v nala) ] && $install nala
			if [ $(command -v nala) ]; then
				grep -q "scrolling_text = false" /etc/nala/nala.conf || sudo sed -i "/scrolling_text/ s/true/false/; /update_show_packages/ s/false/true/; /assume_yes/ s/false/true/" /etc/nala/nala.conf
				echo "Aliasing nala to apt..."
				if [ -f "$CONFDIR/shell/aliasrc" ]; then
					sed -i "s/apt /nala /g; s/update \&\&.*\"/upgrade\"/; s/#placeholder-basic1/alias apt='nala'/" "$CONFDIR/shell/aliasrc"
				else
					echo "$CONFDIR/shell/aliasrc not found"
				fi
			else
				echo "Failed to install Nala"
			fi
			;;
	esac
	echo "Done"
}

tweakgrub() {
	echo "Tweaking grub..."
	defaultgrub="/etc/default/grub"
	if [ -f "$defaultgrub" ]; then
		localdefaultgrub="./extra/grub"
		echo "Backing up $defaultgrub"
		sudo cp -v "$defaultgrub" "$defaultgrub.$bak"
		sudo cp "$defaultgrub" "$localdefaultgrub"
		echo "modifying $defaultgrub"
		sed -e 's/^#\?GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' \
			-e 's/^#\?GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' \
			-e 's/^#\?GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/' \
			-e 's/^#\?GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' \
			-e 's/^#\?GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=false/' \
			-e 's/^#\?GRUB_TERMINAL_OUTPUT=.*/GRUB_TERMINAL_OUTPUT=gfxterm/' \
			-e '/^#GRUB_GFXMODE/ s/^#//' \
			-e 's/^#\?GRUB_THEME=.*/GRUB_THEME="\/boot\/grub\/themes\/zorin\/theme.txt"/' \
			-e 's/^#\?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' \
			-e '/sysrq_always_enabled=1/! s/\(GRUB_CMDLINE_LINUX="[^"]*\)/\1 sysrq_always_enabled=1/' \
			-i $localdefaultgrub
		grep -q "GRUB_DEFAULT" $localdefaultgrub || echo "GRUB_DEFAULT=saved" >>$localdefaultgrub
		grep -q "GRUB_SAVEDEFAULT" $localdefaultgrub || sed -i '/GRUB_DEFAULT=/ a\GRUB_SAVEDEFAULT=true' $localdefaultgrub
		grep -q "GRUB_GFXMODE" $localdefaultgrub || echo "GRUB_GFXMODE=auto" >>$localdefaultgrub
		grep -q "GRUB_THEME" $localdefaultgrub || echo "GRUB_THEME=/boot/grub/themes/zorin/theme.txt" >>$localdefaultgrub

		if [ -d "/boot/grub" ]; then
			sudo mkdir -p /boot/grub/themes
			sudo cp -r ./extra/zorin /boot/grub/themes/ | head -n 1
			sudo cp $localdefaultgrub $defaultgrub
			if [ $(command -v update-grub) ]; then
				sudo update-grub
			else
				sudo grub-mkconfig -o /boot/grub/grub.cfg
			fi

		elif [ -d "/boot/grub2" ]; then
			sudo mkdir -p /boot/grub2/themes
			sudo cp -r ./extra/zorin /boot/grub2/themes/ | head -n 1
			sed -i 's/boot\/grub\//boot\/grub2\//' $localdefaultgrub
			sudo cp $localdefaultgrub $defaultgrub
			if [ $(command -v update-grub) ]; then
				sudo update-grub
			else
				sudo grub2-mkconfig -o /boot/grub2/grub.cfg
			fi

		else
			echo "Directory /boot/grub or /boot/grub2 not found. grub-mkconfig failed"
		fi
	else
		echo "$defaultgrub not found"
	fi
	echo "Done"
}

tweakgnome() {
	echo "Changing GNOME keybindings"

	mkdir -p "$BUDIR"
	dconf dump /org/gnome/ >"$BUDIR/dconf-org.gnome"

	for num in $(seq 9); do
		gsettings set "org.gnome.shell.keybindings" "switch-to-application-${num}" "[]"
		gsettings set "org.gnome.desktop.wm.keybindings" "switch-to-workspace-${num}" "['<Super>${num}']"
		gsettings set "org.gnome.desktop.wm.keybindings" "move-to-workspace-${num}" "['<Shift><Super>${num}']"
	done

	gsettings set "org.gnome.desktop.wm.keybindings" "close" "['<Super>q']"
	gsettings set "org.gnome.shell.keybindings" "toggle-message-tray" "['<Super>m']"
	gsettings set "org.gnome.settings-daemon.plugins.media-keys" "home" "['<Super>e']"
	gsettings set "org.gnome.settings-daemon.plugins.media-keys" "search" "['<Super>d']"
	gsettings set "org.gnome.settings-daemon.plugins.media-keys" "screensaver" "['<Super>l', '<Super>Escape']"

	gsettings set "org.gnome.desktop.wm.keybindings" "switch-applications" "['<Super>Tab']"
	gsettings set "org.gnome.desktop.wm.keybindings" "switch-applications-backward" "['<Shift><Super>Tab']"
	gsettings set "org.gnome.desktop.wm.keybindings" "switch-windows" "['<Alt>Tab']"
	gsettings set "org.gnome.desktop.wm.keybindings" "switch-windows-backward" "['<Shift><Alt>Tab']"

	gsettings set "org.gnome.mutter" "dynamic-workspaces" "false"
	gsettings set "org.gnome.mutter" "attach-modal-dialogs" "false"
	gsettings set "org.gnome.mutter" "center-new-windows" "true"

	gsettings set "org.gnome.desktop.peripherals.keyboard" "repeat-interval" "25"
	gsettings set "org.gnome.desktop.peripherals.keyboard" "delay" "250"

	gsettings set "org.gnome.desktop.wm.preferences" "num-workspaces" "6"
	gsettings set "org.gnome.desktop.wm.preferences" "resize-with-right-button" "true"
	gsettings set "org.gnome.desktop.wm.preferences" "focus-mode" "sloppy"

	gsettings set "org.gnome.desktop.interface" "monospace-font-name" "FiraCode Nerd Font 10"
	gsettings set "org.gnome.desktop.interface" "show-battery-percentage" "true"
	gsettings set "org.gnome.desktop.interface" "clock-show-weekday" "true"
	gsettings set "org.gnome.desktop.calendar" "show-weekdate" "true"

	gsettings set "org.gnome.desktop.input-sources" "xkb-options" "['compose:ralt']"
	gsettings set "org.gnome.desktop.input-sources" "per-window" "true"

	read -rn 1 -p "Select keyboard layout switch keymap: 1-CAPSLOCK, 2-ALT+SHIFT, n-DEFAULT: " kb && echo ""
	case $kb in
		1) gsettings set "org.gnome.desktop.input-sources" "xkb-options" "['grp:caps_toggle', 'compose:ralt']" ;;
		2)
			gsettings set "org.gnome.desktop.wm.keybindings" "switch-input-source" "['<Super>space', 'XF86Keyboard', '<Alt>Shift_L']"
			gsettings set "org.gnome.desktop.wm.keybindings" "switch-input-source-backward" "['<Shift><Super>space', '<Shift>XF86Keyboard', '<Shift>Alt_L']"
			;;
		*) ;;
	esac

	read -rsen 1 -p "Install some extensions? (Y/n) " answ
	if [[ "$answ" == "y" || "$answ" == "Y" || -z "$answ" ]]; then
		if [ ! $(command -v jq) ]; then
			echo "jq not found, installing..."
			$install jq
		fi

		extList=(
			appindicatorsupport@rgcjonas.gmail.com
			Vitals@CoreCoding.com
			blur-my-shell@aunetx
			gnome-ui-tune@itstime.tech
			status-area-horizontal-spacing@mathematical.coffee.gmail.com
			pano@elhan.io
			panelScroll@sun.wxg@gmail.com
			middleclickclose@paolo.tranquilli.gmail.com
			auto-move-windows@gnome-shell-extensions.gcampax.github.com
			ds4battery@slie.ru
			gsconnect@andyholmes.github.io
			just-perfection-desktop@just-perfection
			do-not-disturb-while-screen-sharing-or-recording@marcinjahn.com
			workspaces-by-open-apps@favo02.github.com
			foresight@pesader.dev
		)

		extInstalled=$(gnome-extensions list)
		gnomeVersion=$(gnome-shell --version | grep -o "[0-9].")

		query="https://extensions.gnome.org/extension-query/?shell_version=$gnomeVersion"
		for uuid in "${extList[@]}"; do
			query+="&uuid=$uuid"
		done
		extInfo=$(curl -s "$query")

		declare -A extFullNames
		declare -A extDescriptions
		declare -A extLinks
		for uuid in "${extList[@]}"; do
			extFullNames["$uuid"]=$(jq -r --arg uuid "$uuid" '.extensions[] | select(.uuid==$uuid) | .name' <<<"$extInfo")
			extDescriptions["$uuid"]=$(jq -r --arg uuid "$uuid" '.extensions[] | select(.uuid==$uuid) | .description' <<<"$extInfo")
			extLinks["$uuid"]=$(jq -r --arg uuid "$uuid" '.extensions[] | select(.uuid==$uuid) | .link' <<<"$extInfo")
		done

		for uuid in "${extList[@]}"; do

			extFullName="${extFullNames[$uuid]}"
			echo "$extInstalled" | grep "$uuid" >/dev/null && printf "\033[0;34m%s\033[0m is already installed\n" "$extFullName" && continue # skip installed
			extDescription="${extDescriptions[$uuid]}"
			extLink="https://extensions.gnome.org${extLinks[$uuid]}"
			[ -z "$extFullName" ] && continue # skip incompatible

			while true; do
				printf "Install \033[0;34m%s\033[0m? (Y/n/(d)escription) " "$extFullName"
				read -rsen 1 answ
				case "$answ" in
					"y" | "Y" | "")
						gdbus call --session --dest "org.gnome.Shell" --object-path "/org/gnome/Shell" --method org.gnome.Shell.Extensions.InstallRemoteExtension "$uuid" >/dev/null
						break
						;;
					"d" | "D") printf "=========================\n %s \n\n \033[0;34m%s\033[0m \n=========================\n\n" "$extDescription" "$extLink" ;;
					*) break ;;
				esac
			done
		done

	fi

	echo "Done"
	# echo "You can restore settings using \`dconf load /org/gnome < $BUDIRFP/dconf-org.gnome\` command" # can you?
}

installhyprland() {
	echo "Installing Hyprland..."
	if [ "$hyprland" ]; then
		$install $hyprland
		echo "Done"
	else
		echo "Unsupported distro"
	fi
}

installgaming() {
	echo "Installing gaming apps..."
	$install $gamingrepo
	flatpak install $gamingflatpak
	flatpak override --user --filesystem=xdg-config/MangoHud:ro com.valvesoftware.Steam
	flatpak override --user --filesystem=xdg-config/MangoHud:ro com.usebottles.bottles
	flatpak override --user --filesystem=xdg-data/applications com.usebottles.bottles
	flatpak override --user --filesystem=~/Games com.usebottles.bottles
	flatpak override --user --filesystem=~/.local/share/Steam com.usebottles.bottles
	flatpak override --user --filesystem=~/.var/app/com.valvesoftware.Steam/data/Steam com.usebottles.bottles

	echo "Done"
}

switchtomicro() {
	echo "Switching to micro..."
	[ ! $(command -v micro) ] && echo "Micro not found. Installing..." && $install micro
	sed -i 's/EDITOR="n\?vim"/EDITOR="micro"/; s/VISUAL="n\?vim"/VISUAL="micro"/; /MANPAGER=.nvim/d' "$CONFDIR/shell/profile"
	sed -i '/vi-mode.plugin/ s/^/#/; s/#bindkey -e/bindkey -e/; /ZVM/ s/^/#/' "$CONFDIR/zsh/.zshrc"
	echo "Done. Relog to see changes"
}

while getopts ":hcUfpzCigPGHEtm-:" opt; do case "${opt}" in
	h) usage ;;
	c) copycfg ;;
	z) installzsh ;;
	f) installfonts ;;
	p) installpkgs ;;
	U) userinst=true ;;
	C) installcursor ;;
	i) installicons ;;
	t) installtheme ;;
	P) optimizepm ;;
	g) tweakgrub ;;
	G) tweakgnome ;;
	H) installhyprland ;;
	E) installgaming ;;
	m) switchtomicro ;;
	-) case "${OPTARG}" in
		help) usage ;;
		config) copycfg ;;
		zsh) installzsh ;;
		fonts) installfonts ;;
		packages) installpkgs ;;
		user-only) userinst=true ;;
		cursor) installcursor ;;
		icons) installicons ;;
		theme) installtheme ;;
		pkgmanager) optimizepm ;;
		grub) tweakgrub ;;
		gnome) tweakgnome ;;
		hyprland) installhyprland ;;
		gaming) installgaming ;;
		micro) switchtomicro ;;
		*) echo "Invalid option: --$OPTARG" && usage && exit 1 ;;
	esac ;;
	*) echo "Invalid option: -$OPTARG" && usage && exit 1 ;;
esac done

if [[ -z "$*" || "$*" == "-U" || "$*" == "--user-only" ]]; then
	copycfg
	installzsh
	installpkgs
	installfonts
	installcursor
	installicons
	installtheme
	optimizepm
fi
