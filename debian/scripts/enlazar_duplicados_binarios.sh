#!/bin/bash

# Advertencia: Modificar librerías del sistema puede afectar al gestor de paquetes.
# Úsese con precaución.

dry_run=1
dir_base="/usr/bin"
dirs_secundarios=("/usr/sbin")

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Preparación: Contar archivos y registrar tiempo inicial
mapfile -t archivos_base < <(find "$dir_base" -maxdepth 1 -type f)
total=${#archivos_base[@]}
actual=0
inicio_segundos=$(date +%s)
hoy=$(date +%Y%m%d)

if [ "$dry_run" -eq 1 ]; then
    echo "--- modo simulación activo ---"
fi

for archivo_base in "${archivos_base[@]}"; do
    ((actual++))
    
    # 1. Cálculo de tiempos y estimación
    ahora_segundos=$(date +%s)
    tiempo_transcurrido=$((ahora_segundos - inicio_segundos))
    
    if [ "$actual" -gt 1 ]; then
        segundos_por_archivo=$((tiempo_transcurrido * 1000 / actual))
        segundos_restantes=$(( (total - actual) * segundos_por_archivo / 1000 ))
        unix_fin=$((ahora_segundos + segundos_restantes))
        
        dia_fin=$(date -d "@$unix_fin" +%Y%m%d)
        if [ "$hoy" == "$dia_fin" ]; then
            fecha_fin=$(date -d "@$unix_fin" "+%H:%M:%S")
        else
            fecha_fin=$(date -d "@$unix_fin" "+%d/%m %H:%M:%S")
        fi
    else
        fecha_fin="calculando..."
    fi

    porcentaje=$(( actual * 100 / total ))
    
    # 2. Creamos la línea de progreso (usamos \e[K para limpiar la línea antes de escribir)
    linea_progreso="\r\e[Kprocesando: [%%%-3d] (%d/%d) - fin estimado: %s"
    printf "$linea_progreso" "$porcentaje" "$actual" "$total" "$fecha_fin"

    # 3. Lógica de comparación
    size_base=$(stat -c%s "$archivo_base")

    for dir_sec in "${dirs_secundarios[@]}"; do
        if [ ! -d "$dir_sec" ] || [ -L "$dir_sec" ]; then
            continue
        fi

        while read -r archivo_sec; do
            size_sec=$(stat -c%s "$archivo_sec")
            
            if [ "$size_base" -eq "$size_sec" ]; then
                # comparación rápida de 2 bytes
                if cmp -s -n 2 "$archivo_base" "$archivo_sec"; then
                    # comparación completa
                    if cmp -s "$archivo_base" "$archivo_sec"; then
                        
                        # Limpiamos la línea de progreso actual para que el comando aparezca arriba
                        printf "\r\e[K" 
                        
                        if [ "$dry_run" -eq 0 ]; then
                            ln -srfv "$archivo_base" "$archivo_sec"
                        else
                            echo "ln -srfv \"$archivo_base\" \"$archivo_sec\""
                        fi
                        
                        # Redibujamos el progreso inmediatamente después de imprimir el hallazgo
                        printf "$linea_progreso" "$porcentaje" "$actual" "$total" "$fecha_fin"
                    fi
                fi
            fi
        done < <(find "$dir_sec" -maxdepth 1 -type f)
    done
done

echo -e "\n--- proceso finalizado a las $(date "+%d/%m %H:%M:%S") ---"
