#!/bin/bash

# Verificar que se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

echo "=== 1. Deteniendo servicios de audio conflictivos ==="
# Detener Pipewire y PulseAudio para liberar la tarjeta (ejecutado para el usuario actual)
USER_ID=$(id -u $SUDO_USER)
if [ -n "$USER_ID" ]; then
    su - $SUDO_USER -c "systemctl --user stop pipewire pipewire-pulse wireplumber pipewire.socket pipewire-pulse.socket pulseaudio pulseaudio.socket 2>/dev/null"
fi

# Matar cualquier proceso restante que bloquee ALSA
fuser -kv /dev/snd/* 2>/dev/null

echo "=== 2. Limpiando configuraciones y parches previos ==="
rm -f /etc/modprobe.d/audio-fix.conf
rm -f /etc/modprobe.d/alsa-index.conf
rm -f /etc/modprobe.d/audio-patch.conf
rm -f /etc/modprobe.d/audio.conf
rm -f /etc/modprobe.d/hda-jack-retask.conf
rm -f /lib/firmware/hda-jack-retask.fw
rm -f /root/.asoundrc
# Hacer backup del asoundrc del usuario si existe
[ -f /home/$SUDO_USER/.asoundrc ] && mv /home/$SUDO_USER/.asoundrc /home/$SUDO_USER/.asoundrc.bak

echo "=== 3. Descargando módulos del kernel ==="
modprobe -r snd_hda_codec_hdmi snd_hda_intel snd_hda_codec snd_hda_core ohci_hcd 2>/dev/null

echo "=== 4. Aplicando nueva configuración optimizada ==="
# Forzar el orden de las tarjetas, activar MSI y asignar modelo automático
echo "options snd-hda-intel index=0,1 id=Analog,HDMI model=auto enable_msi=1" > /etc/modprobe.d/audio.conf

echo "=== 5. Recargando módulos e inicializando hardware ==="
modprobe snd_hda_intel
sleep 2 # Dar tiempo al kernel para poblar /dev/snd/

# Desactivar el ahorro de energía que causa chasquidos
echo 0 > /sys/module/snd_hda_intel/parameters/power_save 2>/dev/null

# Rescan del bus PCI específico (si está disponible)
if [ -e /sys/bus/pci/devices/0000:00:14.2/remove ]; then
    echo 1 > /sys/bus/pci/devices/0000:00:14.2/remove
    echo 1 > /sys/bus/pci/rescan
    sleep 2
fi

echo "=== 6. Configurando ALSA por defecto (Tarjeta 1 con Dmix) ==="
cat << 'EOF' > /etc/asound.conf
pcm.mezclador_hardware {
    type dmix
    ipc_key 1024
    ipc_perm 0666
    slave {
        pcm "hw:1,0"
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
    card 1
}
EOF

echo "=== 7. Instalando dependencias de consola silenciosamente ==="
rm -f /var/lib/pacman/db.lck
# Instalar alsa-utils (amixer, aplay) y alsa-tools (hda-verb) sin confirmar
pacman -Sy --noconfirm --needed alsa-utils alsa-tools > /dev/null 2>&1

echo "=== 8. Aplicando parches de bajo nivel (hda-verb) ==="
if [ -c /dev/snd/hwC1D3 ]; then
    hda-verb /dev/snd/hwC1D3 0x16 SET_AMP_GAIN_MUTE 0xb000 >/dev/null 2>&1
    hda-verb /dev/snd/hwC1D3 0x1c SET_AMP_GAIN_MUTE 0xb000 >/dev/null 2>&1
    hda-verb /dev/snd/hwC1D3 0x16 SET_CONNECT_SEL 1 >/dev/null 2>&1
    hda-verb /dev/snd/hwC1D3 0x16 SET_AMP_GAIN_MUTE 0xb07f >/dev/null 2>&1
    echo 1 > /sys/class/sound/hwC1D3/reconfig 2>/dev/null
fi

echo "=== 9. Desmuteando canales automáticamente (Sin Alsamixer) ==="
# Iterar sobre las tarjetas 0 y 1 para subir el volumen y desmutear canales principales
for card in 0 1; do
    amixer -c $card sset Master unmute 100% >/dev/null 2>&1
    amixer -c $card sset PCM unmute 100% >/dev/null 2>&1
    amixer -c $card sset Front unmute 100% >/dev/null 2>&1
    amixer -c $card sset Speaker unmute 100% >/dev/null 2>&1
    amixer -c $card sset Headphone unmute 100% >/dev/null 2>&1
done

# Guardar los niveles de volumen en el sistema
alsactl store

echo "=== 10. Prueba final de audio ==="
# Test de 1 solo ciclo (-l 1) usando la tarjeta configurada
speaker-test -D hw:1,0 -c 2 -l 1 -t wav

echo "Proceso finalizado. El audio debería estar configurado y desmuteado."
