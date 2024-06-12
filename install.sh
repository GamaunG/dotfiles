#!/bin/bash
usage() {
  if [ $(echo $LANG | grep "ru") ]; then
  cat << EOF
Примеры:  ./install.sh [-h -cfz]
	  ./install.sh			Установить основное (то же, что и ./install -czfpCitPg)
	  ./install.sh -UfiC		Установить шрифты, иконки и курсор в $DATADIR/
	  ./install.sh -fUic		Установить шрифты в /local/share/fonts, а иконки и курсор в $DATADIR
	  sudo ./install.sh -cz		Установить zsh/shell конфиг для root пользователя

Основные опции:

  -c, --config		Установить конфиг (zsh и некоторые другие программы)
  -z, --zsh		Установить zsh и использовать его как оболочку по-умолчанию
  -f, --fonts		Установить шрифты (FiraCode Nerd, JetBrains Nerd, IOS emojis)
  -p, --packages	Установить некоторые пакеты (git, vim, lf, lsd, bat, rsync, и т.д.) 
  -U, --user-only	Устанавливать шрифты, иконки, курсоры в $HOME !!ЭТУ ОПЦИЮ НУЖНО УКАЗЫВАТЬ ПЕРЕД -f, -C, -i !!
  -C, --cursor		Установить курсор из Plasma 6
  -i, --icons		Установить иконки Tela-circle
  -t, --theme		Установить GTK3 тему в стиле libadwaita
  -P, --pkgmanager	Оптимизиовать $pm 
  -g, --grub		Установить тему grub из ZorinOS, включить sysrq, savedefault, osprober 

Дополнительные опции:

  -h, --help            Вывести эту помощь и выйти
  -G, --gnome		Штуки для GNOME. Эта опция не будет запущена самостоятельно 
  -H, --hyprland	Установить Hyprland. Только для Arch linux 
  -E, --gaming		Установить Steam, Bottles, ProtonUp-qt, mangohud, gamemode, gamescope
  -m, --micro		Испольовать micro в качестве редактора вместо vim и отключить vi-mode в zsh. Эта опция не будет запущена самостоятельно 
EOF
  else
  cat << EOF
Usage:  ./install.sh [-h -cfz]
	./install.sh			Install defaults (equivalent to ./install -czfpCiPg)
	./install.sh -UfiC		Install fonts, icons and cursor to $DATADIR/
	./install.sh -fUic		Install fonts to /local/share/fonts, but install icons and cursor to $DATADIR
	sudo ./install.sh -cz		Install zsh/shell config for root user


Default options:

  -c, --config		Install config (shell, zsh and some other programms)
  -z, --zsh		Install zsh and set it as default shell
  -f, --fonts		Install fonts (FiraCode Nerd, JetBrains Nerd, IOS emojis)
  -p, --packages	Install some packages (git, vim, lf, lsd, bat, rsync, etc) 
  -C, --cursor		Install Plasma 6 black breeze cursor
  -i, --icons		Install Tela-circle icons
  -t, --theme		Install libadwaita GTK3 theme
  -P, --pkgmanager	Optimize $pm 
  -g, --grub		Install ZorinOS grub theme, enable sysrq, savedefault, osprober 

Extra options:

  -h, --help            Display this help and exit
  -U, --user-only	Install fonts, cursor, icons to $HOME !!THIS OPTION MUST BE ENTERED BEFORE -f, -C, -i !!
  -G, --gnome		Some GNOME things
  -H, --hyprland	install Hyprland. Arch linux only
  -E, --gaming		Install Steam, Bottles, ProtonUp-qt, mangohud, gamemode, gamescope
  -m, --micro		Set micro as default editor instead of vim and disable vi-mode in zsh
EOF
  fi
}

