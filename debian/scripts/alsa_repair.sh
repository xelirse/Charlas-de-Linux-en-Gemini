#!/bin/bash

# =====================================================================
# CONFIGURACIÓN: Define aquí los porcentajes lineales exactos (0-100)
VOL_MASTER=94
VOL_SPEAKER=31
VOL_OTROS=70       # Para Headphone, PCM, Front, etc.
# =====================================================================

# Verificar que se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (sudo)."
  exit 1
fi

echo "=== 1. Deteniendo servicios de audio y cerrando aplicaciones bloqueantes ==="
echo "> killall -9 pipewire wireplumber pulseaudio pipewire-pulse"
killall -9 pipewire wireplumber pulseaudio pipewire-pulse 2>/dev/null

echo "> fuser -k -9 /dev/snd/*"
fuser -k -9 /dev/snd/* 2>/dev/null

echo "=== 2. Limpiando configuraciones y parches previos ==="
rm -vf /etc/modprobe.d/audio-fix.conf /etc/modprobe.d/alsa-index.conf /etc/modprobe.d/audio-patch.conf /etc/modprobe.d/audio.conf /etc/modprobe.d/hda-jack-retask.conf
rm -vf /lib/firmware/hda-jack-retask.fw /root/.asoundrc

for user_home in /home/*; do
    if [ -d "$user_home" ]; then
        rm -fv "$user_home/.asoundrc"
    fi
done

echo "=== 3. Descargando módulos del kernel ==="
echo "> modprobe -r snd_hda_codec_hdmi snd_hda_intel snd_hda_codec snd_hda_core ohci_hcd"
modprobe -r snd_hda_codec_hdmi snd_hda_intel snd_hda_codec snd_hda_core ohci_hcd

echo "=== 4. Aplicando nueva configuración optimizada ==="
echo "options snd-hda-intel index=0,1 id=Analog,HDMI model=auto enable_msi=1" > /etc/modprobe.d/audio.conf

echo "=== 5. Recargando módulos e inicializando hardware ==="
echo "> modprobe -v snd_hda_intel"
modprobe -v snd_hda_intel
sleep 2

echo 0 > /sys/module/snd_hda_intel/parameters/power_save

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

echo "=== 7. Instalando dependencias de ALSA (Solo si faltan) ==="
if ! command -v amixer &>/dev/null || ! command -v hda-verb &>/dev/null; then
    echo "Instalando alsa-utils / alsa-tools..."
    rm -f /var/lib/pacman/db.lck
    pacman -Sy --noconfirm --needed alsa-utils alsa-tools
else
    echo "Las herramientas de ALSA ya están instaladas."
fi

echo "=== 8. Aplicando parches de bajo nivel (hda-verb) ==="
for hw_dev in /dev/snd/hwC*; do
    if [ -c "$hw_dev" ]; then
        echo "Parcheando dispositivo de hardware nativo: $hw_dev"
        echo "> hda-verb $hw_dev 0x16 SET_AMP_GAIN_MUTE 0xb000"
        hda-verb "$hw_dev" 0x16 SET_AMP_GAIN_MUTE 0xb000
        echo "> hda-verb $hw_dev 0x1c SET_AMP_GAIN_MUTE 0xb000"
        hda-verb "$hw_dev" 0x1c SET_AMP_GAIN_MUTE 0xb000
        echo "> hda-verb $hw_dev 0x16 SET_CONNECT_SEL 1"
        hda-verb "$hw_dev" 0x16 SET_CONNECT_SEL 1
        echo "> hda-verb $hw_dev 0x16 SET_AMP_GAIN_MUTE 0xb07f"
        hda-verb "$hw_dev" 0x16 SET_AMP_GAIN_MUTE 0xb07f
        
        codec_num=$(basename "$hw_dev")
        echo 1 > "/sys/class/sound/$codec_num/reconfig"
    fi
done

echo "=== 9. Desmuteando y fijando volúmenes personalizados ==="
for card in 0 1; do
    echo "--- Analizando Tarjeta de sonido $card ---"
    controles_reales=$(amixer -c $card scontrols | cut -d"'" -f2)

    # Desactivar Auto-Mute de forma segura
    if echo "$controles_reales" | grep -q "^Auto-Mute Mode$"; then
        echo "> amixer -c $card sset \"Auto-Mute Mode\" Disabled"
        amixer -c $card sset "Auto-Mute Mode" Disabled
    fi
    if echo "$controles_reales" | grep -q "^Auto-Mute$"; then
        echo "> amixer -c $card sset \"Auto-Mute\" Off"
        amixer -c $card sset "Auto-Mute" Off
    fi
    
    # Ajustar canales asignando su porcentaje correspondiente usando la escala Mapeada (-M)
    for canal in "Master" "PCM" "Front" "Speaker" "Headphone"; do
        if echo "$controles_reales" | grep -q "^$canal$"; then
            
            # Asignar el porcentaje correcto configurado arriba
            case "$canal" in
                "Master")  porcentaje_actual=$VOL_MASTER ;;
                "Speaker") porcentaje_actual=$VOL_SPEAKER ;;
                *)         porcentaje_actual=$VOL_OTROS ;;
            esac
            
            # Usamos -M para forzar a amixer a interpretar el % de forma lineal exacta
            echo "> amixer -M -c $card sset \"$canal\" ${porcentaje_actual}% unmute"
            amixer -M -c $card sset "$canal" "${porcentaje_actual}%" unmute
        fi
    done

    # Salida digital HDMI si existe
    if echo "$controles_reales" | grep -q "^IEC958$"; then
        echo "> amixer -c $card sset \"IEC958\" unmute"
        amixer -c $card sset "IEC958" unmute
    fi
done
echo "> alsactl store"
alsactl store

echo "=== 10. Prueba final de audio ==="
echo "> speaker-test -D default -c 2 -l 1 -t wav"
speaker-test -D default -c 2 -l 1 -t wav

echo "=== 11. Verificando e instalando pnmixer ==="
if ! command -v pnmixer &>/dev/null; then
    echo "pnmixer no está instalado. Procediendo con la instalación..."
    PACKAGE_URL="https://repo.archlinuxcn.org/x86_64/pnmixer-0.7.2-2-x86_64.pkg.tar.zst"
    PACKAGE_FILE="/tmp/pnmixer-0.7.2-2-x86_64.pkg.tar.zst"

    echo "> curl -L -o $PACKAGE_FILE $PACKAGE_URL"
    curl -L -o "$PACKAGE_FILE" "$PACKAGE_URL"
    if [ -f "$PACKAGE_FILE" ]; then
        rm -f /var/lib/pacman/db.lck
        echo "> pacman -U --noconfirm $PACKAGE_FILE"
        pacman -U --noconfirm "$PACKAGE_FILE"
        rm -f "$PACKAGE_FILE"
    fi
else
    echo "pnmixer ya se encuentra instalado."
fi

if command -v pnmixer &>/dev/null && ! pgrep -x "pnmixer" &>/dev/null; then
    echo "Iniciando pnmixer en segundo plano..."
    echo "> DISPLAY=:0 pnmixer &"
    DISPLAY=:0 pnmixer &
fi

echo "Proceso completamente finalizado de forma limpia."
