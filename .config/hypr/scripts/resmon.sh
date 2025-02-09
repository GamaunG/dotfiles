#!/bin/bash
# used in waybar

x() {
	"$@" >/dev/null && exit
}

x pgrep -f net.nokyan.Resources
x pgrep -f io.missioncenter.MissionCenter
x pgrep -f gnome-system-monitor-kde

x gtk-launch net.nokyan.Resources
x gtk-launch io.missioncenter.MissionCenter
x gtk-launch gnome-system-monitor-kde

notify-send "$(realpath -s "$0")" "Failed to start resource monitor app"

