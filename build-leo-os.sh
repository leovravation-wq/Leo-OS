#!/usr/bin/env bash
set -Eeuo pipefail
# Leo OS live ISO builder for Ubuntu 24.04 GitHub-hosted runner.
# Change the settings below to customize the image.
OS_NAME="Leo OS"
VERSION="1.0"
SUITE="bookworm"
LIVE_USER="leo"
DESKTOP_PACKAGES="xfce4 xfce4-goodies xfce4-whiskermenu-plugin"
APPLICATIONS="firefox-esr thunar mousepad galculator xfce4-terminal"
OTHER_PACKAGES="lightdm lightdm-gtk-greeter network-manager network-manager-gnome dbus-x11 arc-theme adwaita-icon-theme fonts-dejavu-core"
WORK="${PWD}/_build"
mkdir -p "$WORK"
cd "$WORK"
lb config --mode debian --distribution "$SUITE" --architectures amd64 \
  --binary-images iso-hybrid --bootloaders "isolinux grub-efi" \
  --debian-installer none --archive-areas "main contrib non-free-firmware" \
  --bootappend-live "boot=live components username=${LIVE_USER} hostname=leo-os" \
  --iso-application "$OS_NAME" --iso-publisher "Leo OS Project" \
  --iso-volume "LEO_OS_1_0"
mkdir -p config/package-lists config/includes.chroot/etc/lightdm/lightdm.conf.d \
 config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml \
 config/includes.chroot/usr/share/backgrounds/leo-os
cat > config/package-lists/leo.list.chroot <<EOF
live-boot
live-config
live-config-systemd
linux-image-amd64
xorg
$DESKTOP_PACKAGES
$APPLICATIONS
$OTHER_PACKAGES
EOF
cat > config/includes.chroot/etc/lightdm/lightdm.conf.d/50-leo.conf <<EOF
[Seat:*]
autologin-user=$LIVE_USER
autologin-user-timeout=0
user-session=xfce
EOF
cat > config/includes.chroot/etc/os-release <<EOF
PRETTY_NAME="$OS_NAME $VERSION"
NAME="$OS_NAME"
VERSION_ID="$VERSION"
ID=debian
ID_LIKE=debian
HOME_URL="https://www.debian.org/"
EOF
cat > config/includes.chroot/usr/share/backgrounds/leo-os/wallpaper.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="1920" height="1080">
<defs><linearGradient id="g" x2="1" y2="1"><stop stop-color="#0B1935"/><stop offset="1" stop-color="#183E75"/></linearGradient></defs>
<rect width="1920" height="1080" fill="url(#g)"/>
<g fill="#248DFF"><rect x="780" y="250" width="165" height="165"/><rect x="965" y="250" width="165" height="165"/><rect x="780" y="435" width="165" height="165"/><rect x="965" y="435" width="165" height="165"/></g>
<text x="960" y="755" fill="white" text-anchor="middle" font-family="sans-serif" font-weight="bold" font-size="90">Leo OS</text>
<text x="960" y="820" fill="#B8D7FF" text-anchor="middle" font-family="sans-serif" font-size="32">Version 1.0</text>
</svg>
EOF
cat > config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
<property name="Net" type="empty">
<property name="ThemeName" type="string" value="Arc-Dark"/>
<property name="IconThemeName" type="string" value="Adwaita"/>
</property></channel>
EOF
cat > config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
<property name="configver" type="int" value="2"/>
<property name="panels" type="array"><value type="int" value="1"/>
<property name="panel-1" type="empty">
<property name="position" type="string" value="p=10;x=960;y=1040"/>
<property name="length" type="uint" value="100"/>
<property name="length-adjust" type="bool" value="false"/>
<property name="size" type="uint" value="42"/>
<property name="plugin-ids" type="array">
<value type="int" value="1"/><value type="int" value="2"/><value type="int" value="3"/><value type="int" value="4"/>
</property></property></property>
<property name="plugins" type="empty">
<property name="plugin-1" type="string" value="whiskermenu"/>
<property name="plugin-2" type="string" value="tasklist"/>
<property name="plugin-3" type="string" value="systray"/>
<property name="plugin-4" type="string" value="clock"/>
</property></channel>
EOF
cat > config/includes.chroot/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
<property name="backdrop" type="empty">
<property name="screen0" type="empty">
<property name="monitor0" type="empty">
<property name="workspace0" type="empty">
<property name="last-image" type="string" value="/usr/share/backgrounds/leo-os/wallpaper.svg"/>
<property name="image-style" type="int" value="5"/>
</property></property></property></property></channel>
EOF
lb build
ISO="$(find . -maxdepth 1 -type f -name '*.iso' -print -quit)"
test -n "$ISO" && test -s "$ISO"
cp "$ISO" "${GITHUB_WORKSPACE:-$(dirname "$WORK")}/leo-os.iso"
