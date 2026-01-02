-- Seed opcional: ingresos de compra y fabricacion demo.
-- Requiere que posgres.sql y posgres_seeds_compras_demo.sql ya hayan sido ejecutados.

-------------------------------------------------
-- Ingreso de compra demo (recepcion a base)
-------------------------------------------------
insert into public.compras_movimientos (id, idcompra, idbase, observacion)
values (
  'a3000000-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000001',
  '88888888-1111-1111-1111-111111111111',
  'Ingreso completo a base Cusco'
)
on conflict (id) do update set
  idcompra = excluded.idcompra,
  idbase = excluded.idbase,
  observacion = excluded.observacion;

insert into public.compras_movimiento_detalle (
  id,
  idmovimiento,
  idproducto,
  cantidad
)
values (
  'a4000000-0000-0000-0000-000000000001',
  'a3000000-0000-0000-0000-000000000001',
  '22222222-1111-1111-1111-111111111111',
  10000
)
on conflict (id) do update set
  idmovimiento = excluded.idmovimiento,
  idproducto = excluded.idproducto,
  cantidad = excluded.cantidad;

-------------------------------------------------
-- Fabricacion interna demo (Stand Mp -> Stand/Maldi)
-------------------------------------------------
insert into public.fabricaciones (
  id,
  idbase,
  idreceta,
  observacion
)
values (
  'b0000000-0000-0000-0000-000000000001',
  '88888888-1111-1111-1111-111111111111',
  '33333333-1111-1111-1111-111111111111',
  'Lote demo 10k Stand Mp'
)
on conflict (id) do update set
  idbase = excluded.idbase,
  idreceta = excluded.idreceta,
  observacion = excluded.observacion;

insert into public.fabricaciones_consumos (
  id,
  idfabricacion,
  idproducto,
  cantidad
)
values (
  'b1000000-0000-0000-0000-000000000001',
  'b0000000-0000-0000-0000-000000000001',
  '22222222-1111-1111-1111-111111111111',
  10000
)
on conflict (id) do update set
  idfabricacion = excluded.idfabricacion,
  idproducto = excluded.idproducto,
  cantidad = excluded.cantidad;

insert into public.fabricaciones_resultados (
  id,
  idfabricacion,
  idproducto,
  cantidad
)
values
  (
    'b2000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000001',
    '22222222-2222-2222-2222-222222222222',
    8000
  ),
  (
    'b2000000-0000-0000-0000-000000000002',
    'b0000000-0000-0000-0000-000000000001',
    '22222222-3333-3333-3333-333333333333',
    2000
  )
on conflict (id) do update set
  idfabricacion = excluded.idfabricacion,
  idproducto = excluded.idproducto,
  cantidad = excluded.cantidad;
