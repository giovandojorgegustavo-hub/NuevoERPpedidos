-- Seed opcional: compra demo con pago.
-- Requiere que posgres.sql ya haya sido ejecutado.

-------------------------------------------------
-- Compra demo de Stand Mp con pago
-------------------------------------------------
insert into public.compras (id, idproveedor, observacion)
values (
  'a0000000-0000-0000-0000-000000000001',
  '66666666-1111-1111-1111-111111111111',
  'Compra demo: Stand Mp 10k uds (venta 6000)'
)
on conflict (id) do update set
  idproveedor = excluded.idproveedor,
  observacion = excluded.observacion;

insert into public.compras_detalle (
  id,
  idcompra,
  idproducto,
  cantidad,
  costo_total
)
values (
  'a1000000-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000001',
  '22222222-1111-1111-1111-111111111111',
  10000,
  6000
)
on conflict (id) do update set
  idcompra = excluded.idcompra,
  idproducto = excluded.idproducto,
  cantidad = excluded.cantidad,
  costo_total = excluded.costo_total;

insert into public.compras_pagos (id, idcompra, idcuenta, monto)
values (
  'a2000000-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000001',
  '77777777-1111-1111-1111-111111111111',
  6000
)
on conflict (id) do update set
  idcompra = excluded.idcompra,
  idcuenta = excluded.idcuenta,
  monto = excluded.monto;
