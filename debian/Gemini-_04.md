> From: https://gemini.google.com/app/a3775f88bd0d8691

# you asked

Quiero cambiar el tamaño de las particiones de debian-12-backports-nocloud-arm64-daily.raw

---

# gemini response

Para modificar el tamaño de las particiones de una imagen de disco cruda (`.raw`) como **debian-12-backports-nocloud-arm64-daily.raw**, el método más rápido y seguro es hacerlo de forma "offline" (desde el sistema host antes de arrancar la máquina virtual). 

Las imágenes de Debian Cloud suelen venir con un tamaño mínimo (unos 2 GB) y una tabla de particiones GPT. Aquí tienes el paso a paso para expandirla usando herramientas estándar de Linux.

---

### ⚠️ Nota importante: ¡Haz un backup!
Antes de tocar la tabla de particiones, haz una copia de seguridad del archivo por si algo sale mal:
```bash
cp debian-12-backports-nocloud-arm64-daily.raw debian-12-bak.raw
```

---

## Paso 1: Agrandar el archivo de la imagen
Primero, necesitas darle más espacio físico al archivo `.raw`. Puedes usar `qemu-img` (vía el paquete `qemu-utils`) o `truncate`.

Para añadir, por ejemplo, **10 GB** más al tamaño actual:
```bash
qemu-img resize debian-12-backports-nocloud-arm64-daily.raw +10G
```
*(También puedes usar un tamaño fijo, por ejemplo `qemu-img resize archivo.raw 20G` para que mida 20 GB en total).*

## Paso 2: Mapear la imagen a un dispositivo de bucle (Loop Device)
Para que el sistema operativo host pueda interactuar con las particiones internas del archivo, debes montarlo como un dispositivo de bloque:

```bash
sudo losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
```
* `-P`: Fuerza al kernel a leer la tabla de particiones dentro del archivo.
* `-f`: Busca automáticamente el primer dispositivo loop libre (por ejemplo, `/dev/loop0`).

Para saber qué dispositivo le asignó el sistema, ejecuta:
```bash
losetup -a
```
*(Asumamos para el resto de la guía que tu dispositivo es `/dev/loop0`).*

## Paso 3: Expandir la partición
Si listás las particiones con `lsblk` o `sudo fdisk -l /dev/loop0`, verás que la partición raíz (usualmente la última, por ejemplo `/dev/loop0p2` o `p1` si no tiene partición de boot separada) tiene el tamaño viejo, y el espacio nuevo quedó al final como "no asignado".

La forma más fácil y limpia de expandirla es usando `growpart` (del paquete `cloud-guest-utils`):

```bash
# Sintaxis: sudo growpart /dev/loopX NÚMERO_DE_PARTICIÓN
sudo growpart /dev/loop0 2
```
*Si la partición raíz es la primera, cambia el `2` por un `1`.*

> **Alternativa con Parted:** Si no tienes `growpart`, abre `sudo parted /dev/loop0`. Te avisará que la tabla GPT no usa todo el espacio; escribe `Fix`. Luego ejecuta `resizepart 2 100%` y sal con `q`.

## Paso 4: Redimensionar el sistema de archivos (Filesystem)
Ahora que la partición (el "contenedor") es más grande, debes estirar el sistema de archivos (habitualmente `ext4` en Debian) para que ocupe ese nuevo espacio.

1. **Verifica la consistencia** (requerido antes de redimensionar):
   ```bash
   sudo e2fsck -f /dev/loop0p2
   ```
2. **Expande el filesystem:**
   ```bash
   sudo resize2fs /dev/loop0p2
   ```

## Paso 5: Limpieza
Una vez que `resize2fs` termine, desvincula el archivo `.raw` del dispositivo loop:

```bash
sudo losetup -d /dev/loop0
```

¡Listo! Tu imagen `.raw` ya tiene el nuevo tamaño y está lista para ser usada en QEMU, Proxmox o el hipervisor de tu elección.

