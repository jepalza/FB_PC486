# FB_PC486
Freebasic PC 486 Emulator Based in PCEM 8.0

Iniciado en : https://www.freebasic.net/forum/viewtopic.php?f=8&t=27435

Versión mejorada de mi emulador, anteriormente publicado en:  https://github.com/countingpine/PCEM_FB486
Los cambios son principalmente en velocidad y en organización de la estructura de ficheros.

Esta basado en el emulador PCEM, version V4.1 pero con muchas partes independientes de posteriores versiones, hasta llegar a la V8.0
Con este código podemos llegar a ejecutar un "80486-DX2-66mhz con FPU (Coprocesador matemático), 16mb de RAM y VGA TSENG de 2mb (res. hasta 800x600)"

No tiene sonido, por que se ralentiza el emulador. Aún tiene muchos fallos, por ejemplo, los cursores del teclado no funcionan la primera vez que se usan, y es necesario pulsar "BLOQ_NUM" para que el emulador los reconozca.

En esta versión he re-organizado las carpetas, y he incluido un fichero de texto muy simple, donde indicamos la geometria y la ruta del disco duro a emplear.
Recomiendo compilar con "fbc64 -gen gcc" (he dejado un .BAT que lo automatiza) en lugar de FBC, por que se gana un 20% de velocidad en la ejecución.

    ![Imagen fb80486_bios.png](https://github.com/jepalza/FB_PC486/blob/main/pictures/fb80486_bios.jpg)
    ![Imagen fb80486_dos1.png](https://github.com/jepalza/FB_PC486/blob/main/pictures/fb80486_dos1.jpg)
    ![Imagen fb80486_dos2.png](https://github.com/jepalza/FB_PC486/blob/main/pictures/fb80486_dos2.jpg)
    ![Imagen fb80486_dos3.png](https://github.com/jepalza/FB_PC486/blob/main/pictures/fb80486_dos3.jpg)
