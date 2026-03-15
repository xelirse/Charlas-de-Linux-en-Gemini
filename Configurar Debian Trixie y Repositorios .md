You asked:
----------

Has dicho

Quiero configurarlo para trixie.

  

Error: No se ha podido localizar el paquete apt

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Vaya, ese error es un clásico "momento de pánico", pero no te preocupes: tiene una explicación lógica. El paquete `apt` es el corazón del sistema; si realmente no estuviera, no podrías ni haber ejecutado el comando para buscarlo.

Lo más probable es que estés intentando instalar algo llamado `apt` (que ya viene preinstalado) o que tu archivo de fuentes (`sources.list`) esté vacío o apuntando a una versión antigua que no reconoce a **Trixie** (Debian 13, la actual versión _Testing_ en 2026).

Aquí tienes cómo poner orden para que tu sistema apunte correctamente a Trixie:

* * *

1\. Verifica tu archivo de fuentes
----------------------------------

Para pasarte a Trixie, debes editar el archivo donde Debian busca los programas. Ejecuta este comando:

Bash

    sudo nano /etc/apt/sources.list

2\. Configura los repositorios de Trixie
----------------------------------------

Borra lo que haya (o coméntalo con `#`) y asegúrate de que aparezcan estas líneas. Al ser la versión _testing_, la estructura es así:

*   `deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware`
    
*   `deb-src http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware`
    
*   `deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware`
    

> **Nota importante:** En 2026, Trixie ya debería estar cerca de ser la nueva estable, pero asegúrate de incluir `non-free-firmware` para evitar problemas con drivers de WiFi o video.

3\. Actualiza el índice
-----------------------

Una vez guardado el archivo (Ctrl+O, Enter, Ctrl+X), limpia y actualiza:

Bash

    sudo apt clean
    sudo apt update

4\. El "Gran Salto" (Upgrade)
-----------------------------

Si estás saltando desde Bookworm (Debian 12) a Trixie, no uses solo `upgrade`. Usa:

Bash

    sudo apt dist-upgrade

* * *

¿Por qué te salía ese error?
----------------------------

Generalmente ocurre por dos razones:

1.  **Error de sintaxis:** Escribiste algo como `apt install apt` (lo cual es redundante).
    
2.  **Repositorios rotos:** Si el `sources.list` tiene errores, `apt` se "ciega" y no encuentra nada, ni siquiera a sí mismo en las listas.
    

**¿Te gustaría que te ayude a verificar si tienes algún paquete roto o prefieres que revisemos la configuración de tu tarjeta de video tras el cambio a Trixie?**

Has parado esta respuesta

---

You asked:
----------

Has dicho

\[manjaro core\_generado\_chroot\]# apt install apt

Error: No se ha podido localizar el paquete apt

\[manjaro core\_generado\_chroot\]# sudo nano /etc/apt/sources.list

\[manjaro core\_generado\_chroot\]# sudo apt clean

sudo apt update

Des:1 http://security.debian.org/debian-security trixie-security InRelease \[43,4 kB\]

Des:2 http://deb.debian.org/debian trixie InRelease \[140 kB\]   

Err:1 http://security.debian.org/debian-security trixie-security InRelease

 The signatures couldn't be verified because no keyring is specified

Err:2 http://deb.debian.org/debian trixie InRelease

 The signatures couldn't be verified because no keyring is specified

Advertencia: Falló la verificación de firma OpenPGP: http://security.debian.org/debian-security trixie-securit

y InRelease: The signatures couldn't be verified because no keyring is specified

Error: El repositorio «http://security.debian.org/debian-security trixie-security InRelease» no está firmado.

Información: No se puede actualizar de un repositorio como este de forma segura y por tanto está deshabilitado

por omisión.

Información: Vea la página de manual apt-secure(8) para los detalles sobre la creación de repositorios y la co

nfiguración de usuarios.

