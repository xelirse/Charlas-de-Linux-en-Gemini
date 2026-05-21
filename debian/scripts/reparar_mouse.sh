#!/bin/bash

# Validar privilegios de root
if [ "$(id -u)" -ne 0 ]; then
    ERROR_MSG="Error: Se requieren privilegios de root (ejecutar con sudo)."
    echo "$ERROR_MSG" >&2
    echo "$ERROR_MSG" | LC_ALL=C xmessage -center -fn fixed -file -
    exit 1
fi

# 1. Instalar xinput usando APT (Salida directa a stdout con colores)
if ! command -v xinput >/dev/null 2>&1; then
    {
        echo -e "\e[1;34m> apt-get update -qq\e[0m"
        apt-get update -qq -o APT::Color=1

        echo -e "\e[1;34m> apt-get install -y -t experimental xinput\e[0m"
        if ! apt-get install -y -t experimental xinput -o APT::Color=1; then
            echo -e "\e[1;33m[-] Experimental no disponible. Reintentando repositorio estable...\e[0m"
            echo -e "\e[1;34m> apt-get install -y xinput\e[0m"
            apt-get install -y xinput -o APT::Color=1
        fi
    } 2>&1
    echo "[*] Proceso de instalación finalizado."
    echo "----------------------------------------"
fi

# Inicializamos el LOG para el reporte de xmessage
LOG=$(mktemp)

# 2. Verificación de archivos físicos o alternativas sysfs para el teclado
echo "[MÓDULOS EN 7.1-AMD64 KERNEL PATH]" >> "$LOG"
TARGET_PATH="/usr/lib/modules/7.1-amd64/kernel"
if [ -d "$TARGET_PATH" ]; then
    for mod in psmouse usbhid atkbd; do
        if find "$TARGET_PATH" -type f -name "${mod}.ko*" | grep -q .; then
            echo "  $mod: DISPONIBLE" >> "$LOG"
        elif [ "$mod" = "atkbd" ] && [ -e /sys/bus/serio/devices/serio0/drvctl ]; then
            echo "  $mod: NO ENCONTRADO (Alternativa sysfs disponible)" >> "$LOG"
        else
            echo "  $mod: NO ENCONTRADO" >> "$LOG"
        fi
    done
else
    echo "  Error: La ruta $TARGET_PATH no existe." >> "$LOG"
fi

# 3. Reinicio de drivers a nivel Kernel
echo -e "\n[*] Reiniciando subsistemas de entrada..." >> "$LOG"
modprobe -r usbhid psmouse atkbd 2>>"$LOG"
sleep 0.5

# Intenta modprobe; si falla por chroot/built-in, re-conecta de forma física por Sysfs
modprobe usbhid 2>>"$LOG" || {
    for dev in /sys/bus/usb/drivers/usbhid/*:* ; do
        if [ -e "$dev" ]; then
            DEV_NAME=$(basename "$dev")
            echo "$DEV_NAME" > /sys/bus/usb/drivers/usbhid/unbind 2>/dev/null
            echo "$DEV_NAME" > /sys/bus/usb/drivers/usbhid/bind 2>/dev/null
            echo "  -> usbhid ($DEV_NAME): Reiniciado vía Sysfs" >> "$LOG"
        fi
    done
}

modprobe psmouse 2>>"$LOG"

modprobe atkbd 2>>"$LOG" || {
    if [ -e /sys/bus/serio/devices/serio0/drvctl ]; then
        echo -n "reconnect" > /sys/bus/serio/devices/serio0/drvctl 2>/dev/null
        echo "  -> atkbd (serio0): Re-conectado vía Sysfs" >> "$LOG"
    fi
}

# 4. Forzar re-detección global en udev
udevadm trigger --subsystem-match=input 2>>"$LOG"

# Forzar habilitación en X11 en caso de que el entorno haya bloqueado o descolgado los punteros
if command -v xinput >/dev/null 2>&1; then
    DISPLAY=:0 xinput list | grep -iE 'pointer|keyboard|mouse|translated' | grep -o 'id=[0-9]*' | cut -d= -f2 | while read -r id; do
        DISPLAY=:0 xinput enable "$id" 2>/dev/null
    done
fi

# 5. Estado actual del Kernel en ejecución
echo -e "\n[MÓDULOS CARGADOS ACTUALMENTE]" >> "$LOG"
lsmod | grep -E 'psmouse|hid|atkbd' >> "$LOG"

echo -e "\n[DMESG RECIENTE]" >> "$LOG"
dmesg | grep -iE 'mouse|psmouse|synaptics|hid|keyboard|atkbd' | tail -n 6 >> "$LOG"

echo -e "\n[XINPUT DISPOSITIVOS]" >> "$LOG"
if command -v xinput >/dev/null 2>&1; then
    DISPLAY=:0 xinput list | grep -E 'pointer|keyboard' >> "$LOG"
else
    echo "xinput no disponible." >> "$LOG"
fi

# Línea final informativa adjunta al reporte
echo -e "\n[RUTA DEL ARCHIVO LOG]" >> "$LOG"
echo "  $LOG" >> "$LOG"

# Imprime el informe limpio en stdout (consola)
cat "$LOG"

# Lanza la interfaz gráfica compacta sin remover el archivo temporal después
LC_ALL=C xmessage -center -fn "6x13" -title "Input Fix (Mouse/Kbd)" -file "$LOG"
