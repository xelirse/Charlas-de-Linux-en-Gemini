You asked:
----------

Has dicho

Hice esto y dejó de funcionar el sistema.

  

killall at-spi-bus-launcher dbus-launch dbus-daemon 2>/dev/null

  

Cuando prendo tarda en cargar el systemd y voy al tty y dice usuario inválido y ni siquiera pide contraseña, nada, solo pongo cualquier usuario y dice inválido.

---

Gemini Replied:
---------------

Ver razonamiento

**Diagnosing System Failure**

I've observed a critical system failure following the execution of the `killall` command targeting several D-Bus processes. The boot sequence is now significantly prolonged, and a TTY login attempt results in an immediate "Invalid User" error, bypassing the password prompt entirely. This suggests a deeply rooted problem within the authentication or D-Bus infrastructure.

**Analyzing Root Cause**

I'm now focusing on potential causes for this persistent failure. I'm exploring how the `killall` command, even after a reboot, could lead to this state. I'm suspecting a startup script issue, a filesystem corruption caused by the abrupt kill command, or a state mismatch due to a custom "Frankeinux" setup. The user profile is a factor to consider.

**Investigating Authentication Failure**

I'm now zeroing in on the "Invalid User" error. It strongly suggests a breakdown in PAM or `systemd-logind`, likely due to the D-Bus interruption. I'm focusing on why killing those processes is inherently risky, as it appears to have deeply destabilized the authentication process. I'll need to explore recovery steps like using a Live ISO or chroot, which I'm familiar with, to analyze `journalctl` and service statuses to confirm. I am remembering to factor in the user's Debian Sid/Manjaro jaro mix.

**Refining The Diagnosis**

I'm now integrating information about the slow boot process into the analysis, and it's looking increasingly like a D-Bus timeout is the culprit. The "Invalid User" error on TTY login now appears to be a consequence of `login` not being able to reach `logind` or a PAM timeout related to a broken D-Bus connection. I'm focusing on the consequences of killing a D-Bus daemon. I'll recommend booting into rescue mode and checking specific files and logs.

Gemini ha dicho
---------------

Lo que sucedió es que al matar el `dbus-daemon` de forma abrupta, cortaste la comunicación del "sistema nervioso" de Linux. **D-Bus** es el encargado de que los procesos se hablen entre sí, y componentes críticos como `systemd-logind` (que maneja los inicios de sesión) y `PAM` (los módulos de autenticación) dependen totalmente de él para validar quién eres.

El retraso en la carga de **systemd** y el error de "usuario inválido" ocurren porque el proceso de login intenta consultar al bus del sistema, no recibe respuesta (timeout) y asume que el usuario no existe o que el subsistema de seguridad está roto.

Aquí tienes los pasos para intentar recuperar el acceso:

### 1\. Acceder mediante `init=/bin/bash`

Como no puedes loguearte ni siquiera en TTY, debes saltarte el proceso de login habitual desde el GRUB:

1.  Reinicia la PC.
    
2.  En el menú de **GRUB**, presiona la tecla `e` sobre la entrada de tu sistema.
    
3.  Busca la línea que empieza con `linux /boot/vmlinuz...` y, al final de esa línea, agrega un espacio y: `init=/bin/bash`
    
4.  Presiona `Ctrl + X` o `F10` para arrancar. Esto te soltará directamente en una terminal con privilegios de root sin pedir contraseña.
    

### 2\. Reparar el entorno desde la Shell de emergencia

Una vez dentro, el sistema de archivos estará en modo "solo lectura". Debes montarlo para poder hacer cambios y revisar los servicios:

Bash

    # Montar la partición raíz como lectura/escritura
    mount -o remount,rw /
    
    # Verificar si hay procesos de dbus muertos o archivos de socket bloqueados
    rm -f /run/dbus/system_bus_socket
    rm -f /var/run/dbus/system_bus_socket
    
    # Intentar iniciar el daemon manualmente para ver si arroja error
    dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation

### 3\. Verificar scripts de inicio

Si el problema persiste después de reiniciar, es muy probable que ese comando `killall` haya quedado guardado en algún script que se ejecuta al arrancar. Revisa los sospechosos habituales:

*   **Tu .bashrc o .profile:** Si lo pusiste ahí, cada vez que el sistema intenta abrir una terminal para loguearte, mata el bus y se rompe.
    
    *   `nano /home/tu_usuario/.bashrc`
        
    *   `nano /root/.bashrc`
        
*   **Scripts de X11/LXDE:** Mira en `/etc/X11/xinit/xinitrc` o en `~/.xinitrc`.
    
*   **Servicios de Systemd:** Revisa si creaste algún archivo en `/etc/systemd/system/` que esté ejecutando ese comando.
    

### 4\. ¿Por qué el login dice "Inválido"?

En entornos modernos (como tu Debian Sid o Manjaro), el comando `login` usa un módulo llamado `pam_systemd`. Si este módulo no puede contactar a `systemd-logind` a través de D-Bus para registrar tu sesión, la autenticación falla por defecto por razones de seguridad. No es que tu usuario haya desaparecido, es que la "puerta" (PAM) no puede verificar la "llave" con el "guardia" (D-Bus).

**Para salir del modo emergencia:** Una vez que limpies los sockets o deshabilites cualquier script problemático, ejecuta:

Bash

    sync
    umount /
    reboot -f

Si el sistema sigue tardando mucho en cargar, presiona `Esc` durante el booteo para ver qué servicio de systemd está en **"A start job is running for..."**. Probablemente sea un servicio esperando por el bus que mataste.

¿Recuerdas haber puesto ese comando en algún archivo de configuración o script de automatización antes de que fallara?

---

You asked:
----------

Has dicho

 > sudo su -

sudo: PAM account management error: Permiso denegado

sudo: a password is required

---

Gemini Replied:
---------------

Ver razonamiento

**Diagnosing System Crash**

I'm zeroing in on the system failure. The `killall` command appears to have taken down crucial components: `at-spi-bus-launcher`, `dbus-launch`, and `dbus-daemon`. Now, TTY login is broken, reporting "invalid user" and skipping the password prompt. Attempting `sudo su -` results in no change. The system's in a critical state; I need to figure out how to recover from this.

**Analyzing Authentication Failure**

I've determined the core problem is PAM's inability to communicate with D-Bus. This blocks `sudo` and normal logins. Specifically, D-Bus's failure prevents PAM from authenticating the user; the "permission denied" error confirms this. This locks the system.

**Clarifying PAM Issues**

I'm now focusing on the PAM account management error. It stems from `pam_systemd.so` failing to locate the system bus, effectively blocking account state checks. I'll need to explain this clearly. The best approach may still be the `init=/bin/bash` method; it bypasses PAM completely. I'll need to provide clear steps. Also, I'll need to offer an alternative boot option.

Gemini ha dicho
---------------

Ese error de **PAM (Pluggable Authentication Modules)** es el síntoma definitivo de que el sistema de autenticación está "ciego". Cuando ejecutas `sudo`, el módulo `pam_systemd.so` intenta registrar la sesión y verificar el estado de tu cuenta consultando a `systemd-logind` a través de D-Bus. Como mataste el bus, la consulta falla y PAM bloquea el acceso por seguridad.

En este estado, **no vas a poder ganar privilegios de root desde la sesión actual**, porque todas las puertas de entrada (sudo, su, login, ssh) pasan por PAM.

Tienes que forzar la entrada saltándote el sistema de gestión de usuarios por completo. Aquí está la hoja de ruta técnica:

### 1\. El bypass de GRUB (init=/bin/bash)

Este es el método más rápido si tienes acceso físico al teclado.

1.  **Reinicia a la fuerza** (botón de reset o manteniendo encendido).
    
2.  En el menú de **GRUB**, pulsa `e` para editar la entrada de arranque.
    
3.  Busca la línea que empieza con `linux` y ve al final.
    
4.  Borra parámetros como `quiet` o `splash` si aparecen, y agrega: `rw init=/bin/bash`
    
    *   _Nota: Al poner `rw` desde aquí, montamos la raíz con permisos de escritura desde el segundo cero._
        
5.  Pulsa `Ctrl+X` para arrancar.
    

Llegarás a un prompt que dice algo como `root@(none):/#`. **Aquí eres root real sin haber pasado por PAM ni D-Bus.**

### 2\. Limpieza de emergencia

Una vez en esa shell:

*   **Limpia los sockets muertos:** D-Bus deja archivos "basura" en `/run` que pueden impedir que el servicio levante bien en el próximo arranque normal.
    
    Bash
    
        rm /run/dbus/system_bus_socket
        rm /run/dbus/pid
    
*   **Revisa scripts de inicio:** Si ese `killall` lo ejecutaste en un script que automatizaste (un `.sh` de mantenimiento o en tu `.bashrc`), **tienes que comentarlo ahora**, o volverás a quedar bloqueado al reiniciar.
    
    Bash
    
        # Ejemplo si está en tu bashrc
        nano /home/tu_usuario/.bashrc 
    

### 3\. El método alternativo: Live USB + Chroot

Si por alguna razón el `init=/bin/bash` falla (a veces pasa en sistemas con configuraciones de kernel muy específicas), usa cualquier Live USB que tengas a mano (Debian, Manjaro, etc.):

1.  Arranca desde el USB.
    
2.  Monta tu partición raíz del disco: `mount /dev/sdXY /mnt`
    
3.  Entra mediante chroot: `chroot /mnt`
    
4.  Desde ahí puedes revisar los logs (`journalctl -D /var/log/journal`) para ver exactamente qué servicio se quedó colgado esperando al bus, o simplemente corregir los archivos de configuración.
    

**¿Por qué te pide contraseña después del error de PAM?** Es un comportamiento de seguridad de `sudo`. Cuando el "Account Management" (la verificación de si la cuenta es válida) falla antes de llegar a la etapa de "Authentication", `sudo` a veces lanza un mensaje genérico de contraseña o simplemente deniega todo. Pero no importa qué pongas, no te va a dejar pasar porque el puente hacia la base de datos de usuarios está roto.

**Recomendación:** No intentes arreglarlo desde la sesión actual; cada comando que lances puede empeorar el estado de la memoria ram del sistema. Ve directo al bypass de GRUB.

¿Ese comando `killall` lo habías metido en algún script de optimización o fue una ejecución manual por única vez?

---

You asked:
----------

Has dicho

Quiero repararlo, estoy desde el chroot del pendrive.

---

Gemini Replied:
---------------

Ver razonamiento

**Fixing the System**

I'm working on restoring the system after accidentally killing D-Bus processes. I'm now chrooting from a Live USB to try and fix the problem. The goal is to regain access and restore normal user logins, since PAM is currently locked out.

**Investigating the Root Cause**