flatpaks="com.github.tchx84.Flatseal net.nokyan.Resources"
gamingflatpak="com.valvesoftware.Steam com.usebottles.bottles net.davidotek.pupgui2 org.freedesktop.Platform.VulkanLayer.gamescope org.freedesktop.Platform.VulkanLayer.MangoHud org.freedesktop.Platform.VulkanLayer.vkBasalt"
if [[ -x $(which pacman 2>/dev/null) ]]; then
	install="sudo pacman -S --needed --noconfirm"
	pm="pacman"
	zsh="zsh sqlite"
	essentials="dash vim git fzf lf lsd bat rsync unzip wget curl base-devel pacman-contrib openssh"
	extrapackages="usbutils tmux glow ripgrep jq wireguard-tools mediainfo neovim yt-dlp pass pass-otp gnome-keyring smartmontools"
	gui="alacritty mpv maim slurp grim tesseract tesseract-data-eng tesseract-data-rus zbar wl-clipboard qpwgraph zathura-pdf-poppler flatpak"
	hyprland="hyprland hyprlock hypridle hyprpaper xdg-desktop-portal-gtk xdg-desktop-portal-hyprland waybar dunst cliphist wofi qt6-wayland qt5-wayland"
	fonts="noto-fonts noto-fonts-cjk"
	gamingrepo="mangohud gamemode gamescope"
elif [[ -d ~/.termux ]]; then
	install="pkg install -y"
	pm="pkg"
	zsh="zsh sqlite"
	essentials="vim git fzf lf lsd bat rsync unzip wget curl which"
	extrapackages="ripgrep jq mediainfo neovim termux-api"
	userinst=true
elif [[ -x $(which dnf 2>/dev/null) ]]; then
	install="sudo dnf install -y"
	pm="dnf"
	zsh="zsh sqlite"
	essentials="dash vim git fzf lsd bat rsync unzip wget curl"
	extrapackages="tmux ripgrep jq wireguard-tools mediainfo neovim yt-dlp pass pass-otp smartmontools"
	gui="alacritty mpv maim slurp grim tesseract tesseract-langpack-eng tesseract-langpack-rus zbar wl-clipboard qpwgraph zathura-pdf-poppler"
	gamingrepo="mangohud gamemode gamescope"
elif [[ -x $(which epmi 2>/dev/null) ]]; then
	install="epmi"
	pm="epm"
	zsh="zsh sqlite3"
	essentials="dash vim git fzf lf lsd bat rsync unzip wget curl"
	extrapackages="tmux glow ripgrep jq wireguard-tools mediainfo neovim yt-dlp smartmontools"
	gui="alacritty mpv maim slurp grim tesseract tesseract-langpack-eng tesseract-langpack-rus zbar wl-clipboard qpwgraph zathura-pdf-poppler"
	gamingrepo="mangohud gamemode gamescope"
elif [[ -x $(which apt 2>/dev/null) ]]; then
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

[[ "$SSH_TTY" ]] && gui=""

INSTALLERDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
#bak="$(date +\%H\%M\%S\-\%d\%m\%y).bak"
bak="$(date +\%y\%m\%d\-\%H\%M\%S).bak"
BUDIR="backup.$bak"
BUDIRFP="$(realpath $BUDIR)"
CONFDIR="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}"
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}"
DLDIR="$INSTALLERDIR/extra/downloads"
wget="wget -cq --hsts-file=/.cache/wget-hsts --show-progress"

backupcfg(){
	mkdir -p $BUDIR/{config,bin}
	cd "$INSTALLERDIR"/.config
	for f in *; do
		cp -r "$CONFDIR/$f" ../$BUDIR/config/
	done
	cd "$INSTALLERDIR"/.local/bin
	for f in *; do
		cp -r "$HOME/.local/bin/$f" ../../$BUDIR/bin/
	done
	cd "$INSTALLERDIR"
	mv -t $BUDIR/ ~/.bash* ~/.profile ~/.vim* ~/.zshrc ~/.zsh_* ~/.zhistory ~/.zprofile 2>/dev/null
	cp "$CACHEDIR"/zsh/zsh_history $BUDIR
}

