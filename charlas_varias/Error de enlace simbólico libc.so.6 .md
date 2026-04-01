You asked:
----------

Has dicho

¿Por qué ocurre este error?

  

ldconfig: /usr/lib/libc.so.6 is not a symbolic link

---

Gemini Replied:
---------------

Gemini ha dicho
---------------

Este es uno de esos errores que pueden ponerte los pelos de punta, porque involucra a la **glibc** (GNU C Library), el corazón de casi todo lo que corre en Linux.

En resumen: **`ldconfig` espera que `/usr/lib/libc.so.6` sea un acceso directo (vínculo simbólico) que apunte al archivo real de la librería, pero se encontró con el archivo real directamente o un archivo corrupto.**

* * *

### ¿Por qué es un problema?

En un sistema saludable, la estructura debería verse así:

*   **Archivo real:** `libc-2.xx.so` (contiene el código ejecutable).
    
*   **Vínculo simbólico:** `libc.so.6` → apunta a `libc-2.xx.so`.
    

El sistema utiliza el nombre genérico (`libc.so.6`) para que, cuando actualices la librería, solo haya que mover el vínculo hacia la nueva versión sin romper todos los programas del PC. Si `libc.so.6` deja de ser un vínculo, el mecanismo de actualización y gestión de librerías de `ldconfig` falla.

* * *

### Causas comunes

1.  **Interrupción durante una actualización:** Si el sistema se apagó o el gestor de paquetes (`pacman`, `apt`, `dnf`) falló mientras actualizaba la glibc.
    
2.  **Intervención manual:** Intentar mover librerías a mano para solucionar otros problemas (un clásico "el remedio fue peor que la enfermedad").
    
3.  **Error de empaquetado:** En distribuciones tipo _Rolling Release_ (como Arch Linux), a veces un paquete mal construido puede causar este desajuste.
    

* * *

### Cómo solucionarlo (con precaución)

**Advertencia:** No cierres la terminal actual ni reinicies hasta estar seguro de que lo arreglaste, o el sistema podría no arrancar.

#### 1\. Identifica el archivo real

Primero, mira qué archivos tienes en esa carpeta: `ls -l /usr/lib/libc.so*`

Deberías ver algo como esto:

Plaintext

    -rwxr-xr-x 1 root root 2345678 abr  1 05:00 libc-2.39.so
    -rwxr-xr-x 1 root root 2345678 abr  1 05:00 libc.so.6  <-- ESTO ES LO QUE ESTÁ MAL (debería ser 'l')

#### 2\. La solución estándar

Si tienes el archivo real (ej. `libc-2.39.so`) y el archivo problemático (`libc.so.6`), la solución suele ser borrar el archivo que no es un link y recrear el vínculo simbólico:

Bash

    sudo rm /usr/lib/libc.so.6
    sudo ln -s /usr/lib/libc-2.3x.so /usr/lib/libc.so.6
    sudo ldconfig

_(Sustituye `2.3x` por la versión exacta que aparezca en tu carpeta)._

#### 3\. Si usas Arch Linux

Este error fue famoso hace un tiempo en Arch. Si es tu caso, usualmente se resuelve forzando la reinstalación de la librería para que el gestor de paquetes repare los enlaces: `sudo pacman -Syu --overwrite /usr/lib/libc.so.6 glibc`

* * *

**¿Qué distribución estás usando y qué estabas haciendo justo antes de que apareciera el error?** Esto me ayudará a decirte el comando exacto para tu sistema.

---