I'm now diving deeper into why D-Bus went down. If it was my fault, a clean reboot should be enough after clearing out stale sockets. If it was a script, I need to hunt it down and disable it. My focus is on checking system consistency and reinstalling core packages as a precaution. I've started mounting virtual filesystems for chroot, then cleaning stale D-Bus files to prevent issues. Next, I'm tracking down the command, likely from Eze's custom scripts. Finally, I'll be checking systemd-logind and D-Bus service status to ensure everything is running smoothly. I need to make sure those libraries haven't gone missing, given that Eze likes to get into the details with Manjaro/Debian Sid.

Gemini ha dicho
---------------

Buenísimo que ya estés en el **chroot**. Desde ahí tenés control total para ver qué "rompió" el arranque y limpiar los restos del `killall`.

Seguí estos pasos para dejar el sistema operativo de nuevo:

### 1\. Asegurarte de que el Chroot sea funcional

Para que comandos como `systemctl` o la comunicación con el bus funcionen dentro del chroot, necesitás tener montados los sistemas de archivos virtuales. Si no lo hiciste antes de entrar, salí un segundo (`exit`) y hacé esto desde el entorno del Live USB:

Bash

    for i in /dev /dev/pts /proc /sys /run; do mount -B $i /mnt$i; done
    chroot /mnt

_(Asumiendo que `/mnt` es donde montaste tu partición raíz)._

### 2\. Limpiar sockets y archivos de bloqueo

El `killall` abrupto suele dejar archivos "huérfanos" en `/run` que confunden a **systemd** al intentar reiniciar el servicio en un arranque normal. Borralos sin miedo:

Bash

    rm -f /run/dbus/system_bus_socket
    rm -f /run/dbus/pid
    rm -f /var/lib/dbus/machine-id
    # Generar un nuevo machine-id por si las dudas
    dbus-uuidgen --ensure

### 3\. El "Detective": ¿De dónde salió ese comando?

Si ese `killall` se está ejecutando solo al bootear, tenés que encontrar el script. Como usás **Geany** y hacés tus propios scripts de automatización, busquemos el texto exacto en los lugares clave:

Bash

    # Buscar en tu home (especialmente en archivos ocultos)
    grep -r "killall dbus-daemon" /home/eze/
    
    # Buscar en los directorios de inicio del sistema
    grep -r "killall dbus-daemon" /etc/init.d/
    grep -r "killall dbus-daemon" /etc/systemd/system/

**Si lo encontrás en un `.bashrc` o en un script de `init`, comentá la línea con un `#`.**

### 4\. Reinstalar D-Bus (Para resetear permisos y configs)

Como estás en un entorno mixto (Debian Sid / Manjaro), a veces el `killall` puede corromper el estado de los paquetes si ocurrió durante una actualización. Reinstalar asegura que los binarios y disparadores de **PAM** estén en su lugar.

*   **Si estás reparando la parte de Debian Sid:**
    
    Bash
    
        apt update
        apt install --reinstall dbus dbus-x11 libpam-systemd
    
*   **Si estás reparando la parte de Manjaro:**
    
    Bash
    
        pacman -Sy dbus libutil-linux
    

### 5\. Verificar el estado de los servicios

Asegurate de que el servicio esté habilitado para el próximo arranque:

Bash

    systemctl enable dbus
    systemctl enable systemd-logind

### 6\. Salida limpia

Para evitar errores de "sistema de archivos ocupado" al reiniciar:

1.  Salí del chroot: `exit`
    
2.  Desmontá todo: `umount -R /mnt`
    
3.  Reiniciá: `reboot`
    

**Un detalle importante:** Si estabas intentando matar el bus de accesibilidad (`at-spi-bus-launcher`) porque te molestaba en los logs, la forma correcta no es un `killall`, sino deshabilitarlo desde la configuración de las aplicaciones de inicio de **LXDE** o renombrando el binario en `/usr/libexec/` (aunque esto es un poco más "sucio").

¿Llegaste a encontrar el comando dentro de algún script de los que estuviste laburando últimamente?

---

You asked:
----------

Has dicho

Quiero reparar esto.

  

 > su -

su: Permiso denegado

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Ese error de `su: Permiso denegado` (incluso sin pedir contraseña) es el mismo síntoma: el binario `su` intenta abrir una sesión de PAM, pero al no haber un bus de sistema activo o estar el entorno de **chroot** "desconectado" de los sockets reales, la autenticación falla por seguridad.

Como ya estás dentro del **chroot**, no necesitas usar `su` ni `sudo`. **Ya eres root**. En el prompt del chroot deberías ver un `#` (en lugar de `$`).

Para reparar la autenticación y que el sistema vuelva a bootear normal, hacé lo siguiente en este orden exacto:

### 1\. Reconfigurar los paquetes de autenticación

A veces, al matar el proceso, se corrompen los estados de los "triggers" de PAM. Vamos a forzar a que el sistema vuelva a registrar los módulos de seguridad.

*   **Si el sistema base es Debian:**
    
    Bash
    
        pam-auth-update --force
    
    _(Asegurate de que "Unix authentication" y "systemd sessions" estén marcados con espacio y dale a OK)._
    
*   **Si el sistema base es Arch/Manjaro:**
    
    Bash
    
        # Reinstalar los archivos base de configuración de PAM
        pacman -S pambase --noconfirm
    

### 2\. Verificar los permisos de los binarios críticos

El comando `killall` no debería cambiar permisos, pero si estabas tocando archivos antes de que se rompa, verificá que `su` y `sudo` tengan el bit **SUID** (el que permite que corran como root).

Bash

    ls -l /bin/su /usr/bin/sudo

Deberían verse así (fijate en la **`s`**): `-rwsr-xr-x 1 root root ... /bin/su`

Si no tienen la `s`, arreglalo con:

Bash

    chmod u+s /bin/su /usr/bin/sudo

### 3\. Resetear el estado de D-Bus y Machine-ID

El sistema de archivos de Debian Sid y Manjaro necesita un `machine-id` válido para que `systemd-logind` arranque. Si el archivo quedó vacío o corrupto por el apagado forzado, PAM va a fallar siempre.

Bash

    # Borrar y regenerar el ID único de la máquina
    rm -f /etc/machine-id /var/lib/dbus/machine-id
    dbus-uuidgen --ensure=/etc/machine-id
    dbus-uuidgen --ensure

### 4\. Revisar bloqueos de usuario

Por las dudas, verificá que tu usuario no haya quedado bloqueado por intentos fallidos (aunque es poco probable, mejor descartar):

Bash

    faillock --user eze --reset

_(Si el comando no existe, no te preocupes, depende de la versión de PAM)._

### 5\. ¿Por qué te sigue fallando dentro del chroot?

Si intentas tirar un `su -` **dentro** del chroot y te da "Permiso denegado", es porque el chroot no tiene el bus de sesión iniciado. **No lo intentes más**, porque no va a funcionar hasta que bootees el sistema real.

**La prueba de fuego:** Salí del chroot, desmontá y reiniciá. Si el sistema llega al TTY y te deja escribir el nombre de usuario, el problema del bus se solucionó.

Bash

    exit
    umount -l /mnt/dev{/pts,} /mnt/proc /mnt/sys /mnt/run
    umount /mnt
    reboot

Si después de reiniciar sigue diciendo "Usuario inválido", avisame y miramos específicamente el contenido de `/etc/pam.d/common-auth`, porque ese `killall` podría haber interrumpido una escritura en ese archivo si justo se estaba actualizando algo.

---

You asked:
----------

Has dicho

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