Advertencia: Falló la verificación de firma OpenPGP: http://deb.debian.org/debian trixie InRelease: The signat

ures couldn't be verified because no keyring is specified

Error: El repositorio «http://deb.debian.org/debian trixie InRelease» no está firmado.

Información: No se puede actualizar de un repositorio como este de forma segura y por tanto está deshabilitado

por omisión.

Información: Vea la página de manual apt-secure(8) para los detalles sobre la creación de repositorios y la co

nfiguración de usuarios.

Información: Algunas fuentes se pueden modernizar. Ejecute «apt modernize-sources» para hacerlo.

\[manjaro core\_generado\_chroot\]# apt modernize-sources

The following files need modernizing:

 - /etc/apt/sources.list

  

Modernizing will replace .list files with the new .sources format,

add Signed-By values where they can be determined automatically,

and save the old files into .list.bak files.

  

This command supports the 'signed-by' and 'trusted' options. If you

have specified other options inside \[\] brackets, please transfer them

manually to the output files; see sources.list(5) for a mapping.

  

For a simulation, respond N in the following prompt.

¿Reescribir las fuentes 1? \[S/n\]  

Modernizing /etc/apt/sources.list...

\- Writing /etc/apt/sources.list.d/moved-from-main.sources

Advertencia: Could not determine Signed-By for URIs: http://deb.debian.org/debian/, Suites: trixie

Advertencia: Could not determine Signed-By for URIs: http://security.debian.org/debian-security/, Suites: trix

ie-security

  

\[manjaro core\_generado\_chroot\]# sudo apt dist-upgrade

Resumen:                              

 Actualizando: 0, Instalando 0, Eliminando: 0, no actualizando: 0

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

El problema es que estás atrapado en un círculo vicioso: tu sistema no confía en los repositorios de Debian porque no tiene instaladas las "llaves" (el **keyring**), pero no puedes instalar el paquete de llaves porque el sistema no confía en el repositorio.

Además, al estar en un entorno **chroot** desde Manjaro, el sistema está "desnudo". El error "No se ha podido localizar el paquete apt" al principio confirma que las listas de paquetes están vacías o son ilegibles por la falta de firmas.

Aquí tienes los pasos para romper el bloqueo:

* * *

1\. Forzar la actualización ignorando las firmas (Temporal)
-----------------------------------------------------------

Para poder bajar las llaves, primero debemos decirle a `apt` que confíe en el repositorio _solo por esta vez_. Ejecuta:

Bash

    apt update --allow-insecure-repositories

2\. Instalar el llavero de Debian
---------------------------------

Una vez que `apt` pueda leer las listas (aunque se queje de la seguridad), instala el paquete que contiene las firmas oficiales:

Bash

    apt install debian-archive-keyring --allow-unauthenticated

3\. Corregir el formato de fuentes
----------------------------------

Como usaste `apt modernize-sources`, ahora tus fuentes están en `/etc/apt/sources.list.d/moved-from-main.sources`. Vamos a editarlas para que apunten correctamente al llavero que acabas de instalar:

1.  Abre el archivo: `nano /etc/apt/sources.list.d/moved-from-main.sources`
    
2.  Asegúrate de que las rutas sean correctas y añade la instrucción `Signed-By` si el comando anterior no lo hizo. Debería verse algo así:
    

Plaintext

    Types: deb
    URIs: http://deb.debian.org/debian/
    Suites: trixie
    Components: main contrib non-free non-free-firmware
    Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

4\. Actualización definitiva
----------------------------

Ahora que ya tienes las llaves en su sitio, el sistema debería funcionar con normalidad y de forma segura:

Bash

    apt update
    apt dist-upgrade

* * *

Un detalle sobre el chroot
--------------------------

Si después de esto sigues viendo que "no encuentra" paquetes básicos como `apt`, es posible que tu base de datos de dpkg esté corrupta o el chroot no se haya creado con las herramientas de Debian (como `debootstrap`).

