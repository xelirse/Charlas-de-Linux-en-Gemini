#!/bin/bash

# Configuración
REAL_APT="/usr/bin/apt_bin"
FORBIDDEN_PKGS=("libc6" "apt" "libc6:amd64" "libc6:i386")
FORBIDDEN_ACTIONS=("reinstall" "remove" "purge")

# Función para verificar si un argumento es un paquete prohibido
is_forbidden_pkg() {
    local arg=$1
    for pkg in "${FORBIDDEN_PKGS[@]}"; do
        if [[ "$arg" == "$pkg" ]]; then
            return 0
        fi
    done
    return 1
}

# Bandera para detectar acciones de riesgo
BLOCK_EXECUTION=0
IS_REINSTALL_FLANKED=0

# Analizar los argumentos
for arg in "$@"; do
    # Detectar si se usa la acción 'reinstall' directamente
    for action in "${FORBIDDEN_ACTIONS[@]}"; do
        if [[ "$arg" == "$action" ]]; then
            ACTION_FOUND="$action"
        fi
    done

    # Detectar el flag --reinstall (común en 'apt install --reinstall')
    if [[ "$arg" == "--reinstall" ]]; then
        IS_REINSTALL_FLANKED=1
    fi

    # Verificar si el argumento es un paquete protegido
    if is_forbidden_pkg "$arg"; then
        PROTECTED_PKG_DETECTED="$arg"
    fi
done

# Lógica de bloqueo
if [[ -n "$PROTECTED_PKG_DETECTED" ]]; then
    if [[ -n "$ACTION_FOUND" ]] || [[ $IS_REINSTALL_FLANKED -eq 1 ]]; then
        echo -e "\e[1;31m[ERROR de Seguridad]\e[0m: Se ha bloqueado la acción sobre el paquete crítico: \e[1;33m$PROTECTED_PKG_DETECTED\e[0m."
        echo "Modificar estos paquetes manualmente puede corromper el sistema (libc6/apt)."
        echo "Usa '$REAL_APT' directamente solo si sabes EXACTAMENTE lo que haces."
        exit 1
    fi
fi

# Si todo está bien, pasar todos los argumentos al apt real
exec "$REAL_APT" "$@"