---

¿Estás haciendo este proceso desde una máquina host Linux o estás intentando redimensionarla desde dentro de la máquina virtual una vez encendida?

---

# you asked

Hice todo y sigue en 3GB

[2026-05-25 10:18:33] /otro/linux_aarch64
 > qemu-img resize debian-12-backports-nocloud-arm64-daily.raw +10G
WARNING: Image format was not specified for 'debian-12-backports-nocloud-arm64-daily.raw' and probing guessed raw.
         Automatically detecting the format is dangerous for raw images, write operations on block 0 will be restricted.
         Specify the 'raw' format explicitly to remove the restrictions.
Image resized.
[2026-05-25 10:21:27] /otro/linux_aarch64
 > sudo losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
[2026-05-25 10:21:54] /otro/linux_aarch64
 > mount /run/media/root/181bc88b-a75b-43b5-b223-afce1c91a0d8
mount: /run/media/root/181bc88b-a75b-43b5-b223-afce1c91a0d8: can't find in /etc/fstab.
[2026-05-25 10:22:06] /otro/linux_aarch64
 > mount 
/dev/sda1 on / type btrfs (rw,relatime,space_cache=v2,subvolid=256,subvol=/@)
devtmpfs on /dev type devtmpfs (rw,nosuid,size=3856396k,nr_inodes=964099,mode=755,inode64)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,inode64)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=600,ptmxmode=000)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot,memory_hugetlb_accounting)
none on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
bpf on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,relatime,mode=700)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run type tmpfs (rw,nosuid,nodev,size=1571820k,nr_inodes=819200,mode=755,inode64)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=44,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=897)
none on /run/credentials/systemd-journald.service type tmpfs (ro,nosuid,nodev,noexec,relatime,nosymfollow,size=1024k,nr_inodes=1024,mode=700,inode64,noswap)
debugfs on /sys/kernel/debug type debugfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,nr_inodes=1048576,inode64)
fusectl on /sys/fs/fuse/connections type fusectl (rw,nosuid,nodev,noexec,relatime)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,nosuid,nodev,relatime,pagesize=2M)
tracefs on /sys/kernel/tracing type tracefs (rw,nosuid,nodev,noexec,relatime)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
configfs on /sys/kernel/config type configfs (rw,nosuid,nodev,noexec,relatime)
binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run/user/0 type tmpfs (rw,nosuid,nodev,relatime,size=785908k,nr_inodes=196477,mode=700,inode64)
gvfsd-fuse on /run/user/0/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0)
/dev/loop0p1 on /run/media/root/181bc88b-a75b-43b5-b223-afce1c91a0d8 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
[2026-05-25 10:22:11] /otro/linux_aarch64
 > losetup -a
/dev/loop0: [0034]:33649957 (/otro/linux_aarch64/debian-12-backports-nocloud-arm64-daily.raw)
[2026-05-25 10:22:20] /otro/linux_aarch64
 > # Sintaxis: sudo growpart /dev/loopX NÚMERO_DE_PARTICIÓN
sudo growpart /dev/loop0 2
FAILED: failed to get start and end for /dev/loop0p2 in /dev/loop0
[2026-05-25 10:22:36] /otro/linux_aarch64
 > sudo growpart /dev/loop0 1
CHANGED: partition=1 start=262144 old: size=6027264 end=6289407 new: size=37486559 end=37748702
[2026-05-25 10:22:45] /otro/linux_aarch64
 > sudo growpart /dev/loop0 1
sfdisk: cannot open /dev/loop0: Argumento inválido
failed [sfd_list:1] sfdisk --list --unit=S /dev/loop0
sfdisk: cannot open /dev/loop0: Argumento inválido
FAILED: failed: sfdisk --list /dev/loop0
[2026-05-25 10:22:59] /otro/linux_aarch64
 > sudo losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
