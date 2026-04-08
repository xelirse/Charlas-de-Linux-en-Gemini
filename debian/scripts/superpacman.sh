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
pacman -Syu --overwrite="*" feh imagemagick w3m catimg jp2a libcaca xdotool xorg-xdpyinfo xorg-xrandr xorg-xwininfo
pacman -Syu --overwrite="*" libid3tag libspectre ghostscript libraw libultrahdr libwmf libzip openexr djvulibre

# Más firmware
rm /var/lib/pacman/db.lck ; pacman.real -Syu --overwrite="*" linux-firmware-qlogic upd72020x-fw aic94xx-firmware wd719x-firmware

# Secureboot signed
pacman -Syu --overwrite="*" sbctl ccid

# lxde
pacman -Syu --overwrite="*" lxde python-pyxdg faad2 fluidsynth libao libcdio-paranoia libdiscid libgme libmad libmms libmpcdec libshout opusfile smbclient wavpack lua-lgi wireless_tools
pacman -Syu --overwrite="*" python-dnspython python-markdown glusterfs python-dnspython python-markdown glusterfs
pacman -Syu --overwrite="*" python-cryptography python-requests-toolbelt python-curio python-trio python-sniffio python-yaml python-pygments python-prettytable python-setuptools
pacman -Syu --overwrite="*" python-inflect python-keyring
pacman -Syu --overwrite="*" python-keyrings-alt python-pluggy python-pycryptodome

# octopi
pacman -Syu --overwrite="*" gst-plugin-pipewire pipewire-alsa pipewire-audio pipewire-docs pipewire-ffado pipewire-libcamera pipewire-onnx pipewire-pulse pipewire-roc pipewire-session-manager pipewire-v4l2 pipewire-x11-bell pipewire-zeroconf realtime-privileges rtkit qt6-declarative qt6-quick3d python inxi lsb-release pacmanlogviewer paru pikaur systemd trizen yay
pacman -Syu --overwrite="*" serd-docs zix-docs sord-docs lv2-docs lv2-example-plugins python-lxml python-markdown python-pygments python-rdflib sord sratom-docs libsndfile lilv-docs python-lilv wireplumber-docs python-gobject expat python-pyqt5 gst-plugin-libcamera libcamera-docs libcamera-tools openmpi libpulse sox jsoncpp-doc assimp which grep curl bind binutils bluez-tools curl dmidecode doas file freeipmi hddtemp iproute2 kmod ipmitool lvm2 lm_sensors mdadm mesa-utils net-tools perl-cpanel-json-xs perl-json-xs perl-io-socket-ssl smartmontools systemd-sysvcompat sudo tree upower usbutils vulkan-tools wget wmctrl xorg-xdpyinfo xorg-xdriinfo xorg-xprop xorg-xrandr bat devtools devtools python-pysocks python-defusedxml pacman-contrib perl-lwp-protocol-https highlight perl-json-xs sudo doas
pacman -Syu --overwrite="*" python-beautifulsoup4 python-cssselect python-html5lib python-lxml-docs python-lxml-html-clean python-yaml python-pygments python-railroad-diagrams python-jinja python-cairo qt5-svg qt5-wayland postgresql-libs mariadb-libs unixodbc libfbclient freetds python-opengl qt5-multimedia qt5-tools qt5-svg qt5-xmlpatterns qt5-declarative qt5-serialport qt5-x11extras qt5-speech openpmix-docs rdma-core cuda rocm-language-runtime prrte-docs cuda hip-runtime-amd gcc-fortran openucc geoip2-database python-jsonschema linux-atm s-nail usbmuxd parallel-docs python-babel mercurial python-brotli python-brotlicffi python-h2 python-pysocks python-fastimport python-gpgme python-idna python-merge3 python-paramiko python-pyopenssl python-pyinotify python-rich python-fastimport python-gpgme python-paramiko unixodbc mariadb-libs postgresql-libs bash-completion java-environment ruby btrfs-progs nvchecker