**¿Cómo creaste el directorio `core_generado_chroot`?** Si lo hiciste manualmente copiando archivos, te faltarán dependencias críticas que `apt` necesita para funcionar.

Has parado esta respuesta

---

You asked:
----------

Has dicho

\[manjaro core\_generado\_chroot\]# apt update --allow-insecure-repositories

Des:1 http://deb.debian.org/debian trixie InRelease \[140 kB\]

Des:2 http://security.debian.org/debian-security trixie-security InRelease \[43,4 kB\]

Ign:2 http://security.debian.org/debian-security trixie-security InRelease

Ign:1 http://deb.debian.org/debian trixie InRelease

Descargados 184 kB en 2s (102 kB/s)

Todos los paquetes están actualizados.

Advertencia: Falló la verificación de firma OpenPGP: http://security.debian.org/debian-security trixie-securit

y InRelease: The signatures couldn't be verified because no keyring is specified

Advertencia: El repositorio «http://security.debian.org/debian-security trixie-security InRelease» no está fir

mado.

Información: Los datos de un repositorio como este no se pueden autenticar y por tanto su uso es potencialment

e peligroso.

Información: Vea la página de manual apt-secure(8) para los detalles sobre la creación de repositorios y la co

nfiguración de usuarios.

Advertencia: Falló la verificación de firma OpenPGP: http://deb.debian.org/debian trixie InRelease: The signat

ures couldn't be verified because no keyring is specified

Advertencia: El repositorio «http://deb.debian.org/debian trixie InRelease» no está firmado.

Información: Los datos de un repositorio como este no se pueden autenticar y por tanto su uso es potencialment

e peligroso.

Información: Vea la página de manual apt-secure(8) para los detalles sobre la creación de repositorios y la co

nfiguración de usuarios.

Información: Hace falta «Signed-By» en la entrada sources.list(5) para «http://deb.debian.org/debian»

Información: Hace falta «Signed-By» en la entrada sources.list(5) para «http://security.debian.org/debian-secu

rity»

\[manjaro core\_generado\_chroot\]# apt install debian-archive-keyring --allow-unauthenticated

Instalando:                            

 debian-archive-keyring

  

Resumen:

 Actualizando: 0, Instalando 1, Eliminando: 0, no actualizando: 0

 Tamaño de la descarga: 179 kB

 Espacio necesario: 309 kB / 4.940 MB disponible

  

ATENCIÓN: ¡No se han podido autenticar los siguientes paquetes!

 debian-archive-keyring

  

Aviso de autenticación ignorado.

Des:1 http://deb.debian.org/debian trixie/main amd64 debian-archive-keyring all 2025.1 \[179 kB\]

Descargados 179 kB en 2s (109 kB/s)               

Seleccionando el paquete debian-archive-keyring previamente no seleccionado.

(Leyendo la base de datos ... 0 ficheros o directorios instalados actualmente.)

Preparando para desempaquetar .../debian-archive-keyring\_2025.1\_all.deb ...

Desempaquetando debian-archive-keyring (2025.1) ...

Configurando debian-archive-keyring (2025.1) ...

\[manjaro core\_generado\_chroot\]# nano /etc/apt/sources.list.d/moved-from-main.sources

\[manjaro core\_generado\_chroot\]# cat /etc/apt/sources.list.d/moved-from-main.sources

\# Modernized from /etc/apt/sources.list

Types: deb deb-src

URIs: http://deb.debian.org/debian/

Suites: trixie

Components: main contrib non-free non-free-firmware

Signed-By:  

  

\# Modernized from /etc/apt/sources.list

Types: deb

URIs: http://security.debian.org/debian-security/

Suites: trixie-security

Components: main contrib non-free non-free-firmware

Signed-By:  

\[manjaro core\_generado\_chroot\]# apt update

apt dist-upgrade

Des:1 http://deb.debian.org/debian trixie InRelease \[140 kB\]

