#!/bin/sh

# Copia la carpeta local del disco al pendrive

cd /

destino="/"
punto_montaje="/run/media/manjaro/cfb49c22-87f2-47d9-a25b-310d8d8578af/@"
disco="/n"
origen="$disco/local"

if [[ ! -d "$disco"  ]];then
	sudo ln -svf "$punto_montaje" "$disco"
fi

cd "$disco"

# Usamos find para obtener CUALQUIER archivo o directorio dentro de origen
# -mindepth 1 evita que procese el propio directorio "./local"
find "$origen" -mindepth 1 | while read -r item; do

	# Calculamos la ruta relativa para el destino
	# Ejemplo: si item es ./local/usr/bin/algo, sub_path será usr/bin/algo
	sub_path="${item#$origen/}"
	objetivo="$destino$sub_path"
	if [ -d "$item" ]; then
		# Si es un directorio, lo creamos en el destino
		mkdir -pv "$objetivo"
	else
		sudo cp -fv "$item" "$objetivo"
	fi
done

konsole -e "sudo entrar" &disown
