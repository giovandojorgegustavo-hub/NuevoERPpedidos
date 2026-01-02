# Arquitectura general

Este documento complementa el README y explica cómo está organizado el proyecto, de modo que cualquier miembro del equipo (o asistente) pueda ubicar rápidamente dónde modificar plantillas, overrides o servicios.

## Capas principales

1. **Flutter App (`lib/src`)**
   - `app.dart`: `MaterialApp` + tema.
   - `auth/`: flujo de autenticación con Supabase.
   - `shell/`: contenedor principal (navegación, acciones globales).
   - `tablas/`: metadata y builders declarativos, organizados como `tablas/datos/<tabla>`, `tablas/vistas/<tabla>` y `tablas/acciones/<tabla>`.
   - `navegacion/`: registro de vistas, builders y lógica de ensamblado.
   - `shared/`: plantillas UI reutilizables (Table, Detail, Form, Inline Table).

2. **Servicios**
   - `ModuleRepository` (Supabase) obtiene metadata: módulos (`ui_modules`), secciones (`ui_sections`), data sources (`ui_section_data_sources`) y campos (`v_ui_section_fields`).
   - Las operaciones CRUD (insert/update/delete) viajan siempre por los `SectionDataSource` que define cada sección en Supabase.

3. **Metadata/Overrides (`lib/src/navegacion/registro_vistas.dart`)**
   - Define `SectionOverrides` con:
     - `formFields` para generar formularios.
     - `dataSource` para listar/editar.
     - `tableColumns`, `detailFields`, `inlineSections`.
     - `detailSubtitleBuilder`, acciones personalizadas, etc.
   - Esta capa determina qué columnas muestra la tabla, qué inline tables se habilitan y qué campos se enseñan en el detalle.

4. **Builders específicos (`lib/src/navegacion/detalle_builders.dart`)**
   - Permiten crear vistas de detalle completamente personalizadas pero manteniendo la plantilla `DetailViewTemplate`.
   - Actualmente tenemos builders para `pedidos_detalle` y `pedidos_pagos`.
5. **Shell dinámico**
   - `lib/src/shell/viewmodels/shell_view_model.dart` concentra el estado (módulo/sección activa, modo actual, perfil, caches).
   - `lib/src/shell/controllers/section_config_builders.dart` provee `TableConfigBuilder`, `DetailConfigBuilder` y `FormConfigBuilder`, que traducen la metadata en configs listas para las plantillas compartidas.
   - `lib/src/shell/ui/` contiene los widgets de layout del shell (`ShellContent`, `MobileShell`, `SectionContentView`), manteniendo `ShellPage` como orquestador ligero.

## Plantillas compartidas

- **TableViewTemplate**: búsqueda, filtros, ordenamiento, acciones por fila/lote, barra superior y `BulkActionBar`.
- **DetailViewTemplate**: header, lista de campos (`DetailFieldConfig`), inline tables y FAB “Editar”. Subtítulo opcional.
- **FormViewTemplate**: campos según `SectionField`, validación, inline tables embebidas, hooks para `onSubmit` y `onCancel`.
- **InlineTableTemplate**: DataTable con acciones inline, selección múltiple, placeholders y estados de carga.

## Inline detail flow

- En `_ShellPage`, `InlineSectionConfig` puede declarar `rowTapSectionId` o `formSectionId`. Cuando el usuario abre un registro inline:
  1. Si el target es una sección visible del módulo, el shell cambia a esa sección (modo detalle).
  2. Si no existe sección física (caso de líneas/pagos), `_openInlineDetailPage` crea un `DetailViewConfig` usando el builder correspondiente y actualiza el panel derecho sin recrear el menú izquierdo.
  3. `_activeInlineDetail` mantiene el estado actual y `_handleInlineDetailBack` vuelve al detalle del pedido padre.

- Los borradores (`_pendingInlineRows`) se muestran en las inline tables y se almacenan en memoria hasta que el pedido se guarda; luego `_persistPendingInlineRows` inserta cada fila en la tabla real.

## Convenciones

- Todas las tablas/vistas en Supabase siguen el patrón `v_<tabla>_vistageneral` para listar y `<tabla>` para INSERT/UPDATE.
- Las vistas por tabla viven en `lib/src/tablas/vistas/<tabla>` y la metadata en `lib/src/tablas/datos/<tabla>`; el registro y builders viven en `lib/src/navegacion`.
- Documentación relacionada:
  - `docs/metadata_overrides.md`: detalla cómo funcionan los overrides.
  - `docs/vistas_por_sesion.md`: mapea cada sección con su plantilla.
