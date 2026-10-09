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
| **Un identificador por animal** | Un solo número. RFID o manual en el **mismo campo**. Opcionalmente un **alias** (nombre corto: "Pinta", "23") para reconocerlo y buscarlo; no reemplaza al arete. |
| **Buscar sin digitar todo** | Todo campo donde se digita un arete es un **buscador**: con los últimos dígitos o el alias aparece la lista (arete · alias · lote) y se escoge. Con el lector entra el número completo como siempre. |
| **Nada se borra de verdad** | El animal vendido o muerto no se elimina: pasa a historial (trazabilidad). Un pesaje o una sanidad mal digitados se pueden borrar, pero el borrado es suave: queda el rastro. |
| **Todo alimenta la Hoja de Vida** | Pesaje, sanidad, dieta, cambio de lote, venta y muerte quedan registrados con fecha. |
| **La fecha es la del hecho** | Todo se registra con el día en que **pasó**, no el día en que se digitó. Por defecto es **hoy**; se puede escoger un día anterior (el peón pesa el 5 y el patrón lo pasa el 8). |

### Fechas: reglas para todo el sistema

- **Hoy por defecto** en todo campo de fecha: quien digita el mismo día no hace pasos de más.
- **Fechas imposibles se bloquean** con un mensaje que explica por qué:
  - una fecha que todavía no llega;
  - cualquier cosa del animal (pesaje, sanidad, cambio de lote, venta, muerte) **antes de su ingreso**;
  - una venta o una muerte **antes de su último pesaje**;
  - un cambio de lote **antes de su último cambio de lote**;
  - una dieta que empiece **antes que la dieta anterior** del lote.
- **Una sola fecha de ingreso** por animal: de ella salen la compra, la entrada al lote, el pesaje de entrada y el arranque de la dieta y de los gastos fijos.
- Un día que no es hoy se guarda al **mediodía** de ese día.
- **Rastro:** si algo se digitó otro día distinto al del hecho, la Hoja de Vida lo muestra: *"Pesado el 05/10 · digitado el 08/10 por Juan"*.

**Terminología:** *lote de manejo* = donde vive el animal en la finca. *Lote de venta* = grupo que se vende junto. Son conceptos distintos.

---

## Módulo 1 — Pantalla de Trabajo (Pesaje) ★ pantalla principal

Donde el ganadero trabaja en la manga. Todo gira alrededor de ella.

### Fecha de la jornada

- Arriba de la pantalla, siempre a la vista: **"Fecha: hoy"**. Al tocarla se escoge otro día.
- Todo lo que se digite queda con ese día: pesajes, animales nuevos (su ingreso) y la sanidad del botón flotante.
- Si no es hoy se pinta de **otro color** ("Digitando el 05/10/2026") con un botón **Volver a hoy**. Al volver a entrar a la pantalla es hoy otra vez.

### Registrar un pesaje

1. **Identificador:** RFID o escritura manual (mismo campo, "Arete o alias").
   - Escribiendo a mano, con **2 o más** caracteres aparece una lista: primero lo exacto,
     luego aretes que **terminan** en lo digitado o alias que **empiezan** así, luego los
     que lo contienen. Tocar uno llena el arete completo y pasa al peso.
   - El campo trae un botón **ABC / 123** para buscar el alias con letras.
   - Debajo del campo se ve el alias y el lote del animal que calza exacto.
   - Si se registra sin escoger y lo digitado no es un arete ni un alias exacto, pero se
     parece a otros, se pregunta **"¿Cuál es?"** con la lista y la opción **"Es nuevo"**.
   - Un alias con letras que no calza con nadie no crea un animal: los aretes son números.