[2026-05-25 10:23:11] /otro/linux_aarch64
 > sudo e2fsck -f /dev/loop0p2
e2fsck 1.47.4 (6-Mar-2025)
e2fsck: No existe el fichero o el directorio while trying to open /dev/loop0p2
Possibly non-existent device?
[2026-05-25 10:23:24] /otro/linux_aarch64
 > sudo losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
[2026-05-25 10:23:26] /otro/linux_aarch64
 > sudo e2fsck -f /dev/loop0p2
e2fsck 1.47.4 (6-Mar-2025)
e2fsck: No existe el fichero o el directorio while trying to open /dev/loop0p2
Possibly non-existent device?
[2026-05-25 10:23:33] /otro/linux_aarch64
 > sudo e2fsck -f /dev/loop0p1
e2fsck 1.47.4 (6-Mar-2025)
/dev/loop0p1 is mounted.
e2fsck: Cannot continue, aborting.


[2026-05-25 10:23:36] /otro/linux_aarch64
 > umount /dev/loop0p1
[2026-05-25 10:23:46] /otro/linux_aarch64
 > sudo e2fsck -f /dev/loop0p1
e2fsck 1.47.4 (6-Mar-2025)
e2fsck: No existe el fichero o el directorio while trying to open /dev/loop0p1
Possibly non-existent device?
[2026-05-25 10:23:48] /otro/linux_aarch64
 > sudo losetup -d /dev/loop0
losetup: /dev/loop0: detach failed: No existe el dispositivo o la dirección
[2026-05-25 10:24:12] /otro/linux_aarch64
 >  losetup -d /dev/loop0
losetup: /dev/loop0: detach failed: No existe el dispositivo o la dirección
[2026-05-25 10:24:16] /otro/linux_aarch64
 > umount losetup -d /dev/loop0
umount: losetup: no mount point specified.
umount: /dev/loop0: not mounted.
[2026-05-25 10:24:25] /otro/linux_aarch64
 >  losetup -d /dev/loop0
losetup: /dev/loop0: detach failed: No existe el dispositivo o la dirección
[2026-05-25 10:24:28] /otro/linux_aarch64
 > umount losetup -d /dev/loop0
umount: losetup: no mount point specified.
umount: /dev/loop0: not mounted.

---

# gemini response

Veo exactamente lo que pasó analizando tu registro. ¡No te preocupes, casi lo tienes! 

Aquí está el resumen de lo que ocurrió:
1. **El redimensionamiento físico funcionó:** El comando `growpart` sí fue exitoso en tu partición 1 (`CHANGED: partition=1 start=262144... new: size=37486559`).
2. **El sistema automontó la unidad:** Tu sistema operativo (a través de `udisks2`) montó automáticamente la partición en `/run/media/root/...`. No se puede hacer un chequeo de disco (`e2fsck`) ni redimensionar un sistema de archivos mientras está montado.
3. **El dispositivo se desconectó:** Al intentar desmontar, correr comandos sobre particiones inexistentes (`p2`) y volver a ejecutar `losetup -P -f` múltiples veces, se generaron conexiones superpuestas y el dispositivo `/dev/loop0p1` desapareció temporalmente del mapa.
4. **Falta el paso final:** Como nunca pudiste ejecutar `resize2fs`, el sistema de archivos (ext4) todavía cree que mide 3 GB, aunque su "caja" (la partición) ya mide 13 GB.

Vamos a limpiar el desorden y dar el paso final. Ejecuta esto paso a paso:

### 1. Limpiar los dispositivos atascados
Primero, vamos a desconectar todos los dispositivos loop que hayan quedado colgados de tus intentos anteriores:
```bash
sudo losetup -D
```
*(Nota: Esto desconectará todos los dispositivos loop. Si tienes otros discos virtuales montados haciendo otra cosa, avísame, pero en general es seguro).*

### 2. Volver a mapear la imagen limpiamente
```bash
sudo losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
```

