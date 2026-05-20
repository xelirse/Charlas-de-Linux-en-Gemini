#!/bin/sh

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
