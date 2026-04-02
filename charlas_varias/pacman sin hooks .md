You asked:
----------

Has dicho

Se cuelga en %100 y no termina de instalar.

  

resolving dependencies...

looking for conflicting packages...

  

Packages (1) xorg-xset-1.2.5-2

  

Total Installed Size:  0,04 MiB

Net Upgrade Size:      0,00 MiB

  

:: Proceed with installation? \[Y/n\] 

(1/1) checking keys in keyring                                                         \[##################################################\] 100%

(1/1) checking package integrity                                                       \[##################################################\] 100%

(1/1) loading package files                                                            \[##################################################\] 100%

(1/1) checking for file conflicts                                                      \[##################################################\] 100%

(1/1) checking available disk space                                                    \[##################################################\] 100%

:: Processing package changes...

(1/1) reinstalling xorg-xset                                                           \[##################################################\] 100%

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Es frustrante cuando parece que la meta está ahí mismo pero el sistema simplemente decide "congelarse". Basado en tu log de Arch Linux (o derivada), el proceso se detiene justo en el paso final de **escritura en disco** o en la ejecución de los **hooks de post-instalación**.

Aquí tienes las causas más probables y cómo solucionarlo:

* * *

### 1\. El proceso "Zombie" (Causa más común)

A veces, `pacman` termina el trabajo pero el proceso de la terminal no recibe la señal de cierre, o un script de post-instalación se quedó esperando algo.

*   **Prueba esto:** Abre una **segunda terminal** y verifica si el paquete ya se instaló:
    
    Bash
    
        pacman -Qi xorg-xset
    
    Si aparece la información del paquete y dice "Install Date" con la fecha de hoy, la instalación **fue exitosa**. Puedes cerrar la terminal colgada con `Ctrl+C` o matando el proceso (`killall pacman`).
    

* * *

### 2\. Bloqueo de la base de datos (`db.lck`)

Si forzaste el cierre de la instalación anterior, es probable que haya quedado un archivo de bloqueo que impide que el sistema termine de registrar el cambio.

*   **Solución:** Borra el archivo de bloqueo manualmente:
    
    Bash
    
        sudo rm /var/lib/pacman/db.lck
    

* * *

### 3\. Problemas de Sincronización de Disco (Sync)

Si estás usando un disco duro externo, una USB, o si el sistema de archivos está teniendo problemas para escribir los metadatos finales:

*   **Solución:** En otra terminal, escribe el comando `sync`. Si este comando también se queda colgado, tienes un problema de hardware o de montaje con tu unidad de almacenamiento.
    

* * *

### 4\. Reinstala el Keyring (Si se cuelga antes de escribir)

Aunque tu log dice que pasó el chequeo de llaves, a veces el cuelgue ocurre porque el servicio `gpg-agent` está bloqueado.

*   **Solución:** Refresca las llaves antes de reintentar:
    
    Bash
    
        sudo pacman -Sy archlinux-keyring
        sudo pacman-key --init
        sudo pacman-key --populate archlinux
    

* * *

### Resumen de acción rápida:

1.  Espera **2 minutos** (a veces los hooks de fuentes o iconos tardan en segundo plano).
    
2.  Presiona `Ctrl+C`.
    
3.  Si no responde, cierra la ventana de la terminal.
    
4.  Ejecuta `sudo rm /var/lib/pacman/db.lck`.
    
5.  Corre `sudo pacman -Syu` para asegurar que no hay archivos corruptos.
    

¿Es la primera vez que te pasa con este paquete o te sucede con cualquier instalación?

---

You asked:
----------

Has dicho

\[manjaro n\]# pacman --root /n -Qi xorg-xset

error: duplicated database entry 'assimp'

error: duplicated database entry 'bcachefs-tools'

error: duplicated database entry 'chromium'

error: duplicated database entry 'discord-canary'

error: duplicated database entry 'dpkg'

error: duplicated database entry 'file'

error: duplicated database entry 'gdb'

error: duplicated database entry 'gdb-common'

error: duplicated database entry 'haskell-asn1-encoding'

error: duplicated database entry 'haskell-asn1-parse'

error: duplicated database entry 'haskell-asn1-types'

error: duplicated database entry 'haskell-crypton'

error: duplicated database entry 'haskell-crypton-x509'

error: duplicated database entry 'haskell-crypton-x509-store'

error: duplicated database entry 'haskell-crypton-x509-system'

error: duplicated database entry 'haskell-crypton-x509-validation'

error: duplicated database entry 'haskell-cryptonite'

error: duplicated database entry 'haskell-data-default'

error: duplicated database entry 'haskell-data-default-instances-dlist'

error: duplicated database entry 'haskell-dlist'

error: duplicated database entry 'haskell-hourglass'

error: duplicated database entry 'haskell-hsopenssl'

error: duplicated database entry 'haskell-hsopenssl-x509-system'

error: duplicated database entry 'haskell-iproute'

error: duplicated database entry 'haskell-memory'

error: duplicated database entry 'haskell-network'

error: duplicated database entry 'haskell-pem'

error: duplicated database entry 'haskell-x509'

error: duplicated database entry 'libcbor'

error: duplicated database entry 'libfido2'

error: duplicated database entry 'libngtcp2'

error: duplicated database entry 'libvpx'

error: duplicated database entry 'luajit'

error: duplicated database entry 'nodejs'

error: duplicated database entry 'openvpn'

error: duplicated database entry 'perl-clone'

error: duplicated database entry 'perl-libwww'

error: duplicated database entry 'python-pygments'

error: duplicated database entry 'python-requests'

error: duplicated database entry 'rubberband'

error: duplicated database entry 'ruby-repl\_type\_completor'

error: duplicated database entry 'simdjson'

error: duplicated database entry 'systemd'

error: duplicated database entry 'systemd-libs'

error: duplicated database entry 'vim'

error: duplicated database entry 'vim-runtime'

error: duplicated database entry 'vpnc'

error: duplicated database entry 'xz'

Name            : xorg-xset

Version         : 1.2.5-2

Description     : User preference utility for X

Architecture    : x86\_64

URL             : https://xorg.freedesktop.org/

Licenses        : custom

Groups          : xorg-apps  xorg

Provides        : None

Depends On      : libxmu

Optional Deps   : None

Required By     : lxinput

Optional For    : xdg-utils

Conflicts With  : None

Replaces        : None

Installed Size  : 40,07 KiB

Packager        : T.J. Townsend <blakkheim@archlinux.org>

Build Date      : dom 14 jul 2024 03:38:39

Install Date    : jue 02 abr 2026 00:07:22

Install Reason  : Explicitly installed

Install Script  : No

Validated By    : Signature

\[root@manjaro 2026-04-01 21:09:47 miércoles /\]$

 > pacman-key --populate archlinux

\==> Appending keys from archlinux.gpg...

/usr/bin/pacman-key: line 196: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 196: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 196: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 196: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 196: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

/usr/bin/pacman-key: line 209: /dev/fd/63: No such file or directory

\==> Locally signing trusted keys in keyring...

  -> Locally signed 5 keys.

\==> Importing owner trust values...

\==> Disabling revoked keys in keyring...

  -> Disabled 38 keys.

\==> Updating trust database...

gpg: next trustdb check due at 2026-10-21

\[root@manjaro 2026-04-01 21:09:54 miércoles /\]$

 > exit

exit

\[manjaro n\]# sudo pacman --root /n -Sy archlinux-keyring

:: Synchronizing package databases...

 core is up to date

 extra is up to date

 multilib is up to date

error: duplicated database entry 'assimp'

error: duplicated database entry 'bcachefs-tools'

error: duplicated database entry 'chromium'

error: duplicated database entry 'discord-canary'

error: duplicated database entry 'dpkg'

error: duplicated database entry 'file'

error: duplicated database entry 'gdb'

error: duplicated database entry 'gdb-common'

error: duplicated database entry 'haskell-asn1-encoding'

error: duplicated database entry 'haskell-asn1-parse'

error: duplicated database entry 'haskell-asn1-types'

error: duplicated database entry 'haskell-crypton'

error: duplicated database entry 'haskell-crypton-x509'

error: duplicated database entry 'haskell-crypton-x509-store'

error: duplicated database entry 'haskell-crypton-x509-system'

error: duplicated database entry 'haskell-crypton-x509-validation'

error: duplicated database entry 'haskell-cryptonite'

error: duplicated database entry 'haskell-data-default'

error: duplicated database entry 'haskell-data-default-instances-dlist'

error: duplicated database entry 'haskell-dlist'

error: duplicated database entry 'haskell-hourglass'

error: duplicated database entry 'haskell-hsopenssl'

error: duplicated database entry 'haskell-hsopenssl-x509-system'

error: duplicated database entry 'haskell-iproute'

error: duplicated database entry 'haskell-memory'

error: duplicated database entry 'haskell-network'

error: duplicated database entry 'haskell-pem'

error: duplicated database entry 'haskell-x509'

error: duplicated database entry 'libcbor'

error: duplicated database entry 'libfido2'

error: duplicated database entry 'libngtcp2'

error: duplicated database entry 'libvpx'

error: duplicated database entry 'luajit'

error: duplicated database entry 'nodejs'

error: duplicated database entry 'openvpn'

error: duplicated database entry 'perl-clone'

error: duplicated database entry 'perl-libwww'

error: duplicated database entry 'python-pygments'

error: duplicated database entry 'python-requests'

error: duplicated database entry 'rubberband'

error: duplicated database entry 'ruby-repl\_type\_completor'

error: duplicated database entry 'simdjson'

error: duplicated database entry 'systemd'

error: duplicated database entry 'systemd-libs'

error: duplicated database entry 'vim'

error: duplicated database entry 'vim-runtime'

error: duplicated database entry 'vpnc'

error: duplicated database entry 'xz'

warning: archlinux-keyring-20260323-1 is up to date -- reinstalling

resolving dependencies...

looking for conflicting packages...

  

Packages (1) archlinux-keyring-20260323-1

  

Total Download Size:   1,20 MiB

Total Installed Size:  1,71 MiB

Net Upgrade Size:      0,00 MiB

  

:: Proceed with installation? \[Y/n\] 

:: Retrieving packages...

 archlinux-keyring-20260323-1-any

^C

Interrupt signal received

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Lo que estás viendo es un síntoma de una base de datos de paquetes **corrupta** o **duplicada**. Esto sucede generalmente cuando una actualización se interrumpe bruscamente (como el cuelgue que mencionaste) y el sistema queda con dos versiones registradas del mismo paquete en `/var/lib/pacman/local/`.

El hecho de que `pacman-key` dé errores de `/dev/fd/63` sugiere que estás trabajando en un entorno **chroot** o con `--root` donde algunos sistemas de archivos virtuales (como `/dev`, `/proc` o `/sys`) no están correctamente montados.

Aquí tienes los pasos para limpiar este desastre:

* * *

### 1\. Limpiar las entradas duplicadas

Pacman está confundido porque hay dos carpetas para cada uno de esos paquetes en la base de datos local.

1.  Ve a la ruta de la base de datos de tu sistema objetivo (el que está en `/n`):
    
    Bash
    
        ls /n/var/lib/pacman/local/ | grep -E "systemd|vim|xz"
    
2.  Verás que para `xz`, por ejemplo, hay dos carpetas (ej. `xz-5.4.1-1` y `xz-5.6.0-1`).
    
3.  **Debes borrar la carpeta de la versión más antigua** para cada paquete que aparezca en tu lista de errores.
    
    *   _Ejemplo:_ `rm -rf /n/var/lib/pacman/local/xz-VERSION-ANTIGUA`.
        
    *   **Cuidado:** No borres ambas, solo la versión vieja.
        

### 2\. Corregir el entorno (si estás en Live USB)

El error `/dev/fd/63: No such file or directory` ocurre porque `pacman-key` necesita descriptores de archivos que no existen en el entorno limitado. Si estás reparando el sistema desde afuera, lo ideal es usar `manjaro-chroot`:

Bash

    # Montar correctamente si no lo has hecho
    manjaro-chroot /n /bin/bash

Esto montará automáticamente `/dev`, `/proc` y `/sys` por ti, permitiendo que `pacman-key` funcione sin errores.

### 3\. Forzar la actualización de la base de datos y llaves

Una vez dentro del chroot (o con los duplicados borrados):

1.  **Refresca las llaves:**
    
    Bash
    
        pacman-key --init
        pacman-key --populate archlinux manjaro
    
2.  **Actualiza el keyring primero:**
    
    Bash
    
        pacman -Sy archlinux-keyring manjaro-keyring
    
3.  **Sincroniza todo el sistema:**
    
    Bash
    
        pacman -Syu
    

* * *

### ¿Por qué se colgó al 100%?

Lo más probable es que durante la instalación de `xorg-xset`, el sistema intentó ejecutar un script de post-instalación que invocó a uno de los paquetes duplicados (como `systemd`). Al encontrar la base de datos corrupta, el proceso entró en un bucle infinito o se bloqueó esperando una respuesta del sistema de archivos.

**Prioridad inmediata:** Borra las carpetas duplicadas en `/n/var/lib/pacman/local/`. Sin eso, `pacman` seguirá fallando en cada operación.

---

You asked:
----------

Has dicho

¿Cómo desactivo los hooks de pacman?

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Para desactivar los hooks de `pacman`, tienes dos caminos dependiendo de si quieres algo temporal o una desactivación permanente.

### 1\. Desactivación Temporal (Recomendado para reparaciones)

Si estás intentando instalar algo y un hook está causando que el sistema se cuelgue (como te pasó antes), puedes saltarte la ejecución de scripts con el flag `--noshit`.

Sin embargo, `pacman` no tiene un flag directo para "desactivar todos los hooks", pero puedes usar:

Bash

    sudo pacman -S paquete --noscripts

**Nota importante:** Esto evita que se ejecuten los scripts de instalación del paquete (`.install`), pero **no siempre** detiene los hooks globales que viven en `/usr/share/libalpm/hooks/`.

* * *

### 2\. Desactivación Permanente o Selectiva

Los hooks en Arch/Manjaro se guardan en dos directorios:

1.  **Hooks del sistema:** `/usr/share/libalpm/hooks/` (No deberías editarlos aquí).
    
2.  **Hooks del administrador:** `/etc/pacman.d/hooks/` (Aquí es donde tú creas los tuyos).
    

#### Para "anular" un hook del sistema:

La forma correcta de desactivar un hook de `/usr/share/` es crear un enlace simbólico a `/dev/null` en la carpeta de configuración del administrador con el **mismo nombre** del archivo.

**Ejemplo: Desactivar el hook que actualiza la base de datos de fuentes:**

Bash

    sudo ln -s /dev/null /etc/pacman.d/hooks/fontconfig.hook

Al hacer esto, `pacman` verá el archivo en `/etc/` y, al estar vinculado a la "nada" (`/dev/null`), ignorará el hook original.

* * *

### 3\. Modificar la configuración de Pacman

Si lo que quieres es evitar que `pacman` haga cosas específicas durante la transacción, puedes revisar el archivo `/etc/pacman.conf`.

Busca la sección `[options]`. Aunque no hay un interruptor global de "No Hooks", puedes usar la opción `NoExtract` para evitar que ciertos archivos de hooks se instalen siquiera, aunque **no es recomendable** porque rompe la integridad del sistema a largo plazo.

* * *

### ¡Cuidado!

Desactivar hooks como los de `systemd`, `mkinitcpio` o `grub` puede dejar tu sistema **incapaz de arrancar**, ya que son los encargados de regenerar la imagen del kernel y actualizar el cargador de arranque tras una actualización.

> **Mi consejo:** En tu caso específico (donde tienes entradas duplicadas y errores de `/dev/fd/63`), el problema **no son los hooks**, sino que el entorno no tiene montado `/dev`. Antes de desactivar nada, asegúrate de estar operando dentro de un `manjaro-chroot`.

¿Hay algún hook específico que sospechas que está bloqueando tu instalación?

---

You asked:
----------

Has dicho

¿Qué tengo que hacer?

  

\[root@manjaro 2026-04-01 21:30:55 miércoles /usr/share/libalpm/hooks\]$

 > pacman -Syu --overwrite="\*" kmod

:: Synchronizing package databases...

 core is up to date

 extra is up to date

 multilib is up to date

 alerque is up to date

 andontie-aur is up to date

 archlinuxcn is up to date

 chaotic-aur is up to date

:: Starting full system upgrade...

resolving dependencies...

looking for conflicting packages...

  

Packages (4) lz4-1:1.10.0-2  xz-5.8.2-1  zstd-1.5.7-3  kmod-34.2-1

  

Total Download Size:   1,60 MiB

Total Installed Size:  5,26 MiB

  

:: Proceed with installation? \[Y/n\] 

:: Retrieving packages...

 xz-5.8.2-1-x86\_64.pkg.tar.zst failed to download

 kmod-34.2-1-x86\_64                                        130,3 KiB  97,5 KiB/s 00:01 \[##################################################\] 100%

 lz4-1:1.10.0-2-x86\_64                                     156,3 KiB   100 KiB/s 00:02 \[##################################################\] 100%

 zstd-1.5.7-3-x86\_64                                       515,0 KiB   246 KiB/s 00:02 \[##################################################\] 100%

 Total (4/4)                                              1641,1 KiB   784 KiB/s 00:02 \[##################################################\] 100%

error: failed retrieving file 'xz-5.8.2-1-x86\_64.pkg.tar.zst' from ftp5.gwdg.de : The requested URL returned error: 404

warning: failed to retrieve some files

error: failed to commit transaction (failed to retrieve some files)

Errors occurred, no packages were upgraded.

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

El error **404** y el hecho de que `xz` falle mientras los otros bajan indica que tu base de datos de paquetes local está ligeramente desincronizada con los espejos (mirrors) o que ese mirror específico está roto.

Como estás operando con `--root /n` (o dentro de un entorno de recuperación), aquí tienes los pasos exactos para forzar la reparación:

### 1\. Actualizar la lista de Mirrors

Es muy probable que el servidor `ftp5.gwdg.de` no tenga el paquete `xz-5.8.2-1` todavía o ya lo haya movido. Necesitas obligar a pacman a descargar una base de datos fresca y usar mirrors actualizados.

Si estás en Manjaro, usa esto para refrescar los mirrors antes de intentar la instalación:

Bash

    sudo pacman-mirrors -f 5

### 2\. Forzar descarga y actualización de base de datos

Para solucionar el error 404, usa el flag `-Syyu` (la doble `y` fuerza la descarga de la base de datos aunque parezca actualizada):

Bash

    pacman --root /n -Syyu kmod lz4 xz zstd --overwrite="*"

* * *

### 3\. ¿Sigues teniendo el problema de los "Duplicated Entries"?

Si no borraste las carpetas duplicadas que mencionaste antes, la instalación de `xz` y `kmod` podría fallar o volver a colgarse al 100%. **Este es el paso crítico que no debes saltarte:**

Ejecuta esto para ver qué carpetas de `xz` tienes:

Bash

    ls /n/var/lib/pacman/local/ | grep xz

Si ves dos versiones (por ejemplo `xz-5.6.0-1` y `xz-5.8.2-1`), **borra la carpeta de la versión vieja** manualmente:

Bash

    rm -rf /n/var/lib/pacman/local/xz-VERSION-VIEJA

_(Repite esto con cada paquete de la lista de errores que pusiste arriba: `systemd`, `vim`, `libcbor`, etc.)_

* * *

### 4\. El problema de los Hooks (Si se vuelve a colgar)

Si después de descargar los paquetes se vuelve a quedar en `100% :: Processing package changes...`, el culpable es casi seguro el entorno.

**Asegúrate de que los sistemas de archivos virtuales estén montados:** Si no estás usando `manjaro-chroot`, pacman se colgará porque no puede acceder a `/dev`. Ejecuta esto antes de reintentar:

Bash

    mount --bind /dev /n/dev
    mount --bind /proc /n/proc
    mount --bind /sys /n/sys
    mount --bind /run /n/run

### Resumen de comandos a ejecutar ahora:

1.  **Limpiar base de datos:** `rm /n/var/lib/pacman/db.lck` (por si acaso).
    
2.  **Actualizar mirrors:** `pacman-mirrors -f 5`.
    
3.  **Instalar:** `pacman --root /n -Syyu xz kmod --overwrite="*"`.
    

**¿Te volvió a salir el error de "duplicated database entry" al ejecutar el comando?** Si es así, no ignores esos errores, son la raíz del cuelgue.

---

