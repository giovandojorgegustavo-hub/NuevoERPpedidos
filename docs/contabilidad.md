# Contabilidad automática

Resumen de cómo el sistema utiliza las cuentas contables. Si necesitas
reutilizar una cuenta o agregar una nueva lógica, revisa esta lista para no
romper los flujos existentes.

## Cuentas especiales

| Código | Nombre                    | Uso actual                                                         |
| ------ | ------------------------ | ------------------------------------------------------------------ |
| 12.01  | Clientes por cobrar       | Pedidos confirmados. Se debita al crear el pedido y se acredita con los cobros. |
| 20.01  | Inventario de mercaderías | Salidas/entradas de compras y capitalización de fabricaciones.     |
| 20.02  | Mercaderías en tránsito   | Compras pendientes de ingresar a base.                             |
| 20.03  | Producción en proceso     | (Reservado) Pendiente para futuras mejoras de fabricación interna. |
| 40.01  | Proveedores por pagar     | Pasivos por compras y por maquilas.                                |
| 48.01  | Pedidos por entregar      | Pasivo por ingresos diferidos hasta que el pedido se entregue.     |
| 69.01  | Costo de mercaderías vendidas | Al entregar pedidos se debita este costo contra el inventario 20.01. |
| 70.01  | Ingresos - Ingreso        | Ventas de pedidos. Se reconoce junto al asiento de cuentas por cobrar. |
| 80.01  | Ajustes - Ajuste          | Ajustes de inventario (faltantes/excedentes) y ajustes monetarios. |
| 80.02  | Ajuste fabricación        | Redondeos en fabricaciones y maquilas.                             |

## Fabricaciones internas

- Tabla `fabricaciones` tiene `idasiento_ajuste`.
- `fn_fabricaciones_sync_ajuste` compara el costo total consumido vs. el costo
  total resultante después de `fn_fabricaciones_recalcular_costos`.
- Si la diferencia absoluta es mayor o igual a S/ 0.01 se registra un movimiento
  `tipo='ajuste'` en la cuenta `80.02`.
- Si se elimina la fabricación, `fn_fabricaciones_cleanup_movimientos` borra el
  asiento asociado.

## Fabricaciones maquila

- Tabla `fabricaciones_maquila` guarda `idasiento_inventario`,
  `idasiento_pasivo` y `idasiento_ajuste`.
- `fn_fabricaciones_maquila_sync_asientos` se ejecuta después del recalculo de
  costos:
  - Inserta/actualiza un movimiento `tipo='ingreso'` en `20.01` por el costo
    final (entra inventario terminado).
  - Inserta/actualiza otro movimiento `tipo='ingreso'` en `40.01` con el mismo
    monto (pasivo/haber para proveedor o caja).
  - Si el total de fuentes (consumos + costos adicionales) difiere del resultado
    en ±0.01, registra un `ajuste` en `80.02`.
- Al eliminar la maquila se limpian estos registros mediante
  `fn_fabricaciones_maquila_cleanup_movimientos`.

## Compras (referencia)

No cambiaron en esta iteración, pero sirven como guía: las compras generan los
asientos `20.02`, `20.01` y `40.01` mediante `fn_compras_sync_asientos`.

## Ajustes de inventario

- `ajustes_detalle` guarda `costo_unitario` y `costo_total` al momento de
  registrar la cantidad real. Se calcula con `fn_producto_costo_promedio` para
  congelar el valor del ajuste.
- `fn_ajustes_sync_asientos` suma el costo total del ajuste y genera dos
  movimientos:
  - Inventario (`20.01`), que aumenta o disminuye según sea excedente o faltante.
  - Gasto por ajuste (`80.01`), para medir las mermas del periodo.
- La tabla `ajustes` almacena `idasiento_inventario` e `idasiento_gasto`; los
  triggers limpian esos movimientos al eliminar el ajuste.

## Pedidos y cobros

- `pedidos` guarda `total_contable` (saldo registrado en cuentas por cobrar) y
  `total_ingreso_reconocido` (lo que ya pasó a 70.01). Las columnas
  `idasiento_*` quedaron sólo para compatibilidad.
- `fn_pedidos_sync_asientos` trabaja en dos etapas:
  1. **Confirmación / cambios de monto**: ajusta `12.01` contra `48.01`. Si el
     pedido sube, se debita CxC y se acredita `Pedidos por entregar`. Si baja o
     se anula, inserta los asientos inversos.
  2. **Entrega**: calcula el monto equivalente entregado (proporcional a las
     cantidades despachadas por producto) únicamente para los movimientos que
     tienen un registro en `viajesdetalles` con `llegada_at` y sin
     devoluciones activas. Sólo esa fracción pasa de `48.01` hacia `70.01`. Si
     se revierte la llegada o se marca una devolución, los triggers
     `trg_viajesdetalles_sync_asientos` y `trg_viajes_devueltos_sync_asientos`
     recalculan y generan la reversa correspondiente.
  - Así se ve en balance: “por cobrar” y “pedidos por entregar” hasta que se
    entregan; el ingreso se reconoce en la medida en que se despacha.
- La misma función calcula `total_costo_reconocido`: por cada variación acredita
  `20.01` (baja de inventario) y debita `69.01` (costo de mercaderías vendidas)
  usando el costo promedio del producto al momento de despachar. Esto permite
  que el estado de resultados muestre `Ingresos - Costo` sin asientos manuales.
- `pagos` cuenta con `idmovimiento_financiero` e
  `idmovimiento_financiero_banco`.
- `fn_pagos_sync_movimientos` crea/actualiza dos movimientos cuando se registra
  un cobro:
  - Se acredita `12.01` (tipo `gasto`) para reducir la cuenta por cobrar.
  - Se debita la cuenta contable asociada a la cuenta bancaria usada (tipo
    `ingreso`).
- Al eliminar un pedido o un pago, los triggers correspondientes limpian los
  movimientos financieros relacionados.
- `pedido_reembolsos` maneja devoluciones de dinero. El trigger
  `fn_pedido_reembolsos_sync_movimientos` registra automáticamente:
  - Un débito en `12.01` (tipo `gasto`) para reflejar la obligación con el
    cliente.
  - Un crédito en la cuenta bancaria seleccionada (tipo `ingreso`) mostrando la
    salida de caja.
- Al eliminar el reembolso, se eliminan ambos movimientos y el historial los
  conserva.

## Incidentes de viaje (robado/dañado)

- Cada movimiento asignado a un viaje puede registrar un incidente mediante las
  tablas `viajes_incidentes` (cabecera) y `viajes_incidentes_detalle` (detalle
  por producto).
- El trigger `fn_viajes_incidentes_detalle_validate` garantiza que los
  productos afectados pertenezcan al mismo movimiento y que la cantidad
  registrada no exceda lo despachado.
- `fn_viajes_incidentes_detalle_sync_asientos` genera automáticamente dos
  movimientos por cada detalle confirmado:
  - Un `ingreso` en `20.01` para retirar el costo del inventario.
  - Un `gasto` en `80.01` (mermas) con el mismo monto.
- Al eliminar el detalle, ambos asientos se limpian y el historial de
  movimientos conserva el registro. Así el inventario contable y las pérdidas
  reflejan inmediatamente los robos o daños reportados en ruta.

---

Si agregas nuevas automatizaciones contables, documenta aquí:

1. Qué evento dispara los movimientos (trigger/función).
2. Qué cuentas se afectan.
3. Cómo se limpian los registros al eliminar la entidad.