Des:2 http://security.debian.org/debian-security trixie-security InRelease \[43,4 kB\]

Descargados 184 kB en 1s (236 kB/s)                                   

Todos los paquetes están actualizados.    

Información: Hace falta «Signed-By» en la entrada sources.list(5) para «http://deb.debian.org/debian»

Información: Hace falta «Signed-By» en la entrada sources.list(5) para «http://security.debian.org/debian-secu

rity»

Instalando:                               

 apt          bsdutils     diffutils  gzip                 ncurses-base  sysvinit-utils

 base-files   coreutils    dpkg       hostname             ncurses-bin   tar

 base-passwd  dash         findutils  init-system-helpers  perl-base     util-linux

 bash         debianutils  grep       libc-bin             sed

  

Instalando dependencias:

 bash-completion  libcap2                 libpam-modules          libtinfo6

 bsdextrautils    libcrypt1               libpam-modules-bin      libudev1

 ca-certificates  libdb5.3t64             libpam-runtime          libunistring5

 debconf          libdebconfclient0       libpam0g                libuuid1

 debconf-i18n     libgcc-s1               libpcre2-8-0            libxxhash0

 gcc-14-base      libgmp10                libseccomp2             libzstd1

 libacl1          libhogweed6t64          libselinux1             manpages

 libapt-pkg7.0    libidn2-0               libsmartcols1           mawk

 libattr1         liblastlog2-2           libsqlite3-0            openssl

 libaudit-common  liblocale-gettext-perl  libssl3t64              openssl-provider-legacy

 libaudit1        liblz4-1                libstdc++6              sensible-utils

 libblkid1        liblzma5                libsystemd0             sqv

 libbz2-1.0       libmd0                  libtext-charwidth-perl  zlib1g

 libc6            libmount1               libtext-iconv-perl

 libcap-ng0       libnettle8t64           libtext-wrapi18n-perl

  

Paquetes sugeridos:

 apt-doc     powermgmt-base             perl           libc-l10n       man-browser  util-linux-extra

 aptitude    bash-doc                   whiptail       locales         bzip2        util-linux-locales

 | synaptic  debconf-doc                | dialog       libnss-nis      ncompress    wtmpdb

 | wajig     debconf-kde-helper         diffutils-doc  libnss-nisplus  xz-utils

 dpkg-dev    debconf-utils              wdiff          cryptsetup-bin  tar-scripts

 gnupg       libgtk3-perl               debsig-verify  libpam-doc      tar-doc

 | gnupg2    libnet-ldap-perl           less           libgcrypt20     dosfstools

 | gnupg1    libterm-readline-gnu-perl  glibc-doc      uuid-runtime    kbd

  

Resumen:

 Actualizando: 0, Instalando 81, Eliminando: 0, no actualizando: 0

 Tamaño de la descarga: 34,4 MB

 Espacio necesario: 124 MB / 4.939 MB disponible

  

¿Continuar? \[S/n\]  

Des:1 http://deb.debian.org/debian trixie/main amd64 gcc-14-base amd64 14.2.0-19 \[49,4 kB\]

Des:2 http://deb.debian.org/debian trixie/main amd64 libc6 amd64 2.41-12+deb13u2 \[2.847 kB\]

Des:3 http://deb.debian.org/debian trixie/main amd64 libgcc-s1 amd64 14.2.0-19 \[72,8 kB\]

Des:4 http://deb.debian.org/debian trixie/main amd64 mawk amd64 1.3.4.20250131-1 \[141 kB\]

Des:5 http://deb.debian.org/debian trixie/main amd64 base-files amd64 13.8+deb13u4 \[73,3 kB\]

Des:6 http://deb.debian.org/debian trixie/main amd64 libtinfo6 amd64 6.5+20250216-2 \[348 kB\]

Des:7 http://deb.debian.org/debian trixie/main amd64 debianutils amd64 5.23.2 \[92,4 kB\]

