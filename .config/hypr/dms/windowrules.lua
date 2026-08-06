-- Window rules. Deploy writes ~/.config/hypr/dms/windowrules.lua

-- hl.window_rule({
-- 	match = { class = "^(org\\.gnome\\.)" },
-- 	rounding = 12,
-- })

hl.window_rule({
	match = { class = "^(firefox|org\\.mozilla\\.firefox)$" },
	workspace = "1",
})

hl.window_rule({
	match = { class = "^(org\\.telegram\\.desktop)$" },
	workspace = "4",
	no_screen_share = true,
})

hl.window_rule({
	match = { class = "^(discord)$" },
	workspace = "4",
})

hl.window_rule({
	match = { class = "^(steam)$" },
	workspace = "5",
})

hl.window_rule({
	match = { class = "^(steam)$", title = "^(Friends List|Steam Settings)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(steam)$", title = "^(notificationtoasts)" },
	no_initial_focus = true,
	pin = true,
})

hl.window_rule({
	match = { class = "^(org\\.keepassxc\\.KeePassXC)$" },
	no_screen_share = true,
})

hl.window_rule({
	match = { class = "^(org\\.gnome\\.World\\.Secrets)$" },
	no_screen_share = true,
})

hl.window_rule({
	match = { class = "^(polkit-gnome-authentication-agent-1)$" },
	stay_focused = true,
	no_screen_share = true,
})

hl.window_rule({
	match = { class = "^(Pinentry-gtk-2)$" },
	stay_focused = true,
	no_screen_share = true,
})

hl.window_rule({
	match = { class = "^(gcr-prompter)$" },
	stay_focused = true,
	no_screen_share = true,
})

hl.window_rule({
	match = { class = "^(org\\.gnome\\.Calculator|gnome-calculator|galculator|[Cc]alculator)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(nm-connection-editor)$" },
	tile = true,
})

hl.window_rule({
	match = { class = "^(org\\.quickshell|com\\.danklinux\\.dms|[Ll]auncher)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(blueman-manager)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(xdg-desktop-portal|xdg-desktop-portal-gtk)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(org\\.kde\\.kdeconnect|org\\.kde\\.kdeconnect\\.daemon)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(blobdrop)$" },
	float = true,
	pin = true,
})

hl.window_rule({
	match = { class = "^(hyprland-share-picker)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(Zenity|zenity|[Zz]enity)$" },
	float = true,
})

hl.window_rule({
	match = {
		class = "^(python3|it\\.mijorus\\.smile|com\\.usebottles\\.bottles|org\\.prismlauncher\\.PrismLauncher|Tk)$",
	},
	float = true,
})

hl.window_rule({
	match = { class = "^(floating)$" },
	float = true,
	size = { 1200, 900 },
	center = true,
})

hl.window_rule({
	match = { class = "^(org\\.telegram\\.desktop)$", title = "^(Media viewer)$" },
	float = true,
	fullscreen = true,
})

hl.window_rule({
	match = { class = "^(firefox|org\\.mozilla\\.firefox)$", title = "^(Opening .*)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(firefox|org\\.mozilla\\.firefox)$", title = "^(Picture-in-Picture)$" },
	float = true,
	pin = true,
})

hl.window_rule({
	match = { class = "^(ueberzugpp.*)$" },
	float = true,
	no_anim = true,
	border_size = 0,
	no_initial_focus = true,
})

hl.window_rule({
	match = { class = "^(zoom)$" },
	float = true,
})

hl.layer_rule({
	match = { namespace = "^(quickshell)$" },
	no_anim = true,
})

hl.layer_rule({
	match = { namespace = "^dms:.*" },
	no_anim = true,
})

hl.layer_rule({
	match = { namespace = "^(wofi)$" },
	no_anim = true,
	no_screen_share = true,
})

hl.layer_rule({
	match = { namespace = "^(swaync-notification-window|swaync-control-center)$" },
	no_screen_share = true,
})
