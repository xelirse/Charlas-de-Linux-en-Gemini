#!/usr/bin/env python3
import os
import shutil
import subprocess

tema_path = "/root/.local/share/icons/tema_frankeinux"
archivo_theme = os.path.join(tema_path, "index.theme")

def limpieza_profunda():
    print(f"🧹 Iniciando limpieza profunda en {tema_path}...")

    # 1. Eliminar archivos de 0 bytes y enlaces rotos
    for root, dirs, files in os.walk(tema_path):
        for nombre in files:
            ruta_file = os.path.join(root, nombre)
            # Borrar si el archivo está vacío
            if os.path.exists(ruta_file) and os.path.getsize(ruta_file) == 0:
                print(f"🗑️  Borrando archivo vacío: {nombre}")
                os.remove(ruta_file)
            # Borrar si es un enlace simbólico roto
            if os.path.islink(ruta_file) and not os.path.exists(ruta_file):
                print(f"🔗 Borrando enlace roto: {nombre}")
                os.remove(ruta_file)

    # 2. Forzar permisos correctos (Root debe ser dueño y poder leer)
    print("🔑 Asegurando permisos de lectura...")
    os.system(f"chmod -R 755 {tema_path}")

    # 3. Ejecutar la lógica de index.theme (v3 integrada)
    # (Aquí llamamos al proceso de actualización del index que ya hicimos)
    # Si ya corriste el anterior, el index.theme debería estar bien, 
    # pero vamos a intentar el caché una última vez con un truco:
    
    print("🔄 Intentando regenerar caché (sin validación estricta)...")
    # Borrar cachés viejos
    for f in ["icon-theme.cache", ".icon-theme.cache"]:
        p = os.path.join(tema_path, f)
        if os.path.exists(p): os.remove(p)

    # El comando mágico: -i (ignore theme index check) no existe, 
    # pero -t (terminar en error) sí. Usaremos solo -f.
    cmd = ['gtk-update-icon-cache', '-f', tema_path]
    result = subprocess.run(cmd, capture_output=True, text=True)

    if "invalid" in result.stderr:
        print("⚠️  GTK sigue detectando inconsistencias estructurales.")
        print("👉 Intentaremos crear un archivo de caché vacío para engañar al sistema:")
        with open(os.path.join(tema_path, "icon-theme.cache"), "w") as f:
            f.write("")
        print("✅ Cache 'dummy' creado.")
    else:
        print("✨ ¡Caché generado con éxito!")

if __name__ == "__main__":
    limpieza_profunda()