Des:8 http://deb.debian.org/debian trixie/main amd64 bash amd64 5.2.37-2+b8 \[1.501 kB\]

Des:9 http://deb.debian.org/debian trixie/main amd64 libcap2 amd64 1:2.75-10+b8 \[28,7 kB\]

Des:10 http://deb.debian.org/debian trixie/main amd64 libsystemd0 amd64 257.9-1~deb13u1 \[453 kB\]

Des:11 http://deb.debian.org/debian trixie/main amd64 bsdutils amd64 1:2.41-5 \[110 kB\]

Des:12 http://deb.debian.org/debian trixie/main amd64 libacl1 amd64 2.3.2-2+b1 \[32,9 kB\]

Des:13 http://deb.debian.org/debian trixie/main amd64 libattr1 amd64 1:2.5.2-3 \[22,9 kB\]

Des:14 http://deb.debian.org/debian trixie/main amd64 libgmp10 amd64 2:6.3.0+dfsg-3 \[560 kB\]

Des:15 http://deb.debian.org/debian trixie/main amd64 libpcre2-8-0 amd64 10.46-1~deb13u1 \[299 kB\]

Des:16 http://deb.debian.org/debian trixie/main amd64 libselinux1 amd64 3.8.1-1 \[84,7 kB\]

Des:17 http://deb.debian.org/debian trixie/main amd64 libzstd1 amd64 1.5.7+dfsg-1 \[304 kB\]

Des:18 http://deb.debian.org/debian trixie/main amd64 zlib1g amd64 1:1.3.dfsg+really1.3.1-1+b1 \[88,9 kB\]

Des:19 http://deb.debian.org/debian trixie/main amd64 libssl3t64 amd64 3.5.5-1~deb13u1 \[2.442 kB\]

Des:20 http://deb.debian.org/debian trixie/main amd64 openssl-provider-legacy amd64 3.5.5-1~deb13u1 \[311 kB\]  

Des:21 http://deb.debian.org/debian trixie/main amd64 coreutils amd64 9.7-3 \[3.024 kB\]                        

Des:22 http://deb.debian.org/debian trixie/main amd64 dash amd64 0.5.12-12 \[98,5 kB\]                          

Des:23 http://deb.debian.org/debian trixie/main amd64 diffutils amd64 1:3.10-4 \[387 kB\]                       

Des:24 http://deb.debian.org/debian trixie/main amd64 libbz2-1.0 amd64 1.0.8-6 \[37,9 kB\]                      

Des:25 http://deb.debian.org/debian trixie/main amd64 liblzma5 amd64 5.8.1-1 \[309 kB\]                         

Des:26 http://deb.debian.org/debian trixie/main amd64 libmd0 amd64 1.1.0-2+b1 \[36,3 kB\]                       

Des:27 http://deb.debian.org/debian trixie/main amd64 tar amd64 1.35+dfsg-3.1 \[815 kB\]                        

Des:28 http://deb.debian.org/debian trixie/main amd64 dpkg amd64 1.22.22 \[1.537 kB\]                           

Des:29 http://deb.debian.org/debian trixie/main amd64 findutils amd64 4.10.0-3 \[700 kB\]                       

Des:30 http://deb.debian.org/debian trixie/main amd64 grep amd64 3.11-4 \[431 kB\]                              

Des:31 http://deb.debian.org/debian trixie/main amd64 gzip amd64 1.13-1 \[138 kB\]                              

Des:32 http://deb.debian.org/debian trixie/main amd64 hostname amd64 3.25 \[11,0 kB\]                           

Des:33 http://deb.debian.org/debian trixie/main amd64 ncurses-bin amd64 6.5+20250216-2 \[438 kB\]               

Des:34 http://deb.debian.org/debian trixie/main amd64 libcrypt1 amd64 1:4.4.38-1 \[90,1 kB\]                    

Des:35 http://deb.debian.org/debian trixie/main amd64 perl-base amd64 5.40.1-6 \[1.666 kB\]                     

