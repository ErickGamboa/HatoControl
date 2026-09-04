#!/usr/bin/env bash
#
# Arma en build/sitio/ lo que se publica en internet:
#
#   /            -> el sitio público (portada, privacidad, soporte)
#   /app/        -> la app Flutter, compilada con --base-href /app/
#
# La portada y las dos páginas legales son HTML estático a propósito: la
# tienda de apps y los buscadores tienen que poder abrirlas sin esperar a que
# baje el bundle de Flutter.
#
# Uso:
#   bash HatoControlWeb/scripts/construir_sitio.sh
#
# Toma el Flutter de $FLUTTER si está definido; si no, usa el que Vercel clona
# en _flutter/ y, en última instancia, el que esté en el PATH (tu máquina).

set -euo pipefail

# Git Bash (Windows) traduce solo los argumentos que parecen rutas, así que
# "--base-href /app/" le llegaría a Flutter como "C:/Program Files/Git/app/".
# En Linux, que es donde compila Vercel, estas variables no molestan.
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL='*'

cd "$(dirname "$0")/.."   # HatoControlWeb/

FLUTTER="${FLUTTER:-}"
if [ -z "$FLUTTER" ]; then
  if [ -x "../_flutter/bin/flutter" ]; then
    FLUTTER="../_flutter/bin/flutter"
  else
    FLUTTER="flutter"
  fi
fi

echo "==> Compilando la app web con $FLUTTER"
"$FLUTTER" build web --release --base-href /app/

SALIDA="build/sitio"
echo "==> Armando $SALIDA"
rm -rf "$SALIDA"
mkdir -p "$SALIDA/img" "$SALIDA/app"

# Sitio público
cp sitio/*.html sitio/estilo.css "$SALIDA/"
cp web/favicon.png "$SALIDA/"

# Imágenes del sitio: las mismas del logo y los módulos que usa la app, para
# que no haya dos versiones del mismo dibujo dando vueltas.
cp assets/logo/emblema_sin_fondo.png "$SALIDA/img/"
cp assets/logo/hatocontrol_logo_sin_fondo.png "$SALIDA/img/"
for icono in recoleccion lotes sanidad dietas venta; do
  cp "assets/iconos/$icono.png" "$SALIDA/img/"
done

# La app, colgada de /app/
cp -R build/web/. "$SALIDA/app/"

echo "==> Listo: $SALIDA"
