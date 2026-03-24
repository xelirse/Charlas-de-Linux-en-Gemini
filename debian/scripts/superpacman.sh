#!/bin/sh

pacman -Syu --overwrite="*" erofsfuse efibootmgr fuse3 libisoburn lzop mtools os-prober sdl update-grub install-grub tk git-zsh-completion tk openssh man perl-libwww perl-term-readkey perl-io-socket-ssl perl-authen-sasl perl-cgi subversion org.freedesktop.secrets less libfido2 x11-ssh-askpass xorg-xauth manjaro-tools-iso-git manjaro-tools-pkg-git manjaro-tools-yaml-git tk ruby-docs ruby-default-gems ruby-bundled-gems ruby-stdlib python-gobject python-notify2 python-psutil tk xdg-desktop-portal npm fakeroot mlocate plocate vim neovim perl-crypt-passwdmd5 perl-digest-sha1 gptfdisk efibootmgr kde-cli-tools exo pcmanfm perl-file-mimeinfo perl-net-dbus perl-x11-protocol xorg-xset calamares zsh-completions

pacman -Syu --overwrite="*" efibootmgr fuse3 libisoburn lzop mtools os-prober sdl update-grub install-grub tk git-zsh-completion tk openssh man perl-libwww perl-term-readkey perl-io-socket-ssl perl-authen-sasl perl-cgi subversion org.freedesktop.secrets less libfido2 x11-ssh-askpass xorg-xauth manjaro-tools-iso-git manjaro-tools-pkg-git manjaro-tools-yaml-git tk ruby-docs ruby-default-gems ruby-bundled-gems ruby-stdlib python-gobject python-notify2 python-psutil tk xdg-desktop-portal npm fakeroot mlocate plocate vim neovim perl-crypt-passwdmd5 perl-digest-sha1 gptfdisk efibootmgr kde-cli-tools exo pcmanfm perl-file-mimeinfo perl-net-dbus perl-x11-protocol xorg-xset calamares zsh-completions

# Luego de pacman
pacman -Sy --overwrite="*" gd perl bash-completion lvm2 smtp-forwarder perl python audispd-plugins audispd-plugins-zos python git appstream dconf glib2-devel gvfs org.freedesktop.secrets gcr gtk3 qt5-x11extras kwayland5 kguiaddons kwindowsystem pcsclite less diffutils words libmicrohttpd apparmor quota-tools systemd-sysvcompat systemd-ukify polkit qrencode iptables libbpf libpwquality libfido2 debuginfod perl base-devel perl-locale-gettext

# Luego de pacman 0
pacman -Sy --overwrite="*" libwebp-utils dav1d-doc java-runtime sdl2-compat ffmpeg openjpeg2 python-setuptools python-pip python-pipx tk git-zsh-completion tk man perl-libwww perl-term-readkey perl-io-socket-ssl perl-authen-sasl perl-cgi subversion freeglut java-runtime graphite-docs harfbuzz-utils libopenraw libwmf x11-ssh-askpass xorg-xauth gtk4 java-runtime samba libblockdev-btrfs libblockdev-dm libblockdev-lvm libblockdev-mpath libblockdev-nvdimm python-libblockdev python-volume_key btrfs-progs dosfstools exfatprogs f2fs-tools nilfs-utils ntfs-3g udftools xfsprogs smartmontools udisks2-btrfs udisks2-lvm2 udisks2-docs btrfs-progs dosfstools exfatprogs f2fs-tools nilfs-utils udftools xfsprogs gvfs-afc gvfs-dnssd gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb gvfs-wsdd nss-mdns python-dbus python-gobject python-twisted rrdtool opengl-man-pages evince kde-cli-tools exo pcmanfm perl-file-mimeinfo perl-net-dbus perl-x11-protocol xorg-xset python-libevdev python-pyudev libinput-tools qt5-svg postgresql-libs mariadb-libs unixodbc libfbclient freetds freetds libfbclient mariadb-libs postgresql-libs unixodbc pyside6 qt6-declarative qt6-declarative ccid python-gobject python-notify2 python-psutil ruby tk python-setuptools python-pillow sbsigntools elfutils lib32-gcc-libs netpbm psutils libxaw perl-file-homedir ed perl-archive-zip

# Linux firmware
pacman -Syu --overwrite="*" linux-firmware
pacman -Syu --overwrite="*" linux-firmware-liquidio linux-firmware-marvell linux-firmware-mellanox linux-firmware-nfp linux-firmware-qcom linux-firmware-qlogic

# neofetch
pacman -Syu --overwrite="*" chaotic-neofetch-git
pacman -Syu --overwrite="*" feh imagemagick nitrogen w3m catimg jp2a libcaca xdotool xorg-xdpyinfo xorg-xrandr xorg-xwininfo