ioctl(1, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(1, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/1", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffedf855150, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

ioctl(2, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(2, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/2", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffedf855150, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

sendto(3, \[{nlmsg\_len=132, nlmsg\_type=0x44c /\* NLMSG\_??? \*/, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=1, nlmsg\_pid=0}, "\\x6f\\x70\\x3d\\x50\\x41\\x4d\\x3a\\x61\\x75\\x74\\x68\\x65\\x6e\\x74\\x69\\x63\\x61\\x74\\x69\\x6f\\x6e\\x20\\x67\\x72\\x61\\x6e\\x74\\x6f\\x72\\x73\\x3d\\x70"...\], 132, 0, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, 12) = 132

poll(\[{fd=3, events=POLLIN}\], 1, 500)   = 1 (\[{fd=3, revents=POLLIN}\])

recvfrom(3, \[{nlmsg\_len=36, nlmsg\_type=NLMSG\_ERROR, nlmsg\_flags=NLM\_F\_CAPPED, nlmsg\_seq=1, nlmsg\_pid=7436}, {error=0, msg={nlmsg\_len=132, nlmsg\_type=AUDIT\_FIRST\_USER\_MSG, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=1, nlmsg\_pid=0}}\], 8988, MSG\_PEEK|MSG\_DONTWAIT, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, \[12\]) = 36

recvfrom(3, \[{nlmsg\_len=36, nlmsg\_type=NLMSG\_ERROR, nlmsg\_flags=NLM\_F\_CAPPED, nlmsg\_seq=1, nlmsg\_pid=7436}, {error=0, msg={nlmsg\_len=132, nlmsg\_type=AUDIT\_FIRST\_USER\_MSG, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=1, nlmsg\_pid=0}}\], 8988, MSG\_DONTWAIT, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, \[12\]) = 36

close(3)                                = 0

rt\_sigprocmask(SIG\_BLOCK, ~\[\], \[\], 8)   = 0

mmap(NULL, 4096, PROT\_READ|PROT\_WRITE, MAP\_DROPPABLE|MAP\_ANONYMOUS, -1, 0) = 0x7fbe0c226000

mmap(NULL, 4096, PROT\_READ|PROT\_WRITE, MAP\_PRIVATE|MAP\_ANONYMOUS, -1, 0) = 0x7fbe0c225000

rt\_sigprocmask(SIG\_SETMASK, \[\], NULL, 8) = 0

getrandom("\\x08\\x9e\\x58\\x96\\x1b\\x9d\\x9d\\x33\\xc4\\x6f\\xb4\\xfc\\xd2\\x5a\\x33\\x3e\\x23\\x5a\\x2e\\xed\\xf8\\x74\\x15\\x14\\xa8\\x40\\x52\\x3d\\x31\\x24\\x40\\xdb", 32, 0) = 32

socket(AF\_NETLINK, SOCK\_RAW|SOCK\_CLOEXEC, NETLINK\_AUDIT) = 3

ioctl(0, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(0, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/0", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffedf855180, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

ioctl(1, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(1, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/1", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffedf855180, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

ioctl(2, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(2, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/2", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffedf855180, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x558d0b65d3c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x558d0b65d3c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

sendto(3, \[{nlmsg\_len=116, nlmsg\_type=0x44d /\* NLMSG\_??? \*/, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=2, nlmsg\_pid=0}, "\\x6f\\x70\\x3d\\x50\\x41\\x4d\\x3a\\x61\\x63\\x63\\x6f\\x75\\x6e\\x74\\x69\\x6e\\x67\\x20\\x67\\x72\\x61\\x6e\\x74\\x6f\\x72\\x73\\x3d\\x3f\\x20\\x61\\x63\\x63"...\], 116, 0, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, 12) = 116

poll(\[{fd=3, events=POLLIN}\], 1, 500)   = 1 (\[{fd=3, revents=POLLIN}\])

recvfrom(3, \[{nlmsg\_len=36, nlmsg\_type=NLMSG\_ERROR, nlmsg\_flags=NLM\_F\_CAPPED, nlmsg\_seq=2, nlmsg\_pid=7436}, {error=0, msg={nlmsg\_len=116, nlmsg\_type=0x44d /\* AUDIT\_??? \*/, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=2, nlmsg\_pid=0}}\], 8988, MSG\_PEEK|MSG\_DONTWAIT, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, \[12\]) = 36

recvfrom(3, \[{nlmsg\_len=36, nlmsg\_type=NLMSG\_ERROR, nlmsg\_flags=NLM\_F\_CAPPED, nlmsg\_seq=2, nlmsg\_pid=7436}, {error=0, msg={nlmsg\_len=116, nlmsg\_type=0x44d /\* AUDIT\_??? \*/, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=2, nlmsg\_pid=0}}\], 8988, MSG\_DONTWAIT, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, \[12\]) = 36

close(3)                                = 0

getpid()                                = 7436

socket(AF\_UNIX, SOCK\_DGRAM|SOCK\_CLOEXEC, 0) = 3

connect(3, {sa\_family=AF\_UNIX, sun\_path="/dev/log"}, 110) = -1 ENOENT (No existe el fichero o el directorio)

close(3)                                = 0

getpid()                                = 7436

openat(AT\_FDCWD, "/var/log/btmp", O\_WRONLY|O\_CLOEXEC) = 3

alarm(0)                                = 0

rt\_sigaction(SIGALRM, {sa\_handler=0x7fbe0c16b330, sa\_mask=\[\], sa\_flags=SA\_RESTORER, sa\_restorer=0x7fbe0c0422d0}, {sa\_handler=SIG\_DFL, sa\_mask=\[\], sa\_flags=0}, 8) = 0

alarm(10)                               = 0

fcntl(3, F\_SETLKW, {l\_type=F\_WRLCK, l\_whence=SEEK\_SET, l\_start=0, l\_len=0}) = 0

alarm(0)                                = 10

rt\_sigaction(SIGALRM, {sa\_handler=SIG\_DFL, sa\_mask=\[\], sa\_flags=SA\_RESTORER, sa\_restorer=0x7fbe0c0422d0}, NULL, 8) = 0

lseek(3, 0, SEEK\_END)                   = 4992

write(3, "\\6\\0\\0\\0\\f\\35\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0"..., 384) = 384

fcntl(3, F\_SETLKW, {l\_type=F\_UNLCK, l\_whence=SEEK\_SET, l\_start=0, l\_len=0}) = 0

close(3)                                = 0

openat(AT\_FDCWD, "/usr/share/locale/es\_AR.UTF-8/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es\_AR.utf8/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es\_AR/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es.UTF-8/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es.utf8/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = 3

fstat(3, {st\_mode=S\_IFREG|0644, st\_size=8677, ...}) = 0

mmap(NULL, 8677, PROT\_READ, MAP\_PRIVATE, 3, 0) = 0x7fbe0c222000

close(3)                                = 0

munmap(0x7fbe0c28d000, 16400)           = 0

munmap(0x7fbe0c288000, 16400)           = 0

munmap(0x7fbe0c283000, 16400)           = 0

munmap(0x7fbe0c27e000, 16400)           = 0

openat(AT\_FDCWD, "/etc/login.defs", O\_RDONLY) = 3

fstat(3, {st\_mode=S\_IFREG|0644, st\_size=4687, ...}) = 0

read(3, "#\\n# /etc/login.defs - Configurat"..., 4096) = 4096

read(3, "#\\n# The pwck(8) utility emits a "..., 4096) = 591

read(3, "", 4096)                       = 0

close(3)                                = 0

openat(AT\_FDCWD, "/etc/default/su", O\_RDONLY) = 3

fstat(3, {st\_mode=S\_IFREG|0755, st\_size=0, ...}) = 0

read(3, "", 4096)                       = 0

close(3)                                = 0

clock\_nanosleep(CLOCK\_REALTIME, 0, {tv\_sec=1, tv\_nsec=0}, 0x7ffedf8577d0) = 0

write(2, "su: ", 4su: )                     = 4

write(2, "Permiso denegado", 16Permiso denegado)        = 16

write(2, "\\n", 1

)                       = 1

dup(1)                                  = 3

close(3)                                = 0

dup(2)                                  = 3

close(3)                                = 0

exit\_group(1)                           = ?

+++ exited with 1 +++

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Este `strace` confirma exactamente lo que sospechábamos: el sistema está intentando validar tu cuenta, pero se encuentra con un muro.

Hay un par de líneas clave en tu log que revelan el desastre:

1.  **`connect(3, {sa_family=AF_UNIX, sun_path="/dev/log"}, 110) = -1 ENOENT`**: `su` intenta avisar al sistema (vía syslog) que alguien está intentando loguearse, pero como mataste los servicios base y estás en chroot, ni siquiera existe el socket del log.
    
2.  **`openat(AT_FDCWD, "/var/log/btmp", O_WRONLY|O_CLOEXEC) = 3`**: El sistema registra el fallo en `btmp` (el archivo de intentos de login fallidos).
    
3.  **`sendto(3, ... OP=PAM:authentication ...)`**: Intenta hablar con el sistema de auditoría del kernel (Netlink), pero PAM finalmente retorna "Permiso denegado" porque no puede completar el ciclo de autenticación sin los daemons corriendo.
    

### Cómo solucionarlo (Plan de Acción en Chroot)

Como ya estás en el chroot del pendrive y **ya eres root** (por eso el chroot funciona), no intentes usar `su`. Vamos a reparar los archivos que están bloqueando el acceso:

#### 1\. Eliminar archivos de "bloqueo"

A veces, `dbus` o `systemd` dejan archivos de socket que, al estar presentes pero sin un proceso detrás, hacen que PAM crea que el sistema está en un estado inconsistente.

Bash

    # Borrar sockets viejos si existen
    rm -f /run/dbus/system_bus_socket
    rm -f /run/systemd/seats/*
    rm -f /var/run/nologin

#### 2\. Revisar `/etc/shadow` y el estado del usuario

Si el log dice "Usuario inválido" en el sistema real, es posible que los archivos de configuración de usuarios estén corruptos o que el sistema no pueda leerlos.

*   Ejecuta: `pwck`
    
    *   _Este comando verifica la integridad de `/etc/passwd` y `/etc/shadow`. Si te ofrece corregir algo, dile que sí._
        

#### 3\. Forzar la regeneración de la configuración de PAM

En tu Debian Sid, esto es vital. Vamos a resetear las reglas de PAM a su estado por defecto para asegurar que no haya un módulo colgado:

Bash

    pam-auth-update --force

_(Asegúrate de que esté marcado "Unix authentication" y "GNOME Keyring daemon" o "systemd sessions" si aparecen)._

#### 4\. El sospechoso: `killall` en el arranque

Si booteas y vuelve a pasar, es porque **tienes ese comando metido en algún lado**. Como usas **Manjaro/Debian Sid** y te gusta meter mano en scripts, buscá en estos lugares específicos:

*   `/etc/profile.d/*.sh`
    
*   `/home/eze/.bash_profile` o `/home/eze/.profile`
    
*   `/etc/rc.local` (si existe)
    

Usa este comando para buscarlo desde el chroot:

Bash

    grep -rn "killall" /etc/ /home/eze/ 2>/dev/null

### 5\. Reparar permisos de archivos críticos

Si estuviste moviendo archivos en `/dev` o `/usr`, fijate que `/etc/passwd` sea legible por todos:

Bash

    chmod 644 /etc/passwd /etc/group
    chmod 600 /etc/shadow

**¿Qué sigue?** Una vez hecho esto, salí del chroot:

1.  `exit`
    
2.  `umount -R /mnt`
    
3.  `reboot`
    

**Si al reiniciar llegás al TTY y te vuelve a decir "Usuario inválido":** Trata de entrar como **root** directamente en el TTY. Si root entra pero "eze" no, el problema es específico de tu configuración de usuario en `/etc/passwd`. Si root tampoco entra, el problema es que `systemd-logind` no está pudiendo iniciar por falta de D-Bus.

¿Te acordás si habías editado algún archivo en `/etc/pam.d/` antes de tirar el `killall`?

---

You asked:
----------

Has dicho

 > sudo su -

sudo: PAM account management error: Permiso denegado

sudo: a password is required

root@manjaro 2026-04-09 00:35:19 jueves /

 > su -

su: Permiso denegado

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

El problema es que estás intentando usar comandos que requieren validación de **PAM** (`sudo`, `su`) dentro de un entorno que no tiene los servicios de autenticación activos (D-Bus y systemd-logind). En un **chroot**, el sistema de seguridad "se marea" porque ve que quieres cambiar de usuario pero no encuentra al "guardia" que autoriza el movimiento.

**Pero hay una buena noticia:** No necesitas `su -`. Como el prompt dice `root@manjaro`, **ya eres root**. Estás operando con el máximo privilegio posible sobre tus archivos.

Para reparar el sistema y que vuelva a bootear normal, haz esto en este orden exacto dentro del chroot:

### 1\. Corregir el estado de D-Bus y Machine-ID

Si el `machine-id` se corrompió o quedó inconsistente, PAM rechazará cualquier intento de login en el próximo booteo.

Bash

    # Borrar archivos de estado viejos
    rm -f /etc/machine-id /var/lib/dbus/machine-id
    # Generar un ID nuevo y limpio
    dbus-uuidgen --ensure=/etc/machine-id
    dbus-uuidgen --ensure

### 2\. Resetear la configuración de PAM (Paso Crítico)

Como estás en un sistema con base Arch/Manjaro, vamos a reinstalar la base de la autenticación para asegurar que no haya archivos de configuración rotos en `/etc/pam.d/`.

Bash

    # Reinstalar pambase y shadow para resetear permisos y configs base
    pacman -S pambase shadow --noconfirm

### 3\. Verificar la integridad de los usuarios

Es posible que el `killall` haya ocurrido mientras el sistema escribía algo. Verifica que no haya errores estructurales en los archivos de usuarios:

Bash

    pwck -r

_Si te pregunta si quieres eliminar entradas duplicadas o corregir errores, dile que sí._

### 4\. Buscar el comando "asesino"

Si ese `killall` está en un script de inicio, tu reparación no servirá de nada porque se volverá a romper al prender. Vamos a buscarlo de forma agresiva en todo `/etc`:

Bash

    grep -rn "killall dbus-daemon" /etc/
    grep -rn "killall dbus-daemon" /home/eze/

**Si aparece algún resultado, edita ese archivo con `nano` y borra o comenta (poniendo un `#` adelante) esa línea.**

### 5\. ¿Por qué el TTY decía "Usuario inválido"?

Normalmente sucede porque el socket de D-Bus está "sucio". Al estar en el chroot, asegúrate de limpiar esto para que systemd no se confunda al arrancar de nuevo:

Bash

    rm -rf /run/*
    rm -rf /var/run/*

_(No te preocupes, estos directorios se recrean vacíos en cada booteo)._

* * *

**Para salir y probar:** No reinicies de golpe. Hazlo de forma limpia:

1.  Escribe `exit` para salir del chroot.
    
2.  Desmonta los puntos críticos (esto es vital para que no se corrompa el disco):
    
    Bash
    
        umount -l /mnt/dev/pts
        umount -l /mnt/dev
        umount -l /mnt/proc
        umount -l /mnt/sys
        umount -l /mnt/run
        umount /mnt
    
3.  Escribe `reboot`.
    

**Dato clave:** Si al prender ves que tarda mucho en `systemd`, fíjate si dice algo de **"A start job is running for User Login Management"**. Si pasa eso, es que todavía hay un script matando el D-Bus en segundo plano. Si logras llegar al TTY, intenta loguearte primero como **root**. Si root entra, el problema es solo de tu usuario `eze`.

---

You asked:
----------

Has dicho

root@manjaro 2026-04-09 00:36:08 jueves /

 > # Reinstalar pambase y shadow para resetear permisos y configs base

pacman -S pambase shadow --noconfirm

advertencia: pambase-20250719-1 está actualizado -- reinstalándolo

advertencia: shadow-4.18.0-1 está actualizado -- reinstalándolo

resolviendo dependencias...

buscando conflictos entre paquetes...

  

Paquetes (2) pambase-20250719-1  shadow-4.18.0-1

  

Tamaño total de la descarga:     1,20 MiB

Tamaño total de la instalación:  3,92 MiB

Tamaño neto tras actualizar:     0,00 MiB

  

:: ¿Continuar con la instalación? \[S/n\] 

:: Obteniendo los paquetes...

 shadow-4.18.0-1-x86\_64                        1230,1 KiB   366 KiB/s 00:03 \[###########################################\] 100%

(2/2) comprobando las claves del depósito                                   \[###########################################\] 100%

(2/2) verificando la integridad de los paquetes                             \[###########################################\] 100%

(2/2) cargando los archivos de los paquetes                                 \[###########################################\] 100%

(2/2) comprobando conflictos entre archivos                                 \[###########################################\] 100%

(2/2) comprobando el espacio disponible en el disco                         \[###########################################\] 100%

:: Procesando los cambios de los paquetes...

(1/2) reinstalando pambase                                                  \[###########################################\] 100%

(2/2) reinstalando shadow                                                   \[###########################################\] 100%

:: Ejecutando los «hooks» de posinstalación...

(1/5) Creating system user accounts...

/usr/lib/sysusers.d/dnsmasq.conf:1: Conflict with earlier configuration for user 'dnsmasq' in /usr/lib/sysusers.d/dnsmasq-base.conf:1, ignoring line.

/usr/lib/sysusers.d/geoclue2.conf:2: Conflict with earlier configuration for user 'geoclue' in /usr/lib/sysusers.d/geoclue-sysusers.conf:1, ignoring line.

/usr/lib/sysusers.d/libvirt-qemu.conf:1: Conflict with earlier configuration for group 'kvm' in /usr/lib/sysusers.d/basic.conf:32, ignoring line.

/usr/lib/sysusers.d/qemu.conf:1: Conflict with earlier configuration for group 'kvm' in /usr/lib/sysusers.d/basic.conf:32, ignoring line.

Creating group 'log' with GID 19.

Creating group 'lock' with GID 54.

Creating group 'network' with GID 90.

Creating group 'power' with GID 98.

Creating group 'ntp' with GID 87.

Creating group 'realtime' with GID 937.

Creating user 'ftp' (n/a) with UID 14 and GID 11.

Creating group 'named' with GID 936.

Suggested user ID 40 for named already used.

Creating user 'named' (BIND DNS Server) with UID 936 and GID 936.

Creating group 'dbus' with GID 81.

Creating user 'dbus' (System Message Bus) with UID 81 and GID 81.

Creating group 'exim' with GID 79.

Creating user 'exim' (Exim MTA) with UID 79 and GID 79.

Creating group 'mysql' with GID 935.

Creating user 'mysql' (MariaDB) with UID 935 and GID 935.

Creating user 'ntp' (Network Time Protocol) with UID 87 and GID 87.

Creating group 'nvidia-persistenced' with GID 143.

Creating user 'nvidia-persistenced' (NVIDIA Persistence Daemon) with UID 143 and GID 143.

Creating user 'rpc' (Rpcbind Daemon) with UID 32 and GID 32.

/etc/gshadow: Group "log" already exists.

error: la orden no se ejecutó correctamente

(2/5) Creating temporary files...

/usr/lib/tmpfiles.d/bind.conf:1: Failed to resolve user 'named': Unknown user

/usr/lib/tmpfiles.d/debian.conf:13: Duplicate line for path "/run/lock", ignoring.

/usr/lib/tmpfiles.d/exim.conf:1: Failed to resolve group 'exim': Unknown group

/usr/lib/tmpfiles.d/exim.conf:2: Failed to resolve user 'exim': Unknown user

/usr/lib/tmpfiles.d/exim.conf:3: Failed to resolve group 'exim': Unknown group

/usr/lib/tmpfiles.d/lockdev.conf:3: Failed to resolve group 'lock': Unknown group

/usr/lib/tmpfiles.d/mariadb.conf:13: Failed to resolve user 'mysql': Unknown user

/usr/lib/tmpfiles.d/mariadb.conf:14: Failed to resolve user 'mysql': Unknown user

/usr/lib/tmpfiles.d/mariadb.conf:19: Failed to resolve user 'mysql': Unknown user

/usr/lib/tmpfiles.d/openvpn.conf:1: Failed to resolve group 'network': Unknown group

/usr/lib/tmpfiles.d/openvpn.conf:2: Failed to resolve group 'network': Unknown group

/usr/lib/tmpfiles.d/openvpn.conf:3: Failed to resolve group 'network': Unknown group

/usr/lib/tmpfiles.d/openvpn.conf:4: Failed to resolve group 'network': Unknown group

/usr/lib/tmpfiles.d/rpcbind.conf:1: Failed to resolve user 'rpc': Unknown user

Detected unsafe path transition /run/systemd (owned by alpm) → /run/systemd/netif (owned by systemd-network) during canonicalization of run/systemd/netif.

Detected unsafe path transition /run/systemd (owned by alpm) → /run/systemd/netif (owned by systemd-network) during canonicalization of run/systemd/netif.

error: la orden no se ejecutó correctamente

(3/5) Reloading system manager configuration...

  Skipped: Running in chroot.

(4/5) Enqueuing marked services...

  Skipped: Running in chroot.

(5/5) Arming ConditionNeedsUpdate...

root@manjaro 2026-04-09 00:36:20 jueves /

 > pwck -r

usuario «list»: el directorio «/var/list» no existe

usuario «irc»: el directorio «/run/ircd» no existe

usuario «mockbuild»: el directorio «/home/mockbuild» no existe

ninguna entrada del fichero de contraseñas concuerda con /etc/passwd

¿desea eliminar la línea «ftp:!\*:20536:::::1:»? No

ninguna entrada del fichero de contraseñas concuerda con /etc/passwd

¿desea eliminar la línea «ntp:!\*:20536::::::»? No

ninguna entrada del fichero de contraseñas concuerda con /etc/passwd

¿desea eliminar la línea «rpc:!\*:20536:::::1:»? No

ninguna entrada del fichero de contraseñas concuerda con /etc/passwd

¿desea eliminar la línea «dbus:!\*:20537::::::»? No

pwck: sin cambios

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Esa salida de `pacman` y `pwck` es muy reveladora. El error `error: la orden no se ejecutó correctamente` en los hooks de **sysusers** y **tmpfiles** ocurre porque el sistema está intentando crear usuarios que ya existen o no puede resolver los grupos debido a la inconsistencia que dejó el `killall` en los archivos de configuración (`/etc/passwd`, `/etc/group`, `/etc/shadow`).

Lo más importante: `pwck` te está diciendo que **"ninguna entrada del fichero de contraseñas concuerda"**. Esto significa que el archivo `/etc/shadow` (donde están las claves) se desincronizó totalmente del `/etc/passwd`.

Vamos a forzar la reparación manual de esos archivos ahora que somos root en el chroot:

### 1\. Sincronizar Shadow y Passwd

Ejecutá este comando para regenerar las entradas de shadow faltantes basándose en passwd:

Bash

    grpck
    pwconv
    grpconv

Esto debería silenciar los errores de "no concuerda" que viste en `pwck`.

### 2\. Reparar el problema de los grupos y usuarios (sysusers)

Como el hook de pacman falló, vamos a forzar la creación de las identidades de sistema manualmente para que D-Bus y otros daemons puedan arrancar:

Bash

    systemd-sysusers
    systemd-tmpfiles --create

Si ves errores de "Already exists", ignoralos. Lo importante es que termine de procesar los que faltan (como `dbus`, `named` o `rpc`).

### 3\. Verificar el archivo `/etc/pam.d/system-auth`

A veces, al reinstalar `pambase`, se crean archivos `.pacnew`. Asegurémonos de que el archivo real no esté vacío:

Bash

    cat /etc/pam.d/system-auth

Deberías ver líneas que mencionan `pam_unix.so` y `pam_systemd.so`. Si está vacío o tiene algo muy raro, avisame.

### 4\. Limpiar los archivos de bloqueo de PAM

A veces PAM deja "tally" o bloqueos por intentos fallidos que persisten incluso en chroot:

Bash

    # Limpiar contadores de intentos fallidos
    faillock --reset

### 5\. El paso final antes de salir: Resetear tu contraseña

Para estar 100% seguros de que el hash en `/etc/shadow` es válido y que PAM lo va a aceptar:

Bash

    passwd eze

_(Poné tu clave de siempre. Si esto falla, es que el archivo shadow está bloqueado en modo solo lectura o corrupto)._

* * *

### ¿Por qué falló el hook de pacman?

El error `/etc/gshadow: Group "log" already exists` indica que el instalador intentó agregar un grupo que ya estaba, pero se frenó por la inconsistencia de los archivos. Al correr `pwconv` y `grpconv` (paso 1), deberías haber limpiado ese camino.

**Intentá reiniciar ahora:**

1.  `exit`
    
2.  `umount -l /mnt/dev/pts /mnt/dev /mnt/proc /mnt/sys /mnt/run`
    
3.  `umount /mnt`
    
4.  `reboot`
    

Si el sistema vuelve a tirar "Usuario inválido" o "Permiso denegado", el problema está en cómo el kernel está montando `/etc` o si hay algún atributo de "inmutabilidad" (`chattr +i`) que quedó activado por error.

¿Te dejó cambiar la contraseña con el comando `passwd` sin errores?

---

You asked:
----------

Has dicho

socket(AF\_NETLINK, SOCK\_RAW|SOCK\_CLOEXEC, NETLINK\_AUDIT) = 3

readlink("/proc/self/exe", "/usr/bin/su", 4096) = 11

ioctl(0, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(0, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/0", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffdd47c6fd0, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

ioctl(1, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(1, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/1", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffdd47c6fd0, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

ioctl(2, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(2, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/2", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffdd47c6fd0, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

sendto(3, \[{nlmsg\_len=132, nlmsg\_type=0x44c /\* NLMSG\_??? \*/, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=1, nlmsg\_pid=0}, "\\x6f\\x70\\x3d\\x50\\x41\\x4d\\x3a\\x61\\x75\\x74\\x68\\x65\\x6e\\x74\\x69\\x63\\x61\\x74\\x69\\x6f\\x6e\\x20\\x67\\x72\\x61\\x6e\\x74\\x6f\\x72\\x73\\x3d\\x70\\x61\\x6d\\x5f\\x72\\x6f\\x6f\\x74\\x6f\\x6b\\x20\\x61\\x63\\x63\\x74\\x3d\\x22\\x72\\x6f\\x6f\\x74\\x22\\x20\\x65\\x78\\x65\\x3d\\x22\\x2f\\x75\\x73\\x72\\x2f\\x62\\x69\\x6e\\x2f\\x73\\x75\\x22\\x20\\x68\\x6f\\x73\\x74\\x6e\\x61\\x6d\\x65\\x3d\\x3f\\x20\\x61\\x64\\x64\\x72\\x3d\\x3f\\x20\\x74\\x65\\x72\\x6d\\x69\\x6e\\x61\\x6c\\x3d\\x3f\\x20\\x72\\x65\\x73\\x3d\\x73\\x75\\x63\\x63\\x65\\x73\\x73\\x00\\x00\\x00\\x00"\], 132, 0, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, 12) = 132

poll(\[{fd=3, events=POLLIN}\], 1, 500)   = 1 (\[{fd=3, revents=POLLIN}\])

recvfrom(3, \[{nlmsg\_len=36, nlmsg\_type=NLMSG\_ERROR, nlmsg\_flags=NLM\_F\_CAPPED, nlmsg\_seq=1, nlmsg\_pid=7844}, {error=0, msg={nlmsg\_len=132, nlmsg\_type=AUDIT\_FIRST\_USER\_MSG, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=1, nlmsg\_pid=0}}\], 8988, MSG\_PEEK|MSG\_DONTWAIT, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, \[12\]) = 36

recvfrom(3, \[{nlmsg\_len=36, nlmsg\_type=NLMSG\_ERROR, nlmsg\_flags=NLM\_F\_CAPPED, nlmsg\_seq=1, nlmsg\_pid=7844}, {error=0, msg={nlmsg\_len=132, nlmsg\_type=AUDIT\_FIRST\_USER\_MSG, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=1, nlmsg\_pid=0}}\], 8988, MSG\_DONTWAIT, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, \[12\]) = 36

close(3)                                = 0

rt\_sigprocmask(SIG\_BLOCK, ~\[\], \[\], 8)   = 0

mmap(NULL, 4096, PROT\_READ|PROT\_WRITE, MAP\_DROPPABLE|MAP\_ANONYMOUS, -1, 0) = 0x7f5d0e02b000

mmap(NULL, 4096, PROT\_READ|PROT\_WRITE, MAP\_PRIVATE|MAP\_ANONYMOUS, -1, 0) = 0x7f5d0e02a000

rt\_sigprocmask(SIG\_SETMASK, \[\], NULL, 8) = 0

getrandom("\\x4d\\x87\\xc3\\x4d\\x14\\xf1\\x74\\xa8\\x34\\xd9\\x8e\\xc5\\x8d\\x41\\xef\\xbb\\xe8\\x78\\x58\\x55\\xd8\\xb3\\xac\\x41\\x96\\xd8\\x72\\x85\\x1b\\x67\\x13\\xe9", 32, 0) = 32

socket(AF\_NETLINK, SOCK\_RAW|SOCK\_CLOEXEC, NETLINK\_AUDIT) = 3

ioctl(0, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(0, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/0", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffdd47c7000, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

ioctl(1, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(1, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/1", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffdd47c7000, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

ioctl(2, TCGETS2, {c\_iflag=BRKINT|ICRNL|IXON|IMAXBEL, c\_oflag=NL0|CR0|TAB0|BS0|VT0|FF0|OPOST|ONLCR, c\_cflag=B38400|CS8|CREAD, c\_lflag=ISIG|ICANON|ECHO|ECHOE|ECHOK|IEXTEN|ECHOCTL|ECHOKE, ...}) = 0

fstat(2, {st\_mode=S\_IFCHR|0600, st\_rdev=makedev(0x88, 0x1), ...}) = 0

readlink("/proc/self/fd/2", "/dev/pts/1", 31) = 10

newfstatat(AT\_FDCWD, "/dev/pts/1", 0x7ffdd47c7000, 0) = -1 ENOENT (No existe el fichero o el directorio)

newfstatat(AT\_FDCWD, "/dev/pts/", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

openat(AT\_FDCWD, "/dev/pts/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=0, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 2 entries \*/, 32768) = 48

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

openat(AT\_FDCWD, "/dev/", O\_RDONLY|O\_NONBLOCK|O\_CLOEXEC|O\_DIRECTORY) = 4

fstat(4, {st\_mode=S\_IFDIR|0755, st\_size=254, ...}) = 0

getdents64(4, 0x55cee3d853c0 /\* 31 entries \*/, 32768) = 800

newfstatat(AT\_FDCWD, "/dev/.", {st\_mode=S\_IFDIR|0755, st\_size=254, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/..", {st\_mode=S\_IFDIR|0755, st\_size=832, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/shm", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/full", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/console", {st\_mode=S\_IFREG|S\_ISVTX|0777, st\_size=15, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/fd", {st\_mode=S\_IFDIR|0500, st\_size=5, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sda8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb1", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb2", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb3", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb4", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb5", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb6", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb7", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/sdb8", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/pts", {st\_mode=S\_IFDIR|0755, st\_size=0, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/zero", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x5), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/random", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x8), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/urandom", {st\_mode=S\_IFCHR|0666, st\_rdev=makedev(0x1, 0x9), ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/null", {st\_mode=S\_IFREG|0644, st\_size=25, ...}, 0) = 0

newfstatat(AT\_FDCWD, "/dev/mapper", {st\_mode=S\_IFDIR|0755, st\_size=14, ...}, 0) = 0

getdents64(4, 0x55cee3d853c0 /\* 0 entries \*/, 32768) = 0

close(4)                                = 0

sendto(3, \[{nlmsg\_len=116, nlmsg\_type=0x44d /\* NLMSG\_??? \*/, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=2, nlmsg\_pid=0}, "\\x6f\\x70\\x3d\\x50\\x41\\x4d\\x3a\\x61\\x63\\x63\\x6f\\x75\\x6e\\x74\\x69\\x6e\\x67\\x20\\x67\\x72\\x61\\x6e\\x74\\x6f\\x72\\x73\\x3d\\x3f\\x20\\x61\\x63\\x63\\x74\\x3d\\x22\\x72\\x6f\\x6f\\x74\\x22\\x20\\x65\\x78\\x65\\x3d\\x22\\x2f\\x75\\x73\\x72\\x2f\\x62\\x69\\x6e\\x2f\\x73\\x75\\x22\\x20\\x68\\x6f\\x73\\x74\\x6e\\x61\\x6d\\x65\\x3d\\x3f\\x20\\x61\\x64\\x64\\x72\\x3d\\x3f\\x20\\x74\\x65\\x72\\x6d\\x69\\x6e\\x61\\x6c\\x3d\\x3f\\x20\\x72\\x65\\x73\\x3d\\x66\\x61\\x69\\x6c\\x65\\x64\\x00\\x00"\], 116, 0, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, 12) = 116

poll(\[{fd=3, events=POLLIN}\], 1, 500)   = 1 (\[{fd=3, revents=POLLIN}\])

recvfrom(3, \[{nlmsg\_len=36, nlmsg\_type=NLMSG\_ERROR, nlmsg\_flags=NLM\_F\_CAPPED, nlmsg\_seq=2, nlmsg\_pid=7844}, {error=0, msg={nlmsg\_len=116, nlmsg\_type=0x44d /\* AUDIT\_??? \*/, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=2, nlmsg\_pid=0}}\], 8988, MSG\_PEEK|MSG\_DONTWAIT, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, \[12\]) = 36

recvfrom(3, \[{nlmsg\_len=36, nlmsg\_type=NLMSG\_ERROR, nlmsg\_flags=NLM\_F\_CAPPED, nlmsg\_seq=2, nlmsg\_pid=7844}, {error=0, msg={nlmsg\_len=116, nlmsg\_type=0x44d /\* AUDIT\_??? \*/, nlmsg\_flags=NLM\_F\_REQUEST|NLM\_F\_ACK, nlmsg\_seq=2, nlmsg\_pid=0}}\], 8988, MSG\_DONTWAIT, {sa\_family=AF\_NETLINK, nl\_pid=0, nl\_groups=00000000}, \[12\]) = 36

close(3)                                = 0

getpid()                                = 7844

socket(AF\_UNIX, SOCK\_DGRAM|SOCK\_CLOEXEC, 0) = 3

connect(3, {sa\_family=AF\_UNIX, sun\_path="/dev/log"}, 110) = -1 ENOENT (No existe el fichero o el directorio)

close(3)                                = 0

getpid()                                = 7844

openat(AT\_FDCWD, "/var/log/btmp", O\_WRONLY|O\_CLOEXEC) = 3

alarm(0)                                = 0

rt\_sigaction(SIGALRM, {sa\_handler=0x7f5d0df6b330, sa\_mask=\[\], sa\_flags=SA\_RESTORER, sa\_restorer=0x7f5d0de422d0}, {sa\_handler=SIG\_DFL, sa\_mask=\[\], sa\_flags=0}, 8) = 0

alarm(10)                               = 0

fcntl(3, F\_SETLKW, {l\_type=F\_WRLCK, l\_whence=SEEK\_SET, l\_start=0, l\_len=0}) = 0

alarm(0)                                = 10

rt\_sigaction(SIGALRM, {sa\_handler=SIG\_DFL, sa\_mask=\[\], sa\_flags=SA\_RESTORER, sa\_restorer=0x7f5d0de422d0}, NULL, 8) = 0

lseek(3, 0, SEEK\_END)                   = 7296

write(3, "\\6\\0\\0\\0\\244\\36\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0root\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0"..., 384) = 384

fcntl(3, F\_SETLKW, {l\_type=F\_UNLCK, l\_whence=SEEK\_SET, l\_start=0, l\_len=0}) = 0

close(3)                                = 0

openat(AT\_FDCWD, "/usr/share/locale/es\_AR.UTF-8/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es\_AR.utf8/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es\_AR/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es.UTF-8/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es.utf8/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = -1 ENOENT (No existe el fichero o el directorio)

openat(AT\_FDCWD, "/usr/share/locale/es/LC\_MESSAGES/Linux-PAM.mo", O\_RDONLY) = 3

fstat(3, {st\_mode=S\_IFREG|0644, st\_size=8677, ...}) = 0

mmap(NULL, 8677, PROT\_READ, MAP\_PRIVATE, 3, 0) = 0x7f5d0e027000

close(3)                                = 0

munmap(0x7f5d0e092000, 16400)           = 0

munmap(0x7f5d0e08d000, 16400)           = 0

munmap(0x7f5d0e088000, 16400)           = 0

munmap(0x7f5d0e083000, 16400)           = 0

openat(AT\_FDCWD, "/etc/login.defs", O\_RDONLY) = 3

fstat(3, {st\_mode=S\_IFREG|0644, st\_size=4687, ...}) = 0

read(3, "#\\n# /etc/login.defs - Configuration control definitions for the shadow package.\\n#\\n\\n#\\n# Enable display of unknown usernames when login(1) failures are recorded.\\n#\\n# WARNING: Unknown usernames may becom"..., 4096) = 4096

read(3, "#\\n# The pwck(8) utility emits a warning for any system account with a home\\n# directory that does not exist.  Some system accounts intentionally do\\n# not have a home directory.  Such accounts may have "..., 4096) = 591

read(3, "", 4096)                       = 0

close(3)                                = 0

openat(AT\_FDCWD, "/etc/default/su", O\_RDONLY) = 3

fstat(3, {st\_mode=S\_IFREG|0755, st\_size=0, ...}) = 0

read(3, "", 4096)                       = 0

close(3)                                = 0

clock\_nanosleep(CLOCK\_REALTIME, 0, {tv\_sec=1, tv\_nsec=0}, 0x7ffdd47c9650) = 0

write(2, "su: ", 4su: )                     = 4

write(2, "Permiso denegado", 16Permiso denegado)        = 16

write(2, "\\n", 1

)                       = 1

dup(1)                                  = 3

close(3)                                = 0

dup(2)                                  = 3

close(3)                                = 0

exit\_group(1)                           = ?

+++ exited with 1 +++

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Ese `strace` es oro puro para el diagnóstico. Me confirma exactamente dónde se está rompiendo la cadena de confianza.

Fijate en esta línea: `connect(3, {sa_family=AF_UNIX, sun_path="/dev/log"}, 110) = -1 ENOENT (No existe el fichero o el directorio)`

Y luego estas: `newfstatat(AT_FDCWD, "/dev/pts/1", 0x7ffdd47c7000, 0) = -1 ENOENT` `sendto(3, ... "res=failed" ...)`

### El Diagnóstico

El problema no es de contraseñas ni de archivos corruptos en `/etc`. El problema es que **el entorno chroot no tiene los dispositivos virtuales montados correctamente**.

Cuando `su` intenta validar quién sos, busca el socket de registro (`/dev/log`) y la terminal actual (`/dev/pts/1`). Como no los encuentra (da `ENOENT`), PAM asume que el entorno es inseguro o está roto y aborta con un **"Permiso denegado"** por seguridad.

### Cómo arreglarlo (pasos obligatorios)

Para que el sistema de autenticación funcione dentro del chroot (y para que la reparación de `pambase` que hiciste antes realmente se aplique al disco), tenés que salir y volver a entrar **montando todo**:

1.  **Salí del chroot actual:**
    
    Bash
    
        exit
    
2.  **Montá el sistema con todos sus "sentidos" activos:** Asumiendo que tu partición de Manjaro es `/dev/sdaX` (cambiala por la que corresponda):
    
    Bash
    
        mount /dev/sdaX /mnt
        for i in /dev /dev/pts /proc /sys /run; do mount -B $i /mnt$i; done
    
3.  **Entrá de nuevo:**
    
    Bash
    
        chroot /mnt
    
4.  **Ahora sí, ejecutá la reparación que falló antes:**
    
    Bash
    
        systemd-sysusers
        systemd-tmpfiles --create
        pwconv
        grpconv
    

**¿Por qué ahora va a funcionar?** Porque ahora `/dev/log` y `/dev/pts` van a existir dentro del chroot (heredados del sistema desde el que estás reparando). Esto permitirá que los scripts de posinstalación de Arch/Manjaro identifiquen correctamente a los usuarios y grupos sin tirar esos errores de `Unknown user`.

* * *

**Una observación sobre tu `strace`:** Vi que `newfstatat` busca `/dev/sda1` hasta `/dev/sdb8` y los ve como directorios (`S_IFDIR`). Eso es muy extraño; deberían ser archivos de bloque. Refuerza mi teoría de que el `/dev` dentro de tu chroot está "vacío" o mal poblado.

Hacé el remount con el `for` que te pasé arriba y probá tirar un `ls -l /dev/log` adentro. Si aparece, ya podés correr los comandos de reparación sin miedo.

---

You asked:
----------

Has dicho

\[manjaro n\]# pwd

/n

\[manjaro n\]# ls

afs            dev          initrd.img.old  lib32       media  props.plist        run    system

bin            etc          install         lib64       mnt    reparar\_libc\_0.sh  sbin   tmp

boot           files.plist  iso             libx32      opt    reparar\_libc\_1.sh  sfs    trixie

bootx64.efi    fix-grub.sh  j               local       otro   reparar\_libc\_2.sh  share  usr

core.efi       glibc-2.43   k               log2.txt    p      reparar\_libc\_3.sh  srv    var

debian-binary  home         ld.so.cache     log\_3.txt   pkg    resolv.conf        sudo   vmlinuz

debian\_trixie  initrd.img   lib             ls\_manjaro  proc   root               sys    vmlinuz.old

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Veo que estás operando desde un directorio llamado `/n` (probablemente tu punto de montaje). El contenido revela que tenés un "Frankeinux" (mezcla de Debian Trixie/Sid con Manjaro) bastante complejo, con scripts de reparación de `libc` y archivos `.plist`.

El problema del `strace` anterior se confirma con tu `ls`: estás intentando arreglar la autenticación, pero el entorno no tiene los túneles de comunicación con el kernel necesarios.

Para arreglarlo desde donde estás parado (`/n`), ejecutá estos montajes **antes** de volver a entrar al chroot. Esto "mapea" el hardware y los procesos del sistema vivo hacia tu instalación rota:

### 1\. Preparar el entorno (Binding)

Desde afuera del chroot (donde hiciste el `ls` recién):

Bash

    mount --bind /dev /n/dev
    mount --bind /dev/pts /n/dev/pts
    mount --bind /proc /n/proc
    mount --bind /sys /n/sys
    mount --bind /run /n/run

### 2\. Entrar y Sincronizar

Ahora que el sistema tiene "ojos y oídos", entrá y forzá la reparación de las bases de datos de usuarios:

Bash

    chroot /n /bin/bash
    # Una vez adentro:
    pwconv
    grpconv
    systemd-sysusers
    systemd-tmpfiles --create

### 3\. El factor "Frankeinux" (Glibc)

Veo una carpeta `glibc-2.43` y scripts `reparar_libc`. Si estuviste tocando la `libc` manualmente, PAM va a fallar siempre porque `su` y `sudo` dependen de `libpam.so`, que a su vez depende de una versión específica de la `libc`.

Si después de los montajes `su -` te sigue dando "Permiso denegado", verificá si no hay un desajuste de versiones:

Bash

    ldd /usr/bin/su

Si ves algún **"not found"** o un path apuntando a `/n/glibc-2.43/...` en lugar de `/usr/lib/`, ahí tenés al culpable. PAM no puede cargar el módulo de autenticación porque no encuentra sus librerías base.

**¿Esos scripts `reparar_libc_X.sh` hacen algún `ln -s` de la `libc.so.6`?** Si la respuesta es sí, asegúrate de que el enlace sea relativo al root del sistema y no a una ruta temporal.

---

You asked:
----------

Has dicho

\[manjaro n\]# mount --bind /dev /n/dev

mount --bind /dev/pts /n/dev/pts

mount --bind /proc /n/proc

mount --bind /sys /n/sys

mount --bind /run /n/run

\[manjaro n\]# chroot /n /bin/bash

\# Una vez adentro:

pwconv

grpconv

systemd-sysusers

systemd-tmpfiles --create

root@manjaro 2026-04-09 00:39:33 jueves /

 > ldd /usr/bin/su

    linux-vdso.so.1 (0x00007f84c7767000)

    libpam.so.0 => /usr/lib/libpam.so.0 (0x00007f84c76c1000)

    libpam\_misc.so.0 => /usr/lib/libpam\_misc.so.0 (0x00007f84c76bc000)

    libc.so.6 => /usr/lib/libc.so.6 (0x00007f84c7400000)

    libaudit.so.1 => /usr/lib/libaudit.so.1 (0x00007f84c7689000)

    /lib64/ld-linux-x86-64.so.2 (0x00007f84c7769000)

    libcap-ng.so.0 => /usr/lib/libcap-ng.so.0 (0x00007f84c7681000)

root@manjaro 2026-04-09 00:39:38 jueves /

 > su -

su: Permission denied

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Esto es realmente extraño. Las librerías de `su` están perfectamente enlazadas a `/usr/lib/`, así que no es un problema de la `libc` o de rutas rotas. Si `su -` te sigue dando "Permission denied" siendo root dentro de un chroot con `/dev`, `/proc` y `/sys` montados, el bloqueo viene de una capa de seguridad más profunda.

Hay tres sospechosos principales ahora mismo:

### 1\. Atributos extendidos o permisos del binario

Si el binario de `su` perdió el bit **SUID**, no puede cambiar de identidad, y PAM lo bloquea. Verificá esto:

Bash

    ls -l /usr/bin/su

Debería verse así (fíjate en la **s**): `-rwsr-xr-x`. Si no tiene la **s**, reparalo:

Bash

    chmod u+s /usr/bin/su

### 2\. Capacidad de Auditoría (Audit)

En tu `strace` anterior, vimos que `su` hablaba con el kernel vía `NETLINK_AUDIT` y recibía un `res=failed`. A veces, el sistema de auditoría del kernel bloquea acciones si no puede registrar el evento. Intentá "engañar" a PAM desactivando el módulo de auditoría temporalmente en la configuración de `su`:

1.  Editá el archivo: `nano /etc/pam.d/su`
    
2.  Buscá líneas que digan `pam_audit.so` (si existen) y comentalas con un `#`.
    
3.  Aprovechando que estás ahí, verificá que la primera línea de **auth** sea: `auth sufficient pam_rootok.so` _(Esto debería permitir que root use `su` sin preguntar nada)._
    

### 3\. El archivo `/etc/shadow` está bloqueado

Si por algún motivo el archivo tiene el atributo de **inmutabilidad**, PAM no puede actualizar los "timestamps" de login y rebota la entrada.

Bash

    lsattr /etc/shadow

Si ves una **i**, quitala: `chattr -i /etc/shadow`.

* * *

### La prueba de fuego: ¿Es PAM o es el binario?

Para descartar si el problema es de PAM o de algo más básico, probá usar la versión de `busybox` (si la tenés instalada) que suele ignorar muchas políticas de PAM:

Bash

    busybox su -

**Pregunta clave:** ¿El `killall dbus-daemon` que mencionaste al principio ocurrió mientras estabas haciendo el **usrmerge** (la conversión a `/usr/lib`)? Si el sistema se colgó en medio de ese movimiento, es posible que tengas librerías duplicadas o archivos en `/lib` (sin el symlink) que están causando un conflicto de contexto que `ldd` no llega a mostrar.

Verificá el link simbólico de la discordia:

Bash

    ls -ld /lib /lib64 /bin /sbin

Todos deberían apuntar a `usr/...`. Si alguno es un directorio real y no un link, ahí está el desastre.

---

You asked:
----------

Has dicho

\[manjaro n\]# mount --bind /dev /n/dev

mount --bind /dev/pts /n/dev/pts

mount --bind /proc /n/proc

mount --bind /sys /n/sys

mount --bind /run /n/run

\[manjaro n\]# chroot /n /bin/bash

\# Una vez adentro:

pwconv

grpconv

systemd-sysusers

systemd-tmpfiles --create

root@manjaro 2026-04-09 00:39:33 jueves /

 > ldd /usr/bin/su

    linux-vdso.so.1 (0x00007f84c7767000)

    libpam.so.0 => /usr/lib/libpam.so.0 (0x00007f84c76c1000)

    libpam\_misc.so.0 => /usr/lib/libpam\_misc.so.0 (0x00007f84c76bc000)

    libc.so.6 => /usr/lib/libc.so.6 (0x00007f84c7400000)

    libaudit.so.1 => /usr/lib/libaudit.so.1 (0x00007f84c7689000)

    /lib64/ld-linux-x86-64.so.2 (0x00007f84c7769000)

    libcap-ng.so.0 => /usr/lib/libcap-ng.so.0 (0x00007f84c7681000)

root@manjaro 2026-04-09 00:39:38 jueves /

 > su -

su: Permission denied

root@manjaro 2026-04-09 00:39:44 jueves /

 > ls -l /usr/bin/su

\-rwsr-xr-x 1 root root 55384 abr  1 08:27 /usr/bin/su

root@manjaro 2026-04-09 00:40:04 jueves /

 > chmod u+s /usr/bin/su

root@manjaro 2026-04-09 00:40:07 jueves /

 > lsattr /etc/shadow

\---------------------- /etc/shadow

root@manjaro 2026-04-09 00:40:13 jueves /

 > busybox su -

root@manjaro 2026-04-09 00:40:19 jueves ~

 > ls -ld /lib /lib64 /bin /sbin

lrwxrwxrwx 1 root root 7 oct 12 13:21 /bin -> usr/bin

lrwxrwxrwx 1 root root 7 oct 12 13:21 /lib -> usr/lib

lrwxrwxrwx 1 root root 7 oct 12 13:21 /lib64 -> usr/lib

lrwxrwxrwx 1 root root 9 abr  3 16:12 /sbin -> /usr/sbin

root@manjaro 2026-04-09 00:40:26 jueves ~

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

¡Bingo! El hecho de que `busybox su -` haya funcionado pero el `su` normal (shadow) falle con "Permission denied" confirma que **el problema es estrictamente de PAM (Pluggable Authentication Modules)**.

Busybox suele saltarse la pila de PAM y validar contra `/etc/shadow` directamente. El `su` de Manjaro, en cambio, le pregunta a PAM: "¿Puedo entrar?", y PAM está respondiendo "No" porque algo en su configuración o en su entorno de ejecución está roto.

Lo más sospechoso es tu symlink de `/sbin`: `lrwxrwxrwx 1 root root 9 abr 3 16:12 /sbin -> /usr/sbin`

En una estructura **merged-usr** estándar de Arch/Manjaro, `/sbin` debería apuntar a `usr/bin` (o `usr/sbin` siendo este último un symlink a `bin`). Pero lo más importante: **fijate en el `/` inicial**. Tus otros links son **relativos** (`usr/lib`), pero `/sbin` es **absoluto** (`/usr/sbin`). Esto puede causar problemas de resolución de rutas dentro del chroot.

### 1\. Corregir los Symlinks de merged-usr

Vamos a uniformar eso para que coincida con el estándar de Arch:

Bash

    # Salí del login de busybox si todavía estás ahí (tipeá exit una vez)
    cd /
    rm sbin
    ln -s usr/bin sbin

### 2\. Revisar el "corazón" de PAM

Si el problema persiste, es probable que algún módulo de PAM esté intentando contactar a un daemon que no existe o que el archivo de configuración se haya corrompido durante el `killall`.

Verificá el contenido de `/etc/pam.d/su`:

Bash

    cat /etc/pam.d/su

Debería empezar con: `auth sufficient pam_rootok.so`

Si esa línea existe y aun así te rebota siendo root, el problema es el módulo **systemd**. Intentemos una reparación quirúrgica en los archivos de configuración base de PAM:

Bash

    # Forzar la reinstalación de pambase pero asegurando que los archivos se escriban
    pacman -S pambase --noconfirm

### 3\. El factor "Namespace" (Contexto de Seguridad)

Como estás en un chroot de un sistema que sufrió un `killall` masivo, puede haber quedado basura en `/run/systemd`. PAM usa archivos ahí para saber si la sesión es válida.

Limpiá los rastros de la sesión anterior:

Bash

    rm -rf /run/systemd/sessions/*
    rm -rf /run/systemd/users/*

### 4\. ¿Tenés SELinux o AppArmor activo?

Aunque Manjaro no usa SELinux por defecto, si Frankeinux tiene componentes de Debian, revisá si hay algo bloqueando:

Bash

    # Si esto devuelve algo, el kernel está bloqueando por seguridad
    aa-status 2>/dev/null

* * *

**Resumen del estado actual:**

*   **Archivos:** OK (passwd/shadow sincronizados).
    
*   **Binarios:** OK (SUID activo).
    
*   **Librerías:** OK (ldd correcto).
    
*   **Falla:** La lógica de decisión de PAM.
    

**Prueba esto después de corregir el link de `/sbin`:** Intentá ejecutar `su -` de nuevo. Si vuelve a decir "Permission denied", ejecutalo con `strace` otra vez pero filtrando por la apertura de archivos de PAM para ver cuál es el que da el error:

Bash

    strace -e openat,access su - 2>&1 | grep pam

---

You asked:
----------

Has dicho

Me gustaría el archivo completo corregido.

  

 > cat /etc/pam.d/su

#

\# The PAM configuration file for the Shadow \`su' service

#

  

\# This allows root to su without passwords (normal operation)

auth       sufficient pam\_rootok.so

auth       sufficient pam\_permit.so

  

\# Uncomment this to force users to be a member of group wheel

\# before they can use \`su'. You can also add "group=foo"

\# to the end of this line if you want to use a group other

\# than the default "wheel" (but this may have side effect of

\# denying "root" user, unless she's a member of "foo" or explicitly

\# permitted earlier by e.g. "sufficient pam\_rootok.so").

\# (Replaces the \`SU\_WHEEL\_ONLY' option from login.defs)

\# auth       required   pam\_wheel.so

  

\# Uncomment this if you want wheel members to be able to

\# su without a password.

\# auth       sufficient pam\_wheel.so trust

  

\# Uncomment this if you want members of a specific group to not

\# be allowed to use su at all.

\# auth       required   pam\_wheel.so deny group=nosu

  

\# Uncomment and edit /etc/security/time.conf if you need to set

\# time restrainst on su usage.

\# (Replaces the \`PORTTIME\_CHECKS\_ENAB' option from login.defs

\# as well as /etc/porttime)

\# account    requisite  pam\_time.so

  

\# This module parses environment configuration file(s)

\# and also allows you to use an extended config

\# file /etc/security/pam\_env.conf.

# 

\# parsing /etc/environment needs "readenv=1"

\# session       required   pam\_env.so readenv=1

\# locale variables are also kept into /etc/default/locale in etch

\# reading this file \*in addition to /etc/environment\* does not hurt

\# session       required   pam\_env.so readenv=1 envfile=/etc/default/locale

  

\# Defines the MAIL environment variable

\# However, userdel also needs MAIL\_DIR and MAIL\_FILE variables

\# in /etc/login.defs to make sure that removing a user 

\# also removes the user's mail spool file.

\# See comments in /etc/login.defs

#

\# "nopen" stands to avoid reporting new mail when su'ing to another user

session    optional   pam\_mail.so nopen

  

\# Sets up user limits according to /etc/security/limits.conf

\# (Replaces the use of /etc/limits in old login)

\# session    required   pam\_limits.so

  

\# The standard Unix authentication modules, used with

\# NIS (man nsswitch) as well as normal /etc/passwd and

\# /etc/shadow entries.

@include common-auth

@include common-account

@include common-session

  

 > strace -e openat,access su - 2>&1 | grep pam

openat(AT\_FDCWD, "/usr/lib/libpam.so.0", O\_RDONLY|O\_CLOEXEC) = 3

openat(AT\_FDCWD, "/usr/lib/libpam\_misc.so.0", O\_RDONLY|O\_CLOEXEC) = 3

openat(AT\_FDCWD, "/etc/pam.d/su-l", O\_RDONLY) = 3

openat(AT\_FDCWD, "/etc/pam.d/su", O\_RDONLY) = 4

openat(AT\_FDCWD, "/usr/lib/security/pam\_rootok.so", O\_RDONLY|O\_CLOEXEC) = 5

openat(AT\_FDCWD, "/usr/lib/security/pam\_permit.so", O\_RDONLY|O\_CLOEXEC) = 5

openat(AT\_FDCWD, "/etc/pam.d/su", O\_RDONLY) = 4

openat(AT\_FDCWD, "/etc/pam.d/su", O\_RDONLY) = 4

openat(AT\_FDCWD, "/usr/lib/security/pam\_keyinit.so", O\_RDONLY|O\_CLOEXEC) = 4

openat(AT\_FDCWD, "/etc/pam.d/su", O\_RDONLY) = 4

openat(AT\_FDCWD, "/usr/lib/security/pam\_mail.so", O\_RDONLY|O\_CLOEXEC) = 6

openat(AT\_FDCWD, "/etc/pam.d/other", O\_RDONLY) = 3

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Ese `strace` es revelador. Fijate en la última línea: `openat(AT_FDCWD, "/etc/pam.d/other", O_RDONLY) = 3`

Cuando `su` termina leyendo `/etc/pam.d/other`, significa que falló en procesar los archivos anteriores o que la cadena de `@include` se rompió. En tu caso, tenés un archivo con formato de **Debian** (`common-auth`, `common-session`) en lo que debería ser un entorno de **Arch/Manjaro**. Si esos archivos `common-*` no existen o están vacíos por el desastre del `usrmerge`, PAM salta a `other`, que por seguridad suele estar configurado como `deny`.

Aquí tenés el archivo `/etc/pam.d/su` corregido al estilo estándar de Arch Linux, que es mucho más directo y evita los `@include` externos que parecen estar dándote problemas en este chroot.

### Archivo corregido: `/etc/pam.d/su`

Copiá y pegá esto (borrando todo lo anterior):

Fragmento de código

    #%PAM-1.0
    auth      sufficient  pam_rootok.so
    # Si querés que no pida pass a nadie (temporal para reparar), activá la siguiente:
    # auth    sufficient  pam_permit.so
    auth      required    pam_unix.so
    account   required    pam_unix.so
    session   required    pam_unix.so
    session   optional    pam_keyinit.so revoke
    session   optional    pam_mail.so standard

* * *

### ¿Por qué este y no el otro?

1.  **`#%PAM-1.0`**: Es la cabecera técnica necesaria.
    
2.  **`pam_rootok.so`**: Si sos root, te deja pasar sin más. Es la clave para que tu `su -` funcione.
    
3.  **`pam_unix.so`**: Reemplaza a los `@include common-*`. Valida contra `/etc/passwd` y `/etc/shadow` directamente sin depender de scripts externos de Debian que quizás estén rotos en tu "Frankeinux".
    
4.  **Eliminamos `pam_audit.so`**: Evitamos que el error de Netlink que vimos en el primer `strace` bloquee la entrada.
    

### Pasos para aplicar y verificar:

1.  **Escribí el archivo**:
    
    Bash
    
        nano /etc/pam.d/su
        # (Pegá el contenido de arriba, guardá y salí)
    
2.  **Verificá los archivos dependientes**: Como tu `su` buscó `su-l`, asegurate de que no haya un archivo que pise la configuración. Lo ideal es que `su-l` sea un symlink o no exista:
    
    Bash
    
        rm -f /etc/pam.d/su-l
        ln -s su /etc/pam.d/su-l
    
3.  **Probá la entrada**:
    
    Bash
    
        su -
    

### Si todavía falla...

Si después de esto sigue diciendo "Permission denied", el problema está en los permisos de lectura de los archivos de configuración. Asegurate de que PAM pueda leer sus propios archivos (ya que `su` pierde privilegios temporalmente para checkear):

Bash

    chmod 644 /etc/pam.d/su
    chmod 644 /etc/shadow
    chmod 644 /etc/passwd

**Dato extra:** En tu `strace` vi que busca `/usr/lib/security/pam_rootok.so`. Asegurate de que ese archivo realmente exista ahí: `ls -l /usr/lib/security/pam_rootok.so`. Si no existe, es porque el `usrmerge` movió las cosas a `/lib/security` y el link no está funcionando bien.

---

You asked:
----------

Has dicho

root@manjaro 2026-04-09 00:48:11 jueves /

 > su -

root@manjaro 2026-04-09 00:48:14 jueves ~

 > sudo su -

sudo: PAM account management error: Permiso denegado

sudo: a password is required

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

¡Excelente avance! Logramos que `su -` funcione, lo cual confirma que el archivo `/etc/pam.d/su` que armamos es correcto y que `pam_rootok.so` está haciendo su trabajo.

Ahora, el error con `sudo` es un síntoma clásico de un sistema **merged-usr** o **Frankeinux** donde la base de datos de cuentas (`account management`) está confundida. El error `PAM account management error` significa que `sudo` pudo autenticarte (sabe quién sos), pero al consultar si tu cuenta es "válida" (si no está expirada, si el shell es correcto, etc.), PAM rebota la consulta.

### El problema: `/etc/pam.d/sudo`

Al igual que con `su`, `sudo` en tu entorno probablemente esté intentando usar los `@include common-*` de Debian que no se llevan bien con el filesystem de Manjaro/Arch.

Vamos a aplicar la misma "limpieza quirúrgica" a `sudo`.

#### 1\. Corregir `/etc/pam.d/sudo`

Cambiá el contenido de `/etc/pam.d/sudo` por este bloque estándar y robusto:

Fragmento de código

    #%PAM-1.0
    auth      include   system-auth
    account   include   system-auth
    session   include   system-auth

**Pero ojo:** Si `system-auth` también está roto (porque apunta a los archivos `common-*`), lo más seguro para recuperar el control ahora mismo es usar este contenido **simplificado**:

Fragmento de código

    #%PAM-1.0
    auth      sufficient  pam_rootok.so
    auth      required    pam_unix.so
    account   required    pam_unix.so
    session   required    pam_unix.so

#### 2\. Verificar el archivo `nsswitch.conf`

Este archivo le dice al sistema de dónde sacar los usuarios. Si se dañó durante el `usrmerge`, `sudo` no sabe cómo validar la cuenta.

Bash

    cat /etc/nsswitch.conf

Asegurate de que las líneas de `passwd`, `group` y `shadow` digan `files`: `passwd: files` `group: files` `shadow: files`

#### 3\. El error de "password is required"

Si `sudo` te pide password siendo root, es porque no está encontrando el archivo de configuración de `sudoers` o PAM no está reconociendo tu sesión actual como privilegiada.

Revisá los permisos de `/etc/sudoers`:

Bash

    ls -l /etc/sudoers
    # Debe ser: -r--r----- 1 root root

Si por error tiene permisos de escritura o no es de root, `sudo` se bloquea por seguridad.

### ¿Por qué `su` funciona y `sudo` no?

`su` es un binario más "simple" que confía ciegamente en `pam_rootok.so` si el UID es 0. `sudo`, en cambio, es mucho más estricto con el **Account Management**; chequea el estado de la terminal, los límites del sistema y la persistencia de la sesión en `/run/systemd/`.

**Hacé esto ahora:**

1.  Aplicá el cambio en `/etc/pam.d/sudo`.
    
2.  Probá de nuevo.
    
3.  Si falla, tirá un: `ls -l /etc/pam.d/system-auth` para ver si ese archivo existe, ya que es el corazón de la autenticación en Arch.
    

Como ya tenés `su -` funcionando, ya tenés "las llaves del reino". Cualquier comando que antes hacías con `sudo`, ahora podés hacerlo directamente desde ese shell de root. ¿Hay algún paquete específico que necesites instalar ahora para terminar de estabilizar el sistema?

---

You asked:
----------

Has dicho

Quiero el archivo completo corregido.

  

 > cat /etc/nsswitch.conf

\# Name Service Switch configuration file.

\# See nsswitch.conf(5) for details.

  

passwd: files systemd

group: files \[SUCCESS=merge\] systemd

shadow: files systemd

gshadow: files systemd

  

publickey: files

  

hosts: mymachines resolve \[!UNAVAIL=return\] files myhostname dns

networks: files

  

protocols: files

services: files

ethers: files

rpc: files

  

netgroup: files

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Tu `nsswitch.conf` tiene un problema de herencia: está intentando usar el módulo `systemd` para validar cuentas, pero como tu sistema está en un estado de "Frankeinux" (con procesos muertos y en medio de un `usrmerge`), ese módulo falla porque no puede hablar con los daemons de `systemd` correspondientes.

Para que `sudo` (y cualquier otra herramienta) funcione de forma robusta ahora, necesitamos que el sistema sea **autónomo** y confíe únicamente en los archivos locales (`files`).

### 1\. Archivo corregido: `/etc/nsswitch.conf`

Reemplazá todo el contenido por este. He eliminado las dependencias de `systemd` y `resolve` que suelen causar bloqueos en entornos chroot o de recuperación:

Ini, TOML

    # /etc/nsswitch.conf corregido para recuperación
    passwd: files
    group: files
    shadow: files
    gshadow: files
    
    publickey: files
    
    # Simplificado para evitar que sudo se cuelgue buscando el hostname
    hosts: files dns
    networks: files
    
    protocols: files
    services: files
    ethers: files
    rpc: files
    
    netgroup: files

* * *

### 2\. Archivo corregido: `/etc/pam.d/sudo`

Como `sudo` te daba error de "Account management", vamos a darle una configuración que no dependa de archivos externos de Debian ni de la salud de `systemd`:

Fragmento de código

    #%PAM-1.0
    # Permitir a root (y a su propio shell de root) usar sudo sin trabas
    auth      sufficient  pam_rootok.so
    
    # Autenticación estándar
    auth      required    pam_unix.so
    account   required    pam_unix.so
    session   required    pam_unix.so
    
    # Opcional: para manejar variables de entorno básicas
    session   required    pam_env.so readenv=1

* * *

### 3\. El factor crítico: El grupo `wheel`

Si después de esto `sudo` te sigue pidiendo contraseña siendo root (o si intentás usarlo con tu usuario Eze), es porque PAM necesita saber si estás en el grupo autorizado.

Ejecutá esto para asegurar que el sistema no tenga dudas:

Bash

    usermod -aG wheel root
    # Y si tu usuario normal es eze:
    usermod -aG wheel eze

### 4\. Limpieza de basura en `/run`

Mencionaste un `killall`. Es muy probable que existan archivos de "bloqueo" o sockets muertos que confunden a PAM sobre si el usuario ya está logueado o no.

Bash

    # Borrar rastros de sesiones muertas que bloquean el account management
    rm -f /run/nologin
    rm -rf /run/systemd/seats/*
    rm -rf /run/systemd/sessions/*

* * *

**¿Qué sigue?** Una vez que pegues estos archivos, probá tirar un `sudo ls`.

*   Si funciona: Ya tenés la pila de autenticación operativa.
    
*   Si dice `sudo: command not found`: Es por el link de `/sbin` que vimos antes; asegurate de que `usr/bin` esté en tu `$PATH` (`export PATH=$PATH:/usr/bin`).
    

Como ya tenés acceso vía `su -`, mi recomendación es que aproveches para **reinstalar el grupo base de Manjaro** para que los symlinks y permisos de `/usr` se asienten definitivamente tras el desastre del `usrmerge`:

Bash

    pacman -Syu coreutils shadow pam pambase --noconfirm

---

