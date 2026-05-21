#!/bin/bash
if [ "$(id -u)" -ne 0 ]; then echo "Error: Requiere root." >&2; exit 1; fi
LOG="/tmp/input_fix_log.txt"
> "$LOG"
exec > >(tee -a "$LOG") 2>&1

echo "=== REPARACIÓN DE INPUT - $(date +'%d/%m/%Y %H:%M') ==="
echo "[--- DIAGNÓSTICO ---]"
dmesg | grep -i "pci" | grep -iE "usb|input" | tail -n 4
echo "-> Módulos:" && lsmod | grep -E 'usbhid|psmouse|atkbd|hid' || echo "Ninguno"
echo "-> Dispositivos:" && ls /sys/class/input | tr '\n' ' ' && echo ""

echo "[*] Reseteando hardware..."
modprobe usbhid >/dev/null 2>&1
modprobe psmouse >/dev/null 2>&1
for dev in /sys/bus/usb/drivers/usbhid/*:*; do
    [ -d "$dev" ] && ID=$(basename "$dev") && echo "  -> Reset USB: $ID" && echo "$ID" > /sys/bus/usb/drivers/usbhid/unbind 2>/dev/null && sleep 0.5 && echo "$ID" > /sys/bus/usb/drivers/usbhid/bind 2>/dev/null
done
for serio in /sys/bus/serio/devices/serio*; do
    [ -f "$serio/drvctl" ] && echo "  -> Reset PS/2: $(basename "$serio")" && echo "reconnect" > "$serio/drvctl" 2>/dev/null
done

echo "[*] Sincronizando..."
xinput list --slave --short 2>/dev/null | grep -o 'id=[0-9]*' | cut -d= -f2 | while read -r id; do
    [ -n "$id" ] && xinput enable "$id" 2>/dev/null && echo "  -> Habilitado ID: $id"
done

echo "[--- TEST ---]"
xinput list --short 2>/dev/null | grep -qi "keyboard" && echo "✅ TECLADO: DETECTADO Y ACTIVO" || echo "❌ TECLADO: NO DETECTADO"
xinput list --short 2>/dev/null | grep -qi "pointer" && echo "✅ MOUSE: DETECTADO Y ACTIVO" || echo "❌ MOUSE: NO DETECTADO"
echo "[STATUS]: Finalizado."

# Cálculo del 70% limpio usando awk para evitar errores de sintaxis en Bash
if command -v xdpyinfo >/dev/null 2>&1; then
    TARGET_W=$(xdpyinfo | grep dimensions | awk '{split($2,a,"x"); print int(a[1]*0.7)}')
    TARGET_H=$(xdpyinfo | grep dimensions | awk '{split($2,a,"x"); print int(a[2]*0.7)}')
else
    TARGET_W=1000; TARGET_H=700
fi

# Interfaz limpia con fuente chica (Monospace 8) sin parámetros inválidos
if command -v zenity >/dev/null 2>&1; then
    zenity --text-info --title="Reporte de Reparación" --filename="$LOG" --width="$TARGET_W" --height="$TARGET_H" --font="Monospace 8" 2>/dev/null &
fi
