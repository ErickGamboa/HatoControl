# Copia los assets que necesita la app web desde la app movil.
#
# Por que existe: Flutter solo encuentra `Image.asset('assets/...')` en los
# assets del paquete que se esta ejecutando. Como la web reutiliza las
# pantallas del paquete `hato_control`, necesita los mismos archivos en las
# mismas rutas. Se copian, no se enlazan, porque Windows no maneja bien los
# enlaces simbolicos en un repositorio.
#
# Se copia solo lo que la web declara en su pubspec, no la carpeta de logos
# completa: ahi viven tambien los originales de marca y el archivo que usa
# flutter_launcher_icons, y duplicarlos en el repo seria peso muerto.
# Si la web empieza a usar otra imagen, hay que agregarla a $logos Y al
# pubspec.yaml.
#
# Correr despues de agregar o cambiar cualquier imagen en la app movil:
#   powershell -ExecutionPolicy Bypass -File scripts\sync_assets.ps1

$ErrorActionPreference = 'Stop'

$logos = @(
    'hatocontrol_logo.png'            # lo usa la pantalla de login compartida
    'emblema_sin_fondo.png'           # la marca de la barra lateral de PC
    'hatocontrol_logo_sin_fondo.png'  # la pantalla de carga de web/index.html
)

$raiz = Split-Path -Parent $PSScriptRoot
$origen = Join-Path (Split-Path -Parent $raiz) 'HatoControlMovil\assets'
$destino = Join-Path $raiz 'assets'

if (-not (Test-Path $origen)) {
    throw "No encuentro los assets de la app movil en: $origen"
}

Write-Host "Copiando assets"
Write-Host "  desde: $origen"
Write-Host "  hacia: $destino"

if (Test-Path $destino) {
    Remove-Item -Recurse -Force $destino
}

New-Item -ItemType Directory -Force -Path (Join-Path $destino 'logo') | Out-Null
Copy-Item -Recurse (Join-Path $origen 'iconos') (Join-Path $destino 'iconos')

foreach ($logo in $logos) {
    $ruta = Join-Path $origen "logo\$logo"
    if (-not (Test-Path $ruta)) {
        throw "Falta el logo que la web declara en su pubspec: $ruta"
    }
    Copy-Item $ruta (Join-Path $destino "logo\$logo")
}

$copiados = (Get-ChildItem -Recurse -File $destino).Count
Write-Host "Listo: $copiados archivo(s)."
