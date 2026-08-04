# HatoControl — Especificación funcional

> **Estado:** documento oro (fuente de verdad del producto).  
> **Para:** Mainor (desarrollo) · **De:** Erick  
> **Qué es:** describe **cómo debe comportarse la app**, no cómo está hoy.  
> **Regla:** si una función **no está aquí**, no pertenece al producto — no se construye; si ya existe, se elimina o se alinea.

App para un **ganadero de campo**: sencilla, **mucho de tocar y poco de escribir**, **offline-first** (la sync a Supabase va en segundo plano).

---

## Principios generales

| Principio | Comportamiento |
|---|---|
| **Offline primero** | Todo se registra y se ve sin señal. Sync automática cuando hay internet. |
| **Poco teclado** | Toques y valores por defecto. Escribir solo lo mínimo (peso, precios). |
| **Una finca activa** | Todos los módulos operan sobre la finca seleccionada. |
| **Un identificador por animal** | Un solo número. RFID o manual en el **mismo campo**. Sin número visual aparte (por ahora). |
| **Nada se borra** | El animal vendido no se elimina: pasa a historial (trazabilidad). |
| **Todo alimenta la Hoja de Vida** | Pesaje, sanidad, dieta, cambio de lote y venta quedan registrados con fecha. |

**Terminología:** *lote de manejo* = donde vive el animal en la finca. *Lote de venta* = grupo que se vende junto. Son conceptos distintos.

---

## Módulo 1 — Pantalla de Trabajo (Pesaje) ★ pantalla principal

Donde el ganadero trabaja en la manga. Todo gira alrededor de ella.

### Registrar un pesaje

1. **Identificador:** RFID o escritura manual (mismo campo).
2. **Peso:** solo manual por ahora.
3. **Animal existente:** guardar pesaje → aparece en la lista del día.
4. **Animal nuevo:** ofrecer registrarlo de una vez, con lo mínimo:
   - Lote de entrada (tocar; lotes del Módulo 3).
   - **Precio de compra** y **peso de compra**.
     - Peso de compra = peso recién digitado (editable).
     - Opción **nació en la finca** → sin precio de compra (o costo aparte si se define después).

### Lista de pesajes del día (misma pantalla)

- Columnas: **Animal | Peso | Ganancia** (vs. pesaje anterior del mismo animal).
- **GMD (kg/día)** = (peso hoy − peso anterior) ÷ días entre pesajes. Número clave de engorde.
- **Pestañas por lote:** una por cada lote pesado hoy.
- **Contador** de animales pesados visible.
- Si ya se pesó hoy y se vuelve a escanear: mostrar el registro y **preguntar si se corrige** (no duplicar).

### Botón flotante de Sanidad (cruz)

Tras registrar el peso de un animal, se **habilita** un FAB con cruz de sanidad.

1. Abre modal con los **medicamentos** del Módulo 2.
2. Cada uno muestra la **dosis ya calculada** con el peso real recién pesado.  
   Ej.: Catosal “50 ml cada 10 kg”, animal 300 kg → dosis para 300 kg.
3. El usuario **toca** los que aplica (**N** medicamentos al mismo animal).
4. Cada aplicación va a la hoja de vida: medicamento, dosis, fecha, **días de retiro**, **costo**.
5. Con retiro: el animal queda **en retiro** hasta `fecha aplicación + días de retiro`.

---

## Módulo 2 — Sanidad

Catálogo de medicamentos de la finca. Se registran una vez; luego aparecen en el modal de la Pantalla de Trabajo.

### Datos del medicamento

- **Nombre** (ej. Catosal).
- **Costo del envase** (ej. ₡10.000).
- **Rendimiento del envase:**
  - Líquidos → tamaño en **ml** (ej. 400 ml).
  - Spray / por rendimiento → **número de aplicaciones** (ej. 50).
- **Tipo de aplicación** (define dosis y costo):
  1. **Por peso** (inyectable / pour-on): cantidad por cada X kg (ej. 50 ml cada 10 kg). La app calcula ml según peso real.
  2. **Dosis fija:** misma cantidad sin importar el peso (ej. 5 ml).
  3. **Por aplicación (spray):** cada uso = **1 aplicación** (sprays, curabicheras, garrapaticidas “al ojo”, etc.).
- **Días de retiro** (ej. 30).

### Costo por uso (suma a la utilidad)

