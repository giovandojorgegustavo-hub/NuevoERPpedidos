## Servicios de dominio

Estos servicios concentran las reglas de negocio que antes vivían en
`ShellPage`, lo que permite que el shell solo orqueste navegación y UI.

- `pedidos/pedido_inline_service.dart`: valida cuándo se pueden crear inlines
  de pedidos (movimientos/pagos) y calcula totales y saldos pendientes
  reutilizando datos persistidos + borradores.
- `movimientos/movimiento_service.dart`: encapsula las validaciones de
  movimientos (campos requeridos, cantidades pendientes) y los filtros de
  referencias basados en el cliente seleccionado.

ShellPage y los controladores consultan estos servicios antes de mostrar
formularios o ejecutar acciones, manteniendo el comportamiento existente pero
con responsabilidades separadas.