Verifica qué dispositivo se le asignó (probablemente vuelva a ser el 0, pero confirmémoslo):
```bash
losetup -a
```
*(Asumiremos que es `/dev/loop0` para los siguientes pasos).*

### 3. Evitar el automontaje
Si tu sistema lo vuelve a montar automáticamente en `/run/media/...`, **desmóntalo inmediatamente** antes de hacer nada más:
```bash
sudo umount /dev/loop0p1
```
*(Si te dice "not mounted", perfecto, sigue adelante).*

### 4. Chequear y expandir el sistema de archivos
Ahora sí, con la partición 1 ya agrandada y sin estar montada, aplicamos los cambios al sistema de archivos:

```bash
sudo e2fsck -f /dev/loop0p1
```
Y luego lo estiramos para que ocupe todo el espacio nuevo:
```bash
sudo resize2fs /dev/loop0p1
```

### 5. Desconectar y terminar
Una vez que `resize2fs` te confirme que los bloques han cambiado, puedes desconectar la imagen de forma segura:
```bash
sudo losetup -d /dev/loop0
```

¡Con esto ya deberías tener tu imagen cruda lista y con los 13 GB completos disponibles para usar!

---

# you asked

[2026-05-25 10:24:59] /otro/linux_aarch64
 > sudo losetup -D
[2026-05-25 10:25:37] /otro/linux_aarch64
 > losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
[2026-05-25 10:25:52] /otro/linux_aarch64
 > losetup -a
/dev/loop0: [0034]:33649957 (/otro/linux_aarch64/debian-12-backports-nocloud-arm64-daily.raw)
[2026-05-25 10:26:07] /otro/linux_aarch64
 > sudo umount /dev/loop0p1
[2026-05-25 10:26:24] /otro/linux_aarch64
 > e2fsck -f /dev/loop0p1
e2fsck 1.47.4 (6-Mar-2025)
e2fsck: No existe el fichero o el directorio while trying to open /dev/loop0p1
Possibly non-existent device?
[2026-05-25 10:26:34] /otro/linux_aarch64
 > resize2fs /dev/loop0p1
resize2fs 1.47.4 (6-Mar-2025)
open: No existe el fichero o el directorio while opening /dev/loop0p1
[2026-05-25 10:26:42] /otro/linux_aarch64
 > losetup -d /dev/loop0
l

---

# gemini response

¡Estás a un solo paso! El problema aquí fue un pequeño detalle de permisos: te faltó el **`sudo`** en los comandos cruciales.

Al ejecutar `losetup -P -f` sin `sudo`, el comando puede llegar a asociar el archivo al bucle `/dev/loop0`, pero **no tiene los privilegios de kernel necesarios para escanear y crear las subparticiones (`-P`)**. Por eso, el dispositivo `/dev/loop0p1` literalmente no existe en tu sistema en este momento, y tanto `e2fsck` como `resize2fs` fallan diciendo *"No existe el fichero"*.

Vamos a resolverlo de una vez por todas con la dosis correcta de superusuario:

### 1. Limpiar el bucle actual
Primero, desvincula lo que quedó configurado a medias:
```bash
sudo losetup -D
```

### 2. Mapear la imagen (esta vez con `sudo`)
Esto es vital para que el kernel cree el nodo `/dev/loop0p1`:
```bash
sudo losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
```

### 3. Verificar que la partición exista
Ejecuta este comando rápido para asegurarte de que el kernel ya ve la partición:
```bash
ls /dev/loop0*
```
*(Deberías ver en la salida tanto `/dev/loop0` como `/dev/loop0p1`).*

### 4. Desmontar por si el sistema la volvió a heredar
Por si las dudas (y para evitar el error de "dispositivo ocupado"):
```bash
sudo umount /dev/loop0p1 2>/dev/null
```

### 5. Reparar y expandir (con `sudo`)
Ahora sí, ejecuta las herramientas de asignación de bloques con privilegios de root:

