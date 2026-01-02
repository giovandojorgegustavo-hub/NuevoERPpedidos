# Metadata y Overrides

Este proyecto se apoya en dos piezas para mantener las vistas declarativas:

1. **Metadata clásico**  
   - Cada tabla/vista tiene un `SectionDataSource` y su lista de `SectionField`.  
   - Están definidos en `lib/src/tablas/datos/<tabla>/*_vista_form.dart` y `*_vista_config.dart`.  
   - `registro_vistas.dart` importa esas constantes y las asocia a cada `sectionId`.  
   - Controlan columnas, tipos de widget (`reference`, `staticOptions`, etc.) y defaults.

2. **Overrides de renderizado**  
   - `SectionOverrides` agrega comportamientos que no están en la metadata pura, por ejemplo columnas fijas, transformaciones de filas, `InlineSectionConfig`, acciones personalizadas.  
   - Las inline se declararon con dos banderas adicionales:
     - `renderAsFormFields`: permite renderizar la tabla hija como campos embebidos en el formulario padre sin duplicar lógica.  
     - `captureDuringCreate`: indica si esos datos deben guardarse como borrador (`_inlineDraftRows`) y persistirse al final mediante `_persistInlineDraftRows`.
   - Si la bandera no está activa, la misma configuración se usa para renderizar una tabla inline clásica y la vista completa (Table View).

## Flujo Shell ↔ Plantillas

- `ShellPage` lee toda la metadata y decide cómo instanciar las plantillas:
  1. **Table View** (`TableViewTemplate`): para las vistas principales y para cualquier inline que abra “Ver”. Usa los mismos `TableAction` (row, bulk, primary) definidos en el módulo.
  2. **Detail View** (`DetailViewTemplate`): muestra los campos definidos en metadata y, si corresponde, tabla inline o secciones embebidas.
  3. **Form View** (`FormViewTemplate`): genera los campos del formulario y, gracias a `embeddedSections`, también puede mostrar los campos de las tablas hijas cuando `renderAsFormFields=true`.
- Las filas pendientes (inline en borrador) se almacenan en `_pendingInlineRows` junto con un `pending_id`. Todas las plantillas consumen ese estado para renderizar las filas en tiempo real aunque todavía no existan en Supabase.

## Normalización lograda

- Movimientos ahora expone todos los campos en un sólo formulario (`Movimientos_VistaForm`), con condicionales `es_provincia` para mostrar Lima o Provincia. Ya no renderizamos ni persistimos secciones hijas (`movimientos_destino_*`), lo que evita pending rows personalizados en el shell.
- Las plantillas son reutilizables porque toda la variación se explica en metadatos y overrides.  
- Podrás replicar cualquier módulo copiando su carpeta de metadata/overrides y documentando las banderas especiales (inline como formulario, acciones, etc.).  
- Si en el futuro Flutter añade más lógicas similares, basta con anexar nuevas banderas/overrides sin tocar la metadata básica.

## Checklist para nuevas secciones

1. Crea `lib/src/tablas/datos/<tabla>/<tabla>_vista_form.dart` con los `SectionField`.
2. Declara `SectionDataSource`, `TableColumnConfig`, `DetailFieldOverride` e
   `InlineSectionConfig` (si aplica) en `*_vista_config.dart`.
3. Agrega la entrada correspondiente en `lib/src/navegacion/registro_vistas.dart`
   referenciando las constantes anteriores.
4. Sólo si necesitas layout adicional, crea archivos en
   `lib/src/tablas/vistas/<tabla>/` y regístralos en `inline_builders.dart` o
   `detalle_builders.dart`.
5. Define acciones en `lib/src/tablas/acciones/<tabla>/` y conéctalas vía
   `SectionOverrides`.