Des:36 http://deb.debian.org/debian trixie/main amd64 sed amd64 4.9-2 \[329 kB\]                                

Des:37 http://deb.debian.org/debian trixie/main amd64 libaudit-common all 1:4.0.2-2 \[12,7 kB\]                 

Des:38 http://deb.debian.org/debian trixie/main amd64 libcap-ng0 amd64 0.8.5-4+b1 \[17,6 kB\]                   

Des:39 http://deb.debian.org/debian trixie/main amd64 libaudit1 amd64 1:4.0.2-2+b2 \[55,1 kB\]                  

Des:40 http://deb.debian.org/debian trixie/main amd64 libdb5.3t64 amd64 5.3.28+dfsg2-9 \[704 kB\]               

Des:41 http://deb.debian.org/debian trixie/main amd64 debconf all 1.5.91 \[121 kB\]                             

Des:42 http://deb.debian.org/debian trixie/main amd64 libpam0g amd64 1.7.0-5 \[69,9 kB\]                        

Des:43 http://deb.debian.org/debian trixie/main amd64 libpam-modules-bin amd64 1.7.0-5 \[49,1 kB\]              

Des:44 http://deb.debian.org/debian trixie/main amd64 libpam-modules amd64 1.7.0-5 \[179 kB\]                   

Des:45 http://deb.debian.org/debian trixie/main amd64 libpam-runtime all 1.7.0-5 \[249 kB\]                     

Des:46 http://deb.debian.org/debian trixie/main amd64 libblkid1 amd64 2.41-5 \[171 kB\]                         

Des:47 http://deb.debian.org/debian trixie/main amd64 libsqlite3-0 amd64 3.46.1-7+deb13u1 \[914 kB\]            

Des:48 http://deb.debian.org/debian trixie/main amd64 liblastlog2-2 amd64 2.41-5 \[28,5 kB\]                    

Des:49 http://deb.debian.org/debian trixie/main amd64 libmount1 amd64 2.41-5 \[209 kB\]                         

Des:50 http://deb.debian.org/debian trixie/main amd64 libsmartcols1 amd64 2.41-5 \[143 kB\]                     

Des:51 http://deb.debian.org/debian trixie/main amd64 libudev1 amd64 257.9-1~deb13u1 \[152 kB\]                 

Des:52 http://deb.debian.org/debian trixie/main amd64 libuuid1 amd64 2.41-5 \[37,6 kB\]                         

Des:53 http://deb.debian.org/debian trixie/main amd64 util-linux amd64 2.41-5 \[1.235 kB\]                      

Des:54 http://deb.debian.org/debian trixie/main amd64 libdebconfclient0 amd64 0.280 \[10,6 kB\]                 

Des:55 http://deb.debian.org/debian trixie/main amd64 base-passwd amd64 3.6.7 \[53,7 kB\]                       

Des:56 http://deb.debian.org/debian trixie/main amd64 libnettle8t64 amd64 3.10.1-1 \[305 kB\]                   

Des:57 http://deb.debian.org/debian trixie/main amd64 libhogweed6t64 amd64 3.10.1-1 \[335 kB\]                  

Des:58 http://deb.debian.org/debian trixie/main amd64 sqv amd64 1.3.0-3+b2 \[661 kB\]                           

Des:59 http://deb.debian.org/debian trixie/main amd64 libxxhash0 amd64 0.8.3-2 \[27,1 kB\]                      

Des:60 http://deb.debian.org/debian trixie/main amd64 liblz4-1 amd64 1.10.0-4 \[63,9 kB\]                       

Des:61 http://deb.debian.org/debian trixie/main amd64 libstdc++6 amd64 14.2.0-19 \[714 kB\]                     

Des:62 http://deb.debian.org/debian trixie/main amd64 libapt-pkg7.0 amd64 3.0.3 \[1.113 kB\]                    