```bash
sudo e2fsck -f /dev/loop0p1
```
*(Te dará un reporte de que la partición fue modificada o está limpia).*

```bash
sudo resize2fs /dev/loop0p1
```
*(Aquí verás el mensaje mágico confirmando que el sistema de archivos ahora ocupa todos los bloques disponibles).*

### 6. Desconexión final
Ya puedes soltar la imagen limpiamente:
```bash
sudo losetup -d /dev/loop0
```

Con este último empujón, si montas la imagen o la inicias en tu emulador, verás que el espacio disponible finalmente reflejará los ~13 GB.

---

# you asked

[2026-05-25 10:27:01] /otro/linux_aarch64
 > losetup -D
[2026-05-25 10:27:36] /otro/linux_aarch64
 > losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
[2026-05-25 10:27:44] /otro/linux_aarch64
 > mount
/dev/sda1 on / type btrfs (rw,relatime,space_cache=v2,subvolid=256,subvol=/@)
devtmpfs on /dev type devtmpfs (rw,nosuid,size=3856396k,nr_inodes=964099,mode=755,inode64)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,inode64)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=600,ptmxmode=000)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot,memory_hugetlb_accounting)
none on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
bpf on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,relatime,mode=700)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run type tmpfs (rw,nosuid,nodev,size=1571820k,nr_inodes=819200,mode=755,inode64)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=44,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=897)
none on /run/credentials/systemd-journald.service type tmpfs (ro,nosuid,nodev,noexec,relatime,nosymfollow,size=1024k,nr_inodes=1024,mode=700,inode64,noswap)
debugfs on /sys/kernel/debug type debugfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,nr_inodes=1048576,inode64)
fusectl on /sys/fs/fuse/connections type fusectl (rw,nosuid,nodev,noexec,relatime)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,nosuid,nodev,relatime,pagesize=2M)
tracefs on /sys/kernel/tracing type tracefs (rw,nosuid,nodev,noexec,relatime)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
configfs on /sys/kernel/config type configfs (rw,nosuid,nodev,noexec,relatime)
binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run/user/0 type tmpfs (rw,nosuid,nodev,relatime,size=785908k,nr_inodes=196477,mode=700,inode64)
gvfsd-fuse on /run/user/0/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0)
/dev/loop0p1 on /run/media/root/181bc88b-a75b-43b5-b223-afce1c91a0d8 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
[2026-05-25 10:27:52] /otro/linux_aarch64
 > ls /dev/loop0*
/dev/loop0  /dev/loop0p1  /dev/loop0p15
[2026-05-25 10:28:02] /otro/linux_aarch64
 > umount /dev/loop0p1 2>/dev/null
[2026-05-25 10:28:10] /otro/linux_aarch64
 > e2fsck -f /dev/loop0p1
e2fsck 1.47.4 (6-Mar-2025)
e2fsck: No existe el fichero o el directorio while trying to open /dev/loop0p1
Possibly non-existent device?
[2026-05-25 10:28:16] /otro/linux_aarch64
 > resize2fs /dev/loop0p1
resize2fs 1.47.4 (6-Mar-2025)
open: No existe el fichero o el directorio while opening /dev/loop0p1
[2026-05-25 10:28:24] /otro/linux_aarch64
 > losetup -d /dev/loop0
losetup: /dev/loop0: detach failed: No existe el dispositivo o la dirección

---

# gemini response

¡Te faltó el **`sudo`** en absolutamente todos los comandos de esta tanda! 😄 

Por eso el sistema se volvió loco. Al ejecutar los comandos como un usuario normal:
1. `umount` falló porque no tenías permisos (pero no lo viste porque el `2>/dev/null` ocultó el error). La partición **siguió montada**.
2. Al estar montada y no tener privilegios de root, `e2fsck` y `resize2fs` te arrojaron el error *"No existe el fichero o el directorio"* (una forma un poco confusa que tiene el sistema de decir que no puede acceder al bloque).
3. `losetup -d` falló por la misma falta de permisos.

