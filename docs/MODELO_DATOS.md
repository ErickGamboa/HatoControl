# HatoControl — Modelo de datos (v1)

Software as a Service para manejo de hato ganadero. Offline-first: base **SQLite local
con Drift** y una **capa de sincronización propia** hacia Supabase (Postgres).

Módulos de esta primera etapa: **fincas, lotes, inventario (animales), pesaje**.
Módulo 2 (dietas + movimientos de lote) documentado abajo; aplicar el schema
via `supabase db push` (`supabase/migrations/20260707203015_module2_dietas.sql`)
antes de sincronizar — ver `docs/SUPABASE_SQL_ORDER.md`.
Módulo 3 (sanidad): `supabase/migrations/20260707203017_module3_sanidad.sql`.
**Documento oro (jul 2026):** catálogo `medicamentos`, `dieta_ingredientes`,
`lotes_venta`, columnas de retiro/dosis en `eventos_sanitarios` y
`peso`/`lote_venta_id` en `ventas` — Drift v12 +
`supabase/migrations/20260723120000_oro_medicamentos_ventas.sql`.
Comportamiento de producto: `docs/ESPECIFICACION_FUNCIONAL.md`.

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

Cálculos derivados (no se guardan, se calculan; ver
`lib/data/estadisticas/estadisticas_pesajes.dart`):
- **Peso actual** del animal = su último pesaje.
- **Aumento entre pesajes** = peso − peso anterior.
- **Aumento total desde que llegó** = último peso − primer peso (el de entrada).
- **Ganancia diaria (kg/día)** usando días de CALENDARIO entre fechas.
- **Ganancia promedio global** = (último − primero) / días de calendario.
- **Resumen por lote** (D-01): los pesajes de los animales del lote se
  agrupan por fecha de calendario ("jornadas"); por período se calcula
  cantidad de animales, peso promedio/mínimo/máximo, ganancia promedio y
  kg/día promedio, comparando cada animal contra su propio pesaje anterior.

### dietas — catálogo por finca (módulo 2)
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| finca_id | uuid → fincas.id | |
| nombre | text | |
| descripcion | text | opcional |
| costo_kg | numeric | ₡ por kilo de alimento — **lo digita el ganadero** |
| kg_animal_dia | numeric | kilos por animal al día — **lo digita el ganadero** |
| costo_animal_dia | numeric | derivado: `costo_kg × kg_animal_dia` (D-02) |
| costo_animal_semana | numeric | derivado: `costo_animal_dia × 7`, solo para mostrar |
| moneda | text | default `CRC` (D-07) |
| created_at | timestamptz | |
| updated_at | timestamptz | |
| deleted_at | timestamptz | borrado suave |

### ventas — venta de un animal (módulo 6)
La venta se registra en dos momentos (D-19): al armar el grupo solo se conocen
los kilos de salida; los datos de planta llegan después.

| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| animal_id | uuid → animales.id | |
| lote_venta_id | uuid → lotes_venta.id | el grupo de venta |
| fecha | timestamptz | |
| peso | numeric | **kilos de salida de la finca**, digitados al armar el grupo |
| peso_pie | numeric | kilos en pie en la planta — digitado después |
| peso_canal | numeric | kilos de canal — digitado después |
| rendimiento | numeric | derivado: `peso_canal / peso_pie * 100` |
| dinero_recibido | numeric | ₡ recibidos. **Fuente de la utilidad**; NULL = utilidad “—” |
| precio | numeric | espejo de `dinero_recibido` (0 mientras no haya liquidación) |
| precio_kg | numeric | derivado: `dinero_recibido / peso_canal` |
| comprador | text | opcional |
| observaciones | text | opcional |

### lote_dietas — historial de asignación dieta ↔ lote
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| lote_id | uuid → lotes.id | |
| dieta_id | uuid → dietas.id | |
| desde | timestamptz | inicio de vigencia |
| hasta | timestamptz | null = vigente |
| costo_animal_dia_snapshot | numeric | costo congelado al asignar |
| created_at | timestamptz | |
| updated_at | timestamptz | |
| deleted_at | timestamptz | |

Reglas:
- Solo una asignación vigente (`hasta IS NULL`) por lote.
- Reasignar cierra la anterior y abre una nueva en la misma transacción local.

### movimientos_lote — historial de cambios de lote (D-05)
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| animal_id | uuid → animales.id | |
| lote_origen | uuid → lotes.id | null en ingreso inicial |
| lote_destino | uuid → lotes.id | |
| fecha | timestamptz | |
| created_at | timestamptz | |
| updated_at | timestamptz | |
| deleted_at | timestamptz | |