Calculado solo a partir de costo y rendimiento del envase:

| Tipo | Fórmula | Ejemplo |
|---|---|---|
| Líquido / inyectable | `costo envase ÷ ml envase × ml aplicados` | ₡10.000 / 10 ml × 2 ml = **₡2.000** |
| Spray / bañable | `costo envase ÷ aplicaciones que rinde` | ₡15.000 / 50 = **₡300** |

La dosificación calcula sola cuánto aplicar y cuánto cuesta según el peso en el momento del pesaje.

---

## Módulo 3 — Lotes

- **Crear lotes** con **nombre** y **número**, ambos editables.
- Son los lotes que se eligen al registrar un animal nuevo en Pesaje.
- **Dentro del lote:** lista con buscador; columnas **Animal | Peso actual**; acción **Cambiar de lote**.
- **Cambiar de lote** se registra en la hoja de vida (con fecha).
- **Tocar un animal** → abre su **Hoja de Vida**.

---

## Módulo 4 — Dietas

Debe ser **sencillo**.

- **Crear dieta:** nombre, **costo por kilo** del alimento, **kilos por animal
  al día**, e **ingredientes** (solo nombres, informativos).
- El costo por animal es **derivado**, no se digita:

```text
costo por animal / día    = costo por kilo × kilos por animal al día
costo por animal / semana = costo por animal / día × 7
```

- La pantalla muestra el resultado en vivo mientras se digita, para que el
  ganadero confirme el número antes de guardar.
- Las dietas se **asignan a lotes** → y por tanto a la hoja de vida de cada animal del lote.
- Al asignar se **congela** el costo/día en la asignación (`lote_dietas`), así
  cambiar después el precio del alimento no altera el historial.
- **Rangos de fecha** si el animal cambia a un lote con otra dieta:
  - *Del [fecha] al [fecha]: Dieta A*
  - *Del [fecha] al [fecha]: Dieta B*
- **Costo total de alimentación** = Σ (costo/día de la dieta × días en ella)
  = Σ (₡/kg × kg por animal al día × días en esa dieta).

---

## Módulo 5 — Hoja de Vida del animal

Consulta de cualquier animal (también al tocar uno en la lista de un lote).

Ordenado por fecha, muestra:

| Sección | Contenido |
|---|---|
| **Pesajes** | Peso y GMD |
| **Sanidad** | Medicamento, dosis, fecha, retiro |
| **Dietas** | Por rangos de fecha |
| **Cambios de lote** | Fechas |
| **Estado actual** | Lote actual, peso actual, si está **en retiro** (y hasta cuándo) |
| **Venta** | Fecha, peso y precio de venta (cuando aplique) |

---

## Módulo 6 — Venta de animales

### Registrar la venta

1. Identificador (RFID o manual).
2. **Validación de retiro:** si hay retiro activo → **alerta y no permite vender**.
3. Digitar **peso** y **precio de venta** → agregar a la lista de la venta en curso.
4. Repetir con todos los animales.
5. **Confirmar la venta:**
   - Salen de su **lote de manejo**.
   - Dejan de aparecer en pesaje y lotes.
   - Quedan en la pestaña **Historial de ventas** de este módulo.

### Historial de ventas

- Cada confirmación es un **lote de venta** (puede mezclar animales de distintos lotes de manejo).
- Por cada lote de venta se muestra la **utilidad**:

```text
Utilidad = Precio de venta − (Precio de compra + Costo de dietas + Costo de sanidad + Gastos fijos)
```

| Componente | Origen |
|---|---|
| Precio de compra | Al ingresar el animal |
| Costo de dietas | Σ (₡/kg × kg por animal al día × días en cada dieta) |
| Costo de sanidad | Σ costo por uso de medicamentos aplicados |
| Gastos fijos | Parte prorrateada por días-animal (Módulo 7) |
| Precio de venta | Digitado al vender |

---

## Módulo 7 — Gastos fijos

Gastos de la finca que **no son de un animal en particular**: salario del peón, luz, agua,
combustible, reparaciones. Se reparten entre los animales para que la utilidad sea real y no
solo la diferencia de compra-venta menos costos directos.

### Qué se digita

| Campo | Comportamiento |
|---|---|
| Concepto | Texto libre corto ("Salario peón", "Luz") |
| Monto | ₡ por mes si se repite; ₡ del gasto si es único |
| ¿Se repite cada mes? | Sí = gasto mensual recurrente · No = gasto de una sola vez |
| Desde | Mes en que empieza (recurrente) o fecha (único) |
| Hasta | Solo al dar de baja. Vacío = sigue vigente |