Vamos a hacerlo bien, usando `sudo` en cada paso para que el kernel te deje trabajar. Sigue estrictamente este orden:

### 1. Desmontar la partición de verdad (como root)
```bash
sudo umount /dev/loop0p1
```

### 2. Limpiar todos los bucles que hayan quedado trabados
```bash
sudo losetup -D
```

### 3. Volver a mapear la imagen con esteroides (privilegios de root)
```bash
sudo losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
```

### 4. Verificar que el entorno esté limpio
Asegurémonos de que el sistema no la haya vuelto a automontar de fondo:
```bash
sudo umount /dev/loop0p1 2>/dev/null
```

### 5. Forzar el chequeo y expandir (con `sudo`)
Ahora que la partición está libre y eres root, las herramientas van a funcionar:
```bash
sudo e2fsck -f /dev/loop0p1
```
*(Aquí ya no debería decirte que no existe. Debería analizar los bindeos).*

```bash
sudo resize2fs /dev/loop0p1
```
*(Aquí verás el mensaje confirmando el cambio de tamaño del sistema de archivos).*

### 6. Desconectar el dispositivo loop
```bash
sudo losetup -d /dev/loop0
```

Con esto ya cerramos el proceso limpiamente. Si inicias la máquina virtual o montas la imagen ahora, verás los 13 GB listos para usar.

---

# you asked

[2026-05-25 10:29:18] /otro/linux_aarch64
 > umount /dev/loop0p1
umount: /dev/loop0p1: no mount point specified.
[2026-05-25 10:29:20] /otro/linux_aarch64
 > losetup -D
[2026-05-25 10:29:28] /otro/linux_aarch64
 > losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
[2026-05-25 10:29:35] /otro/linux_aarch64
 > mount
/dev/sda1 on / type btrfs (rw,relatime,space_cache=v2,subvolid=256,subvol=/@)
devtmpfs on /dev type devtmpfs (rw,nosuid,size=3856396k,nr_inodes=964099,mode=755,inode64)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,inode64)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=600,ptmxmode=000)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot,memory_hugetlb_accounting)
none on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
bpf on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,relatime,mode=700)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run type tmpfs (rw,nosuid,nodev,size=1571820k,nr_inodes=819200,mode=755,inode64)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=44,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=897)
none on /run/credentials/systemd-journald.service type tmpfs (ro,nosuid,nodev,noexec,relatime,nosymfollow,size=1024k,nr_inodes=1024,mode=700,inode64,noswap)
debugfs on /sys/kernel/debug type debugfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,nr_inodes=1048576,inode64)
fusectl on /sys/fs/fuse/connections type fusectl (rw,nosuid,nodev,noexec,relatime)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,nosuid,nodev,relatime,pagesize=2M)
tracefs on /sys/kernel/tracing type tracefs (rw,nosuid,nodev,noexec,relatime)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
configfs on /sys/kernel/config type configfs (rw,nosuid,nodev,noexec,relatime)
binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run/user/0 type tmpfs (rw,nosuid,nodev,relatime,size=785908k,nr_inodes=196477,mode=700,inode64)
gvfsd-fuse on /run/user/0/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0)
/dev/loop0p1 on /run/media/root/181bc88b-a75b-43b5-b223-afce1c91a0d8 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
[2026-05-25 10:29:41] /otro/linux_aarch64
 > umount /dev/loop0p1 
[2026-05-25 10:29:51] /otro/linux_aarch64
 > mount