2. **Peso:** solo manual por ahora.
3. **Animal existente:** guardar pesaje → aparece en la lista. Necesita peso.
4. **Animal nuevo:** ofrecer registrarlo de una vez, con lo mínimo:
   - Lote de entrada (tocar; lotes del Módulo 3).
   - **Peso de entrada** = peso recién digitado (editable). **Puede quedar vacío**: el animal entra sin pesar y su primer pesaje pasa a ser el de entrada.
   - **Compra**, una de tres:
     - **Por kilo:** precio por kilo × peso de entrada (necesita el peso).
     - **Monto total:** lo que costó el animal. El ₡/kg sale de dividir entre el peso de entrada; si entró sin pesar, se calcula solo con su primer pesaje.
     - **Nació en la finca:** compra ₡0.
   - **Alias** (opcional).

### Lista de pesajes digitados hoy (misma pantalla)

- Muestra lo **digitado hoy**, aunque sea de otro día (así se puede corregir). Lo que es de otro día lleva su fecha debajo del arete, y el alias si tiene.
- Un animal dado de alta **sin peso** también sale, con "—" y "Sin peso"; tocarlo deja ponerle el peso (queda como pesaje del día en que entró). Los contadores cuentan solo los pesados.
- Columnas: **Animal | Peso | Ganancia** (vs. pesaje anterior del mismo animal).
- **GMD (kg/día)** = (peso hoy − peso anterior) ÷ días entre pesajes. Número clave de engorde.
- **Pestañas por lote:** una por cada lote pesado.
- **Contador** de animales pesados visible.
- Si ese día ya se pesó y se vuelve a escanear: mostrar el registro y **preguntar si se corrige** (no duplicar: un animal, un peso por día).
- Corregir el lote de un animal recién dado de alta cambia su **lote de entrada** (no inventa un cambio de lote).

### Botón flotante de Sanidad (cruz)

Tras registrar el peso de un animal, se **habilita** un FAB con cruz de sanidad.

1. Abre modal con los **medicamentos** del Módulo 2.
2. Cada uno muestra la **dosis ya calculada** con el peso real recién pesado.  
   Ej.: Catosal “50 ml cada 10 kg”, animal 300 kg → dosis para 300 kg.
3. El usuario **toca** los que aplica (**N** medicamentos al mismo animal).
   La fecha de aplicación viene con la fecha de la jornada y se puede cambiar.
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
- **Dentro del lote:** lista con buscador (por arete o alias, sin importar mayúsculas ni tildes; el alias se ve debajo del arete); columnas **Animal | Peso actual**; acciones **Nuevo pesaje** (con fecha) y **Cambiar de lote**.
- **Cambiar de lote** se registra en la hoja de vida con el **día en que se movió** (hoy por defecto): hasta ese día come la dieta del lote viejo, desde ese día la del nuevo.
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
- Se asignan **desde un día** (hoy por defecto): si el lote ya la venía comiendo, se cobra desde el día real. La dieta anterior termina ese mismo día. Asignar la misma dieta desde antes corrige su inicio. Quitar la dieta también pregunta el día.
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
| **Pesajes** | Peso y GMD. Tocar uno → **corregir peso y día, o borrarlo** |
| **Sanidad** | Medicamento, dosis, fecha, retiro. Tocar uno → **borrarlo** |
| **Dietas** | Por rangos de fecha |
| **Cambios de lote** | Fechas |
| **Estado actual** | Arete y **alias** (lápiz para ponerlo, cambiarlo o quitarlo; no se repite entre animales activos ni puede ser el arete de otro), lote actual, peso actual, si está **en retiro** (y hasta cuándo), fecha de ingreso; botón **Registrar muerte** |
| **Venta** | Fecha, peso y precio de venta (cuando aplique). **Editar compra** (por kilo, monto total o nació) y **fecha de ingreso** |

### Muerte del animal

- Se registra desde la Hoja de Vida con el **día en que murió** (hoy por defecto).
- Sale del inventario (pasa a estado *muerto*) y su **dieta y gastos fijos se cortan ese día**; su parte de gastos fijos queda congelada, igual que en una venta.
- No puede ser antes de su ingreso ni de su último pesaje.

---

## Módulo 6 — Venta de animales

