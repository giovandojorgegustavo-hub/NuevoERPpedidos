# Contrato de totales del pedido

## Inventario de dependencias

### SQL (posgres.sql)
- `v_pedidosestadopago_cargo`
  - definición: `posgres.sql:9548`
  - usa `viajes_devueltos` con `estado != 'pendiente'` para `total_cargos_cliente`
  - uso en `public.v_pedidoestadopago`: `posgres.sql:9635`
- `v_pedidoestadopago`
  - definición: `posgres.sql:9580`
  - uso en `public.v_pedido_estado_general`: `posgres.sql:9845`
  - uso en `public.v_pedido_vistageneral`: `posgres.sql:9905`
- `fn_pedidos_sync_asientos`
  - definición: `posgres.sql:4614`
  - llamadas directas:
    - `public.fn_pedidos_child_sync_asientos`: `posgres.sql:5191` (triggered por `trg_detallepedidos_sync_asientos`)
    - `public.fn_detallemovimientos_sync_asientos`: `posgres.sql:5212` (no tiene trigger declarado en `posgres.sql`)
    - `public.fn_pedidos_header_sync_asientos`: `posgres.sql:5222` (triggered por `trg_pedidos_insert_sync_asientos` y `trg_pedidos_update_sync_asientos`)
    - `public.fn_viajesdetalles_sync_asientos`: `posgres.sql:5942` (no tiene trigger declarado en `posgres.sql`)
    - `public.fn_viajes_devueltos_sync_asientos`: `posgres.sql:5972` (no tiene trigger declarado en `posgres.sql`)
    - `public.fn_viajes_devueltos_detalle_sync_asientos`: `posgres.sql:6005` (no tiene trigger declarado en `posgres.sql`)

### Flutter
- `lib/src/domains/pedidos/pedido_inline_service.dart`: suma `precioventa` (detalle) y `monto` (pagos) para el balance local.
- `lib/src/domains/pedidos/pedido_pago_coordinator.dart`: expone `pedido_total`, `pedido_pagado`, `pedido_saldo` usando solo detalle/pagos.
- `lib/src/shell/services/inline_context_coordinator.dart`: inyecta el contexto de pagos desde `PedidoPagoCoordinator` (no incluye recargo provincia ni devoluciones).

## Contrato de cálculo único

### Componentes
- `BASE_DETALLE` = sum(`v_detallepedidos_ajustado.precioventa`) por pedido.
- `RECARGO_PROVINCIA` = 50 * count(`movimientopedidos` con `estado = 'activo'` y `es_provincia = true`).
- `DEVOLUCIONES_CARGO` = sum(`viajes_devueltos.monto_ida + viajes_devueltos.monto_vuelta + viajes_devueltos.penalidad`) por pedido.
- `PAGOS` = sum(`pagos.monto`) con `pagos.estado = 'activo'`.

### Estados de viajes_devueltos a computar
- incluir `estado != 'pendiente'` (por ejemplo `resuelto_cliente`, `devuelto_base`).

### Fórmula propuesta
- `TOTAL_A_COBRAR(pedido)` =
  - si `pedido.estado_admin != 'activo'` o `pedido.estado != 'activo'` entonces 0
  - si no, `BASE_DETALLE + RECARGO_PROVINCIA + DEVOLUCIONES_CARGO`

- `SALDO(pedido)` = `TOTAL_A_COBRAR(pedido) - PAGOS`
- `ESTADO_PAGO`:
  - `cancelado` si `pedido.estado_admin != 'activo'` o `pedido.estado != 'activo'`
  - `pendiente` si `PAGOS = 0`
  - `terminado` si `SALDO <= 0`
  - `parcial` en otro caso

## Objetos impactados (fase SQL)
- `public.viajes_devueltos`: fuente unica de penalidad/monto_ida/monto_vuelta.
- `public.v_pedidosestadopago_cargo`: total por devoluciones (estado != 'pendiente').
- `public.v_pedidoestadopago`: total/saldo/estado_pago con guard de inactividad.
- `public.fn_pedidos_sync_asientos`: total contable incluye devoluciones y guard de inactividad.
