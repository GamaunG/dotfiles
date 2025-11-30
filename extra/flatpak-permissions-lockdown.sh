#!/usr/bin/bash
# shellcheck disable=SC2088,SC2034
# NEEDS TESTING

# Based on this script:
# https://github.com/secureblue/secureblue/blob/live/files/justfiles/desktop/flatpak.just#L32
#
echo "This script will configure flatpak to automatically reject most permissions"
echo "NOTE: This will break just about all Flatpaks by default, it is ON YOU to configure them to work with this configuration."
echo "You can use the \`flatpakComparePerms\` script to see which permissions an application expected but was denied"

read -rsen 1 -p "Would you like to proceed? [y/N] " confirmation
if [[ "$confirmation" != [Yy] ]]; then
	exit
fi

sharePermissions=("network" "ipc")
socketPermissions=(
	"inherit-wayland-socket"
	"gpg-agent"
	"cups"
	"pcsc"
	"ssh-auth"
	"system-bus"
	"session-bus"
	"fallback-x11"
	"x11"
)
devicePermissions=("all" "shm" "kvm" "input" "usb")
featurePermissions=("canbus" "bluetooth" "devel")
filesystemPermissions=(
	"home"
	"host-etc"
	"host"
	"xdg-data"
	"xdg-config"
	"/run/media"
	"/mnt"
)
knownSessionBusNames=(
	"org.kde.kwalletd6"
	"org.kde.kwalletd5"
	"org.freedesktop.secrets"
	"org.kde.kpasswdserver"
	"org.kde.kpasswdserver6"

	"org.freedesktop.impl.portal.PermissionStore"
	"org.freedesktop.Flatpak"

	# "org.gnome.ControlCenter"
	# "org.gnome.Settings"
	# "org.gnome.SettingsDaemon"
	# "ca.desrt.dconf"
	# "org.kde.KGlobalSettings"

	# "org.kde.*"
	# "org.kde.kded5"
	# "org.kde.kded6"
	# "org.kde.kiod5"
	# "org.kde.kiod6"
	# "org.kde.JobViewServer"

	# "org.kde.kconfig.notify"
	# "org.freedesktop.Notifications"

	# "org.gnome.Software"
	# "org.gnome.SessionManager"
	# "org.gtk.vfs.*"
	# "org.a11y.Bus"
	# "org.freedesktop.Tracker3.Writeback"
	# "org.freedesktop.FileManager1"
)
# knownSystemBusNames=(
# 	"org.bluez"
# 	"org.freedesktop.home1"
# 	"org.freedesktop.hostname1"
# 	"org.freedesktop.import1"
# 	"org.freedesktop.locale1"
# 	"org.freedesktop.LogControl1"
# 	"org.freedesktop.machine1"
# 	"org.freedesktop.network1"
# 	"org.freedesktop.oom1"
# 	"org.freedesktop.portable1"
# 	"org.freedesktop.resolve1"
# 	"org.freedesktop.sysupdate1"
# 	"org.freedesktop.timesync1"
# 	"org.freedesktop.timedate1"
# 	"org.freedesktop.systemd1"
# 	"org.freedesktop.Avahi"
# 	"org.freedesktop.Avahi.*"
# 	"org.freedesktop.login1"
# 	"org.freedesktop.NetworkManager"
# 	"org.freedesktop.UPower"
# 	"org.freedesktop.UDisks2"
# 	"org.freedesktop.fwupd"
# )

echoBlue() {
	printf "\n\033[0;34m%s\033[0m\n" "$@"
}

massOverride() {
	local prefix="$1"
	local -n perms="$2"
	local args=()

	for perm in "${perms[@]}"; do
		printf "Rejecting \033[0;34m%s\033[0m\n" "$perm"
		args+=("${prefix}=${perm}")
	done

	# echo "Full command: flatpak override --user" "${args[@]}"
	flatpak override --user "${args[@]}"
}

echoBlue "-- Share Permissions --"
massOverride "--unshare" sharePermissions

echoBlue "-- Socket Permissions --"
massOverride "--nosocket" socketPermissions

echoBlue "-- Device Permissions --"
massOverride "--nodevice" devicePermissions

echoBlue "-- Feature Permissions --"
massOverride "--disallow" featurePermissions

echoBlue "-- Dangerous Filesystem Permissions --"
massOverride "--nofilesystem" filesystemPermissions

echoBlue "-- Persistent Filesystem Grant --"
echo "Note: This is to unbreak many Flatpaks by allowing the app to store persistent data in their own, isolated home directory without accessing the user's"
flatpak override --user --persist=.

echoBlue "-- Session Bus Name Access --"
massOverride "--no-talk-name" knownSessionBusNames

# echoBlue "-- System Bus Name Access --"
# massOverride "--system-no-talk-name" knownSystemBusNames

echoBlue "-- Granting access to Wayland and hardware acceleration --"
echo "Note: This will grant all apps access to some permissions to ensure most apps work by default, this also encourages the use of these permissions instead of their alternatives"
flatpak override --user --socket=wayland --device=dri

echoBlue "-- Granting Flatseal Access to Bus Names --"
flatpak override --user --talk-name=org.freedesktop.impl.portal.PermissionStore --talk-name=org.gnome.Software com.github.tchx84.Flatseal
flatpak override --user --filesystem="xdg-data/flatpak/overrides:create" com.github.tchx84.Flatseal

# echoBlue "-- Granting Warehouse Access to Bus Names --"
# flatpak override --user --talk-name=org.freedesktop.Flatpak io.github.flattool.Warehouse

echo "Done"
