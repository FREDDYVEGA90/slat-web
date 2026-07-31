# SLAT | Star Logistic and Transport

Sitio web estático de SLAT: transporte terrestre de carga para exportación en contenedores dry y reefer.

**Producción:** https://slat-web.vercel.app

## Estructura

```
index.html      Página completa (una sola página, secciones ancladas)
styles.css      Sistema de diseño y estilos
script.js       Interacciones: nav móvil, reveal on-scroll, contadores, formulario -> WhatsApp
assets/         Imágenes optimizadas que consume el sitio
scripts/        Utilidades PowerShell (generación y optimización del logo, servidor local)
```

Los archivos `Banano.jpg`, `Cacao.jpg`, `Camaron.jpg` y `Logo SLAT.png` en la raíz son los
originales sin optimizar; las versiones que usa el sitio están en `assets/`.

## Desarrollo local

No requiere build ni dependencias. Para levantar un servidor local:

```
powershell -ExecutionPolicy Bypass -File scripts/serve.ps1 -Port 5511
```

Luego abrir http://localhost:5511

## Regenerar el logo

```
pwsh -File scripts/build_logo.ps1 -TargetWidth 240
pwsh -File scripts/optimize_logo.ps1 -Levels 24
```

`build_logo.ps1` recorta el fondo blanco del original y lo reescala; `optimize_logo.ps1`
reduce el peso del PNG posterizando los canales de color.

## Despliegue

Vercel está enlazado a este repositorio y despliega automáticamente en cada push a `main`.

```
git add -A
git commit -m "descripción del cambio"
git push
```

## Contacto configurado en el sitio

- WhatsApp: 098 641 1498 (`593986411498` en los enlaces `wa.me`)
- Correo: starlogistic9@gmail.com
- Base en Guayaquil, cobertura nacional

Los enlaces de Instagram y Facebook en el footer siguen como marcador (`href="#"`)
pendientes de reemplazo por las URLs reales.