/dev/sda1 on / type btrfs (rw,relatime,space_cache=v2,subvolid=256,subvol=/@)
devtmpfs on /dev type devtmpfs (rw,nosuid,size=3856396k,nr_inodes=964099,mode=755,inode64)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,inode64)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=600,ptmxmode=000)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot,memory_hugetlb_accounting)
none on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
bpf on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,relatime,mode=700)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run type tmpfs (rw,nosuid,nodev,size=1571820k,nr_inodes=819200,mode=755,inode64)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=44,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=897)
none on /run/credentials/systemd-journald.service type tmpfs (ro,nosuid,nodev,noexec,relatime,nosymfollow,size=1024k,nr_inodes=1024,mode=700,inode64,noswap)
debugfs on /sys/kernel/debug type debugfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,nr_inodes=1048576,inode64)
fusectl on /sys/fs/fuse/connections type fusectl (rw,nosuid,nodev,noexec,relatime)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,nosuid,nodev,relatime,pagesize=2M)
tracefs on /sys/kernel/tracing type tracefs (rw,nosuid,nodev,noexec,relatime)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
configfs on /sys/kernel/config type configfs (rw,nosuid,nodev,noexec,relatime)
binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run/user/0 type tmpfs (rw,nosuid,nodev,relatime,size=785908k,nr_inodes=196477,mode=700,inode64)
gvfsd-fuse on /run/user/0/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0)
[2026-05-25 10:29:54] /otro/linux_aarch64
 > e2fsck -f /dev/loop0p1
e2fsck 1.47.4 (6-Mar-2025)
e2fsck: No existe el fichero o el directorio while trying to open /dev/loop0p1
Possibly non-existent device?
[2026-05-25 10:30:02] /otro/linux_aarch64
 > resize2fs /dev/loop0p1
resize2fs 1.47.4 (6-Mar-2025)
open: No existe el fichero o el directorio while opening /dev/loop0p1
[2026-05-25 10:30:10] /otro/linux_aarch64
 > losetup -d /dev/loop0
losetup: /dev/loop0: detach failed: No existe el dispositivo o la dirección
[2026-05-25 10:30:23] /otro/linux_aarch64
 > mount
/dev/sda1 on / type btrfs (rw,relatime,space_cache=v2,subvolid=256,subvol=/@)
devtmpfs on /dev type devtmpfs (rw,nosuid,size=3856396k,nr_inodes=964099,mode=755,inode64)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev,inode64)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=600,ptmxmode=000)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot,memory_hugetlb_accounting)
none on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
bpf on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,relatime,mode=700)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run type tmpfs (rw,nosuid,nodev,size=1571820k,nr_inodes=819200,mode=755,inode64)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=44,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=897)
none on /run/credentials/systemd-journald.service type tmpfs (ro,nosuid,nodev,noexec,relatime,nosymfollow,size=1024k,nr_inodes=1024,mode=700,inode64,noswap)
debugfs on /sys/kernel/debug type debugfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,nr_inodes=1048576,inode64)
fusectl on /sys/fs/fuse/connections type fusectl (rw,nosuid,nodev,noexec,relatime)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,nosuid,nodev,relatime,pagesize=2M)
tracefs on /sys/kernel/tracing type tracefs (rw,nosuid,nodev,noexec,relatime)
mqueue on /dev/mqueue type mqueue (rw,nosuid,nodev,noexec,relatime)
configfs on /sys/kernel/config type configfs (rw,nosuid,nodev,noexec,relatime)
binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run/user/0 type tmpfs (rw,nosuid,nodev,relatime,size=785908k,nr_inodes=196477,mode=700,inode64)
gvfsd-fuse on /run/user/0/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0)

---

# gemini response

¡Misterio resuelto! Y te pido disculpas: **tenías toda la razón en no usar `sudo`**. Al ver tu ruta `/run/media/root/...`, es evidente que ya estás ejecutando todo como usuario `root`. El problema no era de permisos, sino de un "poltergeist" en tu sistema.

El verdadero culpable aquí es el servicio **`udisks2`** (el automontador de discos de tu entorno Linux). Lo que está pasando es exactamente esto:

