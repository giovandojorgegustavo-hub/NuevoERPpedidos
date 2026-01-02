# Limpieza SQL

## Que se elimino
- Duplicacion de la validacion de estado cancelado en `fn_viajes_devueltos_detalle_validate`.
- Funciones sin uso en el esquema:
  - `fn_detallemovimientos_sync_asientos`
  - `fn_viajesdetalles_sync_asientos`
  - `fn_viajes_devueltos_sync_asientos`
  - `fn_viajes_devueltos_detalle_sync_asientos`

## Por que no rompe (o que rompe)
- La validacion duplicada removida solo repetia el mismo error; el comportamiento sigue siendo el mismo.
- Las funciones eliminadas no estan conectadas a triggers ni llamadas en `posgres.sql`, por lo que el esquema compila y los flujos existentes no cambian.
- Romperia solo si algun proceso externo las invocaba manualmente para resincronizar asientos; en ese caso habria que reintroducirlas o exponer un proceso equivalente.

## Verificacion adicional
- No hay menciones de `cargos_cliente` en `security_resource_modules` ni en triggers dentro de `posgres.sql`.