copycfg() {
	echo "Installing config..."
	mkdir -p "$CONFDIR/git" "$CACHEDIR/zsh" ~/.local/{src,bin}
	[[ -d $CONFDIR/shell ]] && [[ -d $CONFDIR/zsh ]] && read -rsen 1 -p "Reinstall shell config? (y/N) " answ || answ="y"
	if [[ "$answ" == "y" || "$answ" == "Y" ]]; then
		backupcfg 2>/dev/null

		cp -r ./.zshenv "$HOME/"
		cp -r ./.config/* "$CONFDIR/" 2>/dev/null
		cp -r ./.local/* "$HOME/.local/"
		ln -sf "$CONFDIR/lf/lfub" ~/.local/bin/lfub
		[[ -f "$CONFDIR/shell/aliasrc-extra" ]] || printf "#!/bin/sh\n\n# Extra aliases.\n# This file will not be overwritten when you rerun ./install.sh -c\n# Main file: \$XDG_CONFIG_HOME/shell/aliasrc" >> "$CONFDIR/shell/aliasrc-extra"
		# change distro-specific aliases 
		case $pm in
			pacman) ;;
			dnf) sed -i 's/pacman/dnf/; s/-S --needed/install/; s/-Sy"/update"/; s/-Syyuu/update \&\& sudo dnf upgrade/; s/-Rsn/autoremove/; s/-Scc/clean all/; s/-Ss/search/; s/-Qs/query/; s/-F/provides/' "$CONFDIR/shell/aliasrc";;
			apt) sed -i 's/pacman/apt/; s/-S --needed/install/; s/-Sy"/update"/; s/-Syyuu/update \&\& sudo apt upgrade/; s/-Rsn/remove --purge/; s/-Scc/clean/; s/-Ss/search/; s/-Qs/list --installed/; s/ -F/-file search/; s/-v bat/-v batcat/; s/bat -n/batcat -n/' "$CONFDIR/shell/aliasrc"
				[[ -x $(which nala 2>/dev/null) ]] && sed -i "s/apt /nala /g; s/update \&\&.*\"/upgrade\"/; s/#placeholder-basic1/alias apt='nala'/" "$CONFDIR/shell/aliasrc" ;;
			epm) sed -i 's/sudo pacman/epm/; s/-S --needed/install/; s/-Sy"/update"/; s/-Syyuu/Upgrade/; s/-Rsn/remove/; s/-Scc/clean/; s/-Ss/search/; s/-Qs/qp/; s/-F/sf/' "$CONFDIR/shell/aliasrc" ;;
			pkg) sed -i 's/sudo pacman/pkg/; s/-S --needed/install/; s/-Sy"/update"/; s/-Syyuu/update \&\& pkg upgrade/; s/-Rsn/remove --purge/; s/-Scc/clean/; s/-Ss/search/; s/-Qs/list-installed/; / -F/d; s/ --preserve=xattr//; s/ --xattrs//; s/-vvrPlutXUh/-vvrPlutUh/' $CONFDIR/shell/aliasrc
				sed -i '/vi-mode.plugin/ s/^/#/; /ZVM/ s/^/#/' "$CONFDIR/zsh/.zshrc" ;;
			*) echo "Unable to determine package manager";;
		esac
		[[ ! -f "$CONFDIR/nvim/init.lua" ]] && cp -ri ./extra/nvim "$CONFDIR/" 	# fix vim error in case nvim isn't installed
		sed -i "/typeset -g POWERLEVEL9K_BACKGROUND=/c\  [[ \$SSH_TTY ]] && typeset -g POWERLEVEL9K_BACKGROUND=052 || typeset -g POWERLEVEL9K_BACKGROUND=236" "$CONFDIR/zsh/p10k.zsh"
		# clean ~/ directory
		mkdir -p $DATADIR/{icons,fonts,themes} 2>/dev/null
		[[ -d ~/.icons ]] && mv ~/.icons/* "$DATADIR/icons/" && rmdir ~/.icons
		[[ -d ~/.themes ]] && mv ~/.themes/* "$DATADIR/themes/" && rmdir ~/.themes
		[[ -d ~/.fonts ]] && mv ~/.fonts/* "$DATADIR/fonts/" && rmdir ~/.fonts
		[[ -f "$HOME/.gitconfig" && ! -f "$CONFDIR/git/config" ]] && mv ~/.gitconfig "$CONFDIR/git/config" || touch "$CONFDIR/git/config"

		[[ -f "$BUDIR/.vimrc" ]] && cat ./extra/vimrcAdditions "$BUDIR/.vimrc" >> "$CONFDIR/vim/vimrc" && echo "Your vimrc is now located in ~/.config/vim/vimrc"
	fi
	echo "Done"
}

# Install zsh if not installed
installzsh(){
	[[ ! -x $(which zsh 2>/dev/null) ]] && echo "zsh not found. Installing..." && $install $zsh
	[[ ! -x $(which chsh 2>/dev/null) ]] && $install util-linux-user	# Fedora moment XD
	if [[ $(echo $SHELL | xargs basename) != "zsh" ]]; then
		echo "Changing shell to zsh"
		currentuser="$USER"
		sudo chsh -s $(which zsh) $currentuser && 
		echo "Done. You need to relog" && sleep 2 
	else
		echo "zsh is already installed. Skipping"
	fi
}

# Install packages and dependencies
installpkgs(){
	echo "Installing Packages..."
	[[ -z $KDE_SESSION_VERSION && -x $(which xdg-mime) ]] && defaultfm="$(xdg-mime query default inode/directory)"
	case $pm in
		pacman) $install $essentials $extrapackages $gui
			if [[ ! -x $(which yay 2>/dev/null) ]]; then
				cd "$DLDIR" && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si
				cd "$INSTALLERDIR"
			fi
			if [[ ! -x $(which blobdrop 2>/dev/null) ]]; then
				cd "$DLDIR" 
				$wget https://github.com/vimpostor/blobdrop/releases/download/v2.1/blobdrop-2.1-x86_64-archlinux.pkg.tar.zst && sudo pacman -U ./blobdrop-2.1-x86_64-archlinux.pkg.tar.zst
				cd "$INSTALLERDIR"
			fi
			sudo pacman -Fy
			#sudo cp ./extra/hooks/dashtobinsh.hook /usr/share/libalpm/hooks/ # Breaks some system scripts
			#sudo ln -sfT dash /bin/sh			# Breaks some system scripts
			;;
		dnf) $install $essentials $extrapackages $gui
			if [[ ! -x $(which lf 2>/dev/null) ]]; then
				cd "$DLDIR" 
				$wget https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz && tar -xf lf-linux-amd64.tar.gz && sudo mv ./lf /usr/bin/lf
				cd "$INSTALLERDIR"
			fi
			if [[ ! -x $(which blobdrop 2>/dev/null) ]]; then
				cd "$DLDIR" 
				$wget https://github.com/vimpostor/blobdrop/releases/latest/download/blobdrop-x86_64.AppImage && mv blobdrop-x86_64.AppImage ~/.local/bin/blobdrop
				chmod +x ~/.local/bin/blobdrop
				cd "$INSTALLERDIR"
			fi
			echo "Installing codecs"
			$install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
			$install lame\* --exclude=lame-devel
			sudo dnf group upgrade -y --with-optional Multimedia
			#sudo ln -sfT dash /bin/sh			# Breaks some system scripts
			;;
		apt) $install $essentials $extrapackages $gui
			sudo apt-file update
			flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
			if [[ ! -x $(which lf 2>/dev/null) ]]; then
				cd "$DLDIR" 
				$wget https://github.com/gokcehan/lf/releases/latest/download/lf-linux-amd64.tar.gz && tar -xf lf-linux-amd64.tar.gz && sudo mv ./lf /usr/bin/lf
				cd "$INSTALLERDIR"
			fi
			if [[ ! -x $(which blobdrop 2>/dev/null) ]]; then
				cd "$DLDIR" 
				$wget https://github.com/vimpostor/blobdrop/releases/latest/download/blobdrop-x86_64.AppImage && mv blobdrop-x86_64.AppImage ~/.local/bin/blobdrop
				chmod +x ~/.local/bin/blobdrop
				cd "$INSTALLERDIR"
			fi
			if [[ ! -x $(which lsd 2>/dev/null) ]]; then
				cd "$DLDIR" 
				$wget https://github.com/lsd-rs/lsd/releases/latest/download/lsd_1.0.0_amd64.deb && sudo apt install -y ./lsd_1.0.0_amd64.deb
				cd "$INSTALLERDIR"
			fi
			#sudo ln -sfT dash /bin/sh			# Breaks some system scripts
			;;
		epm) $install $essentials $extrapackages $gui
			if [[ ! -x $(which blobdrop 2>/dev/null) ]]; then
				cd "$DLDIR" 
				$wget https://github.com/vimpostor/blobdrop/releases/download/v2.1/blobdrop-2.1-x86_64-archlinux.pkg.tar.zst && sudo pacman -U ./blobdrop-2.1-x86_64-archlinux.pkg.tar.zst
				cd "$INSTALLERDIR"
			fi
			#sudo ln -sfT dash /bin/sh			# Breaks some system scripts
			;;
		pkg) $install $essentials $extrapackages  ;;
		*) echo "Unable to determine package manager";;
	esac

	flatpak install $flatpaks
	if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
		flatpak install io.github.realmazharhussain.GdmSettings com.mattjakeman.ExtensionManager
	fi

	[[ -z $KDE_SESSION_VERSION && -x $(which xdg-mime) ]] && xdg-mime default $defaultfm inode/directory
	cd "$INSTALLERDIR"
	# Download nvim spellcheck files
	if [[ ! -f "$DATADIR/nvim/site/spell/ru.utf-8.spl" ]]; then
		mkdir -p "$DATADIR/nvim/site/spell"
		curl 'http://ftp.vim.org/pub/vim/runtime/spell/ru.utf-8.spl' -o "$DATADIR/nvim/site/spell/ru.utf-8.spl"
	fi 
	echo "Done"
}

installfonts(){
	echo "Installing Fonts..."
	mkdir -p "$CONFDIR/fontconfig"
	cd "$DLDIR"
	nerdfonts=(FiraCode JetBrainsMono)
	for nerdfont in "${nerdfonts[@]}"; do
		if [[ ! $(fc-list | grep -i $nerdfont) ]]; then
			$wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$nerdfont.zip
			[[ ! -d ./$nerdfont ]] && unzip -q ./$nerdfont.zip -d ./$nerdfont || continue
			mkdir -p $DATADIR/fonts
			[[ $userinst == true ]] && cp -r ./$nerdfont $DATADIR/fonts/ || sudo cp -r ./$nerdfont /usr/share/fonts/  
			fontinstalled=true
		else
			echo "$nerdfont is already installed"
		fi
	done
	if [[ ! $(fc-list | grep -i applecoloremoji) ]]; then
		$wget https://github.com/samuelngs/apple-emoji-linux/releases/latest/download/AppleColorEmoji.ttf
		[[ $userinst == true ]] && cp -r ./AppleColorEmoji.ttf $DATADIR/fonts/ || sudo cp -r ./AppleColorEmoji.ttf /usr/share/fonts/ 
		fontinstalled=true
	else
		echo "AppleColorEmoji is already installed"
	fi
	[[ $fonts ]] && $install $fonts
	[[ $fontinstalled ]] && echo "Updating font cache..." && fc-cache -f
	cd "$INSTALLERDIR"
	echo "Done"
	echo "You can find more compatible fonts at https://nerdfonts.com" && sleep 3
}

installcursor(){
	echo "Installing Cursor..."
	mkdir -p $DATADIR/icons
	[[ $userinst == true ]] && cp -r ./extra/cursor/Bruh $DATADIR/icons/ || sudo cp -r ./extra/cursor/Bruh /usr/share/icons/
	gsettings set org.gnome.desktop.interface cursor-theme "Bruh"
	#[[ -n $CINNAMONVARIABLE ]] && dconf write /org/cinnamon/desktop/interface/cursor-theme "'Bruh'" # Untested
	echo "Done"
}

installicons(){
	echo "Installing Icons..."
	[[ ! -f "$DLDIR/master.zip" ]] && $wget https://github.com/vinceliuice/Tela-circle-icon-theme/archive/refs/heads/master.zip -P "$DLDIR"/
	[[ ! -d "$DLDIR/Tela-circle-icon-theme-master" ]] && unzip -q "$DLDIR/master.zip" -d "$DLDIR"/
	if [[ -d "$DLDIR/Tela-circle-icon-theme-master" ]]; then
		cd "$DLDIR/Tela-circle-icon-theme-master"
		[[ $userinst == true ]] && ./install.sh || sudo ./install.sh
		gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark"
		#[[ -n $CINNAMONVARIABLE ]] && dconf write /org/cinnamon/desktop/interface/icon-theme "'Tela-circle-dark'" # Untested
	else
		echo "Something went wrong"
	fi
	cd "$INSTALLERDIR"
	echo "Done"
}

installtheme(){
	echo "Installing Theme"
	mkdir -p $DATADIR/themes
	cd "$DLDIR"
	$wget https://github.com/lassekongo83/adw-gtk3/releases/download/v5.3/adw-gtk3v5.3.tar.xz
	mkdir -p adw
	tar -xf adw-gtk3v5.3.tar.xz --directory=./adw
	if [[ -d ./adw/adw-gtk3 ]]; then
		[[ $userinst == true ]] && cp -r ./adw/{adw-gtk3,adw-gtk3-dark} $DATADIR/themes/ || sudo cp -r ./adw/{adw-gtk3,adw-gtk3-dark} /usr/share/themes/
		gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	fi
	flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
	cd "$INSTALLERDIR"
	echo "Done"
}

optimizepm(){
	echo "Optimizing $pm..."
	defgeo="RU"
	geo="$(curl -s https://ifconfig.io/all | grep country_code | cut -d' ' -f2)"
	[[ ! "$geo" ]] && geo="$defgeo"
	case $pm in
		pacman)	
			if [ ! $(grep -i manjaro /etc/os-release) ]; then
				pmmirror="/etc/pacman.d/mirrorlist"
				if [[ -f "$pmmirror" ]]; then
					echo "Backing up mirrorlist"
					sudo cp -v $pmmirror $pmmirror.$bak
					echo "Generating mirrorlist..."
					echo -e "## Generated on $(date +\%Y-\%m-\%d_\%H-\%M-\%S)\n\n## By country, https" > "$BUDIR/mirrorlist"
					curl -s "https://archlinux.org/mirrorlist/?country=$geo&country=$defgeo&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - >> "$BUDIR/mirrorlist"
					echo -e "\n## Worldwide\nServer = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch" >> "$BUDIR/mirrorlist" 
					echo -e "\n## By country, http" >> "$BUDIR/mirrorlist"
					curl -s "https://archlinux.org/mirrorlist/?country=$geo&country=$defgeo&protocol=http&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - >> "$BUDIR/mirrorlist"
					sudo cp "$BUDIR/mirrorlist" $pmmirror
					sudo pacman -Syy
				fi
			fi
			pmcfg="/etc/pacman.conf"
			if [[ -f "$pmcfg" ]]; then
				echo "Backing up pacman.conf"
				sudo cp -v $pmcfg $pmcfg.$bak
				sudo sed -i "s/^#Color/Color/; s/^#ParallelDownloads.*/ParallelDownloads = 5/" $pmcfg
			else
				echo "$pmcfg not found"
			fi
			;;

		dnf) pmcfg="/etc/dnf/dnf.conf"
			if [[ -f "$pmcfg" ]]; then
				sudo cp -v $pmcfg $pmcfg.$bak
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

		apt) echo "Installing Nala..." 
			[[ ! -x $(which nala 2>/dev/null) ]] && $install nala
			if [[ -x $(which nala 2>/dev/null) ]]; then 
				grep -q "scrolling_text = false" /etc/nala/nala.conf || sudo sed -i "/scrolling_text/ s/true/false/; /update_show_packages/ s/false/true/; /assume_yes/ s/false/true/" /etc/nala/nala.conf
				echo "Aliasing nala to apt..."
				if [[ -f "$CONFDIR/shell/aliasrc" ]]; then
					sed -i "s/apt /nala /g; s/update \&\&.*\"/upgrade\"/; s/#placeholder-basic1/alias apt='nala'/" $CONFDIR/shell/aliasrc
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

