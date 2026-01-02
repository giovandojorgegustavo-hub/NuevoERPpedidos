# Estructura de tablas (datos, vistas y acciones)

Este proyecto ya migró a un esquema ordenado por tipo de recurso. Cada tabla maestra
vive en tres carpetas principales dentro de `lib/src/tablas/`:

```
tablas/
├── datos/<tabla>/
│   ├── *_vista_form.dart
│   └── *_vista_config.dart (datasource, columnas, inline)
├── vistas/<tabla>/
│   ├── *_vista_tabla.dart / detail / inline
│   └── otros builders específicos
└── acciones/<tabla>/
    └── archivos con `List<TableAction>` o builders de acciones
```

## Flujo

1. **Metadata (datos/)**: define los `SectionField` y `SectionDataSource` que
   Supabase necesita para listar/editar. Si la tabla expone inline sections,
   también declara sus `InlineSectionConfig` aquí.

2. **Registro (`lib/src/navegacion/registro_vistas.dart`)**: importa los archivos
   de `datos/` y referencia sus constantes en `kSectionOverrides`. Ahí se indica
   qué formulario usa cada sección, qué datasource le corresponde, qué inline se
   embebe y qué builder custom (si aplica).

3. **Builders (vistas/)**: implementan layouts personalizados usando las
   plantillas compartidas (`TableViewTemplate`, `DetailViewTemplate`,
   `InlineTableTemplate`). Sólo se crean cuando hace falta formateo extra; el
   resto se resuelve con los overrides definidos en el registro.

4. **Acciones (acciones/)**: cualquier acción de tabla se declara aquí y luego se
   enchufa desde el registro para que el shell la agregue a las plantillas.

## Ejemplo (Pedidos)

- Metadata: `tablas/datos/pedidos/pedidos_vista_form.dart` (campos),
  `tablas/datos/pedidos/pedidos_vista_config.dart` (datasource, columnas,
  inline).
- Builders: `tablas/vistas/pedidos/pedidos_vista_tabla.dart`,
  `pedidos_vista_detail.dart`, `pedidos_movimientos_inline_view.dart`.
- Acciones: `tablas/acciones/pedidos/pedidos_acciones.dart` (placeholder).
- Registro: la entrada `'pedidos_tabla'` en `registro_vistas.dart` usa esas
  constantes y, por lo tanto, el shell renderiza Table/Form/Detail sin código
  adicional.

Cuando un nuevo módulo siga esta plantilla, cualquier desarrollador o agente
podrá ubicar la metadata, los builders y las acciones en segundos. Si detectamos
una tabla fuera de esta estructura, la documentación sirve como referencia para
normalizarla.
