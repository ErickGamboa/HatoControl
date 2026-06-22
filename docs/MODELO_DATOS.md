# HatoControl — Modelo de datos (v1)

Software as a Service para manejo de hato ganadero. Offline-first: base **SQLite local
con Drift** y una **capa de sincronización propia** hacia Supabase (Postgres).

Módulos de esta primera etapa: **fincas, lotes, inventario (animales), pesaje**.

> **Estado:** tablas + seguridad (RLS) aplicadas en Supabase (`geocoundyilwxrnbhcqu`).
> Funciones auxiliares en el esquema `private` (`es_miembro`, `es_admin`, `comparte_finca`,
> `es_creador`). El creador de una finca se agrega como admin **desde el cliente** (no hay
> trigger de auto-admin). Capa de **Cuenta (tenant) + licencias por finca** agregada (ver
> sección abajo).

## Licenciamiento (Cuenta + planes)
- **Cuenta** = unidad que paga la licencia. Cada usuario tiene su propia Cuenta (creada al
  registrarse por el trigger `private.crear_perfil_usuario`). Cada **finca pertenece a una
  Cuenta** (`fincas.cuenta_id`).
- **Licencia por número de fincas propias** de la Cuenta. Planes: **Light=1, Medium=3,
  Pro=5** (tabla `planes`, editable en Supabase).
- El límite cuenta solo las fincas **propias** (`cuenta_id` = esa Cuenta, no borradas).
  Colaborar en fincas de otra Cuenta (vía `finca_miembros`) NO consume el límite.
- **Administración:** cambiar `cuentas.plan` a light/medium/pro en Supabase. Enforcement:
  trigger `private.validar_limite_fincas` (BEFORE INSERT en fincas, respaldo duro) +
  verificación en el cliente (mensaje amigable).

### planes
| Campo | Tipo | Notas |
|---|---|---|
| codigo | text (PK) | 'light' \| 'medium' \| 'pro' |
| nombre | text | |
| limite_fincas | int | 1 / 3 / 5 |

### cuentas
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| nombre | text | |
| dueno_id | uuid → usuarios.id | |
| plan | text → planes.codigo | default 'light' |
| estado | text | 'activa' \| 'suspendida' |

## Convenciones
- **Llaves primarias `uuid` generadas en el cliente** (para que un registro creado
  offline tenga un id estable antes de sincronizar).
- Pesos en **kilogramos (kg)**.
- `created_at` en todas las tablas (timestamptz).
- Para sincronizar: `updated_at` (última modificación, lo fija el servidor) y
  `deleted_at` (borrado suave / soft delete) en las tablas de dominio.

## Tablas

### usuarios (perfil)
El login lo maneja Supabase Auth (`auth.users`). Esta tabla es el perfil público asociado.
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | igual al id de `auth.users` |
| nombre | text | |
| email | text | |
| cuenta_id | uuid → cuentas.id | la Cuenta propia del usuario |
| created_at | timestamptz | |

### fincas
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| nombre | text | obligatorio |
| foto_url | text | opcional (foto de la finca) |
| creada_por | uuid → usuarios.id | dueño original |
| cuenta_id | uuid → cuentas.id | Cuenta dueña/facturada (cuenta para el límite) |
| created_at | timestamptz | |

### finca_miembros — fincas compartidas + roles
Corazón del modelo multi-usuario. Define quién pertenece a cada finca y con qué rol.
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| finca_id | uuid → fincas.id | |
| usuario_id | uuid → usuarios.id | |
| rol | text | `admin` \| `operario` |
| created_at | timestamptz | |

Reglas:
- Restricción única `(finca_id, usuario_id)` — un usuario no se repite en la misma finca.
- El dueño es el primer miembro con rol `admin`. **Puede haber varios admins** (socios).
- Un usuario solo ve las fincas donde tiene una fila aquí, con los permisos de su rol.

### lotes
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| finca_id | uuid → fincas.id | |
| nombre | text | |
| numero | int | |
| created_at | timestamptz | |

### animales — inventario
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | id interno (invisible para el usuario) |
| finca_id | uuid → fincas.id | |
| lote_id | uuid → lotes.id | **obligatorio** (todo animal está en un lote) |
| identificador | text | el número/arete que digita el usuario |
| created_at | timestamptz | fecha de ingreso del animal |

Reglas:
- Restricción única `(finca_id, identificador)` — el arete no se repite dentro de una finca.
- **Mover de lote** = cambiar `lote_id`.
- Al **crear un animal** se registra también su **peso de entrada** como el primer `pesaje`
  (ver abajo).

### pesajes — historial de pesos
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| animal_id | uuid → animales.id | |
| peso | numeric | kg |
| fecha | timestamptz | |
| registrado_por | uuid → usuarios.id | |
| created_at | timestamptz | |

Cálculos derivados (no se guardan, se calculan):
- **Peso actual** del animal = su último pesaje.
- **Aumento entre pesajes** = peso − peso anterior.
- **Aumento total desde que llegó** = último peso − primer peso (el de entrada).
- **Ganancia diaria (kg/día)** opcional, usando las fechas.

## Roles y permisos (resumen)
- **admin:** todo en su finca + agregar/quitar usuarios y asignarles rol (admin u operario).
- **operario:** opera la finca (registra pesajes, mueve animales, etc.) pero no administra usuarios.
- Los permisos finos por pantalla se afinan al construir cada módulo.

## Futuro (anotado, no en v1)
- `movimientos_lote`: historial de cambios de lote por animal (origen, destino, fecha).
- Más atributos del animal (raza, sexo, fecha nacimiento, padres).
- Más tipos de evento (vacunas, tratamientos, partos, ventas).