Des:63 http://deb.debian.org/debian trixie/main amd64 libseccomp2 amd64 2.6.0-2 \[51,7 kB\]                     

Des:64 http://deb.debian.org/debian trixie/main amd64 apt amd64 3.0.3 \[1.452 kB\]                              

Des:65 http://deb.debian.org/debian trixie/main amd64 init-system-helpers all 1.69~deb13u1 \[39,4 kB\]          

Des:66 http://deb.debian.org/debian trixie/main amd64 libc-bin amd64 2.41-12+deb13u2 \[638 kB\]                 

Des:67 http://deb.debian.org/debian trixie/main amd64 ncurses-base all 6.5+20250216-2 \[273 kB\]                

Des:68 http://deb.debian.org/debian trixie/main amd64 sysvinit-utils amd64 3.14-4 \[34,1 kB\]                   

Des:69 http://deb.debian.org/debian trixie/main amd64 liblocale-gettext-perl amd64 1.07-7+b1 \[15,3 kB\]        

Des:70 http://deb.debian.org/debian trixie/main amd64 libtext-charwidth-perl amd64 0.04-11+b4 \[9.476 B\]       

Des:71 http://deb.debian.org/debian trixie/main amd64 libtext-iconv-perl amd64 1.7-8+b4 \[14,4 kB\]             

Des:72 http://deb.debian.org/debian trixie/main amd64 libtext-wrapi18n-perl all 0.06-10 \[8.808 B\]             

Des:73 http://deb.debian.org/debian trixie/main amd64 debconf-i18n all 1.5.91 \[217 kB\]                        

Des:74 http://deb.debian.org/debian trixie/main amd64 sensible-utils all 0.0.25 \[25,0 kB\]                     

Des:75 http://deb.debian.org/debian trixie/main amd64 bash-completion all 1:2.16.0-7 \[319 kB\]                 

Des:76 http://deb.debian.org/debian trixie/main amd64 openssl amd64 3.5.5-1~deb13u1 \[1.499 kB\]                

Des:77 http://deb.debian.org/debian trixie/main amd64 ca-certificates all 20250419 \[162 kB\]                   

Des:78 http://deb.debian.org/debian trixie/main amd64 manpages all 6.9.1-1 \[1.393 kB\]                         

Des:79 http://deb.debian.org/debian trixie/main amd64 bsdextrautils amd64 2.41-5 \[94,6 kB\]                    

Des:80 http://deb.debian.org/debian trixie/main amd64 libunistring5 amd64 1.3-2 \[477 kB\]                      

Des:81 http://deb.debian.org/debian trixie/main amd64 libidn2-0 amd64 2.3.8-2 \[109 kB\]                        

Descargados 34,4 MB en 33s (1.051 kB/s)                                                                       

Seleccionando el paquete gcc-14-base:amd64 previamente no seleccionado.

(Leyendo la base de datos ... 44 ficheros o directorios instalados actualmente.)

Preparando para desempaquetar .../gcc-14-base\_14.2.0-19\_amd64.deb ...

Desempaquetando gcc-14-base:amd64 (14.2.0-19) ...

Configurando gcc-14-base:amd64 (14.2.0-19) ...

Seleccionando el paquete libc6:amd64 previamente no seleccionado.

(Leyendo la base de datos ... 49 ficheros o directorios instalados actualmente.)

Preparando para desempaquetar .../libc6\_2.41-12+deb13u2\_amd64.deb ...

dpkg-query: no packages found matching base-files

Desempaquetando libc6:amd64 (2.41-12+deb13u2) ...

dpkg-deb: error: el subproceso tar fue terminado por la señal (Violación de segmento), volcado de «core»

dpkg: error al procesar el archivo /var/cache/apt/archives/libgcc-s1\_14.2.0-19\_amd64.deb (--unpack):

dpkg-deb --control subprocess failed with exit status 2

Se encontraron errores al procesar:

/var/cache/apt/archives/libgcc-s1\_14.2.0-19\_amd64.deb

Error: Sub-process /usr/bin/dpkg returned an error code (1)

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

¡Uf! Ese **"Violación de segmento (core dumped)"** es el síntoma definitivo de que estamos intentando reconstruir un edificio mientras el suelo se desmorona.

El problema es técnico pero sencillo de entender: estás en un **chroot** (un sistema dentro de otro) y `dpkg` ha intentado usar herramientas del sistema anfitrión (Manjaro) o del sistema nuevo (Debian) que no son compatibles entre sí o que no encuentran sus librerías. Al fallar el desempaquetado de `libc6` y `libgcc-s1`, el sistema se ha quedado "cojo".

Aquí tienes los pasos para intentar rescatar la instalación antes de que el chroot sea totalmente inservible:

* * *

1\. El problema de la arquitectura y el tar
-------------------------------------------

El error de `tar` con _Violación de segmento_ suele ocurrir porque el `tar` que intenta usar `dpkg` no es compatible con la nueva `libc6` que se acaba de medio-instalar.

Desde **FUERA** del chroot (en tu terminal de Manjaro), intenta copiar las herramientas estáticas del anfitrión al chroot para que `dpkg` tenga algo sólido que usar:

Bash

    # Ejecuta esto en Manjaro, NO dentro del chroot
    sudo cp /usr/bin/tar /ruta/a/core_generado_chroot/usr/bin/tar
    sudo cp /usr/bin/gzip /ruta/a/core_generado_chroot/usr/bin/gzip

2\. Forzar la configuración de lo que ya se descargó
----------------------------------------------------

Entra de nuevo al **chroot** e intenta forzar a `dpkg` a terminar lo que empezó, ignorando las dependencias rotas por un momento:

Bash

    # Dentro del chroot
    dpkg --configure -a

Si eso falla, intenta instalar manualmente los paquetes básicos que ya están descargados en la caché:

Bash

    cd /var/cache/apt/archives/
    dpkg -i libc6_*.deb libgcc-s1_*.deb libstdc++6_*.deb

3\. Corregir el archivo de fuentes (Paso Crítico)
-------------------------------------------------

En tu `cat` anterior, vi que el campo `Signed-By:` estaba **vacío**. Esto hará que `apt update` siga quejándose. Déjalo así:

Plaintext

    # En /etc/apt/sources.list.d/moved-from-main.sources
    Types: deb deb-src
    URIs: http://deb.debian.org/debian/
    Suites: trixie
    Components: main contrib non-free non-free-firmware
    Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
    
    Types: deb
    URIs: http://security.debian.org/debian-security/
    Suites: trixie-security
    Components: main contrib non-free non-free-firmware
    Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

4\. ¿Cómo evitar que explote otra vez?
--------------------------------------

Si logras que `dpkg -i` funcione, intenta terminar la instalación por partes, no todo de golpe:

1.  `apt install -f` (Para arreglar dependencias rotas)
    
2.  `apt install bash coreutils`
    
3.  `apt dist-upgrade`
    

* * *

La alternativa "Limpia" (Si nada de lo anterior funciona)
---------------------------------------------------------

Si el chroot sigue dando _Segfault_, es porque la mezcla de binarios de Manjaro y Debian Trixie ha creado un Frankenstein incompatible. En ese caso, lo más sano desde Manjaro es usar `debootstrap`, que es la herramienta oficial para crear chroots de Debian:

Bash

    # En Manjaro
    sudo pacman -S debootstrap
    sudo debootstrap trixie /ruta/a/core_generado_chroot http://deb.debian.org/debian/

Esto te creará un sistema Trixie perfecto y funcional desde el segundo uno, con todas sus llaves y `apt` configurado.

**¿Quieres intentar rescatar el actual con los comandos de `dpkg -i` o prefieres que te guíe para hacer un `debootstrap` limpio?**

Has parado esta respuesta

---

