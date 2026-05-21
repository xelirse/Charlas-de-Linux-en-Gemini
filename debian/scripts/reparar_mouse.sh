#!/bin/bash

# 1. Validación de Root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Se requieren privilegios de root." >&2
    exit 1
fi

LOG="/tmp/input_fix_log.txt"
> "$LOG"

# Redirigir stdout y stderr a la terminal Y al archivo LOG
# (Se redirigen errores de xinput a /dev/null para evitar advertencias de Wayland)
exec > >(tee -a "$LOG") 2>&1

echo "========================================================="
echo "           REPARACIÓN DE INPUT - $(date +'%d/%m/%Y %H:%M')"
echo "========================================================="

# 2. Diagnóstico del sistema
echo -e "\n[--- DIAGNÓSTICO DE SISTEMA ---]"
echo "-> Rutas PCI / Sysfs (dmesg reciente):"
dmesg | grep -i "pci" | grep -iE "usb|input" | tail -n 4
echo -e "\n-> Módulos (usbhid/psmouse/atkbd):"
lsmod | grep -E 'usbhid|psmouse|atkbd|hid' || echo "  (Ninguno detectado)"

echo -e "\n-> Dispositivos en /sys/class/input:"
ls /sys/class/input | tr '\n' ' '
echo -e "\n"

# 3. Reparación de Hardware
echo "[*] Iniciando reparación física..."
modprobe usbhid >/dev/null 2>&1
modprobe psmouse >/dev/null 2>&1

# USB
for dev in /sys/bus/usb/drivers/usbhid/*:*; do
    if [ -d "$dev" ]; then
        ID=$(basename "$dev")
        echo "  -> Reset USB: $ID"
        echo "$ID" > /sys/bus/usb/drivers/usbhid/unbind 2>/dev/null
        sleep 0.5
        echo "$ID" > /sys/bus/usb/drivers/usbhid/bind 2>/dev/null
    fi
done

# PS/2
for serio in /sys/bus/serio/devices/serio*; do
    if [ -f "$serio/drvctl" ]; then
        echo "  -> Reset PS/2: $(basename "$serio")"
        echo "reconnect" > "$serio/drvctl" 2>/dev/null
    fi
done

# 4. Sincronización y Test
echo -e "\n[*] Sincronizando dispositivos..."
# El stderr es redirigido a /dev/null para silenciar warnings de Xwayland
xinput list --slave --short 2>/dev/null | grep -o 'id=[0-9]*' | cut -d= -f2 | while read -r id; do
    if [ -n "$id" ]; then
        xinput enable "$id" 2>/dev/null
        echo "  -> Habilitado ID: $id"
    fi
done

echo -e "\n========================================================="
echo "[--- TEST DE HARDWARE ---]"

# Test de presencia
if xinput list --short 2>/dev/null | grep -qi "keyboard"; then
    echo "[OK] TECLADO: Detectado"
else
    echo "[!!] TECLADO: No detectado"
fi

if xinput list --short 2>/dev/null | grep -qi "pointer"; then
    echo "[OK] MOUSE: Detectado"
else
    echo "[!!] MOUSE: No detectado"
fi
echo "========================================================="
echo "[STATUS]: Reparación finalizada."

# 5. Reporte Visual (Autoajustable)
# Obtenemos resolución de pantalla para calcular dimensiones
if command -v xdpyinfo >/dev/null 2>&1; then
    SCREEN_DIM=$(xdpyinfo | grep dimensions | awk '{print $2}')
    TARGET_W=$(( $(echo $SCREEN_DIM | cut -d'x' -f1) * 70 / 100 ))
    TARGET_H=$(( $(echo $SCREEN_DIM | cut -d'x' -f2) * 70 / 100 ))
else
    TARGET_W=1000; TARGET_H=700
fi

# Zenity limpio (sin etiquetas HTML)
if command -v zenity >/dev/null 2>&1; then
    zenity --text-info --title="Reporte de Reparación" --filename="$LOG" \
           --width="$TARGET_W" --height="$TARGET_H" --font="Monospace 9" 2>/dev/null &
elif command -v xmessage >/dev/null 2>&1; then
    xmessage -center -geometry "${TARGET_W}x${TARGET_H}" -title "Reporte de Reparación" -file "$LOG" 2>/dev/null &
fi