tweakgrub(){
	echo "Tweaking grub..."
	defaultgrub="/etc/default/grub"
	if [[ -f "$defaultgrub" ]]; then
		localdefaultgrub="./extra/grub"
		echo "Backing up $defaultgrub"
		sudo cp -v $defaultgrub $defaultgrub.$bak
		sudo cp $defaultgrub $localdefaultgrub
		echo "modifying $defaultgrub"
		sed -i 's/^#\?GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/; s/^#\?GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/; s/^#\?GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/; s/^#\?GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/; s/^#\?GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=false/; s/^#\?GRUB_TERMINAL_OUTPUT=.*/GRUB_TERMINAL_OUTPUT=gfxterm/; /^#GRUB_GFXMODE/s/^#//; s/^#\?GRUB_THEME=.*/GRUB_THEME="\/boot\/grub\/themes\/zorin\/theme.txt"/; s/^#\?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/; /sysrq_always_enabled=1/! s/\(GRUB_CMDLINE_LINUX="[^"]*\)/\1 sysrq_always_enabled=1/' $localdefaultgrub
		grep -q "GRUB_DEFAULT" $localdefaultgrub || echo "GRUB_DEFAULT=saved" >> $localdefaultgrub
		grep -q "GRUB_SAVEDEFAULT" $localdefaultgrub || sed -i '/GRUB_DEFAULT=/ a\GRUB_SAVEDEFAULT=true' $localdefaultgrub
		grep -q "GRUB_GFXMODE" $localdefaultgrub || echo "GRUB_GFXMODE=auto" >> $localdefaultgrub
		grep -q "GRUB_THEME" $localdefaultgrub || echo "GRUB_THEME=/boot/grub/themes/zorin/theme.txt" >> $localdefaultgrub

		if [[ -d /boot/grub ]]; then
			sudo mkdir -p /boot/grub/themes
			sudo cp -r ./extra/zorin /boot/grub/themes/ | head -n 1
			sudo cp $localdefaultgrub $defaultgrub  
			if [[ -x $(which update-grub 2>/dev/null) ]]; then
				sudo update-grub 
			else
				sudo grub-mkconfig -o /boot/grub/grub.cfg
			fi

		elif [[ -d /boot/grub2 ]]; then
			sudo mkdir -p /boot/grub2/themes
			sudo cp -r ./extra/zorin /boot/grub2/themes/ | head -n 1
			sed -i 's/boot\/grub\//boot\/grub2\//' $localdefaultgrub
			sudo cp $localdefaultgrub $defaultgrub
			if [[ -x $(which update-grub 2>/dev/null) ]]; then
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

tweakgnome(){
	echo "Changing GNOME keybindings"

	mkdir -p "$BUDIR"
	dconf dump /org/gnome/ > "$BUDIR/dconf-org.gnome"

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
	gsettings set "org.gnome.desktop.wm.preferences" "focus-mode" "mouse"

	gsettings set "org.gnome.desktop.interface" "monospace-font-name" "FiraCode Nerd Font 10"
	gsettings set "org.gnome.desktop.interface" "show-battery-percentage" "true"
	gsettings set "org.gnome.desktop.interface" "clock-show-weekday" "true"
	gsettings set "org.gnome.desktop.calendar" "show-weekdate" "true"

	gsettings set "org.gnome.desktop.input-sources" "xkb-options" "['compose:ralt']"
	gsettings set "org.gnome.desktop.input-sources" "per-window" "true"

	read -rn 1 -p "Select keyboard layout switch keymap: 1-CAPSLOCK, 2-ALT+SHIFT, n-DEFAULT: " kb && echo ""
	case $kb in 
		1) gsettings set "org.gnome.desktop.input-sources" "xkb-options" "['grp:caps_toggle', 'compose:ralt']" ;;
		2) gsettings set "org.gnome.desktop.wm.keybindings" "switch-input-source" "['<Super>space', 'XF86Keyboard', '<Alt>Shift_L']"
			gsettings set "org.gnome.desktop.wm.keybindings" "switch-input-source-backward" "['<Shift><Super>space', '<Shift>XF86Keyboard', '<Shift>Alt_L']" ;;
		*) ;;
	esac

	read -rsen 1 -p "Install some extensions? (Y/n) " answ
	if [[ "$answ" == "y" || "$answ" == "Y" || -z "$answ" ]]; then
		if [[ ! -x $(which jq 2>/dev/null) ]]; then
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
			ds4battery@slie.ru
			gsconnect@andyholmes.github.io
			do-not-disturb-while-screen-sharing-or-recording@marcinjahn.com
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
			echo "$extInstalled" | grep "$uuid" >/dev/null && printf "\033[0;34m$extFullName\033[0m is already installed\n" && continue # skip installed
			extDescription="${extDescriptions[$uuid]}"
			extLink="https://extensions.gnome.org${extLinks[$uuid]}"
			[[ -z "$extFullName" ]] && continue # skip incompatible

			while true; do
				printf "Install \033[0;34m$extFullName\033[0m? (Y/n/(d)escription) "
				read -rsen 1 answ
				case "$answ" in
				"y"|"Y"|"") gdbus call --session --dest "org.gnome.Shell" --object-path "/org/gnome/Shell" --method org.gnome.Shell.Extensions.InstallRemoteExtension "$uuid" >/dev/null
					break
					;;
				"d"|"D") printf "=========================\n $extDescription \n\n \033[0;34m$extLink\033[0m \n=========================\n\n" ;;
				*) break ;;
				esac
			done
		done

	fi

	echo "Done"
	# echo "You can restore settings using \`dconf load /org/gnome < $BUDIRFP/dconf-org.gnome\` command" # can you?
}