Se escribe al crear animal (origen null) y al mover de lote.

### eventos_sanitarios — sanidad por animal (módulo 3, D-04)
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| animal_id | uuid → animales.id | |
| tipo | text | `vacuna` \| `medicamento` \| `desparasitacion` \| `otro` |
| producto | text | nombre del producto |
| dosis | text | opcional |
| fecha | timestamptz | |
| responsable_id | uuid → usuarios.id | opcional |
| observaciones | text | opcional |
| costo | numeric | opcional; alimenta módulo 4 |
| created_at | timestamptz | |
| updated_at | timestamptz | |
| deleted_at | timestamptz | borrado suave |

Reglas:
- Un registro por aplicación por animal; el modo lote crea N filas en una transacción.
- `costo` nullable hasta que se use en ventas/rentabilidad.

### feature_flags — módulos on/off por scope (módulo 5, D-15)
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| scope | text | `global` \| `cuenta` \| `finca` |
| scope_id | uuid | null solo si `scope = 'global'` |
| clave | text | nombre del módulo/feature, p. ej. `dietas` |
| habilitado | boolean | default `true` |
| nota | text | opcional, para el admin que gestiona el flag |
| created_at | timestamptz | |
| updated_at | timestamptz | |
| deleted_at | timestamptz | borrado suave |

Reglas:
- **Solo lectura desde la app.** RLS solo otorga `SELECT` a `authenticated`;
  el CLI (`hatoctl`, workstream aparte) escribe con `service_role`. Por eso
  la tabla local **no tiene columna `pendiente`**: nunca hay un cambio local
  que subir, así que el invariante habitual "escritura local ⇒
  `pendiente=true`" no aplica aquí (excepción documentada, no un olvido).
  `SyncService` solo la BAJA, nunca la sube.
- Resolución de `FeatureFlagsRepository.isEnabled(clave, ...)`: precedencia
  **finca > cuenta > global > defaultValue** (fail-open): si no hay fila en
  ningún scope para esa `clave`, se asume habilitado a menos que se pase
  `defaultValue: false`.

### gastos_fijos — gastos indirectos de la finca (módulo 7, D-17)
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| finca_id | uuid → fincas.id | el gasto solo se reparte entre animales de esta finca |
| concepto | text | "Salario peón", "Luz" |
| monto | numeric | ₡ por mes si `periodicidad = 'mensual'`; ₡ del gasto si `'unico'` |
| periodicidad | text | `mensual` \| `unico` |
| desde | timestamptz | mensual: 1° del mes en que empieza · único: fecha del gasto |
| hasta | timestamptz | null = vigente; se llena al dar de baja |
| moneda | text | default `CRC` (D-07) |
| created_at | timestamptz | |
| updated_at | timestamptz | |
| deleted_at | timestamptz | borrado suave |

### gasto_fijo_cargos — parte congelada por animal (módulo 7, D-17)
| Campo | Tipo | Notas |
|---|---|---|
| id | uuid (PK) | |
| gasto_fijo_id | uuid → gastos_fijos.id | |
| animal_id | uuid → animales.id | |
| mes | timestamptz | primer día del mes al que corresponde el cargo |
| dias | int | días-animal que le tocaron en ese mes |
| monto | numeric | ₡ congelados |
| created_at | timestamptz | |
| updated_at | timestamptz | |
| deleted_at | timestamptz | borrado suave |

Reglas:
- Se escribe **solo al vender** (o al salir el animal). Mientras el animal está activo su
  parte se calcula en vivo y no se persiste.
- Único por `(gasto_fijo_id, animal_id, mes)` entre filas no borradas.
- El prorrateo de un mes descuenta lo ya congelado y reparte el resto entre los animales
  activos por días-animal — así un gasto digitado atrasado lo absorben solo los no vendidos
  y la suma sigue siendo el 100% del gasto.

## Roles y permisos (resumen)
- **admin:** todo en su finca + agregar/quitar usuarios y asignarles rol (admin u operario).
- **operario:** opera la finca (registra pesajes, mueve animales, etc.) pero no administra usuarios.
- Los permisos finos por pantalla se afinan al construir cada módulo.

## Futuro (anotado, no en v1)
- `movimientos_lote`: historial de cambios de lote por animal (origen, destino, fecha).
- Más atributos del animal (raza, sexo, fecha nacimiento, padres).
- Más tipos de evento (vacunas, tratamientos, partos, ventas).
