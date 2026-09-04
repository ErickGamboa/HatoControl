# Publicar HatoControl Web en Vercel

La configuración vive en `vercel.json`, en la raíz del repo, para que quede
versionada y no dependa de clics en el panel.

## Cómo conectarlo (una sola vez)

1. En Vercel: **Add New → Project** y elegir el repo `HatoControl`.
2. **Root Directory: la raíz del repo** (dejarlo vacío). No poner
   `HatoControlWeb`: la app web depende del paquete de la app móvil por ruta
   relativa (`../HatoControlMovil`), así que el build necesita ver las dos
   carpetas.
3. Framework Preset: **Other**.
4. Los comandos los toma de `vercel.json`; no hay que escribirlos a mano.
5. Deploy.

Que el proyecto de Android e iOS esté en el mismo repo no afecta nada: Vercel
solo publica lo que quede en `HatoControlWeb/build/sitio`.

## Qué se publica

El dominio tiene dos cosas: el sitio público y la app.

| URL           | Qué es                                          |
| ------------- | ----------------------------------------------- |
| `/`           | Portada de HatoControl (HTML estático)          |
| `/privacidad` | Política de privacidad                          |
| `/soporte`    | Soporte y preguntas frecuentes                  |
| `/app/`       | La app Flutter: el login y todo lo demás        |

**Las dos páginas legales son HTML plano a propósito.** App Store y Google
Play piden un enlace público a la política de privacidad y otro a soporte, y
el revisor (o el robot que las revisa) tiene que poder leerlas sin esperar a
que baje un bundle de Flutter de varios megas. Por eso también la portada es
estática: lo que se comparte y lo que indexa Google abre al instante.

Las dos páginas se editan en `HatoControlWeb/sitio/`. Si cambia la política
de privacidad, se cambia ahí y se actualiza la fecha de arriba.

## Qué hace el build

Vercel no trae Flutter instalado, así que el paso de instalación lo baja:

```
installCommand:  clona Flutter 3.44.1 en _flutter/ + precache web + pub get
buildCommand:    bash HatoControlWeb/scripts/construir_sitio.sh
outputDirectory: HatoControlWeb/build/sitio
```

El script compila la app con `--base-href /app/` y arma la carpeta que se
publica: el sitio estático en la raíz y `build/web` colgado de `app/`.

Por eso cada deploy tarda unos **3 a 5 minutos** en vez de segundos: se baja
el SDK de Flutter cada vez. Es el precio de no tener Flutter nativo en la
plataforma.

**La versión de Flutter está fijada a propósito** (`-b 3.44.1`, la misma con
la que se desarrolla). Si se usara `stable`, una liberación de Flutter podría
romper el deploy de producción un martes cualquiera sin que nadie tocara el
código. Al subir la versión local, actualizar también ese número en
`vercel.json`.

## Alternativa: compilar en la máquina y subir el resultado

Si esos minutos estorban:

```bash
bash HatoControlWeb/scripts/construir_sitio.sh
vercel deploy --prebuilt   # o subir build/sitio como sitio estático
```

Deploy en segundos, pero se pierde el automático al hacer `git push`.

Para verlo en la computadora antes de subirlo, cualquier servidor estático
sobre `HatoControlWeb/build/sitio` sirve; ojo que sin Vercel las URL sin
`.html` (`/privacidad`) no resuelven solas.

## Notas

- `cleanUrls` es lo que hace que `/privacidad` funcione sin el `.html`. Esas
  URL son las que van en la ficha de App Store y Google Play, así que no
  conviene cambiarlas después de haberlas enviado a revisión.
- El `rewrites` a `/app/index.html` es para que cualquier URL dentro de
  `/app/` cargue la app. Hoy la app no usa rutas en la barra de direcciones,
  pero si algún día se agregan enlaces profundos, ya está listo. Los archivos
  que sí existen (el bundle, los assets) se sirven directo: en Vercel los
  rewrites corren después de buscar en el disco.
- La clave `anon` de Supabase va embebida en el bundle y eso es correcto: es
  pública por diseño y la seguridad real la dan las políticas RLS. La clave
  `service_role` nunca debe llegar acá.
- El primer deploy hay que verificarlo: si el clone de Flutter falla o la
  imagen de build de Vercel se queda corta de espacio, el log lo dice y se
  ajusta el comando.
