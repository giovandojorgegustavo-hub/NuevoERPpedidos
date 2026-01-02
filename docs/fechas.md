# Fechas: reglas y flujo de datos

Este documento describe la forma correcta de manejar fechas para evitar
desfases UTC/local, duplicar lógica o romper orden/filtros.

## Principios

- Display: el formateo por tipo (fechas) vive en un solo lugar.
- Transformers por tabla: solo lógica de negocio (labels, estados, cálculos).
- Persistencia: siempre UTC ISO, sin cambios en este flujo.
- No usar `*_display` por ahora.

## Flujo actual (aprobado)

1. Carga de datos:
   - `ShellController._loadSectionData` normaliza una sola vez.
   - `normalizeRowForDisplay`:
     - limpia strings vacíos / "null"
     - formatea fechas usando `formatLocalDateTimeFromValue`
2. Transformers por tabla:
   - solo derivaciones de negocio (no formatear fechas).
3. Guardado:
   - `SectionFormCoordinator` normaliza a UTC ISO.

## Archivos clave

- Normalizador global: `lib/src/shared/utils/row_normalizers.dart`
- Detección de campos fecha: `lib/src/shared/utils/template_formatters.dart`
- Utilidades de fechas: `lib/src/shared/utils/date_time_utils.dart`
- Persistencia (UTC ISO): `lib/src/shell/section_form_coordinator.dart`

## Reglas concretas

### SIEMPRE hacer
- Usar `normalizeRowForDisplay` para fechas en UI.
- Mantener el valor original de la fecha en el row (se formatea en el mismo key).
- Mantener el guardado en UTC ISO (`normalizeToUtcIsoString`).

### NUNCA hacer
- No formatear fechas en `tablas/datos/...` ni `tablas/vistas/...`.
- No agregar parse/format manual en transformers por tabla.
- No crear `*_display` para fechas sin aprobación explícita.

## Detección de campos fecha

La detección está limitada a:
- claves que terminan en `_at`
- tokens que empiezan con `fecha` o `date` (por ejemplo `fecha`, `fecha_pago`,
  `date_created`)

No agregar heurísticas adicionales sin aprobación. Si un campo no encaja:
1. Preferir alias en la vista SQL para incluir `_at` o `fecha_*`.
2. Si no es posible, pedir aprobación para ampliar `isDateFieldKey`.

## Cómo agregar un nuevo campo fecha

1. Asegurar que el nombre de la columna cumple el criterio de detección.
2. No tocar transformers por tabla para formatear la fecha.
3. Verificar en UI que el formato `YYYY-MM-DD HH:mm:ss` en horario local
   aparece consistente.

## Orden y filtros

El formato `YYYY-MM-DD HH:mm:ss` conserva orden lexicográfico cronológico.
Se acepta este riesgo por ahora. Si aparece un problema real de orden o filtro,
se evaluará migrar a `*_display` con aprobación explícita.
