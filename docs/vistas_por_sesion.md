# Vistas y plantillas por sección

Esta nota resume qué plantilla usa cada sección del módulo y qué campos/acciones esperamos ver en la UI. Así cualquier desarrollador o chatbot puede verificar rápidamente si la vista que está renderizando coincide con el diseño acordado.

## Pedidos (`pedidos_tabla`)

- **Table View**: `TableViewTemplate`
  - Columnas fijas (override): Fecha de registro, Cliente, Estado pago/entrega/general.
  - Acciones: `Nuevo` abre el formulario; tap en fila abre el detalle.
- **Detail View**: `DetailViewTemplate`
  - Campos visibles: Fecha de registro, Cliente, Número de cliente, Observación.
  - Inline sections:
    - Detalle del pedido (lista editable).
    - Pagos registrados.
    - Movimientos asociados (abre la sección `movimientos`).
  - Botón flotante “Editar”.
- **Form View**: `FormViewTemplate`
  - Campos definidos en `Pedidos_VistaForm`.
  - Inline tables permitidas durante la edición (detalle, pagos, movimientos).

## Detalle de pedido (`pedidos_detalle`)

- **Detalle personal (standalone o desde inline)**:
  - Builder: `buildPedidosDetalleDetailView`.
  - Campos: Nombre (`producto_nombre`), Cantidad, Precio.
  - Reutiliza `DetailViewTemplate` para layout, incluyendo FAB “Editar”.
- **Form View**: `detallePedidosInlineFields`.
  - Disponible cuando se crea una línea desde el pedido o se abre la sección completa.

## Pagos (`pedidos_pagos`)

- **Detalle personal (standalone o desde inline)**:
  - Builder: `buildPagosVistaDetail`.
  - Campos: Fecha de registro, Fecha de pago (formateadas a `YYYY-MM-DD HH:MM:SS`), Monto y Cuenta bancaria.
- **Form View**: `Pagos_VistaForm`.

## Movimientos (`pedidos_movimientos` y `movimientos`)

- **Table View**: hereda la plantilla estándar con columnas según overrides.
- **Detail View**: usa el template global mostrando sólo los campos del movimiento y, si aplica, el detalle de productos. Los datos de destino Lima/Provincia ya llegan en la misma fila.
- **Form View**: ambos sections reutilizan `Movimientos_VistaForm`, añadiendo headers condicionales para Lima/Provincia en función de `es_provincia`.
- **Inline detail**: cuando se abre desde “Movimientos asociados”, la misma plantilla se reutiliza.

## Comportamiento de inline detail

- Todas las tablas inline (detalle, pagos, movimientos) vuelven a renderizarse dentro del shell principal usando `DetailViewTemplate`.
- Si la fila es un borrador (`__pending`) se oculta el botón de edición; en registros persistidos se muestra el FAB “Editar”.
- El estado del shell (menú izquierdo, sección activa) no se pierde; sólo el panel derecho cambia al detalle solicitado.