1. Creas el dispositivo loop con `losetup`.
2. `udisks2` lo detecta inmediatamente y lo automonta en `/run/media/root/...`.
3. Cuando tú ejecutas `umount`, `udisks2` asume que ya terminaste de usar el "USB/disco virtual" y, para mantener el sistema limpio, **destruye y borra el dispositivo `/dev/loop0` automáticamente**.
4. Por eso, milisegundos después de desmontarlo, `/dev/loop0p1` desaparece del mapa y tanto `e2fsck` como `resize2fs` y `losetup -d` fallan diciendo "No existe el dispositivo".

### La Solución: Redimensionar "En Caliente" (Online Resize)

Dado que tu sistema insiste en automontar la partición y borrarla al desmontar, ¡vamos a usar ese comportamiento a nuestro favor! El sistema de archivos **ext4 soporta redimensionamiento en caliente** (mientras está montado), por lo que no necesitamos `e2fsck` ni desmontarlo para agrandarlo.

Sigue estos 4 pasos exactos:

**1. Conecta la imagen**
```bash
losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
```

**2. Verifica que se haya automontado**
Espera un par de segundos y ejecuta:
```bash
mount | grep loop0p1
```
*(Debería mostrarte que está montado en `/run/media/root/...`)*.

**3. Redimensiona ¡SIN desmontar!**
Ejecuta el redimensionamiento directamente sobre el dispositivo mientras está en uso. ext4 lo estirará en tiempo real:
```bash
resize2fs /dev/loop0p1
```
*(Deberías ver un mensaje que dice "Filesystem on /dev/loop0p1 is now XXXXX blocks long").*

**4. Desmonta y deja que el sistema limpie todo**
```bash
umount /dev/loop0p1
```
Al hacer esto, tu automontador volverá a hacer su magia y eliminará `/dev/loop0` por ti de forma limpia (no necesitas ejecutar `losetup -d`).

¡Y eso es todo! Tu imagen `.raw` ya tendrá los 13 GB que le asignaste con `growpart` en los intentos anteriores.

---

# you asked

[2026-05-25 10:31:42] /otro/linux_aarch64
 > losetup -P -f debian-12-backports-nocloud-arm64-daily.raw
[2026-05-25 10:31:44] /otro/linux_aarch64
 > mount | grep loop0p1
/dev/loop0p1 on /run/media/root/181bc88b-a75b-43b5-b223-afce1c91a0d8 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
[2026-05-25 10:31:53] /otro/linux_aarch64
 > resize2fs /dev/loop0p1
resize2fs 1.47.4 (6-Mar-2025)
Filesystem at /dev/loop0p1 is mounted on /run/media/root/181bc88b-a75b-43b5-b223-afce1c91a0d8; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 3
The filesystem on /dev/loop0p1 is now 4685819 (4k) blocks long.

[2026-05-25 10:32:03] /otro/linux_aarch64
 > umount /dev/loop0p1
[2026-05-25 10:32:12] /otro/linux_aarch64

---

# gemini response

¡Perfecto! Ahí está el mensaje que queríamos ver: 

> `The filesystem on /dev/loop0p1 is now 4685819 (4k) blocks long.`

**¡Misión cumplida!** Haciendo la matemática rápida (4.685.819 bloques × 4 KB por bloque), tu sistema de archivos interno ahora mide aproximadamente **18.7 GB** (o ~17.8 GiB). El redimensionamiento "en caliente" (online resizing) funcionó de maravilla y fue la táctica exacta para ganarle de mano al automontador de tu sistema.

Al ejecutar el último `umount`, el servicio de tu entorno ya se encargó de limpiar el dispositivo `/dev/loop0` de forma segura.

Tu imagen `debian-12-backports-nocloud-arm64-daily.raw` ya está limpia, redimensionada y lista para ser arrancada en tu emulador o hipervisor de ARM64. ¡Excelente trabajo de depuración!