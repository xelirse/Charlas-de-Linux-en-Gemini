#!/bin/bash

# Verificar que se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

echo "=== 1. Deteniendo servicios de audio conflictivos ==="
USER_ID=$(id -u $SUDO_USER)
if [ -n "$USER_ID" ]; then
    su - $SUDO_USER -c "systemctl --user stop pipewire pipewire-pulse wireplumber pipewire.socket pipewire-pulse.socket pulseaudio pulseaudio.socket 2>/dev/null"
fi
fuser -kv /dev/snd/* 2>/dev/null

echo "=== 2. Limpiando configuraciones y parches previos ==="
rm -f /etc/modprobe.d/audio-fix.conf /etc/modprobe.d/alsa-index.conf /etc/modprobe.d/audio-patch.conf /etc/modprobe.d/audio.conf /etc/modprobe.d/hda-jack-retask.conf
rm -f /lib/firmware/hda-jack-retask.fw /root/.asoundrc
[ -f /home/$SUDO_USER/.asoundrc ] && mv /home/$SUDO_USER/.asoundrc /home/$SUDO_USER/.asoundrc.bak 2>/dev/null

echo "=== 3. Descargando módulos del kernel ==="
modprobe -r snd_hda_codec_hdmi snd_hda_intel snd_hda_codec snd_hda_core ohci_hcd 2>/dev/null

echo "=== 4. Aplicando nueva configuración optimizada ==="
# Forzamos que la analógica sea la tarjeta 0
echo "options snd-hda-intel index=0,1 id=Analog,HDMI model=auto enable_msi=1" > /etc/modprobe.d/audio.conf

echo "=== 5. Recargando módulos e inicializando hardware ==="
modprobe snd_hda_intel
sleep 2

echo 0 > /sys/module/snd_hda_intel/parameters/power_save 2>/dev/null

if [ -e /sys/bus/pci/devices/0000:00:14.2/remove ]; then
    echo 1 > /sys/bus/pci/devices/0000:00:14.2/remove
    echo 1 > /sys/bus/pci/rescan
    sleep 2
fi

echo "=== 6. Configurando ALSA por defecto (Tarjeta 0 con Dmix) ==="
cat << 'EOF' > /etc/asound.conf
pcm.mezclador_hardware {
    type dmix
    ipc_key 1024
    ipc_perm 0666
    slave {
        pcm "hw:0,0"
        channels 2
        rate 48000
    }
}

pcm.!default {
    type plug
    slave.pcm "mezclador_hardware"
}

ctl.!default {
    type hw
    card 0
}
EOF

echo "=== 7. Instalando dependencias de consola silenciosamente ==="
rm -f /var/lib/pacman/db.lck
pacman -Sy --noconfirm --needed alsa-utils alsa-tools > /dev/null 2>&1

echo "=== 8. Aplicando parches de bajo nivel (hda-verb) ==="
# Detectar dinámicamente cualquier nodo de hardware de sonido activo (sea hwC0D3, hwC0D0, etc.)
for hw_dev in /dev/snd/hwC*; do
    if [ -c "$hw_dev" ]; then
        hda-verb "$hw_dev" 0x16 SET_AMP_GAIN_MUTE 0xb000 >/dev/null 2>&1
        hda-verb "$hw_dev" 0x1c SET_AMP_GAIN_MUTE 0xb000 >/dev/null 2>&1
        hda-verb "$hw_dev" 0x16 SET_CONNECT_SEL 1 >/dev/null 2>&1
        hda-verb "$hw_dev" 0x16 SET_AMP_GAIN_MUTE 0xb07f >/dev/null 2>&1
        # Forzar reconfiguración del códec detectado
        codec_num=$(basename "$hw_dev")
        echo 1 > "/sys/class/sound/$codec_num/reconfig" 2>/dev/null
    fi
done

echo "=== 9. Desmuteando canales automáticamente (Sin Alsamixer) ==="
# Asegurar volumen al máximo en tarjeta 0 y tarjeta 1
for card in 0 1; do
    amixer -c $card sset Master unmute 100% >/dev/null 2>&1
    amixer -c $card sset PCM unmute 100% >/dev/null 2>&1
    amixer -c $card sset Front unmute 100% >/dev/null 2>&1
    amixer -c $card sset Speaker unmute 100% >/dev/null 2>&1
    amixer -c $card sset Headphone unmute 100% >/dev/null 2>&1
done
alsactl store

echo "=== 10. Prueba final de audio ==="
# Ahora apuntamos al dispositivo correcto (default o hw:0,0)
speaker-test -D default -c 2 -l 1 -t wav

echo "Proceso finalizado. El audio debería estar configurado en la Tarjeta 0 y desmuteado."
# 1. Definir la URL y el nombre del paquete
PACKAGE_URL="https://repo.archlinuxcn.org/x86_64/pnmixer-0.7.2-2-x86_64.pkg.tar.zst"
PACKAGE_FILE="pnmixer-0.7.2-2-x86_64.pkg.tar.zst"

# 2. Descargar el paquete
echo "Descargando pnmixer..."
curl -O "$PACKAGE_URL"

# 3. Instalar el paquete localmente
# -U: instalar desde archivo
# --noconfirm: evita confirmaciones manuales
echo "Instalando pnmixer..."
sudo pacman -U --noconfirm "$PACKAGE_FILE"

# 4. Limpieza (opcional)
rm "$PACKAGE_FILE"

# 5. Ejecutar pnmixer en segundo plano
echo "Ejecutando pnmixer..."
pnmixer > /dev/null 2>&1 &

echo "Instalación y ejecución completadas."
