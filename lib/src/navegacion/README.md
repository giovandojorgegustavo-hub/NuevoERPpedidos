# Navegación y overrides

Esta carpeta conecta la metadata declarativa (`tablas/datos`) con las plantillas
UI (`shared/`). Contiene:

- `registro_vistas.dart`: mapa `kSectionOverrides` que indica, por sección,
  qué formulario, datasource, columnas, inline y acciones usar. Importa las
  constantes de `tablas/datos/<tabla>` y las expone al shell.
- `inline_types.dart`: typedefs y contextos para los builders inline
  (`InlineSectionViewBuilder`, `InlinePendingDisplayBuilder`).
- `inline_builders.dart`: registro de funciones que personalizan inline
  sections. Cuando un `InlineSectionConfig` define `builderSectionId`, el shell
  consulta este mapa.
- `detalle_builders.dart`: builders para `DetailViewTemplate` cuando se necesita
  un layout distinto al genérico.
- `detail_field_override.dart`: modelo simple para definir campos visibles en
  el Detail View.

El shell (`shell_page.dart`) solo conoce este registro y las plantillas
compartidas. Cualquier personalización nueva pasa primero por `registro_vistas`,
manteniendo separada la metadata de la lógica de UI. Los controladores del shell
(por ejemplo `InlineTablePresenter` y `TableConfigBuilder` en `shell/controllers`)
consumen estos builders para montar las vistas dinámicas sin acoplar la UI a casos
puntuales.