installhyprland(){
	echo "Installing Hyprland..."
	if [[ "$hyprland" ]]; then
		$install $hyprland
	fi
	echo "Done"
}

installgaming(){
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

switchtomicro(){
	echo "Switching to micro..."
	[[ ! -x $(which micro 2>/dev/null) ]] && echo "Micro not found. Installing..." && $install micro
	sed -i 's/EDITOR="n\?vim"/EDITOR="micro"/; s/VISUAL="n\?vim"/VISUAL="micro"/; /MANPAGER=.nvim/d' $CONFDIR/shell/profile
	sed -i '/vi-mode.plugin/ s/^/#/; s/#bindkey -e/bindkey -e/; /ZVM/ s/^/#/' $CONFDIR/zsh/.zshrc
	echo "Done. Relog to see changes"
}

while getopts ":hcUfpzCigPGHEtm-:" opt; do case "${opt}" in
	h) usage;;
	c) copycfg;;
	z) installzsh;;
	f) installfonts;;
	p) installpkgs;;
	U) userinst=true;;
	C) installcursor;;
	i) installicons;;
	t) installtheme;;
	P) optimizepm;;
	g) tweakgrub;;
	G) tweakgnome;;
	H) installhyprland;;
	E) installgaming;;
	m) switchtomicro;;
	-) case "${OPTARG}" in
		help) usage;;
		config) copycfg;;
		zsh) installzsh;;
		fonts) installfonts;;
		packages) installpkgs;;
		user-only) userinst=true;;
		cursor) installcursor;;
		icons) installicons;;
		theme) installtheme;;
		pkgmanager) optimizepm;;
		grub) tweakgrub;;
		gnome) tweakgnome;;
		hyprland) installhyprland;;
		gaming) installgaming;;
		micro) switchtomicro;;
		*) echo "Invalid option: --$OPTARG" && usage && exit 1 ;;
	esac;;
*) echo "Invalid option: -$OPTARG" && usage && exit 1 ;;
esac done

if [[ -z "$*" ]] || [[ "$*" == "-U" ]] || [[ "$*" == "--user-only" ]]; then
	copycfg
	installzsh
	installpkgs
	installfonts
	installcursor
	installicons
	installtheme
	optimizepm
	tweakgrub
fi

exit 0
