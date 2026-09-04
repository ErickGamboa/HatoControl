# HatoControl Web

La misma app de HatoControl, en el navegador. Se conecta a **la misma base de
datos y el mismo login** que la app de Android (proyecto Supabase
`geocoundyilwxrnbhcqu`), así que el ganadero puede trabajar desde el teléfono,
desde el navegador del teléfono o desde la computadora, como le quede cómodo.

## Cómo se ve en cada pantalla

| Dónde se abre | Qué muestra |
| --- | --- |
| Teléfono (ancho < 1000 px) | **Exactamente** la interfaz de la app nativa. No es una copia parecida: son literalmente los mismos widgets del paquete `hato_control`. |
| Computadora (ancho ≥ 1000 px) | Distribución de escritorio: menú fijo a la izquierda, barra de estado arriba y el módulo abierto en el centro. Mismos colores, mismo logo, mismos íconos. |

El corte está en `lib/app/adaptador_pantalla.dart` (`kAnchoEscritorio`) y
reacciona en vivo: si se achica la ventana de la computadora, la app pasa sola
a la interfaz móvil.

## Cómo está armado (y por qué)

Este proyecto **no reescribe la app**: la consume.

```
HatoControl/
├── HatoControlMovil/     ← el producto: pantallas, repositorios, sync, tema
└── HatoControlWeb/       ← este proyecto: solo el arranque y la vista de PC
    └── pubspec.yaml         dependencia: hato_control (path: ../HatoControlMovil)
```

La razón es simple: si la web tuviera su propia copia de las pantallas, cada
cambio habría que programarlo dos veces y con el tiempo las versiones se irían
separando. Así, un arreglo en el módulo de pesaje sale al mismo tiempo en el
APK, en la web del teléfono y en la web de la computadora.

Lo único que vive acá:

| Archivo | Para qué |
| --- | --- |
| `lib/main.dart` | Arranque (usa el mismo `bootstrapHatoControl()` de la app nativa). |
| `lib/app/adaptador_pantalla.dart` | Decide entre interfaz móvil y de escritorio. |
| `lib/escritorio/` | La distribución de computadora (menú, barra superior, paneles). |
| `assets/` | Copia de los assets de la app móvil (ver más abajo). |
| `web/` | Página que envuelve la app, íconos y los binarios de SQLite. |

### Los datos

En web tampoco se habla con Supabase directamente desde las pantallas: se usa
el mismo `SyncService` y los mismos repositorios. La base local es SQLite
compilado a WebAssembly (`web/sqlite3.wasm` + `web/drift_worker.js`), que el
navegador guarda en IndexedDB o en OPFS según lo que soporte.

Esto es un detalle interno, no el "modo sin internet" de la app nativa: la web
está pensada para usarse conectada. La caché local es lo que hace que las
listas se pinten al instante y que no se pierda un dato si la conexión
parpadea a mitad de un guardado.

### Lo que la web no hace

- **Foto de la finca:** en el navegador no hay archivos del dispositivo, así
  que la foto se ve (desde el servidor) pero no se puede tomar ni cambiar. Se
  cambia desde el teléfono. Es la decisión D-09 del proyecto.

## Correrlo

```bash
flutter pub get
flutter run -d chrome            # desarrollo
flutter build web                # release -> build/web/
```

Para armar lo que se publica de verdad (la portada y la app juntas):

```bash
bash scripts/construir_sitio.sh  # -> build/sitio/
```

### El sitio público

`sitio/` es la portada de HatoControl y sus dos páginas legales, en HTML
plano: `index.html`, `privacidad.html` y `soporte.html`. No son parte del
bundle de Flutter a propósito: App Store y Google Play piden un enlace
público a la política de privacidad y otro a soporte, y tienen que abrir sin
esperar a que baje la app. En el dominio quedan como `/`, `/privacidad`,
`/soporte`, y la app queda colgada de `/app/`. Los detalles del deploy están
en `VERCEL.md`.

Para probar la vista móvil en la computadora: abrir las herramientas de
desarrollo de Chrome (F12) y activar el modo dispositivo, o simplemente
angostar la ventana a menos de 1000 px.

### Assets

Los íconos y el logo se copian desde la app móvil, porque Flutter solo
encuentra `Image.asset('assets/...')` en los assets del proyecto que corre.
Después de agregar o cambiar una imagen en `HatoControlMovil/assets/`:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\sync_assets.ps1
```

### Binarios de SQLite

`web/sqlite3.wasm` y `web/drift_worker.js` están versionados a propósito. Si
algún día se sube la versión de `drift` o `sqlite3` en el `pubspec.lock` de la
app móvil, hay que volver a bajarlos de la versión que corresponda:

- `sqlite3.wasm` → releases de `simolus3/sqlite3.dart`, tag `sqlite3-<versión>`
- `drift_worker.js` → releases de `simolus3/drift`, tag `drift-<versión>`

## Calidad

```bash
dart format lib test
flutter analyze
flutter test
```

Y, como este proyecto depende de la app móvil, cualquier cambio que la toque
tiene que dejar verde también:

```bash
cd ../HatoControlMovil && flutter analyze && flutter test
```