Un gasto recurrente se digita **una sola vez** y el sistema lo aplica solo cada mes hasta que
se da de baja. El ganadero no vuelve a digitarlo.

### Cómo se reparte (prorrateo por días-animal)

El gasto del mes se divide entre el **total de días que todos los animales estuvieron en la
finca ese mes**, y a cada animal se le carga su parte:

```text
días-animal del mes = Σ (días que estuvo cada animal en la finca ese mes)
parte del animal    = monto del mes × sus días ÷ días-animal del mes
```

Ejemplo: peón ₡300.000 en un mes de 31 días, 10 animales el mes completo y 1 que entró el
día 20 (12 días) → 10×31 + 12 = **322 días-animal** → ₡931,68 por animal-día. El que estuvo
todo el mes absorbe ₡28.882 y el que entró tarde ₡11.180. La suma de todas las partes es
**exactamente ₡300.000**.

### Reglas

1. **Alcance por finca.** Un gasto pertenece a una finca y solo se reparte entre sus animales.
2. **Mes en curso:** se devenga por día transcurrido (monto × días transcurridos ÷ días del
   mes), igual que la dieta corre día por día. No se carga el mes completo por adelantado.
3. **Se congela al vender.** Al confirmar la venta, la parte acumulada de ese animal queda
   guardada y su utilidad **no vuelve a cambiar nunca**.
4. **Un gasto digitado atrasado se reparte solo entre los animales no vendidos.** Lo ya
   congelado no se toca; el resto lo absorben los que todavía están en la finca.
5. **Sin animales activos no se reparte nada.** El gasto queda registrado, sin cargo. No es
   un error.
6. **Animal sin venta:** el gasto fijo se muestra acumulado en vivo, pero la utilidad sigue
   en `—` (regla general: sin venta no hay utilidad).

---

## Cálculos clave (norma)

| Cálculo | Fórmula |
|---|---|
| Ganancia entre pesajes | peso actual − peso anterior |
| GMD (kg/día) | (peso actual − peso anterior) ÷ días entre pesajes |
| Dosis por peso | (cantidad por cada X kg) según peso del animal |
| Dosis fija | cantidad fija |
| Dosis spray | 1 aplicación |
| Costo uso (líquido) | costo envase ÷ ml envase × ml aplicados |
| Costo uso (spray) | costo envase ÷ aplicaciones que rinde |
| Fin de retiro | fecha aplicación + días de retiro |
| Costo dieta / animal / día | costo por kilo × kilos por animal al día |
| Costo dieta / animal | Σ (costo/día × días en esa dieta) |
| Costo sanidad / animal | Σ costo por uso de cada aplicación |
| Gasto fijo / animal-día | monto del mes ÷ Σ días-animal del mes |
| Gasto fijo / animal | Σ (por mes: monto por repartir × sus días ÷ días-animal del mes) |
| Utilidad / animal | venta − (compra + dietas + sanidad + gastos fijos) |
| Utilidad / lote de venta | Σ utilidad de los animales del lote |

---

## Fuera de alcance (no construir / retirar si existe)

Todo lo que no esté en los módulos 1–7 ni en los principios anteriores. En particular, **no** forman parte de esta visión:

- Pantalla **Corral** paralela a Pesaje (la Pantalla de Trabajo **es** Pesaje).
- Historial agregado / gráficas por **lote** como módulo aparte.
- Catálogo sanitario distinto al modelo de medicamentos + dosis/costo/retiro de aquí.
- Economía con “otros costos” **por animal** (tabla `costos_otros`), márgenes o rentabilidades:
  siguen **fuera** de la fórmula de utilidad. Los gastos fijos del Módulo 7 **sí** entran, y son
  el único costo indirecto admitido.
- Feature flags de producto, comparativas entre dietas/lotes, u otros dashboards no descritos.

Plataforma base (auth, fincas, cuenta/licencia, sync) se mantiene como infraestructura; no es “módulo de campo” de esta especificación, pero tampoco se elimina.

Documentos técnicos (`MODELO_DATOS`, `DECISIONES`, `QA_AUTOMATION`, roadmap de implementación) deben **alinearse a este documento**, no al revés.
