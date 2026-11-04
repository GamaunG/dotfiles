-- DMS Window Rules — managed by Dux Shell
-- Do not edit manually; changes may be overwritten

-- DMS-RULE: id=dms_rule_0, name=
hl.window_rule({ match = { class = "^(firefox|org\\.mozilla\\.firefox)$" }, workspace = "1" })

-- DMS-RULE: id=dms_rule_1, name=
hl.window_rule({ match = { class = "^(org\\.telegram\\.desktop)$" }, workspace = "4" })

-- DMS-RULE: id=dms_rule_2, name=
hl.window_rule({ match = { class = "^(discord)$" }, workspace = "4" })

-- DMS-RULE: id=dms_rule_3, name=
hl.window_rule({ match = { class = "^(steam)$" }, workspace = "5" })

-- DMS-RULE: id=dms_rule_4, name=
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List|Steam Settings)$" }, float = true })

-- DMS-RULE: id=dms_rule_5, name=
hl.window_rule({ match = { class = "^(steam)$", title = "^(notificationtoasts)" }, pin = true, no_initial_focus = true })

-- DMS-RULE: id=dms_rule_6, name=
hl.window_rule({ match = { class = "^(polkit-gnome-authentication-agent-1)$" }, stay_focused = true })

-- DMS-RULE: id=dms_rule_7, name=
hl.window_rule({ match = { class = "^(Pinentry-gtk-2)$" }, stay_focused = true })

-- DMS-RULE: id=dms_rule_8, name=
hl.window_rule({ match = { class = "^(gcr-prompter)$" }, stay_focused = true })

-- DMS-RULE: id=dms_rule_9, name=
hl.window_rule({ match = { class = "^(org\\.gnome\\.Calculator|gnome-calculator|galculator|[Cc]alculator)$" }, float = true })

-- DMS-RULE: id=dms_rule_10, name=
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, tile = true })

-- DMS-RULE: id=dms_rule_11, name=
hl.window_rule({ match = { class = "^(org\\.quickshell|com\\.danklinux\\.dms|[Ll]auncher)$" }, float = true })

-- DMS-RULE: id=dms_rule_12, name=
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })

-- DMS-RULE: id=dms_rule_13, name=
hl.window_rule({ match = { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$" }, float = true })

-- DMS-RULE: id=dms_rule_14, name=
hl.window_rule({ match = { class = "^(xdg-desktop-portal|xdg-desktop-portal-gtk)$" }, float = true })

-- DMS-RULE: id=dms_rule_15, name=
hl.window_rule({ match = { class = "^(org\\.kde\\.kdeconnect|org\\.kde\\.kdeconnect\\.daemon)$" }, float = true })

-- DMS-RULE: id=dms_rule_16, name=
hl.window_rule({ match = { class = "^(blobdrop)$" }, float = true, pin = true })

-- DMS-RULE: id=dms_rule_17, name=
hl.window_rule({ match = { class = "^(hyprland-share-picker)$" }, float = true })

-- DMS-RULE: id=dms_rule_18, name=
hl.window_rule({ match = { class = "^(Zenity|zenity|[Zz]enity)$" }, float = true })

-- DMS-RULE: id=dms_rule_19, name=
hl.window_rule({ match = { class = "^(python3|it\\.mijorus\\.smile|com\\.usebottles\\.bottles|org\\.prismlauncher\\.PrismLauncher|Tk)$" }, float = true })

-- DMS-RULE: id=dms_rule_20, name=
hl.window_rule({ match = { class = "^(floating)$" }, float = true, size = { 1200, 900 } })

-- DMS-RULE: id=dms_rule_21, name=
hl.window_rule({ match = { class = "^(org\\.telegram\\.desktop)$", title = "^(Media viewer)$" }, float = true, fullscreen = true })

-- DMS-RULE: id=dms_rule_22, name=
hl.window_rule({ match = { class = "^(firefox|org\\.mozilla\\.firefox)$", title = "^(Opening .*)$" }, float = true })

-- DMS-RULE: id=dms_rule_23, name=
hl.window_rule({ match = { class = "^(firefox|org\\.mozilla\\.firefox)$", title = "^(Picture-in-Picture)$" }, float = true, pin = true })

-- DMS-RULE: id=dms_rule_24, name=
hl.window_rule({ match = { class = "^(ueberzugpp.*)$" }, float = true, border_size = 0, no_anim = true, no_initial_focus = true })

-- DMS-RULE: id=dms_rule_25, name=
hl.window_rule({ match = { class = "^(zoom)$" }, float = true })

-- DMS-RULE: id=dms-floating-windows, name=DMS Floating Windows
hl.window_rule({ match = { class = "^(dev\\.duxlabs\\.shell|com\\.danklinux\\.dms)$" }, float = true })

-- DMS-RULE: id=dms-window-opaque, name=DMS Window Opaque
hl.window_rule({ match = { class = "^(dev\\.duxlabs\\.shell|com\\.danklinux\\.dms)$" }, opaque = true })