La venta ocurre en **dos momentos**, porque el ganadero no sabe cuánto le pagan
hasta que la planta liquida (D-19).

### Momento 1 — Armar el grupo de venta

1. Identificador (RFID o manual), con el mismo buscador por arete o alias que en Trabajo.
2. **Validación de retiro:** si hay retiro activo → **alerta y no permite vender**.
3. Digitar los **kilos de salida de la finca** → agregar a la lista. **Nada más:
   no se pide precio ni dinero**, porque todavía no se conocen.
4. Repetir con todos los animales.
5. **Confirmar**, con el **día en que salieron** (hoy por defecto). Dieta, gastos
   fijos, pesaje de salida y revisión del retiro se cortan **ese día**, aunque la
   venta se digite después. Si ese día ya se había pesado, los kilos de salida
   corrigen ese pesaje (no se duplica).
   - Salen de su **lote de manejo**.
   - Dejan de aparecer en pesaje y lotes.
   - Quedan en la pestaña **Historial** de este módulo.
   - Su utilidad se muestra como **“—”**: falta la liquidación.

### Momento 2 — Registrar los datos de planta, animal por animal

En el historial se toca cada animal del grupo y se registra:

| Dato | Cómo entra |
|---|---|
| **Peso en pie** | Digitado (el de la planta; puede diferir del de salida de finca) |
| **Peso en canal** | Digitado |
| **% de rendimiento** | **Calculado:** peso en canal ÷ peso en pie × 100 |
| **Dinero recibido** | Digitado. **De aquí sale la utilidad** |

Se pueden guardar datos parciales (por ejemplo solo los pesos) y completar el
dinero después. El ₡/kg de canal se muestra derivado (dinero ÷ peso en canal).

### Historial de ventas

- Cada confirmación es un **grupo de venta** (puede mezclar animales de distintos lotes de manejo).
- Por cada animal:

```text
Utilidad = Dinero recibido − (Precio de compra + Costo de dietas + Costo de sanidad + Gastos fijos)
```

| Componente | Origen |
|---|---|
| Precio de compra | Al ingresar el animal |
| Costo de dietas | Σ (₡/kg × kg por animal al día × días en cada dieta) |
| Costo de sanidad | Σ costo por uso de medicamentos aplicados |
| Gastos fijos | Parte prorrateada por días-animal (Módulo 7) |
| Dinero recibido | Registrado con los datos de planta |

### Análisis por grupo de venta

Cada grupo muestra, sobre los animales ya liquidados:

| Dato | Cálculo |
|---|---|
| Utilidad total | Σ utilidad de los animales con dinero registrado |
| **Rendimiento promedio** | Promedio simple del % de los que tienen los dos pesos |
| Dinero recibido total | Σ dinero recibido |
| Kilos de salida / en pie / de canal | Σ de cada peso |
| ₡ por kilo de canal | dinero total ÷ kilos de canal totales |
| Animales pendientes | Cuántos del grupo aún no tienen liquidación |

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
| Rendimiento / animal | peso en canal ÷ peso en pie × 100 |
| Utilidad / animal | **dinero recibido** − (compra + dietas + sanidad + gastos fijos) |
| Utilidad / grupo de venta | Σ utilidad de los animales ya liquidados del grupo |
| Rendimiento promedio / grupo | promedio simple del rendimiento de los que lo tienen |
| ₡ por kilo de canal | dinero recibido ÷ peso en canal |

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
  **Sí** entra el análisis por **grupo de venta** del Módulo 6 (utilidad total y rendimiento
  promedio), porque está descrito ahí (D-19).

Plataforma base (auth, fincas, cuenta/licencia, sync) se mantiene como infraestructura; no es “módulo de campo” de esta especificación, pero tampoco se elimina.

Documentos técnicos (`MODELO_DATOS`, `DECISIONES`, `QA_AUTOMATION`, roadmap de implementación) deben **alinearse a este documento**, no al revés.
