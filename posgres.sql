-------------------------------------------------
-- 0. CONFIGURACIÓN INICIAL
-------------------------------------------------
create extension if not exists "pgcrypto"; -- para gen_random_uuid()

-------------------------------------------------
-- 1. SEGURIDAD Y ADMINISTRACIÓN BÁSICA
-------------------------------------------------

-- Resumen rápido de módulos:
-- | Módulo          | Entidades principales                           |
-- | bases           | clientes, direcciones, productos, hubs          |
-- | pedidos         | pedidos, detalle, viajes                        |
-- | operaciones     | movimientos, destinos, incidentes               |
-- | finanzas        | cuentas, pagos, cargos, gastos                  |
-- | almacen         | asignaciones y entregas en ruta                 |
-- | administracion  | perfiles y catálogos internos                   |
-- | contabilidad    | reportes contables mensuales                    |
-- | asistencias     | slots, asignaciones y marcas                    |
-- | comunicaciones  | incidencias y comunicaciones internas           |
-- | reportes        | tableros operativos (ganancias, KPIs)           |

-------------------------------------------------
-- 1.1 Catálogos y tablas de seguridad
-------------------------------------------------

create table if not exists security_modules (
  nombre text primary key,
  descripcion text
);

insert into security_modules (nombre, descripcion) values
  ('bases', 'Catálogos maestros'),
  ('pedidos', 'Registro y edición de pedidos'),
  ('operaciones', 'Movimientos y destinos'),
  ('finanzas', 'Tesorería (caja y bancos)'),
  ('almacen', 'Control de almacén y entregas'),
  ('administracion', 'Gestión interna y perfiles'),
  ('contabilidad', 'Contabilidad (GL)'),
  ('asistencias', 'Gestión de turnos y asistencias'),
  ('comunicaciones', 'Incidencias y comunicaciones internas'),
  ('reportes', 'Indicadores y resúmenes operativos')
on conflict (nombre) do nothing;

create table if not exists security_roles (
  rol text primary key,
  descripcion text
);

create or replace view public.v_security_roles as
select
  rol as id,
  rol,
  descripcion
from public.security_roles;

insert into security_roles (rol, descripcion) values
  ('admin', 'Acceso total'),
  ('atencion', 'Equipo de pedidos/operaciones'),
  ('bases', 'Operadores asignados a una base'),
  ('gerente', 'Gerencia operativa')
on conflict (rol) do nothing;

create table if not exists role_modules (
  rol text references security_roles(rol) on delete cascade,
  modulo text references security_modules(nombre) on delete cascade,
  primary key (rol, modulo)
);

insert into role_modules (rol, modulo) values
  ('admin', 'bases'),
  ('admin', 'pedidos'),
  ('admin', 'operaciones'),
  ('admin', 'finanzas'),
  ('admin', 'almacen'),
  ('admin', 'administracion'),
  ('admin', 'contabilidad'),
  ('admin', 'asistencias'),
  ('admin', 'comunicaciones'),
  ('admin', 'reportes'),
  ('atencion', 'pedidos'),
  ('atencion', 'operaciones'),
  ('atencion', 'asistencias'),
  ('bases', 'bases'),
  ('bases', 'pedidos'),
  ('bases', 'operaciones'),
  ('bases', 'comunicaciones'),
  ('gerente', 'bases'),
  ('gerente', 'pedidos'),
  ('gerente', 'operaciones'),
  ('gerente', 'finanzas'),
  ('gerente', 'almacen'),
  ('gerente', 'administracion'),
  ('gerente', 'asistencias'),
  ('gerente', 'comunicaciones')
on conflict (rol, modulo) do nothing;

create table if not exists security_resource_modules (
  schema_name text not null default 'public',
  relation_name text not null,
  modulo text not null references security_modules(nombre),
  ops text[] not null default array['select','insert','update','delete'],
  primary key (schema_name, relation_name, modulo)
);

insert into security_resource_modules (relation_name, modulo) values
  ('clientes', 'bases'),
  ('direccion', 'bases'),
  ('direccion_provincia', 'bases'),
  ('numrecibe', 'bases'),
  ('categorias', 'bases'),
  ('productos', 'bases'),
  ('v_productos_para_venta', 'bases'),
  ('v_productos_para_compra', 'bases'),
  ('v_productos_vistageneral', 'bases'),
  ('bases', 'bases'),
  ('base_packings', 'bases'),
  ('perfiles', 'administracion'),
  ('pedidos', 'pedidos'),
  ('detallepedidos', 'pedidos'),
  ('movimientopedidos', 'operaciones'),
  ('detallemovimientopedidos', 'almacen'),
  ('viajes', 'pedidos'),
  ('viajesdetalles', 'almacen'),
  ('incidentes', 'operaciones'),
  ('cuentas_bancarias', 'finanzas'),
  ('pagos', 'finanzas'),
  ('gastos_operativos', 'finanzas'),
  ('transferencias', 'operaciones'),
  ('transferencias_detalle', 'operaciones'),
  ('fabricaciones', 'operaciones'),
  ('fabricaciones_consumos', 'operaciones'),
  ('fabricaciones_resultados', 'operaciones'),
  ('fabricaciones_maquila', 'operaciones'),
  ('fabricaciones_maquila_consumos', 'operaciones'),
  ('fabricaciones_maquila_resultados', 'operaciones'),
  ('fabricaciones_maquila_costos', 'operaciones'),
  ('recetas', 'operaciones'),
  ('recetas_insumos', 'operaciones'),
  ('recetas_resultados', 'operaciones'),
  ('v_recetas_vistageneral', 'operaciones'),
  ('v_recetas_insumos_detalle', 'operaciones'),
  ('v_recetas_resultados_detalle', 'operaciones'),
  ('v_recetas_insumos_stock', 'operaciones'),
  ('v_ajustes_vistageneral', 'operaciones'),
  ('v_ajustes_detalle_vistageneral', 'operaciones'),
  ('v_ajustes_costos', 'operaciones'),
  ('v_transferencias_vistageneral', 'operaciones'),
  ('v_transferencias_detalle_vistageneral', 'operaciones'),
  ('costo_producto_historial', 'operaciones'),
  ('v_recetas_disponibles_por_base', 'operaciones'),
  ('v_recetas_resultados_catalogo', 'operaciones'),
  ('ajustes', 'operaciones'),
  ('ajustes_detalle', 'operaciones'),
  ('compras', 'operaciones'),
  ('compras_detalle', 'operaciones'),
  ('compras_pagos', 'operaciones'),
  ('compras_movimientos', 'operaciones'),
  ('compras_movimiento_detalle', 'operaciones'),
  ('compras_reversiones', 'operaciones'),
  ('compras_reversion_movimientos', 'operaciones'),
  ('v_productos_para_compra', 'operaciones'),
  ('v_productos_vistageneral', 'operaciones'),
  ('v_movimientos_disponibles_viaje', 'operaciones'),
  ('transferencias_gastos', 'operaciones'),
  ('v_stock_por_base', 'administracion'),
  ('v_costos_historial', 'operaciones'),
  ('v_stock_disponible_por_base', 'operaciones'),
  ('v_fabricaciones_internas_vistageneral', 'operaciones'),
  ('v_fabricaciones_internas_consumos', 'operaciones'),
  ('v_fabricaciones_internas_resultados', 'operaciones'),
  ('v_fabricaciones_maquila_vistageneral', 'operaciones'),
  ('v_fabricaciones_maquila_consumos', 'operaciones'),
  ('v_fabricaciones_maquila_resultados', 'operaciones'),
  ('v_fabricaciones_maquila_costos', 'operaciones'),
  ('cuentas_contables', 'finanzas'),
  ('movimientos_financieros', 'finanzas'),
  ('v_movimientos_financieros_vistageneral', 'finanzas'),
  ('v_finanzas_gastos_pedidos', 'finanzas'),
  ('v_finanzas_movimientos_ingresos_gastos', 'finanzas'),
  ('v_finanzas_ajustes_dinero', 'finanzas'),
  ('v_finanzas_transferencias_dinero', 'finanzas'),
  ('v_finanzas_historial_cuentas', 'finanzas'),
  ('v_finanzas_saldo_cuentas', 'finanzas'),
  ('asistencias_slots', 'asistencias'),
  ('asistencias_base_slots', 'asistencias'),
  ('asistencias_excepciones', 'asistencias'),
  ('asistencias_registro', 'asistencias'),
  ('v_asistencias_slots', 'asistencias'),
  ('v_asistencias_base_slots', 'asistencias'),
  ('v_asistencias_pendientes', 'asistencias'),
  ('v_asistencias_historial', 'asistencias'),
  ('v_asistencias_permisos', 'asistencias'),
  ('v_reportes_pedidos_detalle_costos', 'reportes'),
  ('v_reportes_pedidos_ganancia', 'reportes'),
  ('v_reportes_pedidos_detalle_ganancia', 'reportes'),
  ('v_reportes_ganancia_diaria', 'reportes'),
  ('v_reportes_ganancia_mensual', 'reportes'),
  ('v_reportes_ganancia_mensual_clientes', 'reportes'),
  ('v_reportes_ganancia_mensual_productos', 'reportes'),
  ('v_reportes_ganancia_mensual_bases', 'reportes'),
  ('v_reportes_meses', 'reportes'),
  ('incidentes', 'comunicaciones'),
  ('incidentes_historial', 'comunicaciones'),
  ('v_comunicaciones_internas', 'comunicaciones'),
  ('v_comunicaciones_internas_bases', 'comunicaciones'),
  ('comunicaciones_internas', 'comunicaciones'),
  ('comunicaciones_internas_respuestas', 'comunicaciones')
on conflict (schema_name, relation_name, modulo) do nothing;

insert into security_resource_modules (relation_name, modulo, ops) values
  ('clientes', 'pedidos', array['select','insert','update']),
  ('direccion', 'pedidos', array['select','insert','update']),
  ('direccion_provincia', 'pedidos', array['select','insert','update']),
  ('numrecibe', 'pedidos', array['select','insert','update']),
  ('productos', 'pedidos', array['select']),
  ('v_productos_para_venta', 'pedidos', array['select']),
  ('bases', 'pedidos', array['select']),
  ('cuentas_bancarias', 'pedidos', array['select','insert','update'])
on conflict (schema_name, relation_name, modulo) do nothing;

-------------------------------------------------
-- 1.3 Metadatos de UI (módulos y vistas)
-------------------------------------------------

create table if not exists ui_modules (
  id text primary key,
  nombre text not null,
  descripcion text,
  icon text,
  orden int not null default 0,
  security_module text references security_modules(nombre),
  activo boolean not null default true,
  creado_at timestamptz not null default now(),
  actualizado_at timestamptz not null default now()
);

create table if not exists ui_sections (
  id text primary key,
  module_id text not null references ui_modules(id) on delete cascade,
  nombre text not null,
  descripcion text,
  icon text,
  orden int not null default 0,
  activo boolean not null default true,
  creado_at timestamptz not null default now(),
  actualizado_at timestamptz not null default now()
);

create table if not exists ui_section_data_sources (
  section_id text primary key references ui_sections(id) on delete cascade,
  list_schema text not null default 'public',
  list_relation text not null,
  list_is_view boolean not null default true,
  form_schema text not null default 'public',
  form_relation text not null,
  form_is_view boolean not null default false,
  detail_schema text,
  detail_relation text,
  detail_is_view boolean,
  activo boolean not null default true,
  creado_at timestamptz not null default now(),
  actualizado_at timestamptz not null default now()
);

create or replace function public.fn_ui_sections_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.actualizado_at = now();
  return new;
end;
$$;

create trigger trg_ui_modules_updated
before update on ui_modules
for each row
execute function public.fn_ui_sections_updated_at();

create trigger trg_ui_sections_updated
before update on ui_sections
for each row
execute function public.fn_ui_sections_updated_at();

create trigger trg_ui_section_sources_updated
before update on ui_section_data_sources
for each row
execute function public.fn_ui_sections_updated_at();

insert into ui_modules (id, nombre, descripcion, icon, orden, security_module)
values
  ('pedidos', 'Pedidos', 'Pedidos, movimientos y viajes.', 'inventory_2_outlined', 1, 'pedidos'),
  (
    'administracion',
    'Administración',
    'Perfiles y configuración interna.',
    'admin_panel_settings',
    2,
    'administracion'
  ),
  (
    'base',
    'Base',
    'Operaciones por base (movimientos y viajes asignados).',
    'store_mall_directory',
    3,
    'bases'
  ),
  (
    'operaciones',
    'Operaciones',
    'Catálogos operativos (bases y packings).',
    'handyman',
    4,
    'operaciones'
  ),
  (
    'finanzas',
    'Tesorería',
    'Caja, bancos y movimientos (base caja).',
    'account_balance_wallet',
    5,
    'finanzas'
  ),
  (
    'comunicaciones',
    'Comunicaciones',
    'Comunicaciones internas por base.',
    'forum',
    10,
    'comunicaciones'
  ),
  (
    'asistencias',
    'Asistencias',
    'Programación de horarios y control de asistencia por base.',
    'list_alt',
    7,
    'asistencias'
  ),
  (
    'reporte_asistencia',
    'Reporte asistencia',
    'Tablero diario de asistencia por base.',
    'table_chart_outlined',
    8,
    'asistencias'
  ),
  (
    'reportes_generales',
    'Reportes generales',
    'Reportes de pedidos y ganancias.',
    'table_chart_outlined',
    9,
    'reportes'
  ),
  (
    'contabilidad',
    'Contabilidad',
    'Contabilidad (GL) y estados financieros.',
    'table_view',
    6,
    'contabilidad'
  )
on conflict (id) do update set
  nombre = excluded.nombre,
  descripcion = excluded.descripcion,
  icon = excluded.icon,
  orden = excluded.orden,
  security_module = excluded.security_module,
  activo = true,
  actualizado_at = now();

insert into ui_sections (id, module_id, nombre, descripcion, icon, orden)
values
  ('pedidos_tabla', 'pedidos', 'Pedidos', 'Tabla maestra de pedidos.', 'table_chart_outlined', 1),
  ('movimientos', 'pedidos', 'Movimientos', 'Seguimiento de movimientos de pedidos.', 'swap_horiz', 2),
  ('viajes', 'pedidos', 'Viajes', 'Asignación y control de viajes.', 'local_shipping_outlined', 3),
  (
    'movimientos_base',
    'base',
    'Movimientos por base',
    'Movimientos asignados a tu base.',
    'maps_home_work',
    1
  ),
  (
    'viajes_bases',
    'base',
    'Viajes por base',
    'Asignación de viajes limitada a una base.',
    'local_shipping',
    2
  ),
  (
    'comunicaciones_base',
    'base',
    'Comunicaciones',
    'Registro de comunicaciones por base.',
    'forum',
    3
  ),
  (
    'comunicaciones',
    'comunicaciones',
    'Comunicaciones',
    'Seguimiento de comunicaciones registradas.',
    'forum',
    1
  ),
  ('viajes_detalle', 'pedidos', 'Detalle de viaje', 'Detalle por movimiento dentro del viaje.', 'list_alt', 5),
  (
    'viajes_devueltos',
    'pedidos',
    'Viajes devueltos',
    'Seguimiento de devoluciones dentro de pedidos.',
    'assignment_return',
    6
  ),
  (
    'viajes_incidentes',
    'pedidos',
    'Viajes incidentes',
    'Incidentes registrados y productos afectados.',
    'report_problem',
    7
  ),
  (
    'pedido_rectificaciones',
    'pedidos',
    'Rectificaciones',
    'Rectificaciones asociadas a pedidos.',
    'edit_note',
    8
  ),
  (
    'pedido_reembolsos',
    'pedidos',
    'Devoluciones',
    'Reembolsos o devoluciones monetarias de pedidos.',
    'undo',
    9
  ),
  (
    'usuarios',
    'administracion',
    'Usuarios',
    'Gestión de roles y bases asignadas.',
    'group',
    1
  ),
  (
    'cuentas_bancarias_asignadas',
    'administracion',
    'Cuentas bancarias (gerentes)',
    'Asignación de cuentas bancarias por gerente.',
    'account_balance',
    2
  ),
  (
    'bases',
    'operaciones',
    'Bases',
    'Catálogo de bases y packings.',
    'warehouse',
    20
  ),
  (
    'bases_lectura',
    'base',
    'Bases (lectura)',
    'Consulta de bases y packings sin edición.',
    'visibility',
    2
  ),
  (
    'operaciones_stock',
    'operaciones',
    'Stock',
    'Existencias consolidadas por base.',
    'inventory_2',
    1
  ),
  (
    'historial_operaciones',
    'operaciones',
    'Historial de operaciones',
    'Detalle cronológico de movimientos de inventario.',
    'history_toggle_off',
    2
  ),
  (
    'transferencias',
    'operaciones',
    'Transferencias',
    'Traslados entre bases.',
    'sync_alt',
    4
  ),
  (
    'ajustes',
    'operaciones',
    'Ajustes',
    'Tomas de inventario por base.',
    'tune',
    7
  ),
  (
    'compras',
    'operaciones',
    'Compras',
    'Registro y seguimiento de compras y sus estados.',
    'shopping_cart_checkout',
    3
  ),
  (
    'fabricaciones_internas',
    'operaciones',
    'Fabricación interna',
    'Procesos internos con múltiples productos de salida.',
    'scatter_plot',
    5
  ),
  (
    'fabricaciones_maquila',
    'operaciones',
    'Fabricación · Maquila',
    'Procesos tercerizados con costos adicionales.',
    'construction',
    6
  ),
  (
    'productos',
    'operaciones',
    'Productos',
    'Catálogo maestro de productos e insumos.',
    'category',
    8
  ),
  (
    'recetas',
    'operaciones',
    'Recetas',
    'Catálogo de recetas e ingredientes.',
    'receipt_long',
    9
  ),
  (
    'costos_historial',
    'operaciones',
    'Costos históricos',
    'Bitácora de costos por operación.',
    'query_stats',
    10
  ),
  (
    'stock_admin',
    'administracion',
    'Stock administrativo',
    'Inventario con costos para administradores.',
    'inventory',
    5
  ),
  (
    'finanzas_saldos',
    'finanzas',
    'Saldos bancarios',
    'Stock disponible por cuenta bancaria.',
    'savings_outlined',
    1
  ),
  (
    'finanzas_movimientos',
    'finanzas',
    'Tesorería / Movimientos',
    'Ingresos, gastos, ajustes y transferencias (caja).',
    'compare_arrows',
    3
  ),
  (
    'finanzas_historial',
    'finanzas',
    'Historial financiero',
    'Entradas y salidas consolidadas por cuenta.',
    'history',
    2
  ),
  (
    'finanzas_gastos',
    'finanzas',
    'Gastos',
    'Gastos operativos y de soporte.',
    'request_quote',
    4
  ),
  (
    'finanzas_cuentas',
    'finanzas',
    'Cuentas bancarias',
    'Catálogo de cuentas y medios de cobro.',
    'account_balance_wallet',
    5
  ),
  (
    'contabilidad_trial_balance',
    'contabilidad',
    'Balance de comprobación (GL)',
    'Balance por cuenta en el mayor.',
    'table_chart_outlined',
    1
  ),
  (
    'contabilidad_profit_loss',
    'contabilidad',
    'Estado de resultados (GL)',
    'Ingresos y gastos contables.',
    'leaderboard_outlined',
    2
  ),
  (
    'contabilidad_balance_sheet',
    'contabilidad',
    'Balance general (GL)',
    'Activos, pasivos y patrimonio contables.',
    'bar_chart',
    3
  ),
  (
    'contabilidad_historial',
    'contabilidad',
    'Historial contable (GL)',
    'Detalle cronologico de asientos.',
    'history',
    4
  ),
  (
    'asistencias_slots',
    'asistencias',
    'Slots de asistencia',
    'Horarios base para marcar asistencia.',
    'table_chart_outlined',
    1
  ),
  (
    'asistencias_base_slots',
    'asistencias',
    'Horarios por base',
    'Plantilla de días y horarios por base.',
    'table_chart_outlined',
    2
  ),
  (
    'asistencias_pendientes',
    'asistencias',
    'Registro de asistencia',
    'Marcación diaria según la plantilla.',
    'list_alt',
    3
  ),
  (
    'asistencias_permisos',
    'asistencias',
    'Permisos',
    'Días comunicados como ausencia.',
    'list_alt',
    4
  ),
  (
    'asistencias_historial',
    'asistencias',
    'Historial',
    'Historial completo de asistencias.',
    'list_alt',
    5
  ),
  (
    'reporte_asistencia_tablero',
    'reporte_asistencia',
    'Tablero asistencia',
    'Registro diario de asistencia por base.',
    'table_chart_outlined',
    1
  ),
  (
    'reportes_pedidos',
    'reportes_generales',
    'Pedidos con ganancia',
    'Pedidos con ganancia total.',
    'table_chart_outlined',
    1
  ),
  (
    'reportes_pedidos_detalle',
    'reportes_generales',
    'Detalle pedidos con ganancia',
    'Detalle de pedidos con costo y ganancia.',
    'table_chart_outlined',
    2
  ),
  (
    'reportes_ganancia_diaria',
    'reportes_generales',
    'Ganancia diaria',
    'Ganancia total por dia.',
    'table_chart_outlined',
    3
  ),
  (
    'reportes_ganancia_mensual',
    'reportes_generales',
    'Ganancia mensual',
    'Ganancia total por mes.',
    'table_chart_outlined',
    4
  ),
  (
    'reportes_ganancia_clientes_meses',
    'reportes_generales',
    'Ganancia por cliente (mes)',
    'Ganancia por cliente segun mes.',
    'table_chart_outlined',
    5
  ),
  (
    'reportes_ganancia_productos_meses',
    'reportes_generales',
    'Ganancia por producto (mes)',
    'Ganancia por producto segun mes.',
    'table_chart_outlined',
    6
  ),
  (
    'reportes_ganancia_bases_meses',
    'reportes_generales',
    'Ganancia por base (mes)',
    'Ganancia por base segun mes.',
    'table_chart_outlined',
    7
  )
on conflict (id) do update set
  module_id = excluded.module_id,
  nombre = excluded.nombre,
  descripcion = excluded.descripcion,
  icon = excluded.icon,
  orden = excluded.orden,
  activo = true,
  actualizado_at = now();

insert into ui_section_data_sources (
  section_id,
  list_relation,
  list_is_view,
  form_relation,
  form_is_view,
  detail_relation,
  detail_is_view
)
values
  ('pedidos_tabla', 'v_pedido_vistageneral', true, 'pedidos', false, 'v_pedido_vistageneral', true),
  ('movimientos', 'v_movimiento_vistageneral', true, 'movimientopedidos', false, 'v_movimiento_vistageneral', true),
  ('viajes', 'v_viaje_vistageneral', true, 'viajes', false, 'v_viaje_vistageneral', true),
  (
    'movimientos_base',
    'v_movimiento_vistageneral_bases',
    true,
    'movimientopedidos',
    false,
    'v_movimiento_vistageneral',
    true
  ),
  (
    'viajes_bases',
    'v_viaje_vistageneral_bases',
    true,
    'viajes',
    false,
    'v_viaje_vistageneral_bases',
    true
  ),
  (
    'comunicaciones_base',
    'v_comunicaciones_internas_bases',
    true,
    'comunicaciones_internas',
    false,
    'v_comunicaciones_internas_bases',
    true
  ),
  (
    'comunicaciones',
    'v_comunicaciones_internas',
    true,
    'comunicaciones_internas',
    false,
    'v_comunicaciones_internas',
    true
  ),
  ('viajes_detalle', 'v_viaje_detalle_vistageneral', true, 'viajesdetalles', false, 'v_viaje_detalle_vistageneral', true),
  (
    'viajes_devueltos',
    'v_viajes_devueltos_vistageneral',
    true,
    'viajes_devueltos',
    false,
    'v_viajes_devueltos_vistageneral',
    true
  ),
  (
    'viajes_incidentes',
    'v_viajes_incidentes_vistageneral',
    true,
    'viajes_incidentes',
    false,
    'v_viajes_incidentes_vistageneral',
    true
  ),
  (
    'pedido_rectificaciones',
    'v_pedido_rectificaciones_vistageneral',
    true,
    'pedido_rectificaciones',
    false,
    'v_pedido_rectificaciones_vistageneral',
    true
  ),
  (
    'pedido_reembolsos',
    'v_pedido_reembolsos_vistageneral',
    true,
    'pedido_reembolsos',
    false,
    'v_pedido_reembolsos_vistageneral',
    true
  ),
  (
    'usuarios',
    'v_perfiles_vistageneral',
    true,
    'perfiles',
    false,
    'v_perfiles_vistageneral',
    true
  ),
  (
    'cuentas_bancarias_asignadas',
    'v_cuentas_bancarias_asignadas',
    true,
    'cuentas_bancarias_asignadas',
    false,
    'v_cuentas_bancarias_asignadas',
    true
  ),
  (
    'bases',
    'v_bases_vistageneral',
    true,
    'bases',
    false,
    'v_bases_vistageneral',
    true
  ),
  (
    'bases_lectura',
    'v_bases_vistageneral',
    true,
    '',
    false,
    'v_bases_vistageneral',
    true
  ),
  (
    'operaciones_stock',
    'v_stock_por_base',
    true,
    '',
    false,
    'v_stock_por_base',
    true
  ),
  (
    'historial_operaciones',
    'v_kardex_operativo',
    true,
    '',
    false,
    'v_kardex_operativo',
    true
  ),
  (
    'transferencias',
    'v_transferencias_vistageneral',
    true,
    'transferencias',
    false,
    'v_transferencias_vistageneral',
    true
  ),
  (
    'ajustes',
    'v_ajustes_vistageneral',
    true,
    'ajustes',
    false,
    'v_ajustes_vistageneral',
    true
  ),
  (
    'compras',
    'v_compras_vistageneral',
    true,
    'compras',
    false,
    'v_compras_vistageneral',
    true
  ),
  (
    'fabricaciones_internas',
    'v_fabricaciones_internas_vistageneral',
    true,
    'fabricaciones',
    false,
    'v_fabricaciones_internas_vistageneral',
    true
  ),
  (
    'fabricaciones_maquila',
    'v_fabricaciones_maquila_vistageneral',
    true,
    'fabricaciones_maquila',
    false,
    'v_fabricaciones_maquila_vistageneral',
    true
  ),
  (
    'recetas',
    'v_recetas_vistageneral',
    true,
    'recetas',
    false,
    'v_recetas_vistageneral',
    true
  ),
  (
    'productos',
    'v_productos_vistageneral',
    true,
    'productos',
    false,
    'v_productos_vistageneral',
    true
  ),
  (
    'stock_admin',
    'v_stock_por_base',
    true,
    '',
    false,
    'v_stock_por_base',
    true
  ),
  (
    'costos_historial',
    'v_costos_historial',
    true,
    '',
    false,
    'v_costos_historial',
    true
  ),
  (
    'finanzas_saldos',
    'v_finanzas_saldo_cuentas',
    true,
    '',
    false,
    'v_finanzas_saldo_cuentas',
    true
  ),
  (
    'finanzas_historial',
    'v_finanzas_historial_cuentas',
    true,
    '',
    false,
    'v_finanzas_historial_cuentas',
    true
  ),
  (
    'finanzas_movimientos',
    'v_movimientos_financieros_historial',
    true,
    'movimientos_financieros',
    false,
    'v_movimientos_financieros_historial',
    true
  ),
  (
    'finanzas_gastos',
    'v_finanzas_gastos_pedidos',
    true,
    'gastos_operativos',
    false,
    'v_finanzas_gastos_pedidos',
    true
  ),
  (
    'finanzas_cuentas',
    'v_cuentas_bancarias_visibles',
    true,
    'cuentas_bancarias',
    false,
    'v_cuentas_bancarias_visibles',
    true
  ),
  (
    'contabilidad_trial_balance',
    'v_contabilidad_balance_comprobacion',
    true,
    '',
    false,
    'v_contabilidad_balance_comprobacion',
    true
  ),
  (
    'contabilidad_profit_loss',
    'v_contabilidad_estado_resultados',
    true,
    '',
    false,
    'v_contabilidad_estado_resultados',
    true
  ),
  (
    'contabilidad_balance_sheet',
    'v_contabilidad_balance_general',
    true,
    '',
    false,
    'v_contabilidad_balance_general',
    true
  ),
  (
    'contabilidad_historial',
    'v_contabilidad_historial',
    true,
    '',
    false,
    'v_contabilidad_historial',
    true
  ),
  (
    'asistencias_slots',
    'v_asistencias_slots',
    true,
    'asistencias_slots',
    false,
    'v_asistencias_slots',
    true
  ),
  (
    'asistencias_base_slots',
    'v_asistencias_base_slots',
    true,
    'asistencias_base_slots',
    false,
    'v_asistencias_base_slots',
    true
  ),
  (
    'asistencias_pendientes',
    'v_asistencias_pendientes',
    true,
    'asistencias_registro',
    false,
    'v_asistencias_pendientes',
    true
  ),
  (
    'asistencias_permisos',
    'v_asistencias_permisos',
    true,
    'asistencias_excepciones',
    false,
    'v_asistencias_permisos',
    true
  ),
  (
    'asistencias_historial',
    'v_asistencias_historial',
    true,
    '',
    false,
    'v_asistencias_historial',
    true
  ),
  (
    'reporte_asistencia_tablero',
    'v_asistencias_pendientes',
    true,
    'asistencias_registro',
    false,
    'v_asistencias_pendientes',
    true
  ),
  (
    'reportes_pedidos',
    'v_reportes_pedidos_ganancia',
    true,
    '',
    false,
    'v_reportes_pedidos_ganancia',
    true
  ),
  (
    'reportes_pedidos_detalle',
    'v_reportes_pedidos_detalle_ganancia',
    true,
    '',
    false,
    'v_reportes_pedidos_detalle_ganancia',
    true
  ),
  (
    'reportes_ganancia_diaria',
    'v_reportes_ganancia_diaria',
    true,
    '',
    false,
    'v_reportes_ganancia_diaria',
    true
  ),
  (
    'reportes_ganancia_mensual',
    'v_reportes_ganancia_mensual',
    true,
    '',
    false,
    'v_reportes_ganancia_mensual',
    true
  ),
  (
    'reportes_ganancia_clientes_meses',
    'v_reportes_meses',
    true,
    '',
    false,
    'v_reportes_meses',
    true
  ),
  (
    'reportes_ganancia_productos_meses',
    'v_reportes_meses',
    true,
    '',
    false,
    'v_reportes_meses',
    true
  ),
  (
    'reportes_ganancia_bases_meses',
    'v_reportes_meses',
    true,
    '',
    false,
    'v_reportes_meses',
    true
  )
on conflict (section_id) do update set
  list_relation = excluded.list_relation,
  list_is_view = excluded.list_is_view,
  form_relation = excluded.form_relation,
  form_is_view = excluded.form_is_view,
  detail_relation = excluded.detail_relation,
  detail_is_view = excluded.detail_is_view,
  activo = true,
  actualizado_at = now();

-- Bases / hubs logísticos (se definen temprano por dependencias de perfiles)
create table if not exists bases (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create table if not exists base_packings (
  id uuid primary key default gen_random_uuid(),
  idbase uuid not null references bases(id) on delete cascade,
  nombre text not null,
  tipo text not null default 'general',
  observacion text,
  activo boolean not null default true,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  unique (idbase, nombre)
);

create or replace view public.v_bases_vistageneral as
select
  b.id,
  b.nombre,
  b.registrado_at,
  b.editado_at,
  coalesce(
    (
      select count(*)
      from public.base_packings bp
      where bp.idbase = b.id
    ),
    0
  ) as packings_totales,
  coalesce(
    (
      select count(*)
      from public.base_packings bp
      where bp.idbase = b.id
        and bp.activo = true
    ),
    0
  ) as packings_activos
from public.bases b;

create or replace view public.v_base_packings_vistageneral as
select
  bp.id,
  bp.idbase,
  b.nombre as base_nombre,
  bp.nombre,
  bp.tipo,
  bp.observacion,
  bp.activo,
  bp.registrado_at,
  bp.editado_at,
  concat_ws(
    ' / ',
    bp.nombre,
    bp.tipo,
    nullif(bp.observacion, '')
  ) as picker_label
from public.base_packings bp
join public.bases b on b.id = bp.idbase;

create table if not exists perfiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nombre text,
  rol text not null references security_roles(rol) default 'atencion',
  idbase uuid references bases(id) on delete set null,
  activo boolean not null default true,
  registrado_at timestamptz default now(),
  editado_at timestamptz default now(),
  registrado_por uuid,
  editado_por uuid,
  check (rol <> 'bases' or idbase is not null)
);

create or replace view public.v_perfiles_vistageneral as
select
  p.user_id,
  p.nombre,
  p.rol,
  r.descripcion as rol_descripcion,
  p.idbase,
  b.nombre as base_nombre,
  p.activo,
  p.registrado_at,
  p.editado_at
from public.perfiles p
left join public.bases b on b.id = p.idbase
left join public.security_roles r on r.rol = p.rol;

create or replace view public.v_perfiles_gerentes as
select
  p.user_id as id,
  coalesce(p.nombre, p.user_id::text) as nombre,
  p.user_id,
  p.rol,
  p.activo
from public.perfiles p
where p.rol = 'gerente'
  and p.activo = true;

-------------------------------------------------
-- 1.2 Funciones auxiliares
-------------------------------------------------

create or replace function public.fn_perfiles_handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_is_first_admin boolean;
  v_rol text := 'atencion';
begin
  -- Garantiza que sólo un registro evalúe el rol inicial al mismo tiempo
  lock table public.perfiles in share row exclusive mode;

  select not exists (
    select 1
    from public.perfiles p
    where p.rol = 'admin'
      and p.activo = true
  ) into v_is_first_admin;

  if v_is_first_admin then
    v_rol := 'admin';
  end if;

  insert into public.perfiles (user_id, nombre, rol, registrado_por, editado_por)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.email),
    v_rol,
    new.id,
    new.id
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

create or replace function public.fn_es_admin()
returns boolean
language sql
stable
set search_path = public
as $$
  select exists(
    select 1
    from public.perfiles p
    where p.user_id = auth.uid()
      and p.rol = 'admin'
      and p.activo = true
  );
$$;

create or replace function public.fn_has_module(target_module text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    public.fn_es_admin()
    or exists (
      select 1
      from public.perfiles p
      join public.role_modules rm on rm.rol = p.rol
      where p.user_id = auth.uid()
        and p.activo = true
        and rm.modulo = target_module
    ),
    false
  );
$$;

create or replace function public.fn_perfiles_set_audit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    new.registrado_at := coalesce(new.registrado_at, now());
    new.editado_at := coalesce(new.editado_at, now());
    new.registrado_por := coalesce(new.registrado_por, auth.uid(), new.user_id);
    new.editado_por := coalesce(new.editado_por, auth.uid(), new.user_id);
  else
    if new.rol <> old.rol and not public.fn_es_admin() then
      raise exception 'Solo administradores pueden cambiar roles';
    end if;
    new.editado_at := now();
    new.editado_por := coalesce(auth.uid(), new.editado_por, old.editado_por);
  end if;
  return new;
end;
$$;

-------------------------------------------------
-- 1.3 Triggers
-------------------------------------------------

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1 from pg_trigger where tgname = 'on_auth_user_created_perfil'
  ) then
    create trigger on_auth_user_created_perfil
    after insert on auth.users
    for each row execute function public.fn_perfiles_handle_new_user();
  end if;
end;
$$;

create trigger perfiles_set_audit
before insert or update on public.perfiles
for each row
execute function public.fn_perfiles_set_audit();
create policy bases_admin_insert
  on public.bases
  for insert
  with check (public.fn_es_admin());

-------------------------------------------------
-- 1.4 RLS y políticas automáticas
-------------------------------------------------

alter table public.perfiles enable row level security;

create policy perfiles_admin_full
  on public.perfiles
  for all
  using (public.fn_es_admin())
  with check (public.fn_es_admin());

create policy perfiles_self_read
  on public.perfiles
  for select
  using (auth.uid() = user_id);

create policy perfiles_self_update
  on public.perfiles
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

do $$
declare
  rec record;
  op text;
  policy_name text;
  fqname text;
  sql text;
begin
  for rec in
    select *
    from public.security_resource_modules
  loop
    fqname := format('%I.%I', rec.schema_name, rec.relation_name);
    if to_regclass(fqname) is null then
      continue;
    end if;
    execute format('alter table %I.%I enable row level security', rec.schema_name, rec.relation_name);
    for op in select unnest(rec.ops) loop
      policy_name := format('rls_%s_%s_%s', rec.modulo, rec.relation_name, op);
      if op = 'insert' then
        sql := format(
          'create policy %I on %I.%I for insert with check (public.fn_has_module(%L))',
          policy_name,
          rec.schema_name,
          rec.relation_name,
          rec.modulo
        );
      elsif op = 'update' then
        sql := format(
          'create policy %I on %I.%I for update using (public.fn_has_module(%L)) with check (public.fn_has_module(%L))',
          policy_name,
          rec.schema_name,
          rec.relation_name,
          rec.modulo,
          rec.modulo
        );
      else
        sql := format(
          'create policy %I on %I.%I for %s using (public.fn_has_module(%L))',
          policy_name,
          rec.schema_name,
          rec.relation_name,
          op,
          rec.modulo
        );
      end if;
      execute sql;
    end loop;
  end loop;
end;
$$;

-------------------------------------------------
-- 1.5 Grants mínimos para Supabase
-------------------------------------------------

grant usage on schema public to authenticated, anon;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant usage on all sequences in schema public to authenticated;
-------------------------------------------------
-- 2. MÓDULO 1 · BASES / ENTIDADES MAESTRAS
-------------------------------------------------

-- ============================================
-- TABLA: CLIENTES (versión simplificada con origen)
-- ============================================

create table if not exists clientes (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  numero text not null unique,
  canal text not null check (canal in ('telegram','referido','ads','qr')),
  referido_por uuid references clientes(id) on delete set null,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  check (canal <> 'referido' or referido_por is not null)
);



-- Direcciones de entrega asociadas a un cliente
create table if not exists direccion (
  id uuid primary key default gen_random_uuid(),
  idcliente uuid not null references clientes(id) on delete cascade,
  direccion text not null,
  referencia text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

-- Dirección para provincia (con datos del destinatario)
create table if not exists direccion_provincia (
  id uuid primary key default gen_random_uuid(),
  idcliente uuid not null references clientes(id) on delete cascade,
  lugar_llegada text not null,  -- dirección/destino en provincia
  nombre_completo text not null,
  dni    text not null,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

-- Contactos que reciben el pedido (otro número/persona)
create table if not exists numrecibe (
  id uuid primary key default gen_random_uuid(),
  idcliente uuid not null references clientes(id) on delete cascade,
  numero text not null,
  nombre_contacto text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);


-- Catálogo de categorías de productos
create table if not exists categorias (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,        -- Ej: "Proteico", "Bowl", "Guarnición", etc.
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

-- Productos que vendes
create table if not exists productos (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  idcategoria uuid references categorias(id) on delete set null,
  activo boolean default true,
  es_para_venta boolean not null default false,
  es_para_compra boolean not null default false,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create or replace view public.v_productos_para_venta as
select
  p.id,
  p.nombre,
  p.idcategoria,
  p.activo,
  p.registrado_at,
  p.editado_at
from public.productos p
where p.es_para_venta;

create or replace view public.v_productos_para_compra as
select
  p.id,
  p.nombre,
  p.idcategoria,
  p.activo,
  p.registrado_at,
  p.editado_at
from public.productos p
where p.es_para_compra;

-------------------------------------------------
-- Recetas (cabecera e insumos/resultados)
-------------------------------------------------

create table if not exists recetas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  activo boolean not null default true,
  notas text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create table if not exists recetas_insumos (
  id uuid primary key default gen_random_uuid(),
  idreceta uuid not null references recetas(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(14,4) not null check (cantidad > 0),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create table if not exists recetas_resultados (
  id uuid primary key default gen_random_uuid(),
  idreceta uuid not null references recetas(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(14,4) not null check (cantidad > 0),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create or replace view public.v_recetas_vistageneral as
select
  r.id,
  r.nombre,
  r.activo,
  r.notas,
  coalesce(i.insumos_registrados, 0) as insumos_registrados,
  coalesce(o.resultados_registrados, 0) as resultados_registrados,
  r.registrado_at
from public.recetas r
left join (
  select idreceta, count(*)::int as insumos_registrados
  from public.recetas_insumos
  group by idreceta
) i on i.idreceta = r.id
left join (
  select idreceta, count(*)::int as resultados_registrados
  from public.recetas_resultados
  group by idreceta
) o on o.idreceta = r.id;

create or replace view public.v_recetas_insumos_detalle as
select
  ri.id,
  ri.idreceta,
  ri.idproducto,
  p.nombre as producto_nombre,
  ri.cantidad,
  ri.registrado_at
from public.recetas_insumos ri
left join public.productos p on p.id = ri.idproducto;

create or replace view public.v_recetas_resultados_detalle as
select
  rr.id,
  rr.idreceta,
  rr.idproducto,
  p.nombre as producto_nombre,
  rr.cantidad,
  rr.registrado_at
from public.recetas_resultados rr
left join public.productos p on p.id = rr.idproducto;

create or replace view public.v_recetas_resultados_catalogo as
select
  rr.idreceta,
  rr.idproducto as id,
  p.nombre,
  rr.cantidad
from public.recetas_resultados rr
join public.productos p on p.id = rr.idproducto;

create or replace view public.v_productos_vistageneral as
select
  p.id,
  p.nombre,
  p.idcategoria,
  c.nombre as categoria_nombre,
  coalesce(c.nombre, 'Sin categoría') as categoria_nombre_filtro,
  p.activo,
  p.es_para_venta,
  p.es_para_compra,
  p.registrado_at,
  p.editado_at,
  p.registrado_por,
  p.editado_por
from public.productos p
left join public.categorias c on c.id = p.idcategoria;

-------------------------------------------------
-- TABLA: LISTA_PRECIOS
-------------------------------------------------
create table if not exists lista_precios (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);


-------------------------------------------------
-- TABLA: LISTA_PRECIOS_DET (escalones por producto)
-- Regla: precio_unitario = precio / cantidad_del_escalon
-------------------------------------------------
create table if not exists lista_precios_det (
  id uuid primary key default gen_random_uuid(),
  idlista uuid not null references lista_precios(id) on delete cascade,
  idproducto uuid not null references productos(id) on delete cascade,
  cantidad_escalon numeric(12,4) not null check (cantidad_escalon > 0),
  precio_unitario  numeric(12,6) not null check (precio_unitario >= 0),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  unique (idlista, idproducto, cantidad_escalon)
);


-- ============================================
-- 3. MÓDULO PEDIDOS · Pedidos (sin 'estado', con campos de auditoría)
-- ============================================

create table if not exists pedidos (
  id uuid primary key default gen_random_uuid(),
  idcliente uuid not null references clientes(id) on delete cascade,
  idlista_precios uuid references lista_precios(id),
  codigo text unique,
  total_contable numeric(14,2) not null default 0,
  total_ingreso_reconocido numeric(14,2) not null default 0,
  total_costo_reconocido numeric(14,2) not null default 0,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  estado_admin text not null default 'activo'
    check (estado_admin in ('activo','anulado_error','cancelado_cliente')),
  estado text not null default 'activo'
    check (estado in ('activo','cancelado')),
  observacion text,
  idasiento_por_cobrar uuid unique,
  idasiento_ingreso uuid unique
);

alter table if exists public.pedidos
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','cancelado'));

alter table if exists public.pedidos
  add column if not exists contable_version integer not null default 1;

create sequence if not exists public.pedidos_codigo_seq start 1;

create or replace function public.fn_pedidos_set_codigo()
returns trigger
language plpgsql
as $$
begin
  if new.codigo is not null and btrim(new.codigo) <> '' then
    return new;
  end if;
  new.codigo := concat('P', nextval('public.pedidos_codigo_seq')::text);
  return new;
end;
$$;

create trigger trg_pedidos_set_codigo
before insert on public.pedidos
for each row
execute function public.fn_pedidos_set_codigo();

-- ============================================
-- DETALLE DE PEDIDOS (precio venta)
-- ============================================

create table if not exists detallepedidos (
  id uuid primary key default gen_random_uuid(),
  idpedido uuid not null references pedidos(id) on delete cascade,
  idproducto uuid not null references productos(id),

  cantidad numeric(10,2) not null check (cantidad > 0),
  precioventa numeric(10,2) not null check (precioventa >= 0),

  estado text not null default 'activo'
    check (estado in ('activo','cancelado')),

  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

alter table if exists public.detallepedidos
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','cancelado'));

create unique index if not exists detallepedidos_activo_unq
  on public.detallepedidos (idpedido, idproducto)
  where estado = 'activo';

create or replace view public.v_detallepedidos_vistageneral as
select
  dp.id,
  dp.idpedido,
  dp.idproducto,
  prod.nombre as producto_nombre,
  dp.cantidad,
  dp.precioventa,
  dp.registrado_at
from public.detallepedidos dp
left join public.productos prod on prod.id = dp.idproducto
where dp.estado = 'activo';

create table if not exists pedido_reembolsos (
  id uuid primary key default gen_random_uuid(),
  idpedido uuid not null references pedidos(id) on delete cascade,
  monto numeric(12,2) not null,
  observacion text,
  link_evidencia text,
  idcuenta uuid,
  idmovimiento_financiero_cxc uuid,
  idmovimiento_financiero_banco uuid,
  registrado_at timestamptz default now(),
  registrado_por uuid references auth.users(id),
  editado_at timestamptz,
  editado_por uuid references auth.users(id)
);

create or replace view public.v_pedido_reembolsos_resumen as
select
  pr.idpedido,
  count(*)                         as cantidad_reembolsos,
  coalesce(sum(pr.monto), 0)::numeric(14,2) as total_reembolsado
from public.pedido_reembolsos pr
group by pr.idpedido;


-- Eventos administrativos (anulaciones, cancelaciones)
create table if not exists pedidos_eventos_admin (
  id uuid primary key default gen_random_uuid(),
  idpedido uuid not null references pedidos(id) on delete cascade,
  estado_previo text not null,
  estado_nuevo text not null,
  tipo_evento text not null
    check (tipo_evento in ('anulado_error','cancelado_cliente')),
  motivo text,
  registrado_at timestamptz default now(),
  registrado_por uuid references auth.users(id)
);

create or replace function public.fn_pedidos_log_estado_admin()
returns trigger
language plpgsql
as $$
declare
  v_motivo text;
begin
  -- Permit optional motivo via current_setting('erp.pedido_evento_motivo')
  v_motivo := nullif(current_setting('erp.pedido_evento_motivo', true), '');

  if old.estado_admin is distinct from new.estado_admin then
    insert into public.pedidos_eventos_admin (
      idpedido,
      estado_previo,
      estado_nuevo,
      tipo_evento,
      motivo,
      registrado_por
    )
    values (
      new.id,
      old.estado_admin,
      new.estado_admin,
      new.estado_admin,
      v_motivo,
      coalesce(new.editado_por, new.registrado_por, auth.uid())
    );
  end if;

  return new;
end;
$$;


create trigger tg_pedidos_log_estado_admin
after update of estado_admin on public.pedidos
for each row
when (old.estado_admin is distinct from new.estado_admin)
execute function public.fn_pedidos_log_estado_admin();

create or replace function public.fn_pedidos_block_cancel()
returns trigger
language plpgsql
as $$
begin
  if new.estado = 'cancelado'
      and old.estado is distinct from new.estado then
    if exists (
      select 1
      from public.detallepedidos dp
      where dp.idpedido = new.id
        and dp.estado = 'activo'
      limit 1
    ) then
      raise exception
        'No puedes cancelar el pedido mientras tenga detalle activo.';
    end if;
    if exists (
      select 1
      from public.pagos pg
      where pg.idpedido = new.id
        and pg.estado = 'activo'
      limit 1
    ) then
      raise exception
        'No puedes cancelar el pedido mientras tenga pagos activos.';
    end if;
    if exists (
      select 1
      from public.movimientopedidos mp
      where mp.idpedido = new.id
        and mp.estado = 'activo'
      limit 1
    ) then
      raise exception
        'No puedes cancelar el pedido mientras tenga movimientos activos.';
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_pedidos_block_cancel
before update of estado on public.pedidos
for each row
execute function public.fn_pedidos_block_cancel();

create or replace function public.fn_pedidos_cancelar(
  p_idpedido uuid,
  p_estado_admin text default 'cancelado_cliente',
  p_motivo text default null,
  p_usuario uuid default null
)
returns void
language plpgsql
as $$
declare
  v_pedido public.pedidos%rowtype;
  v_reg_at timestamptz := now();
  v_reg_por uuid;
  v_motivo text;
begin
  if p_idpedido is null then
    raise exception 'Pedido requerido.';
  end if;

  select *
    into v_pedido
  from public.pedidos
  where id = p_idpedido
  for update;

  if not found then
    raise exception 'No se encontró el pedido.';
  end if;

  if v_pedido.estado = 'cancelado' then
    return;
  end if;

  if p_estado_admin is not null
      and p_estado_admin not in ('anulado_error','cancelado_cliente') then
    raise exception 'Estado admin inválido para cancelación.';
  end if;

  v_reg_por := coalesce(
    p_usuario,
    auth.uid(),
    v_pedido.editado_por,
    v_pedido.registrado_por
  );
  v_motivo := nullif(btrim(p_motivo), '');
  if v_motivo is null then
    v_motivo := case
      when p_estado_admin = 'anulado_error' then 'Anulado por error'
      when p_estado_admin = 'cancelado_cliente' then 'Cancelado por cliente'
      else 'Cancelacion de pedido'
    end;
  end if;
  perform set_config('erp.pedido_evento_motivo', v_motivo, true);

  if exists (
    select 1
    from public.movimientopedidos mp
    join public.viajesdetalles vd on vd.idmovimiento = mp.id
    where mp.idpedido = p_idpedido
      and vd.llegada_at is not null
    limit 1
  ) then
    raise exception
      'No puedes cancelar el pedido mientras tenga movimientos con llegada registrada.';
  end if;

  if exists (
    select 1
    from public.movimientopedidos mp
    join public.viajesdetalles vd on vd.idmovimiento = mp.id
    where mp.idpedido = p_idpedido
    limit 1
  ) then
    raise exception
      'No puedes cancelar el pedido mientras tenga movimientos asignados a viajes.';
  end if;

  update public.detallemovimientopedidos dmp
    set estado = 'cancelado',
        editado_at = v_reg_at,
        editado_por = v_reg_por
  from public.movimientopedidos mp
  where mp.id = dmp.idmovimiento
    and mp.idpedido = p_idpedido
    and dmp.estado <> 'cancelado';

  update public.movimientopedidos
    set estado = 'cancelado',
        editado_at = v_reg_at,
        editado_por = v_reg_por
  where idpedido = p_idpedido
    and estado <> 'cancelado';

  if exists (
    select 1
    from (
      select
        coalesce(env.idproducto, dev.idproducto) as idproducto,
        coalesce(env.enviado, 0)::numeric(12,2)
        - coalesce(dev.devuelto, 0)::numeric(12,2) as neto
      from (
        select dmp.idproducto, sum(dmp.cantidad)::numeric(12,2) as enviado
        from public.movimientopedidos mp
        join public.detallemovimientopedidos dmp on dmp.idmovimiento = mp.id
        where mp.idpedido = p_idpedido
          and mp.estado = 'activo'
          and dmp.estado = 'activo'
        group by dmp.idproducto
      ) env
      full join (
        select dmp.idproducto, sum(vdd.cantidad)::numeric(12,2) as devuelto
        from public.viajes_devueltos vd
        join public.viajes_devueltos_detalle vdd on vdd.iddevuelto = vd.id
        join public.detallemovimientopedidos dmp on dmp.id = vdd.iddetalle_movimiento
        where vd.idpedido = p_idpedido
          and vd.estado = 'devuelto_base'
        group by dmp.idproducto
      ) dev on dev.idproducto = env.idproducto
    ) totales
    where totales.neto <> 0
  ) then
    raise exception
      'No puedes cancelar el pedido porque el neto enviado no esta conciliado.';
  end if;

  update public.detallepedidos
    set estado = 'cancelado',
        editado_at = v_reg_at,
        editado_por = v_reg_por
  where idpedido = p_idpedido
    and estado <> 'cancelado';

  update public.pagos
    set estado = 'cancelado',
        editado_at = v_reg_at,
        editado_por = v_reg_por
  where idpedido = p_idpedido
    and estado <> 'cancelado';

  update public.pedidos
    set estado = 'cancelado',
        estado_admin = coalesce(p_estado_admin, estado_admin),
        editado_at = v_reg_at,
        editado_por = v_reg_por
  where id = p_idpedido;
end;
$$;



-------------------------------------------------
-- 4. MÓDULO OPERACIONES (Movimientos + Destinos)
-------------------------------------------------

-- Movimiento logístico (salida/entrega)
-- ============================================
-- TABLA: MOVIMIENTOS DE PEDIDOS
-- ============================================

create table if not exists movimientopedidos (
  id uuid primary key default gen_random_uuid(),
  idpedido uuid not null references pedidos(id) on delete cascade,
  idbase uuid references bases(id),
  codigo text unique,
  es_provincia boolean not null default false,
  destino_lima_iddireccion uuid references direccion(id),
  destino_lima_idnumrecibe uuid references numrecibe(id),
  destino_provincia_iddireccion uuid references direccion_provincia(id),
  fecharegistro timestamptz default now(),
  observacion text,
  estado text not null default 'activo'
    check (estado in ('activo','cancelado')),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  constraint movimientopedidos_provincia_destino_chk
    check (
      es_provincia = false
      or (
        destino_provincia_iddireccion is not null
        and destino_lima_iddireccion is null
        and destino_lima_idnumrecibe is null
      )
    ),
  constraint movimientopedidos_lima_destino_chk
    check (
      es_provincia = true
      or (
        destino_lima_iddireccion is not null
        and destino_lima_idnumrecibe is not null
        and destino_provincia_iddireccion is null
      )
    )
);

alter table if exists public.movimientopedidos
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','cancelado'));

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'movimientopedidos_provincia_destino_chk'
      and conrelid = 'public.movimientopedidos'::regclass
  ) then
    alter table public.movimientopedidos
      add constraint movimientopedidos_provincia_destino_chk
      check (
        es_provincia = false
        or (
          destino_provincia_iddireccion is not null
          and destino_lima_iddireccion is null
          and destino_lima_idnumrecibe is null
        )
      );
  end if;
end $$;

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'movimientopedidos_lima_destino_chk'
      and conrelid = 'public.movimientopedidos'::regclass
  ) then
    alter table public.movimientopedidos
      add constraint movimientopedidos_lima_destino_chk
      check (
        es_provincia = true
        or (
          destino_lima_iddireccion is not null
          and destino_lima_idnumrecibe is not null
          and destino_provincia_iddireccion is null
        )
      );
  end if;
end $$;

create sequence if not exists public.movimientos_codigo_seq start 1;

create or replace function public.fn_movimientopedidos_set_codigo()
returns trigger
language plpgsql
as $$
declare
  v_pedido_codigo text;
  v_mov_num text;
begin
  if new.codigo is not null and btrim(new.codigo) <> '' then
    return new;
  end if;

  select codigo
    into v_pedido_codigo
  from public.pedidos
  where id = new.idpedido
  limit 1;

  if v_pedido_codigo is null or btrim(v_pedido_codigo) = '' then
    v_pedido_codigo := concat('P', nextval('public.pedidos_codigo_seq')::text);
    update public.pedidos
      set codigo = v_pedido_codigo
    where id = new.idpedido
      and (codigo is null or btrim(codigo) = '');
  end if;

  v_mov_num := nextval('public.movimientos_codigo_seq')::text;
  new.codigo := concat(v_pedido_codigo, '/M', v_mov_num);
  return new;
end;
$$;

create trigger trg_movimientopedidos_set_codigo
before insert on public.movimientopedidos
for each row
execute function public.fn_movimientopedidos_set_codigo();


create table if not exists pedido_rectificaciones (
  id uuid primary key default gen_random_uuid(),
  idpedido uuid not null references pedidos(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(12,2) not null,
  motivo text,
  estado text not null default 'pendiente'
    check (estado in ('pendiente', 'en_proceso', 'completado', 'cancelado')),
  idmovimiento uuid references movimientopedidos(id) on delete set null,
  observacion text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create or replace view public.v_pedido_rectificaciones_vistageneral as
select
  pr.id,
  pr.idpedido,
  pr.idproducto,
  prod.nombre                as producto_nombre,
  pr.cantidad,
  pr.motivo,
  pr.estado,
  pr.idmovimiento,
  mp.fecharegistro           as movimiento_fecha,
  pr.observacion,
  pr.registrado_at,
  pr.editado_at,
  pr.registrado_por,
  pr.editado_por
from public.pedido_rectificaciones pr
left join public.productos prod on prod.id = pr.idproducto
left join public.movimientopedidos mp on mp.id = pr.idmovimiento;

create or replace view public.v_detallepedidos_ajustado as
with detalle_base as (
  select
    dp.idpedido as pedido_id,
    dp.idproducto,
    sum(dp.cantidad)::numeric(12,2) as cantidad_base,
    sum(dp.precioventa)::numeric(12,2) as precioventa_base
  from public.detallepedidos dp
  where dp.estado = 'activo'
  group by dp.idpedido, dp.idproducto
),
rectificaciones as (
  select
    pr.idpedido as pedido_id,
    pr.idproducto,
    sum(pr.cantidad)::numeric(12,2) as cantidad_rectificada
  from public.pedido_rectificaciones pr
  where pr.estado in ('pendiente', 'en_proceso', 'completado')
  group by pr.idpedido, pr.idproducto
),
totales as (
  select
    coalesce(b.pedido_id, r.pedido_id) as pedido_id,
    coalesce(b.idproducto, r.idproducto) as idproducto,
    coalesce(b.cantidad_base, 0)::numeric(12,2) as cantidad_base,
    coalesce(b.precioventa_base, 0)::numeric(12,2) as precioventa_base,
    coalesce(r.cantidad_rectificada, 0)::numeric(12,2) as cantidad_rectificada
  from detalle_base b
  full join rectificaciones r
    on r.pedido_id = b.pedido_id
   and r.idproducto = b.idproducto
)
select
  pedido_id as idpedido,
  idproducto,
  greatest(cantidad_base + cantidad_rectificada, 0)::numeric(12,2) as cantidad,
  case
    when cantidad_base > 0 then
      (precioventa_base / cantidad_base)::numeric(18,6)
    else 0
  end as precio_unitario,
  case
    when cantidad_base > 0 then
      round(
        (precioventa_base / cantidad_base)
        * greatest(cantidad_base + cantidad_rectificada, 0),
        2
      )
    else 0
  end::numeric(12,2) as precioventa
from totales
where greatest(cantidad_base + cantidad_rectificada, 0) > 0;

-- Detalle del movimiento (qué producto y cuánto salió)
create table if not exists detallemovimientopedidos (
  id uuid primary key default gen_random_uuid(),
  idmovimiento uuid not null references movimientopedidos(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(10,2) not null check (cantidad > 0),
  estado text not null default 'activo'
    check (estado in ('activo','cancelado')),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

alter table if exists public.detallemovimientopedidos
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','cancelado'));

create unique index if not exists detallemovimientopedidos_activo_unq
  on public.detallemovimientopedidos (idmovimiento, idproducto)
  where estado = 'activo';

create or replace view public.v_movimiento_detalle_vistageneral as
select
  dmp.id,
  dmp.idmovimiento,
  dmp.idproducto,
  prod.nombre as producto_nombre,
  dmp.cantidad
from public.detallemovimientopedidos dmp
left join public.productos prod on prod.id = dmp.idproducto
where dmp.estado = 'activo';

-------------------------------------------------
-- 4.2 VIAJES Y ASIGNACIONES
-------------------------------------------------

create table if not exists viajes (
  id uuid primary key default gen_random_uuid(),

  -- Datos del motorizado
  nombre_motorizado text not null,
  num_llamadas text,
  num_wsp text,            -- opcional
  num_pago text,
  link text not null,
  idbase uuid not null references bases(id),
  
  monto numeric(10,2) not null check (monto >= 0),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);


-- Relación viaje ↔ movimientos (entregas efectivas)
create table if not exists viajesdetalles (
  id uuid primary key default gen_random_uuid(),
  idmovimiento uuid not null references movimientopedidos(id) on delete cascade,
  idviaje uuid not null references viajes(id) on delete cascade,
  idpacking uuid not null references base_packings(id),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  llegada_at timestamptz,
  devuelto_solicitado_at timestamptz,
  unique (idmovimiento)  -- << bloquea reutilizar el movimiento en otro viaje
);

create or replace function public.fn_movimientopedidos_block_delete_if_viaje()
returns trigger
language plpgsql
as $$
begin
  if exists (
    select 1
    from public.viajesdetalles vd
    where vd.idmovimiento = old.id
    limit 1
  ) then
    raise exception
      'No puedes eliminar este movimiento porque ya fue asignado a un viaje.';
  end if;
  return old;
end;
$$;

create trigger trg_movimientopedidos_block_delete
before delete on public.movimientopedidos
for each row
execute function public.fn_movimientopedidos_block_delete_if_viaje();

create or replace function public.fn_movimientopedidos_block_cancel()
returns trigger
language plpgsql
as $$
begin
  if new.estado = 'cancelado'
      and old.estado is distinct from new.estado then
    if exists (
      select 1
      from public.detallemovimientopedidos dmp
      where dmp.idmovimiento = new.id
        and dmp.estado = 'activo'
      limit 1
    ) then
      raise exception
        'No puedes cancelar el movimiento mientras tenga detalle activo.';
    end if;
    if exists (
      select 1
      from public.viajesdetalles vd
      where vd.idmovimiento = new.id
      limit 1
    ) then
      raise exception
        'No puedes cancelar el movimiento porque ya fue asignado a un viaje.';
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_movimientopedidos_block_cancel
before update of estado on public.movimientopedidos
for each row
execute function public.fn_movimientopedidos_block_cancel();

create or replace function public.fn_pedidos_movimiento_cancelar(
  p_movimiento_id uuid,
  p_usuario uuid default null
)
returns void
language plpgsql
as $$
declare
  v_mov public.movimientopedidos%rowtype;
  v_reg_at timestamptz;
  v_reg_por uuid;
begin
  if p_movimiento_id is null then
    raise exception 'Movimiento requerido.';
  end if;

  select *
    into v_mov
  from public.movimientopedidos
  where id = p_movimiento_id
  for update;

  if not found then
    return;
  end if;

  if v_mov.estado = 'cancelado' then
    return;
  end if;

  if exists (
    select 1
    from public.viajesdetalles vd
    where vd.idmovimiento = p_movimiento_id
      and vd.llegada_at is not null
    limit 1
  ) then
    raise exception
      'No puedes cancelar el movimiento porque ya tiene llegada registrada.';
  end if;

  if exists (
    select 1
    from public.viajesdetalles vd
    where vd.idmovimiento = p_movimiento_id
    limit 1
  ) then
    raise exception
      'No puedes cancelar el movimiento porque ya fue asignado a un viaje.';
  end if;

  v_reg_por := coalesce(
    p_usuario,
    v_mov.editado_por,
    v_mov.registrado_por,
    auth.uid()
  );
  v_reg_at := coalesce(v_mov.editado_at, v_mov.registrado_at, now());

  update public.detallemovimientopedidos
    set estado = 'cancelado',
        editado_at = v_reg_at,
        editado_por = v_reg_por
  where idmovimiento = p_movimiento_id
    and estado <> 'cancelado';

  update public.movimientopedidos
    set estado = 'cancelado',
        editado_at = v_reg_at,
        editado_por = v_reg_por
  where id = p_movimiento_id
    and estado <> 'cancelado';
end;
$$;

create or replace function public.fn_detallemovimientopedidos_block_entrega()
returns trigger
language plpgsql
as $$
declare
  v_movimiento uuid;
begin
  v_movimiento := coalesce(new.idmovimiento, old.idmovimiento);

  if v_movimiento is null then
    return case when tg_op = 'DELETE' then old else new end;
  end if;

  if exists (
    select 1
    from public.viajesdetalles vd
    where vd.idmovimiento = v_movimiento
      and vd.llegada_at is not null
    limit 1
  ) then
    raise exception
      'No puedes modificar detalle de movimiento % porque ya tiene llegada registrada.',
      v_movimiento;
  end if;

  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger trg_detallemovimientopedidos_block_entrega
before insert or update or delete on public.detallemovimientopedidos
for each row
execute function public.fn_detallemovimientopedidos_block_entrega();

create table if not exists viajes_devueltos (
  id uuid primary key default gen_random_uuid(),
  idviaje_detalle uuid not null references viajesdetalles(id) on delete cascade,
  idmovimiento uuid not null references movimientopedidos(id) on delete cascade,
  idpedido uuid not null references pedidos(id) on delete cascade,
  idbase_retorno uuid references bases(id),
  link_evidencia text,
  monto_ida numeric(12,2) not null default 0 check (monto_ida >= 0),
  monto_vuelta numeric(12,2) not null default 0 check (monto_vuelta >= 0),
  penalidad numeric(12,2) not null default 50,
  cliente_resuelto_at timestamptz,
  devuelto_recibido_at timestamptz,
  estado text not null default 'pendiente'
    check (
      estado in (
        'pendiente',
        'resuelto_cliente',
        'devuelto_base'
      )
    ),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create unique index if not exists viajes_devueltos_idviaje_detalle_unq
  on public.viajes_devueltos (idviaje_detalle);

create table if not exists viajes_devueltos_detalle (
  id uuid primary key default gen_random_uuid(),
  iddevuelto uuid not null references viajes_devueltos(id) on delete cascade,
  iddetalle_movimiento uuid not null references detallemovimientopedidos(id) on delete cascade,
  idmovimiento uuid not null references movimientopedidos(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(10,2) not null check (cantidad > 0),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  unique (iddevuelto, iddetalle_movimiento)
);

create or replace function public.fn_viajes_devueltos_detalle_block_posted()
returns trigger
language plpgsql
as $$
declare
  v_devuelto uuid;
  v_estado text;
begin
  v_devuelto := coalesce(new.iddevuelto, old.iddevuelto);
  if v_devuelto is null then
    return case when tg_op = 'DELETE' then old else new end;
  end if;

  select estado
    into v_estado
  from public.viajes_devueltos
  where id = v_devuelto;

  if v_estado = 'devuelto_base' then
    raise exception
      'No puedes modificar detalle de devolucion % porque ya esta en estado devuelto_base.',
      v_devuelto;
  end if;

  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger trg_viajes_devueltos_detalle_block_posted
before insert or update or delete on public.viajes_devueltos_detalle
for each row
execute function public.fn_viajes_devueltos_detalle_block_posted();

create or replace function public.fn_viajes_devueltos_detalle_validate()
returns trigger
language plpgsql
as $$
declare
  v_detalle detallemovimientopedidos%rowtype;
  v_movimiento uuid;
begin
  if tg_op = 'UPDATE'
      and new.iddetalle_movimiento is distinct from old.iddetalle_movimiento then
    raise exception 'No puedes cambiar el detalle asociado a la devolución.';
  end if;

  select *
    into v_detalle
  from public.detallemovimientopedidos
  where id = new.iddetalle_movimiento;

  if not found then
    raise exception
      'No se encontró el detalle de movimiento %.',
      new.iddetalle_movimiento;
  end if;
  if v_detalle.estado = 'cancelado' then
    raise exception
      'El detalle de movimiento seleccionado está cancelado.';
  end if;

  select idmovimiento
    into v_movimiento
  from public.viajes_devueltos
  where id = new.iddevuelto;

  if not found then
    raise exception 'No se encontró la devolución %.', new.iddevuelto;
  end if;

  if v_detalle.idmovimiento <> v_movimiento then
    raise exception
      'El detalle seleccionado no pertenece al movimiento de la devolución.';
  end if;

  if new.cantidad > v_detalle.cantidad then
    raise exception
      'La cantidad devuelta (%.2f) no puede exceder la cantidad enviada (%.2f).',
      new.cantidad,
      v_detalle.cantidad;
  end if;

  new.idmovimiento := v_detalle.idmovimiento;
  new.idproducto := v_detalle.idproducto;
  return new;
end;
$$;

create trigger trg_viajes_devueltos_detalle_validate
before insert or update on public.viajes_devueltos_detalle
for each row
execute function public.fn_viajes_devueltos_detalle_validate();

create or replace function public.fn_viajes_devueltos_seed_detalle()
returns trigger
language plpgsql
as $$
begin
  insert into public.viajes_devueltos_detalle (
    iddevuelto,
    iddetalle_movimiento,
    cantidad,
    registrado_por
  )
  select
    new.id,
    dmp.id,
    dmp.cantidad,
    coalesce(new.editado_por, new.registrado_por, auth.uid())
  from public.detallemovimientopedidos dmp
  where dmp.idmovimiento = new.idmovimiento
    and dmp.estado = 'activo'
  on conflict (iddevuelto, iddetalle_movimiento) do nothing;

  return new;
end;
$$;

create trigger trg_viajes_devueltos_seed_detalle
after insert on public.viajes_devueltos
for each row
execute function public.fn_viajes_devueltos_seed_detalle();

create or replace function public.fn_detallepedidos_block_delete()
returns trigger
language plpgsql
as $$
declare
  v_has_movimiento boolean;
begin
  select exists (
    select 1
    from public.detallemovimientopedidos dmp
    join public.movimientopedidos mp on mp.id = dmp.idmovimiento
    where mp.idpedido = old.idpedido
      and dmp.idproducto = old.idproducto
    limit 1
  )
    into v_has_movimiento;

  if not v_has_movimiento then
    return old;
  end if;

  raise exception
    'No puedes eliminar este detalle porque ya tiene movimientos registrados. Usa una rectificación.';
  return old;
end;
$$;

create trigger trg_detallepedidos_block_delete
before delete on public.detallepedidos
for each row
execute function public.fn_detallepedidos_block_delete();

create or replace function public.fn_detallepedidos_block_update()
returns trigger
language plpgsql
as $$
declare
  v_has_movimiento boolean;
begin
  select exists (
    select 1
    from public.detallemovimientopedidos dmp
    join public.movimientopedidos mp on mp.id = dmp.idmovimiento
    where mp.idpedido = old.idpedido
      and dmp.idproducto = old.idproducto
      and mp.estado = 'activo'
      and dmp.estado = 'activo'
    limit 1
  )
    into v_has_movimiento;

  if v_has_movimiento then
    if new.estado = 'cancelado' and old.estado is distinct from new.estado then
      raise exception
        'No puedes cancelar este detalle porque ya tiene movimientos activos. Usa una rectificación.';
    end if;
    raise exception
      'No puedes modificar este detalle porque ya tiene movimientos registrados. Usa una rectificación.';
  end if;

  return new;
end;
$$;

create trigger trg_detallepedidos_block_update
before update on public.detallepedidos
for each row
execute function public.fn_detallepedidos_block_update();



create table if not exists pedido_cargos_logistica (
  id uuid primary key default gen_random_uuid(),
  idpedido uuid not null references pedidos(id) on delete cascade,
  idviaje_devuelto uuid references viajes_devueltos(id) on delete set null,
  tipo text not null,
  monto numeric(12,2) not null,
  descripcion text,
  link_evidencia text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create or replace function public.fn_viajes_detalle_sync_devuelto()
returns trigger
language plpgsql
as $$
declare
  v_pedido uuid;
  v_base uuid;
  v_exists uuid;
begin
  if new.devuelto_solicitado_at is null then
    return new;
  end if;
  if tg_op <> 'UPDATE' then
    return new;
  end if;
  select id
    into v_exists
  from public.viajes_devueltos
  where idviaje_detalle = new.id
  limit 1;
  if v_exists is not null then
    return new;
  end if;
  select mp.idpedido, mp.idbase
    into v_pedido, v_base
  from public.movimientopedidos mp
  where mp.id = new.idmovimiento
  limit 1;
  if v_pedido is null then
    raise exception
      'No se pudo determinar el pedido para el movimiento % al registrar devolución.',
      new.idmovimiento;
  end if;
  insert into public.viajes_devueltos (
    idviaje_detalle,
    idmovimiento,
    idpedido,
    idbase_retorno,
    registrado_por
  ) values (
    new.id,
    new.idmovimiento,
    v_pedido,
    v_base,
    coalesce(new.editado_por, new.registrado_por)
  );
  return new;
end;
$$;

create trigger trg_viajes_detalle_sync_devuelto
after update on public.viajesdetalles
for each row
when (
  old.devuelto_solicitado_at is distinct from new.devuelto_solicitado_at
  and new.devuelto_solicitado_at is not null
)
execute function public.fn_viajes_detalle_sync_devuelto();

-------------------------------------------------
-- 5. MÓDULO FINANZAS (Pagos, Cuentas y Cargos)
-------------------------------------------------

-- Catálogo de cuentas contables (se define primero por dependencias)
create table if not exists cuentas_contables (
  id uuid primary key default gen_random_uuid(),
  codigo text not null unique,
  nombre text not null,
  tipo text not null check (tipo in ('activo','pasivo','patrimonio','ingreso','gasto')),
  parent_id uuid references cuentas_contables(id),
  es_terminal boolean default true,
  es_gasto_operativo boolean default false,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create unique index if not exists idx_cuentas_contables_codigo_norm
  on public.cuentas_contables (lower(trim(codigo)));

-- Catálogo de cuentas bancarias y medios de cobro
create table if not exists cuentas_bancarias (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,         -- Ej: "Cuenta Yape", "Interbank Principal", "BCP Secundaria"
  banco text not null,          -- Ej: "Yape", "Interbank", "BBVA", "BCP", "Plin"
  activa boolean default true,
  idcuenta_contable uuid references cuentas_contables(id),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create or replace view public.v_cuentas_bancarias_vistageneral as
select
  cb.id,
  cb.nombre,
  cb.banco,
  cb.activa,
  cb.idcuenta_contable,
  cb.registrado_at,
  cb.editado_at,
  cb.registrado_por,
  cb.editado_por,
  cc.codigo as cuenta_contable_codigo,
  cc.nombre as cuenta_contable_nombre
from public.cuentas_bancarias cb
left join public.cuentas_contables cc on cc.id = cb.idcuenta_contable;

create table if not exists cuentas_bancarias_asignadas (
  id uuid primary key default gen_random_uuid(),
  idcuenta uuid not null references cuentas_bancarias(id) on delete cascade,
  idusuario uuid not null references perfiles(user_id) on delete cascade,
  activo boolean not null default true,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  unique (idcuenta, idusuario)
);

create or replace view public.v_cuentas_bancarias_asignadas as
select
  a.id,
  a.idcuenta,
  cb.nombre as cuenta_nombre,
  cb.banco as cuenta_banco,
  a.idusuario,
  p.nombre as usuario_nombre,
  p.rol as usuario_rol,
  a.activo,
  a.registrado_at,
  a.editado_at,
  a.registrado_por,
  a.editado_por
from public.cuentas_bancarias_asignadas a
join public.cuentas_bancarias cb on cb.id = a.idcuenta
join public.perfiles p on p.user_id = a.idusuario;

create or replace view public.v_cuentas_bancarias_visibles as
select
  vcb.*
from public.v_cuentas_bancarias_vistageneral vcb
where public.fn_es_admin()
  or not exists (
    select 1
    from public.perfiles pf
    where pf.user_id = auth.uid()
      and pf.activo = true
      and pf.rol = 'gerente'
  )
  or exists (
    select 1
    from public.cuentas_bancarias_asignadas cba
    where cba.idcuenta = vcb.id
      and cba.idusuario = auth.uid()
      and cba.activo = true
  );

create or replace function public.fn_cuentas_bancarias_prevent_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar cuentas bancarias; desactiva la cuenta.';
end;
$$;

create trigger trg_cuentas_bancarias_prevent_delete
before delete on public.cuentas_bancarias
for each row
execute function public.fn_cuentas_bancarias_prevent_delete();

alter table public.cuentas_bancarias_asignadas enable row level security;

create policy cuentas_bancarias_asignadas_admin_full
  on public.cuentas_bancarias_asignadas
  for all
  using (public.fn_es_admin())
  with check (public.fn_es_admin());

create policy cuentas_bancarias_asignadas_self_read
  on public.cuentas_bancarias_asignadas
  for select
  using (idusuario = auth.uid());

create sequence if not exists public.cuentas_bancarias_codigo_seq start 2;

create or replace function public.fn_cuentas_bancarias_set_cuenta()
returns trigger
language plpgsql
as $$
declare
  v_parent uuid;
  v_codigo text;
  v_registrado_por uuid;
begin
  if tg_op = 'INSERT' then
    if new.idcuenta_contable is not null then
      return new;
    end if;

    select id into v_parent
    from public.cuentas_contables
    where codigo = '10'
    limit 1;

    if v_parent is null then
      raise exception 'Configura la cuenta contable 10 (Caja y Bancos) antes de crear cuentas bancarias.';
    end if;

    v_codigo := concat('10.', lpad(nextval('public.cuentas_bancarias_codigo_seq')::text, 2, '0'));
    v_registrado_por := coalesce(new.registrado_por, auth.uid());

    insert into public.cuentas_contables (
      id,
      codigo,
      nombre,
      tipo,
      parent_id,
      registrado_at,
      registrado_por
    )
    values (
      gen_random_uuid(),
      v_codigo,
      concat('Banco ', new.nombre),
      'activo',
      v_parent,
      coalesce(new.registrado_at, now()),
      v_registrado_por
    )
    returning id into new.idcuenta_contable;
    return new;
  elsif tg_op = 'UPDATE' then
    if new.idcuenta_contable is null then
      return new;
    end if;
    if new.nombre is distinct from old.nombre then
      update public.cuentas_contables
      set nombre = concat('Banco ', new.nombre),
          editado_at = now(),
          editado_por = coalesce(auth.uid(), new.editado_por, old.editado_por)
      where id = new.idcuenta_contable;
    end if;
    return new;
  end if;

  return new;
end;
$$;

create trigger trg_cuentas_bancarias_set_cuenta
before insert or update on public.cuentas_bancarias
for each row
execute function public.fn_cuentas_bancarias_set_cuenta();

create or replace view public.v_pedido_reembolsos_vistageneral as
select
  pr.id,
  pr.idpedido,
  pr.monto,
  pr.observacion,
  pr.link_evidencia,
  pr.idcuenta,
  cb.nombre as cuenta_nombre,
  pr.registrado_at,
  pr.registrado_por,
  pr.editado_at,
  pr.editado_por
from public.pedido_reembolsos pr
left join public.cuentas_bancarias cb on cb.id = pr.idcuenta;

do $$
declare
  v_parent uuid;
  v_row record;
  v_codigo text;
  v_new_id uuid;
begin
  select id into v_parent
  from public.cuentas_contables
  where codigo = '10'
  limit 1;

  if v_parent is null then
    return;
  end if;

  for v_row in
    select id, nombre
    from public.cuentas_bancarias
    where idcuenta_contable is null
  loop
    v_codigo := concat(
      '10.',
      lpad(nextval('public.cuentas_bancarias_codigo_seq')::text, 2, '0')
    );

    insert into public.cuentas_contables (
      id,
      codigo,
      nombre,
      tipo,
      parent_id,
      registrado_at,
      registrado_por
    )
    values (
      gen_random_uuid(),
      v_codigo,
      concat('Banco ', v_row.nombre),
      'activo',
      v_parent,
      now(),
      coalesce(
        auth.uid(),
        '00000000-0000-0000-0000-000000000000'::uuid
      )
    )
    returning id into v_new_id;

    update public.cuentas_bancarias
    set idcuenta_contable = v_new_id
    where id = v_row.id;
  end loop;
end;
$$;

-- Pagos asociados al pedido
create table if not exists pagos (
  id uuid primary key default gen_random_uuid(),
  idpedido uuid not null references pedidos(id) on delete cascade,
  idcuenta uuid references cuentas_bancarias(id),   -- cuenta usada
  codigo text unique,
  monto numeric(10,2) not null check (monto >= 0),
  estado text not null default 'activo'
    check (estado in ('activo','cancelado')),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  fechapago timestamptz not null,
  idmovimiento_financiero uuid unique,
  idmovimiento_financiero_banco uuid unique
);

alter table if exists public.pagos
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','cancelado'));

create sequence if not exists public.pagos_codigo_seq start 1;

create or replace function public.fn_pagos_set_codigo()
returns trigger
language plpgsql
as $$
declare
  v_pedido_codigo text;
  v_pago_num text;
begin
  if new.codigo is not null and btrim(new.codigo) <> '' then
    return new;
  end if;

  select codigo
    into v_pedido_codigo
  from public.pedidos
  where id = new.idpedido
  limit 1;

  if v_pedido_codigo is null or btrim(v_pedido_codigo) = '' then
    v_pedido_codigo := concat('P', nextval('public.pedidos_codigo_seq')::text);
    update public.pedidos
      set codigo = v_pedido_codigo
    where id = new.idpedido
      and (codigo is null or btrim(codigo) = '');
  end if;

  v_pago_num := nextval('public.pagos_codigo_seq')::text;
  new.codigo := concat(v_pedido_codigo, '/PG', v_pago_num);
  return new;
end;
$$;

create trigger trg_pagos_set_codigo
before insert on public.pagos
for each row
execute function public.fn_pagos_set_codigo();

create or replace function public.fn_pedido_total_con_cargos(p_idpedido uuid)
returns numeric
language sql
as $$
  select (
    coalesce((
      select sum(dp.precioventa)
      from public.v_detallepedidos_ajustado dp
      where dp.idpedido = p_idpedido
    ), 0)
    + coalesce((
      select sum(
        coalesce(vd.penalidad, 0)
        + coalesce(vd.monto_ida, 0)
        + coalesce(vd.monto_vuelta, 0)
      )
      from public.viajes_devueltos vd
      where vd.idpedido = p_idpedido
        and vd.estado = 'devuelto_base'
    ), 0)
    + coalesce((
      select count(*) * 50.00
      from public.movimientopedidos mp
      where mp.idpedido = p_idpedido
        and mp.es_provincia = true
        and mp.estado = 'activo'
    ), 0)
  )::numeric(12,2);
$$;

create or replace function public.fn_pagos_block_sobrepago()
returns trigger
language plpgsql
as $$
declare
  v_total_pagado numeric(12,2);
  v_total_pedido numeric(12,2);
  v_exclude_id uuid;
begin
  if new.estado <> 'activo' then
    return new;
  end if;

  v_exclude_id := case when tg_op = 'UPDATE' then old.id else null end;

  perform 1
  from public.pedidos p
  where p.id = new.idpedido
  for update;

  select coalesce(sum(pg.monto), 0)::numeric(12,2)
    into v_total_pagado
  from public.pagos pg
  where pg.idpedido = new.idpedido
    and pg.estado = 'activo'
    and (v_exclude_id is null or pg.id <> v_exclude_id);

  v_total_pedido := public.fn_pedido_total_con_cargos(new.idpedido);

  if (coalesce(v_total_pagado, 0) + new.monto)
     > (coalesce(v_total_pedido, 0) + 0.01) then
    raise exception
      'Pago excede el total del pedido (incluye devoluciones y provincia).';
  end if;

  return new;
end;
$$;

create trigger trg_pagos_block_sobrepago
before insert or update on public.pagos
for each row
execute function public.fn_pagos_block_sobrepago();

create or replace function public.fn_pagos_prevent_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar pagos; usa cancelar.';
end;
$$;

create trigger trg_pagos_prevent_delete
before delete on public.pagos
for each row
execute function public.fn_pagos_prevent_delete();

create table if not exists movimientos_financieros (
  id uuid primary key default gen_random_uuid(),
  tipo text not null check (tipo in ('ingreso','gasto','ajuste','transferencia')),
  origen text,
  source_key text,
  descripcion text not null,
  monto numeric(14,2) not null check (monto > 0),
  idpedido uuid references pedidos(id) on delete set null,
  idcuenta_origen uuid references cuentas_bancarias(id),
  idcuenta_destino uuid references cuentas_bancarias(id),
  idcuenta_contable uuid references cuentas_contables(id),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  estado text not null default 'posted'
    check (estado in ('draft','posted','reversed')),
  posted_at timestamptz,
  periodo_contable text,
  reversed_by_id uuid references movimientos_financieros(id) on delete set null,
  check (
    (tipo = 'transferencia' and idcuenta_origen is not null and idcuenta_destino is not null and idcuenta_origen <> idcuenta_destino)
    or (tipo <> 'transferencia')
  ),
  check (
    (tipo in ('ingreso','gasto','ajuste') and idcuenta_contable is not null)
    or (tipo = 'transferencia' and idcuenta_contable is null)
  )
);

alter table public.movimientos_financieros
  add column if not exists origen text;

alter table public.movimientos_financieros
  add column if not exists source_key text;

alter table public.movimientos_financieros
  add column if not exists estado text not null default 'posted'
    check (estado in ('draft','posted','reversed'));

alter table public.movimientos_financieros
  add column if not exists posted_at timestamptz;

alter table public.movimientos_financieros
  add column if not exists periodo_contable text;

alter table public.movimientos_financieros
  add column if not exists reversed_by_id uuid
    references movimientos_financieros(id) on delete set null;

create unique index if not exists idx_movimientos_financieros_source_key
  on public.movimientos_financieros (source_key)
  where source_key is not null and estado <> 'reversed';

update public.movimientos_financieros
set posted_at = coalesce(registrado_at, now())
where posted_at is null
  and estado = 'posted';

create table if not exists contabilidad_periodos (
  periodo_contable text primary key,
  cerrado boolean not null default false,
  cerrado_at timestamptz,
  cerrado_por uuid references auth.users(id),
  observacion text
);

create index if not exists idx_contabilidad_periodos_cerrado
  on public.contabilidad_periodos (cerrado, periodo_contable);

create or replace function public.fn_contabilidad_periodos_block_auto()
returns trigger
language plpgsql
as $$
begin
  if new.observacion = 'Auto creado por GL' then
    raise exception
      'Periodo contable % no existe; cree el periodo antes de postear.',
      new.periodo_contable;
  end if;
  return new;
end;
$$;

create trigger trg_contabilidad_periodos_block_auto
before insert on public.contabilidad_periodos
for each row
execute function public.fn_contabilidad_periodos_block_auto();

create or replace function public.fn_contabilidad_periodo_key(p_timestamp timestamptz)
returns text
language sql
stable
as $$
  select to_char(timezone('America/Lima', coalesce($1, now())), 'YYYYMM');
$$;

insert into public.contabilidad_periodos (
  periodo_contable,
  cerrado,
  observacion
)
values (
  public.fn_contabilidad_periodo_key(now()),
  false,
  'Inicial'
)
on conflict (periodo_contable) do nothing;

update public.movimientos_financieros
set periodo_contable = public.fn_contabilidad_periodo_key(posted_at)
where periodo_contable is null
  and estado = 'posted'
  and posted_at is not null;

-------------------------------------------------
-- GL / Libro mayor (doble partida)
-------------------------------------------------

-------------------------------------------------
-- 1. Tablas principales
-------------------------------------------------

create table if not exists public.gl_journal_entries (
  id uuid primary key default gen_random_uuid(),
  source_prefix text,
  source_id uuid,
  source_key text not null,
  periodo_contable text,
  descripcion text not null,
  estado text not null default 'draft'
    check (estado in ('draft','posted','reversed')),
  posted_at timestamptz,
  reversed_by_id uuid references public.gl_journal_entries(id) on delete set null,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);

alter table public.gl_journal_entries
  alter column source_key set not null;

create unique index if not exists idx_gl_journal_entries_source_key
  on public.gl_journal_entries (source_key);

create index if not exists idx_gl_journal_entries_periodo
  on public.gl_journal_entries (periodo_contable, estado);

create table if not exists public.gl_journal_lines (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid not null references public.gl_journal_entries(id) on delete cascade,
  account_id uuid not null references public.cuentas_contables(id),
  debit numeric(14,2) not null default 0 check (debit >= 0),
  credit numeric(14,2) not null default 0 check (credit >= 0),
  memo text,
  line_source_key text,
  check (not (debit > 0 and credit > 0))
);

create index if not exists idx_gl_journal_lines_entry
  on public.gl_journal_lines (entry_id);

create index if not exists idx_gl_journal_lines_account
  on public.gl_journal_lines (account_id);

create unique index if not exists idx_gl_journal_lines_source_key
  on public.gl_journal_lines (entry_id, line_source_key)
  where line_source_key is not null;

alter table public.movimientos_financieros
  add column if not exists gl_entry_id uuid
    references public.gl_journal_entries(id) on delete set null;

-------------------------------------------------
-- 2. Integridad de posted y cierres de periodo
-------------------------------------------------

create or replace function public.fn_gl_entries_set_posted_at()
returns trigger
language plpgsql
as $$
declare
  v_period text;
  v_cerrado boolean;
  v_line_count integer;
  v_debit numeric(14,2);
  v_credit numeric(14,2);
  v_create_period boolean := false;
begin
  if new.estado = 'posted' then
    if new.posted_at is null then
      new.posted_at := now();
    end if;

    v_period := public.fn_contabilidad_periodo_key(new.posted_at);
    new.periodo_contable := v_period;

    select cerrado
      into v_cerrado
    from public.contabilidad_periodos
    where periodo_contable = v_period;

    if not found then
      if v_create_period then
        insert into public.contabilidad_periodos (periodo_contable, cerrado, observacion)
        values (v_period, false, 'Auto creado por GL')
        on conflict (periodo_contable) do nothing;
      else
        raise exception 'Periodo contable % no existe; cree el periodo antes de postear.', v_period;
      end if;
    elsif v_cerrado then
      raise exception 'Periodo contable % cerrado; no se puede postear asientos.', v_period;
    end if;

    select count(*),
           coalesce(sum(debit), 0),
           coalesce(sum(credit), 0)
      into v_line_count, v_debit, v_credit
    from public.gl_journal_lines
    where entry_id = new.id;

    if v_line_count < 2 then
      raise exception 'Asiento % requiere al menos 2 lineas para postear.', new.id;
    end if;

    if v_debit <> v_credit then
      raise exception 'Asiento % descuadrado: debitos %, creditos %.', new.id, v_debit, v_credit;
    end if;
  end if;

  return new;
end;
$$;

create trigger trg_gl_entries_set_posted_at
before insert or update on public.gl_journal_entries
for each row
execute function public.fn_gl_entries_set_posted_at();

create or replace function public.fn_gl_entries_protect_posted()
returns trigger
language plpgsql
as $$
begin
  if old.estado in ('posted','reversed') then
    if tg_op = 'DELETE' then
      raise exception 'No se puede eliminar asientos posteados.';
    end if;

    if old.estado = 'posted'
        and new.estado = 'reversed'
        and old.reversed_by_id is null
        and new.reversed_by_id is not null
        and old.source_prefix is not distinct from new.source_prefix
        and old.source_id is not distinct from new.source_id
        and old.source_key is not distinct from new.source_key
        and old.periodo_contable is not distinct from new.periodo_contable
        and old.descripcion is not distinct from new.descripcion
        and old.posted_at is not distinct from new.posted_at
        and old.created_at is not distinct from new.created_at
        and old.created_by is not distinct from new.created_by then
      return new;
    end if;

    raise exception 'No se puede editar asientos posteados.';
  end if;

  return new;
end;
$$;

create trigger trg_gl_entries_protect_posted
before update or delete on public.gl_journal_entries
for each row
execute function public.fn_gl_entries_protect_posted();

create or replace function public.fn_gl_lines_protect_posted()
returns trigger
language plpgsql
as $$
declare
  v_estado text;
begin
  if tg_op = 'INSERT' then
    select estado
      into v_estado
    from public.gl_journal_entries
    where id = new.entry_id;
  elsif tg_op = 'UPDATE' then
    select estado
      into v_estado
    from public.gl_journal_entries
    where id = new.entry_id;
  else
    select estado
      into v_estado
    from public.gl_journal_entries
    where id = old.entry_id;
  end if;

  if not found then
    raise exception 'Asiento no existe para lineas.';
  end if;

  if v_estado in ('posted','reversed') then
    raise exception 'No se puede modificar lineas de un asiento posteado.';
  end if;

  if tg_op = 'UPDATE' and new.entry_id is distinct from old.entry_id then
    select estado
      into v_estado
    from public.gl_journal_entries
    where id = old.entry_id;

    if found and v_estado in ('posted','reversed') then
      raise exception 'No se puede mover lineas desde un asiento posteado.';
    end if;
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger trg_gl_lines_protect_posted
before insert or update or delete on public.gl_journal_lines
for each row
execute function public.fn_gl_lines_protect_posted();

-------------------------------------------------
-- 3. Funciones de posteo y reversa
-------------------------------------------------

create or replace function public.fn_gl_post_entry(p_entry_id uuid)
returns uuid
language plpgsql
as $$
declare
  v_entry public.gl_journal_entries%rowtype;
begin
  if p_entry_id is null then
    return null;
  end if;

  select *
    into v_entry
  from public.gl_journal_entries
  where id = p_entry_id
  for update;

  if not found then
    return null;
  end if;

  if v_entry.estado = 'posted' then
    return v_entry.id;
  end if;

  if v_entry.estado = 'reversed' then
    raise exception 'No se puede postear un asiento revertido.';
  end if;

  update public.gl_journal_entries
    set estado = 'posted',
        posted_at = coalesce(v_entry.posted_at, now())
  where id = v_entry.id;

  return v_entry.id;
end;
$$;

create or replace function public.fn_gl_reverse_entry(
  p_entry_id uuid,
  p_reason text default null,
  p_period_policy text default 'current_period'
)
returns uuid
language plpgsql
as $$
declare
  v_entry public.gl_journal_entries%rowtype;
  v_new_id uuid;
  v_desc text;
  v_policy text := lower(coalesce(p_period_policy, 'current_period'));
  v_posted_at timestamptz;
  v_period text;
  v_cerrado boolean;
begin
  if p_entry_id is null then
    return null;
  end if;

  select *
    into v_entry
  from public.gl_journal_entries
  where id = p_entry_id
  for update;

  if not found then
    return null;
  end if;

  if v_entry.estado = 'reversed' then
    return v_entry.reversed_by_id;
  end if;

  if v_entry.estado <> 'posted' then
    raise exception 'Solo se pueden revertir asientos posteados.';
  end if;

  if v_policy not in ('same_period','current_period','auto') then
    raise exception 'Politica de reversa invalida: %.', v_policy;
  end if;

  if v_policy = 'current_period' then
    v_posted_at := now();
  elsif v_policy = 'same_period' then
    v_posted_at := coalesce(v_entry.posted_at, now());
    v_period := public.fn_contabilidad_periodo_key(v_posted_at);

    select cerrado
      into v_cerrado
    from public.contabilidad_periodos
    where periodo_contable = v_period;

    if not found then
      raise exception 'Periodo contable % no existe; no se puede revertir en el mismo periodo.', v_period;
    elsif v_cerrado then
      raise exception 'Periodo contable % cerrado; no se puede revertir en el mismo periodo.', v_period;
    end if;
  else
    v_posted_at := coalesce(v_entry.posted_at, now());
    v_period := public.fn_contabilidad_periodo_key(v_posted_at);

    select cerrado
      into v_cerrado
    from public.contabilidad_periodos
    where periodo_contable = v_period;

    if not found or v_cerrado then
      v_posted_at := now();
    end if;
  end if;

  v_desc := concat('Reversa: ', v_entry.descripcion);
  if p_reason is not null and btrim(p_reason) <> '' then
    v_desc := concat(v_desc, ' | Motivo: ', p_reason);
  end if;

  insert into public.gl_journal_entries (
    source_prefix,
    source_id,
    source_key,
    descripcion,
    estado,
    posted_at,
    created_by
  )
  values (
    'reversal',
    v_entry.id,
    concat('reversal:', v_entry.id::text),
    v_desc,
    'draft',
    v_posted_at,
    coalesce(auth.uid(), v_entry.created_by)
  )
  returning id into v_new_id;

  insert into public.gl_journal_lines (
    entry_id,
    account_id,
    debit,
    credit,
    memo,
    line_source_key
  )
  select
    v_new_id,
    account_id,
    credit,
    debit,
    case
      when memo is null or btrim(memo) = '' then 'Reversa'
      else concat(memo, ' | Reversa')
    end,
    case
      when line_source_key is null then null
      else concat('reversal:', line_source_key)
    end
  from public.gl_journal_lines
  where entry_id = v_entry.id;

  perform public.fn_gl_post_entry(v_new_id);

  update public.gl_journal_entries
    set estado = 'reversed',
        reversed_by_id = v_new_id
  where id = v_entry.id;

  return v_new_id;
end;
$$;

-------------------------------------------------
-- 4. Helper para tesoreria (crear asiento desde una fuente)
-------------------------------------------------

create or replace function public.fn_gl_create_entry(
  p_source_prefix text,
  p_source_id uuid,
  p_source_key text,
  p_descripcion text,
  p_lines jsonb,
  p_created_by uuid default auth.uid(),
  p_post boolean default true
)
returns uuid
language plpgsql
as $$
declare
  v_entry_id uuid;
  v_source_key text;
  v_inserted boolean := false;
begin
  if p_descripcion is null or btrim(p_descripcion) = '' then
    raise exception 'Descripcion requerida.';
  end if;

  v_source_key := p_source_key;
  if v_source_key is null and p_source_prefix is not null and p_source_id is not null then
    v_source_key := concat(p_source_prefix, ':', p_source_id::text);
  end if;

  if v_source_key is null or btrim(v_source_key) = '' then
    raise exception 'source_key requerido; use p_source_key o p_source_prefix + p_source_id.';
  end if;

  insert into public.gl_journal_entries (
    source_prefix,
    source_id,
    source_key,
    descripcion,
    estado,
    created_by
  )
  values (
    p_source_prefix,
    p_source_id,
    v_source_key,
    p_descripcion,
    'draft',
    p_created_by
  )
  on conflict (source_key) do nothing
  returning id into v_entry_id;

  if v_entry_id is null and v_source_key is not null then
    select id
      into v_entry_id
    from public.gl_journal_entries
    where source_key = v_source_key;
  else
    v_inserted := true;
  end if;

  if v_entry_id is null then
    raise exception 'No se pudo crear asiento.';
  end if;

  if v_inserted then
    insert into public.gl_journal_lines (
      entry_id,
      account_id,
      debit,
      credit,
      memo,
      line_source_key
    )
    select
      v_entry_id,
      account_id,
      round(coalesce(debit, 0), 2),
      round(coalesce(credit, 0), 2),
      memo,
      line_source_key
    from jsonb_to_recordset(p_lines) as x(
      account_id uuid,
      debit numeric,
      credit numeric,
      memo text,
      line_source_key text
    );
  end if;

  if p_post then
    perform public.fn_gl_post_entry(v_entry_id);
  end if;

  return v_entry_id;
end;
$$;

-------------------------------------------------
-- 5. Vistas contables (ledger, balance, P&L)
-------------------------------------------------

create or replace view public.vw_gl_trial_balance as
select
  e.periodo_contable,
  max(e.posted_at) as ultimo_posted_at,
  l.account_id,
  cc.codigo as cuenta_codigo,
  cc.nombre as cuenta_nombre,
  cc.tipo as cuenta_tipo,
  sum(l.debit) as debit,
  sum(l.credit) as credit,
  sum(l.debit - l.credit) as saldo
from public.gl_journal_entries e
join public.gl_journal_lines l on l.entry_id = e.id
join public.cuentas_contables cc on cc.id = l.account_id
where e.estado in ('posted','reversed')
group by e.periodo_contable, l.account_id, cc.codigo, cc.nombre, cc.tipo;

create or replace view public.vw_gl_ledger as
select
  e.id as entry_id,
  l.id as line_id,
  e.posted_at,
  e.periodo_contable,
  l.account_id,
  cc.codigo as cuenta_codigo,
  cc.nombre as cuenta_nombre,
  cc.tipo as cuenta_tipo,
  e.descripcion,
  l.memo,
  l.debit,
  l.credit,
  sum(l.debit - l.credit) over (
    partition by l.account_id
    order by e.posted_at, e.id, l.id
    rows between unbounded preceding and current row
  ) as saldo_acumulado
from public.gl_journal_entries e
join public.gl_journal_lines l on l.entry_id = e.id
join public.cuentas_contables cc on cc.id = l.account_id
where e.estado in ('posted','reversed');

create or replace view public.vw_gl_profit_loss as
select
  e.periodo_contable,
  l.account_id,
  cc.codigo as cuenta_codigo,
  cc.nombre as cuenta_nombre,
  cc.tipo as cuenta_tipo,
  sum(l.debit) as debit,
  sum(l.credit) as credit,
  case
    when cc.tipo = 'ingreso' then sum(l.credit - l.debit)
    else sum(l.debit - l.credit)
  end as monto
from public.gl_journal_entries e
join public.gl_journal_lines l on l.entry_id = e.id
join public.cuentas_contables cc on cc.id = l.account_id
where e.estado in ('posted','reversed')
  and cc.tipo in ('ingreso','gasto')
group by e.periodo_contable, l.account_id, cc.codigo, cc.nombre, cc.tipo;

create or replace view public.vw_gl_balance_sheet as
select
  e.periodo_contable,
  l.account_id,
  cc.codigo as cuenta_codigo,
  cc.nombre as cuenta_nombre,
  cc.tipo as cuenta_tipo,
  sum(l.debit) as debit,
  sum(l.credit) as credit,
  case
    when cc.tipo = 'activo' then sum(l.debit - l.credit)
    else sum(l.credit - l.debit)
  end as monto
from public.gl_journal_entries e
join public.gl_journal_lines l on l.entry_id = e.id
join public.cuentas_contables cc on cc.id = l.account_id
where e.estado in ('posted','reversed')
  and cc.tipo in ('activo','pasivo','patrimonio')
group by e.periodo_contable, l.account_id, cc.codigo, cc.nombre, cc.tipo;

create or replace view public.v_contabilidad_balance_comprobacion as
select
  periodo_contable as periodo,
  to_char(
    timezone('America/Lima', ultimo_posted_at),
    'YYYY-MM-DD HH24:MI:SS'
  ) as fecha,
  account_id as idcuenta_contable,
  cuenta_codigo as cuenta_contable_codigo,
  cuenta_nombre as cuenta_contable_nombre,
  cuenta_tipo as tipo,
  debit as debe,
  credit as haber,
  saldo
from public.vw_gl_trial_balance;

create or replace view public.v_contabilidad_estado_resultados as
select
  periodo_contable as periodo,
  account_id as idcuenta_contable,
  cuenta_codigo as cuenta_contable_codigo,
  cuenta_nombre as cuenta_contable_nombre,
  cuenta_tipo as tipo,
  monto
from public.vw_gl_profit_loss;

create or replace view public.v_contabilidad_balance_general as
select
  periodo_contable as periodo,
  account_id as idcuenta_contable,
  cuenta_codigo as cuenta_contable_codigo,
  cuenta_nombre as cuenta_contable_nombre,
  cuenta_tipo as tipo,
  monto as saldo
from public.vw_gl_balance_sheet;

-------------------------------------------------
-- 6. Permisos por modulo (contabilidad)
-------------------------------------------------

insert into public.security_resource_modules (relation_name, modulo) values
  ('gl_journal_entries', 'contabilidad'),
  ('gl_journal_lines', 'contabilidad'),
  ('vw_gl_trial_balance', 'contabilidad'),
  ('vw_gl_ledger', 'contabilidad'),
  ('vw_gl_profit_loss', 'contabilidad'),
  ('vw_gl_balance_sheet', 'contabilidad'),
  ('v_contabilidad_balance_comprobacion', 'contabilidad'),
  ('v_contabilidad_estado_resultados', 'contabilidad'),
  ('v_contabilidad_balance_general', 'contabilidad'),
  ('v_contabilidad_historial', 'contabilidad')
on conflict (schema_name, relation_name, modulo) do nothing;

insert into public.security_resource_modules (relation_name, modulo) values
  ('v_compras_historial_contable', 'operaciones')
on conflict (schema_name, relation_name, modulo) do nothing;

create table if not exists movimientos_financieros_historial (
  historial_id uuid primary key default gen_random_uuid(),
  movimiento_id uuid not null references movimientos_financieros(id) on delete cascade,
  version integer not null,
  operacion text not null check (operacion in ('insert','update','delete')),
  tipo text not null,
  descripcion text not null,
  monto numeric(14,2) not null,
  idpedido uuid references pedidos(id),
  idcuenta_origen uuid references cuentas_bancarias(id),
  idcuenta_destino uuid references cuentas_bancarias(id),
  idcuenta_contable uuid references cuentas_contables(id),
  gl_entry_id uuid references gl_journal_entries(id) on delete set null,
  observacion text,
  registrado_at timestamptz,
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  logged_at timestamptz not null default now(),
  unique (movimiento_id, version)
);

alter table public.movimientos_financieros_historial
  add column if not exists gl_entry_id uuid
    references public.gl_journal_entries(id) on delete set null;

create index if not exists idx_movimientos_financieros_historial_movimiento
  on movimientos_financieros_historial (movimiento_id);

create or replace function public.fn_movimientos_financieros_log()
returns trigger
language plpgsql
as $$
declare
  snapshot movimientos_financieros%rowtype;
  v_version integer;
begin
  if tg_op = 'DELETE' then
    snapshot := old;
  else
    snapshot := new;
  end if;

  select coalesce(max(version), 0) + 1
    into v_version
  from public.movimientos_financieros_historial
  where movimiento_id = snapshot.id;

  insert into public.movimientos_financieros_historial (
    movimiento_id,
    version,
    operacion,
    tipo,
    descripcion,
    monto,
    idpedido,
    idcuenta_origen,
    idcuenta_destino,
    idcuenta_contable,
    gl_entry_id,
    observacion,
    registrado_at,
    editado_at,
    registrado_por,
    editado_por,
    logged_at
  )
  values (
    snapshot.id,
    v_version,
    lower(tg_op),
    snapshot.tipo,
    snapshot.descripcion,
    snapshot.monto,
    snapshot.idpedido,
    snapshot.idcuenta_origen,
    snapshot.idcuenta_destino,
    snapshot.idcuenta_contable,
    snapshot.gl_entry_id,
    snapshot.observacion,
    snapshot.registrado_at,
    snapshot.editado_at,
    snapshot.registrado_por,
    snapshot.editado_por,
    now()
  );

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger trg_movimientos_financieros_log
after insert or update on public.movimientos_financieros
for each row
execute function public.fn_movimientos_financieros_log();

create trigger trg_movimientos_financieros_log_delete
before delete on public.movimientos_financieros
for each row
execute function public.fn_movimientos_financieros_log();

create or replace function public.fn_movimientos_financieros_set_posted_at()
returns trigger
language plpgsql
as $$
declare
  v_period text;
  v_cerrado boolean;
begin
  if new.estado = 'posted' then
    if new.posted_at is null then
      new.posted_at := coalesce(new.registrado_at, now());
    end if;

    v_period := public.fn_contabilidad_periodo_key(new.posted_at);
    new.periodo_contable := v_period;

    select cerrado
      into v_cerrado
    from public.contabilidad_periodos
    where periodo_contable = v_period;

    if found and v_cerrado then
      raise exception 'Periodo contable % cerrado; no se puede postear movimientos.', v_period;
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_movimientos_financieros_set_posted_at
before insert or update on public.movimientos_financieros
for each row
execute function public.fn_movimientos_financieros_set_posted_at();

create or replace function public.fn_movimientos_financieros_protect_posted()
returns trigger
language plpgsql
as $$
begin
  if old.estado in ('posted','reversed') then
    if tg_op = 'DELETE' then
      raise exception 'No se puede eliminar movimientos posteados.';
    end if;

    if old.estado = 'posted'
        and new.estado = 'reversed'
        and old.reversed_by_id is null
        and new.reversed_by_id is not null
        and old.tipo is not distinct from new.tipo
        and old.origen is not distinct from new.origen
        and old.source_key is not distinct from new.source_key
        and old.descripcion is not distinct from new.descripcion
        and old.monto is not distinct from new.monto
        and old.idpedido is not distinct from new.idpedido
        and old.idcuenta_origen is not distinct from new.idcuenta_origen
        and old.idcuenta_destino is not distinct from new.idcuenta_destino
        and old.idcuenta_contable is not distinct from new.idcuenta_contable
        and old.observacion is not distinct from new.observacion
        and old.registrado_at is not distinct from new.registrado_at
        and old.registrado_por is not distinct from new.registrado_por
        and old.posted_at is not distinct from new.posted_at
        and old.periodo_contable is not distinct from new.periodo_contable then
      return new;
    end if;

    raise exception 'No se puede editar movimientos posteados; usa reversas.';
  end if;

  return new;
end;
$$;

create trigger trg_movimientos_financieros_protect_posted
before update or delete on public.movimientos_financieros
for each row
execute function public.fn_movimientos_financieros_protect_posted();

create or replace function public.fn_movimientos_financieros_prevent_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar movimientos financieros; usa reversas.';
end;
$$;

create trigger trg_movimientos_financieros_prevent_delete
before delete on public.movimientos_financieros
for each row
execute function public.fn_movimientos_financieros_prevent_delete();

create or replace function public.fn_movimientos_financieros_reversar(
  p_movimiento_id uuid,
  p_motivo text default null,
  p_registrado_at timestamptz default null,
  p_registrado_por uuid default null
)
returns uuid
language plpgsql
as $$
declare
  v_orig public.movimientos_financieros%rowtype;
  v_new_id uuid;
  v_tipo text;
  v_reg_at timestamptz := coalesce(p_registrado_at, now());
  v_reg_por uuid := coalesce(p_registrado_por, auth.uid());
  v_desc text;
  v_obs text;
  v_origen text;
begin
  if p_movimiento_id is null then
    return null;
  end if;

  select *
    into v_orig
  from public.movimientos_financieros
  where id = p_movimiento_id
  for update;

  if not found then
    return null;
  end if;

  if v_orig.estado = 'reversed' then
    return v_orig.reversed_by_id;
  end if;

  if v_orig.reversed_by_id is not null then
    return v_orig.reversed_by_id;
  end if;

  if v_orig.tipo = 'ingreso' then
    v_tipo := 'gasto';
  elsif v_orig.tipo = 'gasto' then
    v_tipo := 'ingreso';
  elsif v_orig.tipo = 'ajuste' then
    v_tipo := 'ingreso';
  else
    v_tipo := 'transferencia';
  end if;

  v_desc := concat('Reversa: ', v_orig.descripcion);

  if p_motivo is not null and btrim(p_motivo) <> '' then
    if v_orig.observacion is null or btrim(v_orig.observacion) = '' then
      v_obs := concat('Reversa: ', p_motivo);
    else
      v_obs := concat(v_orig.observacion, ' | Reversa: ', p_motivo);
    end if;
  else
    v_obs := v_orig.observacion;
  end if;

  if v_orig.origen is null or btrim(v_orig.origen) = '' then
    v_origen := 'reversa';
  else
    v_origen := concat('reversa:', v_orig.origen);
  end if;

  insert into public.movimientos_financieros (
    tipo,
    origen,
    source_key,
    descripcion,
    monto,
    idpedido,
    idcuenta_origen,
    idcuenta_destino,
    idcuenta_contable,
    observacion,
    registrado_at,
    registrado_por,
    estado,
    posted_at
  )
  values (
    v_tipo,
    v_origen,
    concat('reversa:', v_orig.id::text),
    v_desc,
    v_orig.monto,
    v_orig.idpedido,
    case when v_orig.tipo = 'transferencia' then v_orig.idcuenta_destino else v_orig.idcuenta_origen end,
    case when v_orig.tipo = 'transferencia' then v_orig.idcuenta_origen else v_orig.idcuenta_destino end,
    v_orig.idcuenta_contable,
    v_obs,
    v_reg_at,
    v_reg_por,
    'posted',
    v_reg_at
  )
  returning id into v_new_id;

  update public.movimientos_financieros
    set estado = 'reversed',
        reversed_by_id = v_new_id,
        editado_at = v_reg_at,
        editado_por = v_reg_por
  where id = v_orig.id;

  return v_new_id;
end;
$$;

create or replace function public.fn_reversar_por_source_prefix(
  p_source_prefix text,
  p_motivo text default null,
  p_registrado_at timestamptz default null,
  p_registrado_por uuid default null
)
returns integer
language plpgsql
as $$
declare
  v_row record;
  v_total integer := 0;
begin
  if p_source_prefix is null or btrim(p_source_prefix) = '' then
    return 0;
  end if;

  for v_row in
    select id
    from public.movimientos_financieros
    where origen is not null
      and origen like (p_source_prefix || '%')
      and estado <> 'reversed'
      and reversed_by_id is null
      and origen not like 'reversa:%'
  loop
    perform public.fn_movimientos_financieros_reversar(
      v_row.id,
      p_motivo,
      p_registrado_at,
      p_registrado_por
    );
    v_total := v_total + 1;
  end loop;

  return v_total;
end;
$$;

insert into public.movimientos_financieros_historial (
  movimiento_id,
  version,
  operacion,
  tipo,
  descripcion,
  monto,
  idpedido,
  idcuenta_origen,
  idcuenta_destino,
  idcuenta_contable,
  gl_entry_id,
  observacion,
  registrado_at,
  editado_at,
  registrado_por,
  editado_por,
  logged_at
)
select
  mf.id,
  1 as version,
  'insert' as operacion,
  mf.tipo,
  mf.descripcion,
  mf.monto,
  mf.idpedido,
  mf.idcuenta_origen,
  mf.idcuenta_destino,
  mf.idcuenta_contable,
  mf.gl_entry_id,
  mf.observacion,
  mf.registrado_at,
  mf.editado_at,
  mf.registrado_por,
  mf.editado_por,
  coalesce(mf.registrado_at, now())
from public.movimientos_financieros mf
on conflict (movimiento_id, version) do nothing;

create table if not exists viajes_incidentes (
  id uuid primary key default gen_random_uuid(),
  idviaje_detalle uuid not null references viajesdetalles(id) on delete cascade,
  tipo text not null check (tipo in ('robado','danado')),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  unique (idviaje_detalle)
);

create table if not exists viajes_incidentes_detalle (
  id uuid primary key default gen_random_uuid(),
  idincidente uuid not null references viajes_incidentes(id) on delete cascade,
  iddetalle_movimiento uuid not null references detallemovimientopedidos(id) on delete cascade,
  idmovimiento uuid not null references movimientopedidos(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(10,2) not null check (cantidad > 0),
  idasiento_inventario uuid references gl_journal_entries(id) on delete set null,
  idasiento_gasto uuid references gl_journal_entries(id) on delete set null,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  unique (idincidente, iddetalle_movimiento)
);

alter table if exists public.viajes_incidentes_detalle
  add column if not exists contable_version integer not null default 1;

create or replace function public.fn_viajes_incidentes_detalle_block_entrega()
returns trigger
language plpgsql
as $$
declare
  v_movimiento uuid;
begin
  v_movimiento := coalesce(new.idmovimiento, old.idmovimiento);

  if v_movimiento is null then
    select idmovimiento
      into v_movimiento
    from public.detallemovimientopedidos
    where id = coalesce(new.iddetalle_movimiento, old.iddetalle_movimiento);
  end if;

  if v_movimiento is null then
    return case when tg_op = 'DELETE' then old else new end;
  end if;

  if exists (
    select 1
    from public.viajesdetalles vd
    where vd.idmovimiento = v_movimiento
      and vd.llegada_at is not null
    limit 1
  ) then
    raise exception
      'No puedes modificar incidente del movimiento % porque ya tiene llegada registrada.',
      v_movimiento;
  end if;

  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger trg_viajes_incidentes_detalle_block_entrega
before insert or update or delete on public.viajes_incidentes_detalle
for each row
execute function public.fn_viajes_incidentes_detalle_block_entrega();

create or replace function public.fn_viajes_incidentes_detalle_validate()
returns trigger
language plpgsql
as $$
declare
  v_detalle detallemovimientopedidos%rowtype;
  v_movimiento_incidente uuid;
begin
  if tg_op = 'UPDATE'
      and new.iddetalle_movimiento is distinct from old.iddetalle_movimiento then
    raise exception 'No puedes cambiar el detalle asociado al incidente.';
  end if;

  select *
    into v_detalle
  from public.detallemovimientopedidos
  where id = new.iddetalle_movimiento;

  if not found then
    raise exception
      'No se encontró el detalle de movimiento %.',
      new.iddetalle_movimiento;
  end if;

  select vd.idmovimiento
    into v_movimiento_incidente
  from public.viajes_incidentes inc
  join public.viajesdetalles vd on vd.id = inc.idviaje_detalle
  where inc.id = new.idincidente;

  if not found then
    raise exception 'No se encontró el incidente %.', new.idincidente;
  end if;

  if v_detalle.idmovimiento <> v_movimiento_incidente then
    raise exception
      'El detalle seleccionado no pertenece al movimiento del incidente.';
  end if;

  if new.cantidad > v_detalle.cantidad then
    raise exception
      'La cantidad del incidente (%.2f) no puede exceder la cantidad enviada (%.2f).',
      new.cantidad,
      v_detalle.cantidad;
  end if;

  new.idmovimiento := v_detalle.idmovimiento;
  new.idproducto := v_detalle.idproducto;
  return new;
end;
$$;

create trigger trg_viajes_incidentes_detalle_validate
before insert or update on public.viajes_incidentes_detalle
for each row
execute function public.fn_viajes_incidentes_detalle_validate();

create or replace function public.fn_viajes_incidentes_detalle_sync_asientos()
returns trigger
language plpgsql
as $$
declare
  v_row public.viajes_incidentes_detalle%rowtype;
  v_monto numeric(18,4);
  v_abs numeric(18,4);
  v_cuenta_inventario uuid;
  v_cuenta_gasto uuid;
  v_desc text;
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_idpedido uuid;
  v_tipo text;
  v_motivo text;
  v_version integer;
  v_max_version integer;
  v_source_prefix text;
  v_base_key text;
  v_source_key text;
  v_entry_id uuid;
  v_old record;
begin
  if tg_op = 'DELETE' then
    v_row := old;
  else
    v_row := new;
  end if;

  select id into v_cuenta_inventario
  from public.cuentas_contables
  where codigo = '20.01'
  limit 1;

  select id into v_cuenta_gasto
  from public.cuentas_contables
  where codigo = '80.01'
  limit 1;

  if v_cuenta_inventario is null or v_cuenta_gasto is null then
    if tg_op = 'DELETE' then
      return old;
    end if;
    return new;
  end if;

  select mp.idpedido
    into v_idpedido
  from public.movimientopedidos mp
  where mp.id = v_row.idmovimiento
  limit 1;

  select tipo
    into v_tipo
  from public.viajes_incidentes
  where id = v_row.idincidente;

  v_monto := coalesce(v_row.cantidad, 0)
           * coalesce(public.fn_producto_costo_promedio(v_row.idproducto), 0);
  v_abs := abs(v_monto);

  if tg_op = 'DELETE' then
    v_reg_at := coalesce(old.editado_at, old.registrado_at, now());
    v_reg_por := coalesce(old.editado_por, old.registrado_por, auth.uid());
    v_motivo := 'Incidente eliminado';
  else
    v_reg_at := coalesce(new.editado_at, new.registrado_at, now());
    v_reg_por := coalesce(new.editado_por, new.registrado_por, auth.uid());
    v_motivo := 'Incidente actualizado';
  end if;

  v_source_prefix := 'incidente_detalle';
  v_base_key := concat(v_source_prefix, ':', v_row.id::text);

  if tg_op in ('UPDATE','DELETE') then
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = v_row.id
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;
  end if;

  if tg_op = 'DELETE' or v_abs < 0.01 then
    if tg_op = 'DELETE' then
      return old;
    else
      new.idasiento_inventario := null;
      new.idasiento_gasto := null;
      return new;
    end if;
  end if;

  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = v_row.id
    and source_prefix = v_source_prefix;

  v_version := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;
  v_source_key := case
    when v_version = 1 then v_base_key
    else concat(v_base_key, ':v', v_version::text)
  end;
  if tg_op <> 'DELETE' then
    new.contable_version := v_version;
  end if;

  v_desc := concat(
    'Incidente ',
    coalesce(v_tipo, 'robado'),
    ' movimiento ',
    v_row.idmovimiento::text
  );

  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := v_row.id,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_cuenta_gasto,
        'debit', round(v_abs::numeric, 2),
        'credit', 0,
        'memo', 'Robo o daño en viaje',
        'line_source_key', 'gasto'
      ),
      jsonb_build_object(
        'account_id', v_cuenta_inventario,
        'debit', 0,
        'credit', round(v_abs::numeric, 2),
        'memo', 'Robo o daño en viaje',
        'line_source_key', 'inventario'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  new.idasiento_inventario := v_entry_id;
  new.idasiento_gasto := v_entry_id;

  return new;
end;
$$;

create trigger trg_viajes_incidentes_detalle_sync
before insert or update or delete on public.viajes_incidentes_detalle
for each row
execute function public.fn_viajes_incidentes_detalle_sync_asientos();

create table if not exists gastos_operativos (
  id uuid primary key default gen_random_uuid(),
  idpedido uuid not null references pedidos(id) on delete cascade,
  idcuenta uuid references cuentas_bancarias(id),
  idcuenta_contable_tipo uuid not null references cuentas_contables(id),
  idcuenta_contable uuid references cuentas_contables(id),
  descripcion text,
  monto numeric(10,2) not null check (monto >= 0),
  idmovimiento_financiero uuid unique references movimientos_financieros(id) on delete set null,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'gastos_operativos'
      and column_name = 'idcuenta_contable_tipo'
  ) then
    alter table public.gastos_operativos
      add column idcuenta_contable_tipo uuid references public.cuentas_contables(id);
  end if;

  update public.gastos_operativos go
  set idcuenta_contable_tipo = cc.parent_id
  from public.cuentas_contables cc
  where go.idcuenta_contable_tipo is null
    and go.idcuenta_contable = cc.id
    and cc.parent_id is not null;

  update public.gastos_operativos go
  set idcuenta_contable_tipo = cc.id
  from public.cuentas_contables cc
  where go.idcuenta_contable_tipo is null
    and cc.codigo = '60.06';

  update public.gastos_operativos go
  set idcuenta_contable_tipo = cc.id
  from public.cuentas_contables cc
  where go.idcuenta_contable_tipo is null
    and cc.codigo = '60';

end $$;

alter table public.gastos_operativos
  alter column idcuenta_contable_tipo set not null;

create or replace function public.fn_gastos_operativos_resolve_tipo()
returns trigger
language plpgsql
as $$
begin
  if new.idcuenta_contable is null then
    return new;
  end if;
  select parent_id
  into new.idcuenta_contable_tipo
  from public.cuentas_contables
  where id = new.idcuenta_contable;
  if new.idcuenta_contable_tipo is null then
    raise exception 'La cuenta contable seleccionada no tiene cuenta padre configurada.';
  end if;
  return new;
end;
$$;

create trigger trg_gastos_operativos_resolve_tipo
before insert or update on public.gastos_operativos
for each row
execute function public.fn_gastos_operativos_resolve_tipo();

create or replace function public.fn_gastos_operativos_sync_movimiento()
returns trigger
language plpgsql
as $$
declare
  v_descripcion text;
  v_monto numeric(10,2);
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_tipo_nombre text;
  v_new_id uuid;
  v_motivo text;
begin
  if tg_op = 'DELETE' then
    if old.idmovimiento_financiero is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero,
        'Gasto operativo eliminado',
        coalesce(old.editado_at, old.registrado_at, now()),
        coalesce(old.editado_por, old.registrado_por, auth.uid())
      );
    end if;
    return old;
  end if;

  if new.idcuenta is null or new.idcuenta_contable is null then
    if new.idmovimiento_financiero is not null then
      perform public.fn_movimientos_financieros_reversar(
        new.idmovimiento_financiero,
        'Gasto operativo sin cuenta',
        coalesce(new.editado_at, new.registrado_at, now()),
        coalesce(new.editado_por, new.registrado_por, auth.uid())
      );
      new.idmovimiento_financiero := null;
    end if;
    return new;
  end if;

  select nombre
  into v_tipo_nombre
  from public.cuentas_contables
  where id = new.idcuenta_contable_tipo;

  v_descripcion := coalesce(new.descripcion, v_tipo_nombre, 'Gasto operativo');
  v_monto := new.monto;
  v_reg_at := coalesce(new.registrado_at, now());
  v_reg_por := coalesce(new.registrado_por, auth.uid());
  v_motivo := case when tg_op = 'INSERT' then 'Gasto operativo registrado' else 'Gasto operativo actualizado' end;

  if tg_op = 'INSERT' or new.idmovimiento_financiero is null then
    insert into public.movimientos_financieros (
      tipo,
      origen,
      source_key,
      descripcion,
      monto,
      idcuenta_origen,
      idcuenta_contable,
      observacion,
      registrado_at,
      registrado_por
    )
    values (
      'gasto',
      concat('gasto_operativo:', new.id::text),
      concat('gasto_operativo:', new.id::text),
      v_descripcion,
      v_monto,
      new.idcuenta,
      new.idcuenta_contable,
      null,
      v_reg_at,
      v_reg_por
    )
    on conflict (source_key) where source_key is not null and estado <> 'reversed'
    do update set
      tipo = excluded.tipo,
      origen = excluded.origen,
      descripcion = excluded.descripcion,
      monto = excluded.monto,
      idcuenta_origen = excluded.idcuenta_origen,
      idcuenta_contable = excluded.idcuenta_contable,
      observacion = excluded.observacion,
      registrado_at = excluded.registrado_at,
      registrado_por = excluded.registrado_por
    where movimientos_financieros.estado = 'draft'
    returning id into new.idmovimiento_financiero;
  else
    perform public.fn_movimientos_financieros_reversar(
      new.idmovimiento_financiero,
      v_motivo,
      coalesce(new.editado_at, now()),
      coalesce(new.editado_por, auth.uid())
    );
    insert into public.movimientos_financieros (
      tipo,
      origen,
      source_key,
      descripcion,
      monto,
      idcuenta_origen,
      idcuenta_contable,
      observacion,
      registrado_at,
      registrado_por
    )
    values (
      'gasto',
      concat('gasto_operativo:', new.id::text),
      concat('gasto_operativo:', new.id::text),
      v_descripcion,
      v_monto,
      new.idcuenta,
      new.idcuenta_contable,
      null,
      v_reg_at,
      v_reg_por
    )
    on conflict (source_key) where source_key is not null and estado <> 'reversed'
    do update set
      tipo = excluded.tipo,
      origen = excluded.origen,
      descripcion = excluded.descripcion,
      monto = excluded.monto,
      idcuenta_origen = excluded.idcuenta_origen,
      idcuenta_contable = excluded.idcuenta_contable,
      observacion = excluded.observacion,
      registrado_at = excluded.registrado_at,
      registrado_por = excluded.registrado_por
    where movimientos_financieros.estado = 'draft'
    returning id into v_new_id;
    new.idmovimiento_financiero := v_new_id;
  end if;

  return new;
end;
$$;

create trigger trg_gastos_operativos_sync_movimiento
before insert or update or delete on public.gastos_operativos
for each row
execute function public.fn_gastos_operativos_sync_movimiento();

create or replace function public.fn_gastos_operativos_prevent_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar gastos operativos.';
end;
$$;

create trigger trg_gastos_operativos_prevent_delete
before delete on public.gastos_operativos
for each row
execute function public.fn_gastos_operativos_prevent_delete();

create or replace function public.fn_pedidos_sync_asientos(p_idpedido uuid)
returns void
language plpgsql
as $$
declare
  v_pedido record;
  v_total_detalle numeric(14,2);
  v_total_devoluciones_cargos numeric(14,2);
  v_total_provincia numeric(14,2);
  v_total numeric(14,2);
  v_movs_prov integer;
  v_cxc_account uuid;
  v_deferred_account uuid;
  v_desc text;
  v_event_user uuid;
  v_old record;
  v_amount_total numeric(14,2);
  v_source_prefix text;
  v_source_key text;
  v_motivo text;
  v_version_cxc integer;
  v_max_version integer;
begin
  select
    p.id,
    p.estado_admin,
    p.estado,
    p.total_contable,
    p.total_ingreso_reconocido,
    p.total_costo_reconocido,
    p.contable_version,
    p.observacion,
    p.registrado_at,
    p.registrado_por,
    p.editado_por,
    cli.nombre as cliente_nombre
  into v_pedido
  from public.pedidos p
  left join public.clientes cli on cli.id = p.idcliente
  where p.id = p_idpedido;

  if not found then
    return;
  end if;

  select coalesce(sum(dp.precioventa), 0)::numeric(14,2)
    into v_total_detalle
  from public.v_detallepedidos_ajustado dp
  where dp.idpedido = p_idpedido;

  select coalesce(
      sum(
        coalesce(vd.penalidad, 0)
        + coalesce(vd.monto_ida, 0)
        + coalesce(vd.monto_vuelta, 0)
      ),
      0
    )::numeric(14,2)
    into v_total_devoluciones_cargos
  from public.viajes_devueltos vd
  where vd.idpedido = p_idpedido
    and vd.estado = 'devuelto_base';

  select coalesce(sum(case when m.es_provincia then 1 else 0 end), 0)::integer
    into v_movs_prov
  from public.movimientopedidos m
  where m.idpedido = p_idpedido
    and m.estado = 'activo';

  v_total_provincia := coalesce(v_movs_prov, 0) * 50.00;
  v_total := coalesce(v_total_detalle, 0)
           + coalesce(v_total_devoluciones_cargos, 0)
           + coalesce(v_total_provincia, 0);

  if v_pedido.estado_admin <> 'activo' or v_pedido.estado <> 'activo' then
    v_total := 0;
  end if;

  v_desc := concat('Pedido ', coalesce(v_pedido.cliente_nombre, ''));
  v_event_user := coalesce(auth.uid(), v_pedido.editado_por, v_pedido.registrado_por);
  v_motivo := 'Recalculo pedido';

  select id into v_cxc_account
  from public.cuentas_contables
  where codigo = '12.01'
  limit 1;

  select id into v_deferred_account
  from public.cuentas_contables
  where codigo = '48.01'
  limit 1;

  if v_cxc_account is null
      or v_deferred_account is null then
    raise exception
      'Configura las cuentas contables 12.01 y 48.01 antes de registrar pedidos.';
  end if;

  v_amount_total := round(v_total, 2);

  v_version_cxc := coalesce(v_pedido.contable_version, 1);
  if v_amount_total >= 0.01 then
    select coalesce(
        max(
          case
            when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
            else 1
          end
        ),
        0
      )
      into v_max_version
    from public.gl_journal_entries
    where source_id = p_idpedido
      and source_prefix = 'pedido_cxc';

    v_version_cxc := case
      when v_max_version >= 1 then v_max_version + 1
      else 1
    end;
    update public.pedidos
      set contable_version = v_version_cxc
    where id = p_idpedido;
  end if;

  v_source_prefix := 'pedido_cxc';
  v_source_key := case
    when v_version_cxc = 1 then concat(v_source_prefix, ':', p_idpedido::text)
    else concat(v_source_prefix, ':', p_idpedido::text, ':v', v_version_cxc::text)
  end;
  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = p_idpedido
      and source_prefix = v_source_prefix
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
  end loop;
  if v_amount_total >= 0.01 then
    perform public.fn_gl_create_entry(
      p_source_prefix := v_source_prefix,
      p_source_id := p_idpedido,
      p_source_key := v_source_key,
      p_descripcion := v_desc,
      p_lines := jsonb_build_array(
        jsonb_build_object(
          'account_id', v_cxc_account,
          'debit', v_amount_total,
          'credit', 0,
          'memo', v_pedido.observacion,
          'line_source_key', 'cxc'
        ),
        jsonb_build_object(
          'account_id', v_deferred_account,
          'debit', 0,
          'credit', v_amount_total,
          'memo', v_pedido.observacion,
          'line_source_key', 'diferido'
        )
      ),
      p_created_by := v_event_user,
      p_post := true
    );
  end if;

  update public.pedidos
    set total_contable = v_total,
        idasiento_por_cobrar = null,
        idasiento_ingreso = null
  where id = p_idpedido;
end;
$$;

create or replace function public.fn_pedidos_evento_entrega(
  p_movimiento_id uuid,
  p_event_user uuid default null
)
returns uuid
language plpgsql
as $$
declare
  v_mov record;
  v_total_ingreso numeric(14,2) := 0;
  v_total_costo numeric(14,2) := 0;
  v_deferred_account uuid;
  v_ingreso_account uuid;
  v_inventory_account uuid;
  v_costo_account uuid;
  v_desc text;
  v_source_key text;
  v_entry_id uuid;
  v_existing uuid;
  v_event_user uuid;
begin
  if p_movimiento_id is null then
    return null;
  end if;

  select
    mp.id,
    mp.idpedido,
    mp.codigo,
    mp.estado,
    p.estado_admin,
    p.observacion
  into v_mov
  from public.movimientopedidos mp
  join public.pedidos p on p.id = mp.idpedido
  where mp.id = p_movimiento_id;

  if not found then
    return null;
  end if;

  if v_mov.estado <> 'activo' or v_mov.estado_admin <> 'activo' then
    return null;
  end if;

  v_source_key := concat('pedido_entrega:', p_movimiento_id::text);
  select id
    into v_existing
  from public.gl_journal_entries
  where source_key = v_source_key
    and source_prefix = 'pedido_entrega'
  limit 1;

  if v_existing is not null then
    return v_existing;
  end if;

  select
    coalesce(sum(
      greatest(dmp.cantidad - coalesce(inc.cantidad_incidente, 0), 0)
      * coalesce(dp.precio_unitario, 0)
    ), 0)::numeric(14,2),
    coalesce(sum(
      greatest(dmp.cantidad - coalesce(inc.cantidad_incidente, 0), 0)
      * coalesce(public.fn_producto_costo_promedio(dmp.idproducto), 0)
    ), 0)::numeric(14,2)
    into v_total_ingreso, v_total_costo
  from public.detallemovimientopedidos dmp
  join public.movimientopedidos mp on mp.id = dmp.idmovimiento
  left join (
    select
      iddetalle_movimiento,
      coalesce(sum(cantidad), 0)::numeric(12,2) as cantidad_incidente
    from public.viajes_incidentes_detalle
    group by iddetalle_movimiento
  ) inc on inc.iddetalle_movimiento = dmp.id
  left join public.v_detallepedidos_ajustado dp
    on dp.idpedido = mp.idpedido
   and dp.idproducto = dmp.idproducto
  where dmp.idmovimiento = p_movimiento_id
    and dmp.estado = 'activo'
    and mp.estado = 'activo';

  if coalesce(v_total_ingreso, 0) < 0.01 and coalesce(v_total_costo, 0) < 0.01 then
    return null;
  end if;

  select id into v_deferred_account
  from public.cuentas_contables
  where codigo = '48.01'
  limit 1;

  select id into v_ingreso_account
  from public.cuentas_contables
  where codigo = '70.01'
  limit 1;

  select id into v_inventory_account
  from public.cuentas_contables
  where codigo = '20.01'
  limit 1;

  select id into v_costo_account
  from public.cuentas_contables
  where codigo = '69.01'
  limit 1;

  if v_deferred_account is null
      or v_ingreso_account is null
      or v_inventory_account is null
      or v_costo_account is null then
    raise exception
      'Configura las cuentas contables 48.01, 69.01, 70.01 y 20.01 antes de registrar entregas.';
  end if;

  v_desc := concat('Entrega movimiento ', coalesce(v_mov.codigo, p_movimiento_id::text));
  v_event_user := coalesce(p_event_user, auth.uid());

  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := 'pedido_entrega',
    p_source_id := p_movimiento_id,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_deferred_account,
        'debit', round(v_total_ingreso, 2),
        'credit', 0,
        'memo', v_mov.observacion,
        'line_source_key', 'diferido'
      ),
      jsonb_build_object(
        'account_id', v_ingreso_account,
        'debit', 0,
        'credit', round(v_total_ingreso, 2),
        'memo', v_mov.observacion,
        'line_source_key', 'ingreso'
      ),
      jsonb_build_object(
        'account_id', v_costo_account,
        'debit', round(v_total_costo, 2),
        'credit', 0,
        'memo', v_mov.observacion,
        'line_source_key', 'costo'
      ),
      jsonb_build_object(
        'account_id', v_inventory_account,
        'debit', 0,
        'credit', round(v_total_costo, 2),
        'memo', v_mov.observacion,
        'line_source_key', 'inventario'
      )
    ),
    p_created_by := v_event_user,
    p_post := true
  );

  update public.pedidos
    set total_ingreso_reconocido = coalesce(total_ingreso_reconocido, 0) + round(v_total_ingreso, 2),
        total_costo_reconocido = coalesce(total_costo_reconocido, 0) + round(v_total_costo, 2)
  where id = v_mov.idpedido;

  return v_entry_id;
end;
$$;

create or replace function public.fn_pedidos_evento_devolucion(
  p_devuelto_id uuid,
  p_event_user uuid default null
)
returns uuid
language plpgsql
as $$
declare
  v_dev record;
  v_total_ingreso numeric(14,2) := 0;
  v_total_costo numeric(14,2) := 0;
  v_deferred_account uuid;
  v_ingreso_account uuid;
  v_inventory_account uuid;
  v_costo_account uuid;
  v_desc text;
  v_source_key text;
  v_entry_id uuid;
  v_existing uuid;
  v_event_user uuid;
  v_entrega uuid;
begin
  if p_devuelto_id is null then
    return null;
  end if;

  select
    vd.id,
    vd.idpedido,
    vd.idmovimiento,
    vd.estado,
    vd.observacion,
    mp.codigo as movimiento_codigo,
    p.estado_admin
  into v_dev
  from public.viajes_devueltos vd
  left join public.movimientopedidos mp on mp.id = vd.idmovimiento
  left join public.pedidos p on p.id = vd.idpedido
  where vd.id = p_devuelto_id;

  if not found then
    return null;
  end if;

  if v_dev.estado <> 'devuelto_base' then
    return null;
  end if;

  if v_dev.estado_admin is not null and v_dev.estado_admin <> 'activo' then
    return null;
  end if;

  v_source_key := concat('pedido_devolucion:', p_devuelto_id::text);
  select id
    into v_existing
  from public.gl_journal_entries
  where source_key = v_source_key
    and source_prefix = 'pedido_devolucion'
  limit 1;

  if v_existing is not null then
    return v_existing;
  end if;

  select id
    into v_entrega
  from public.gl_journal_entries
  where source_prefix = 'pedido_entrega'
    and source_id = v_dev.idmovimiento
  limit 1;

  if v_entrega is null then
    return null;
  end if;

  select
    coalesce(sum(vdd.cantidad * coalesce(dp.precio_unitario, 0)), 0)::numeric(14,2),
    coalesce(sum(vdd.cantidad * coalesce(public.fn_producto_costo_promedio(vdd.idproducto), 0)), 0)::numeric(14,2)
    into v_total_ingreso, v_total_costo
  from public.viajes_devueltos_detalle vdd
  left join public.movimientopedidos mp on mp.id = vdd.idmovimiento
  left join public.v_detallepedidos_ajustado dp
    on dp.idpedido = mp.idpedido
   and dp.idproducto = vdd.idproducto
  where vdd.iddevuelto = p_devuelto_id;

  if coalesce(v_total_ingreso, 0) < 0.01 and coalesce(v_total_costo, 0) < 0.01 then
    return null;
  end if;

  select id into v_deferred_account
  from public.cuentas_contables
  where codigo = '48.01'
  limit 1;

  select id into v_ingreso_account
  from public.cuentas_contables
  where codigo = '70.01'
  limit 1;

  select id into v_inventory_account
  from public.cuentas_contables
  where codigo = '20.01'
  limit 1;

  select id into v_costo_account
  from public.cuentas_contables
  where codigo = '69.01'
  limit 1;

  if v_deferred_account is null
      or v_ingreso_account is null
      or v_inventory_account is null
      or v_costo_account is null then
    raise exception
      'Configura las cuentas contables 48.01, 69.01, 70.01 y 20.01 antes de registrar devoluciones.';
  end if;

  v_desc := concat('Devolucion movimiento ', coalesce(v_dev.movimiento_codigo, v_dev.idmovimiento::text));
  v_event_user := coalesce(p_event_user, auth.uid());

  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := 'pedido_devolucion',
    p_source_id := p_devuelto_id,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_ingreso_account,
        'debit', round(v_total_ingreso, 2),
        'credit', 0,
        'memo', v_dev.observacion,
        'line_source_key', 'ingreso'
      ),
      jsonb_build_object(
        'account_id', v_deferred_account,
        'debit', 0,
        'credit', round(v_total_ingreso, 2),
        'memo', v_dev.observacion,
        'line_source_key', 'diferido'
      ),
      jsonb_build_object(
        'account_id', v_inventory_account,
        'debit', round(v_total_costo, 2),
        'credit', 0,
        'memo', v_dev.observacion,
        'line_source_key', 'inventario'
      ),
      jsonb_build_object(
        'account_id', v_costo_account,
        'debit', 0,
        'credit', round(v_total_costo, 2),
        'memo', v_dev.observacion,
        'line_source_key', 'costo'
      )
    ),
    p_created_by := v_event_user,
    p_post := true
  );

  update public.pedidos
    set total_ingreso_reconocido = greatest(coalesce(total_ingreso_reconocido, 0) - round(v_total_ingreso, 2), 0),
        total_costo_reconocido = greatest(coalesce(total_costo_reconocido, 0) - round(v_total_costo, 2), 0)
  where id = v_dev.idpedido;

  return v_entry_id;
end;
$$;

create or replace function public.fn_viajesdetalles_evento_entrega()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' then
    return old;
  end if;

  if new.llegada_at is not null and (tg_op = 'INSERT' or old.llegada_at is distinct from new.llegada_at) then
    perform public.fn_pedidos_evento_entrega(
      new.idmovimiento,
      coalesce(new.editado_por, new.registrado_por)
    );
  end if;

  return new;
end;
$$;

create or replace function public.fn_viajes_devueltos_evento_devolucion()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' then
    return old;
  end if;

  if new.estado = 'devuelto_base'
      and (tg_op = 'INSERT' or old.estado is distinct from new.estado) then
    perform public.fn_pedidos_evento_devolucion(
      new.id,
      coalesce(new.editado_por, new.registrado_por)
    );
  end if;

  return new;
end;
$$;

create or replace function public.fn_viajes_devueltos_detalle_evento_devolucion()
returns trigger
language plpgsql
as $$
declare
  v_estado text;
  v_id uuid;
begin
  v_id := coalesce(new.iddevuelto, old.iddevuelto);
  if v_id is null then
    return case when tg_op = 'DELETE' then old else new end;
  end if;

  select estado
    into v_estado
  from public.viajes_devueltos
  where id = v_id;

  if v_estado = 'devuelto_base' then
    perform public.fn_pedidos_evento_devolucion(
      v_id,
      coalesce(new.editado_por, new.registrado_por, old.editado_por, old.registrado_por)
    );
  end if;

  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create or replace function public.fn_pedidos_child_sync_asientos()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' and old.idpedido is distinct from new.idpedido then
    if old.idpedido is not null then
      perform public.fn_pedidos_sync_asientos(old.idpedido);
    end if;
    if new.idpedido is not null then
      perform public.fn_pedidos_sync_asientos(new.idpedido);
    end if;
  else
    perform public.fn_pedidos_sync_asientos(coalesce(new.idpedido, old.idpedido));
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create or replace function public.fn_pedidos_header_sync_asientos()
returns trigger
language plpgsql
as $$
begin
  perform public.fn_pedidos_sync_asientos(new.id);
  return new;
end;
$$;

create or replace function public.fn_pedidos_cleanup_asientos()
returns trigger
language plpgsql
as $$
declare
  v_old record;
begin
  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = old.id
      and source_prefix in (
        'pedido_cxc',
        'pedido_ingreso',
        'pedido_costo',
        'pedido_entrega',
        'pedido_devolucion'
      )
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, 'Pedido eliminado');
  end loop;
  return old;
end;
$$;

create or replace function public.fn_pagos_postear_gl(p_pago_id uuid)
returns uuid
language plpgsql
as $$
declare
  v_pago public.pagos%rowtype;
  v_cxc_account uuid;
  v_bank_account uuid;
  v_cliente text;
  v_descripcion text;
  v_monto numeric(12,2);
  v_reg_por uuid;
  v_source_prefix text := 'cobro_cliente';
  v_base_key text;
  v_source_key text;
  v_version integer;
  v_max_version integer;
  v_entry_id uuid;
  v_old record;
begin
  if p_pago_id is null then
    return null;
  end if;

  select *
    into v_pago
  from public.pagos
  where id = p_pago_id
  for update;

  if not found then
    return null;
  end if;

  if v_pago.estado <> 'activo' then
    raise exception 'Pago % no esta activo.', v_pago.id;
  end if;

  if v_pago.idcuenta is null then
    raise exception 'Pago % requiere cuenta bancaria.', v_pago.id;
  end if;

  if coalesce(v_pago.monto, 0) <= 0 then
    raise exception 'Pago % requiere monto mayor a cero.', v_pago.id;
  end if;

  select id into v_cxc_account
  from public.cuentas_contables
  where codigo = '12.01'
  limit 1;

  if v_cxc_account is null then
    raise exception 'No existe la cuenta contable 12.01 (Clientes por cobrar).';
  end if;

  select
    cli.nombre,
    cb.idcuenta_contable
    into v_cliente, v_bank_account
  from public.pedidos ped
  left join public.clientes cli on cli.id = ped.idcliente
  left join public.cuentas_bancarias cb on cb.id = v_pago.idcuenta
  where ped.id = v_pago.idpedido;

  if v_bank_account is null then
    raise exception
      'La cuenta bancaria seleccionada no tiene una cuenta contable asociada.';
  end if;

  v_descripcion := concat('Cobro pedido ', coalesce(v_cliente, ''));
  v_monto := round(v_pago.monto::numeric, 2);
  v_reg_por := coalesce(v_pago.editado_por, v_pago.registrado_por, auth.uid());

  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = v_pago.id
      and source_prefix = v_source_prefix
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(
      v_old.id,
      'Cobro cliente actualizado',
      'auto'
    );
  end loop;

  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = v_pago.id
    and source_prefix = v_source_prefix;

  v_version := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;
  v_base_key := concat(v_source_prefix, ':', v_pago.id::text);
  v_source_key := case
    when v_version = 1 then v_base_key
    else concat(v_base_key, ':v', v_version::text)
  end;

  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := v_pago.id,
    p_source_key := v_source_key,
    p_descripcion := v_descripcion,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_bank_account,
        'debit', v_monto,
        'credit', 0,
        'memo', v_descripcion,
        'line_source_key', 'banco'
      ),
      jsonb_build_object(
        'account_id', v_cxc_account,
        'debit', 0,
        'credit', v_monto,
        'memo', v_descripcion,
        'line_source_key', 'cxc'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  return v_entry_id;
end;
$$;

create or replace function public.fn_pagos_sync_movimientos()
returns trigger
language plpgsql
as $$
declare
  v_cxc_account uuid;
  v_bank_account uuid;
  v_bank_nombre text;
  v_cliente text;
  v_descripcion text;
  v_monto numeric(12,2);
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_idpedido uuid;
  v_pago public.pagos%rowtype;
  v_mov_cxc uuid;
  v_mov_banco uuid;
  v_gl_entry_id uuid;
  v_old record;
begin
  if pg_trigger_depth() > 1 then
    return case when tg_op = 'DELETE' then old else new end;
  end if;

  if tg_op = 'DELETE' then
    v_pago := old;
  else
    v_pago := new;
  end if;

  if tg_op = 'UPDATE'
      and old.estado is not distinct from new.estado
      and old.idcuenta is not distinct from new.idcuenta
      and old.monto is not distinct from new.monto
      and old.fechapago is not distinct from new.fechapago
      and old.idpedido is not distinct from new.idpedido then
    return new;
  end if;

  select id into v_cxc_account
  from public.cuentas_contables
  where codigo = '12.01'
  limit 1;

  if v_cxc_account is null then
    raise exception 'No existe la cuenta contable 12.01 (Clientes por cobrar).';
  end if;

  v_idpedido := v_pago.idpedido;
  v_reg_at := coalesce(v_pago.editado_at, v_pago.registrado_at, now());
  v_reg_por := coalesce(v_pago.editado_por, v_pago.registrado_por, auth.uid());

  if tg_op <> 'DELETE' and v_pago.estado = 'cancelado' then
    if old.idmovimiento_financiero is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero,
        'Pago cancelado',
        v_reg_at,
        v_reg_por
      );
    end if;
    if old.idmovimiento_financiero_banco is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero_banco,
        'Pago cancelado',
        v_reg_at,
        v_reg_por
      );
    end if;

    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = v_pago.id
        and source_prefix = 'cobro_cliente'
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, 'Pago cancelado', 'current_period');
    end loop;

    update public.pagos
      set idmovimiento_financiero = null,
          idmovimiento_financiero_banco = null
    where id = v_pago.id;

    return new;
  end if;

  if tg_op = 'DELETE' then
    if old.idmovimiento_financiero is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero,
        'Pago eliminado',
        v_reg_at,
        v_reg_por
      );
    end if;
    if old.idmovimiento_financiero_banco is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero_banco,
        'Pago eliminado',
        v_reg_at,
        v_reg_por
      );
    end if;

    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = v_pago.id
        and source_prefix = 'cobro_cliente'
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, 'Pago eliminado', 'current_period');
    end loop;
    return old;
  end if;

  if v_pago.idcuenta is null or v_pago.monto <= 0 then
    if old.idmovimiento_financiero is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero,
        'Pago sin cuenta',
        v_reg_at,
        v_reg_por
      );
    end if;
    if old.idmovimiento_financiero_banco is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero_banco,
        'Pago sin cuenta',
        v_reg_at,
        v_reg_por
      );
    end if;

    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = v_pago.id
        and source_prefix = 'cobro_cliente'
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, 'Pago sin cuenta', 'current_period');
    end loop;

    update public.pagos
      set idmovimiento_financiero = null,
          idmovimiento_financiero_banco = null
    where id = v_pago.id;

    return new;
  end if;

  select
    cli.nombre,
    cb.idcuenta_contable,
    cb.nombre
    into v_cliente, v_bank_account, v_bank_nombre
  from public.pedidos ped
  left join public.clientes cli on cli.id = ped.idcliente
  left join public.cuentas_bancarias cb on cb.id = v_pago.idcuenta
  where ped.id = v_idpedido;

  if v_bank_account is null then
    raise exception
      'La cuenta bancaria seleccionada no tiene una cuenta contable asociada.';
  end if;

  v_descripcion := concat('Cobro pedido ', coalesce(v_cliente, ''));
  v_monto := v_pago.monto;
  v_reg_at := coalesce(v_pago.fechapago, v_pago.registrado_at, now());
  v_reg_por := coalesce(v_pago.registrado_por, auth.uid());

  if tg_op <> 'INSERT' then
    if old.idmovimiento_financiero is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero,
        'Pago actualizado',
        v_reg_at,
        v_reg_por
      );
    end if;
  end if;

  v_gl_entry_id := public.fn_pagos_postear_gl(v_pago.id);

  insert into public.movimientos_financieros (
    tipo,
    origen,
    source_key,
    descripcion,
    monto,
    idpedido,
    idcuenta_contable,
    observacion,
    registrado_at,
    registrado_por,
    gl_entry_id
  )
  values (
    'ingreso',
    concat('pago:', v_pago.id::text, ':cxc'),
    concat('pago:', v_pago.id::text, ':cxc'),
    v_descripcion,
    v_monto,
    v_idpedido,
    v_cxc_account,
    concat('Pedido ID: ', coalesce(v_idpedido::text, '')),
    v_reg_at,
    v_reg_por,
    v_gl_entry_id
  )
  on conflict (source_key) where source_key is not null and estado <> 'reversed'
  do update set
    tipo = excluded.tipo,
    origen = excluded.origen,
    descripcion = excluded.descripcion,
    monto = excluded.monto,
    idpedido = excluded.idpedido,
    idcuenta_contable = excluded.idcuenta_contable,
    observacion = excluded.observacion,
    registrado_at = excluded.registrado_at,
    registrado_por = excluded.registrado_por,
    gl_entry_id = excluded.gl_entry_id
  where movimientos_financieros.estado = 'draft'
  returning id into v_mov_cxc;

  if tg_op <> 'INSERT' then
    if old.idmovimiento_financiero_banco is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero_banco,
        'Pago actualizado',
        v_reg_at,
        v_reg_por
      );
    end if;
  end if;

  insert into public.movimientos_financieros (
    tipo,
    origen,
    source_key,
    descripcion,
    monto,
    idpedido,
    idcuenta_contable,
    observacion,
    registrado_at,
    registrado_por,
    gl_entry_id
  )
  values (
    'gasto',
    concat('pago:', v_pago.id::text, ':banco'),
    concat('pago:', v_pago.id::text, ':banco'),
    v_descripcion,
    v_monto,
    v_idpedido,
    v_bank_account,
    concat('Cuenta bancaria: ', coalesce(v_bank_nombre, '')),
    v_reg_at,
    v_reg_por,
    v_gl_entry_id
  )
  on conflict (source_key) where source_key is not null and estado <> 'reversed'
  do update set
    tipo = excluded.tipo,
    origen = excluded.origen,
    descripcion = excluded.descripcion,
    monto = excluded.monto,
    idpedido = excluded.idpedido,
    idcuenta_contable = excluded.idcuenta_contable,
    observacion = excluded.observacion,
    registrado_at = excluded.registrado_at,
    registrado_por = excluded.registrado_por,
    gl_entry_id = excluded.gl_entry_id
  where movimientos_financieros.estado = 'draft'
  returning id into v_mov_banco;

  update public.pagos
    set idmovimiento_financiero = v_mov_cxc,
        idmovimiento_financiero_banco = v_mov_banco
  where id = v_pago.id;

  return new;
end;
$$;

create trigger trg_detallepedidos_sync_asientos
after insert or update or delete on public.detallepedidos
for each row
execute function public.fn_pedidos_child_sync_asientos();

create trigger trg_movimientopedidos_sync_asientos
after insert or delete on public.movimientopedidos
for each row
execute function public.fn_pedidos_child_sync_asientos();

create trigger trg_movimientopedidos_sync_asientos_update
after update on public.movimientopedidos
for each row
when (
  old.idpedido is distinct from new.idpedido or
  old.estado is distinct from new.estado or
  old.es_provincia is distinct from new.es_provincia
)
execute function public.fn_pedidos_child_sync_asientos();

create trigger trg_viajes_devueltos_recalc_asientos
after insert or delete on public.viajes_devueltos
for each row
execute function public.fn_pedidos_child_sync_asientos();

create trigger trg_viajes_devueltos_recalc_asientos_update
after update on public.viajes_devueltos
for each row
when (
  old.idpedido is distinct from new.idpedido or
  old.estado is distinct from new.estado or
  old.penalidad is distinct from new.penalidad or
  old.monto_ida is distinct from new.monto_ida or
  old.monto_vuelta is distinct from new.monto_vuelta
)
execute function public.fn_pedidos_child_sync_asientos();

create trigger trg_pedido_rectificaciones_sync_asientos
after insert or update or delete on public.pedido_rectificaciones
for each row
execute function public.fn_pedidos_child_sync_asientos();

create trigger trg_pedidos_insert_sync_asientos
after insert on public.pedidos
for each row
execute function public.fn_pedidos_header_sync_asientos();

create trigger trg_pedidos_update_sync_asientos
after update on public.pedidos
for each row
when (
  old.estado_admin is distinct from new.estado_admin or
  old.estado is distinct from new.estado or
  old.idcliente is distinct from new.idcliente or
  old.observacion is distinct from new.observacion
)
execute function public.fn_pedidos_header_sync_asientos();

create trigger trg_pedidos_cleanup_asientos
before delete on public.pedidos
for each row
execute function public.fn_pedidos_cleanup_asientos();

create or replace function public.fn_pedidos_prevent_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar pedidos; usa cancelar.';
end;
$$;

create trigger trg_pedidos_prevent_delete
before delete on public.pedidos
for each row
execute function public.fn_pedidos_prevent_delete();

create trigger trg_pagos_sync_movimientos
after insert or update or delete on public.pagos
for each row
execute function public.fn_pagos_sync_movimientos();

create or replace view public.v_pagos_sin_gl as
select
  pg.id,
  pg.idpedido,
  pg.idcuenta,
  pg.monto,
  pg.fechapago,
  pg.registrado_at,
  pg.registrado_por
from public.pagos pg
where pg.estado = 'activo'
  and pg.idcuenta is not null
  and pg.monto > 0
  and not exists (
    select 1
    from public.gl_journal_entries e
    where e.source_prefix = 'cobro_cliente'
      and e.source_id = pg.id
      and e.estado = 'posted'
  );

create or replace function public.fn_pagos_postear_gl_pendientes()
returns integer
language plpgsql
as $$
declare
  v_row record;
  v_total integer := 0;
begin
  for v_row in
    select id
    from public.v_pagos_sin_gl
  loop
    perform public.fn_pagos_postear_gl(v_row.id);
    v_total := v_total + 1;
  end loop;

  return v_total;
end;
$$;

create or replace function public.fn_pedido_reembolsos_sync_movimientos()
returns trigger
language plpgsql
as $$
declare
  v_cxc_account uuid;
  v_bank_account uuid;
  v_bank_nombre text;
  v_cliente text;
  v_descripcion text;
  v_monto numeric(12,2);
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_observacion text;
begin
  select id into v_cxc_account
  from public.cuentas_contables
  where codigo = '12.01'
  limit 1;

  if v_cxc_account is null then
    raise exception 'No existe la cuenta contable 12.01 (Clientes por cobrar).';
  end if;

  if tg_op = 'DELETE' then
    if old.idmovimiento_financiero_cxc is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero_cxc,
        'Reembolso eliminado',
        coalesce(old.editado_at, old.registrado_at, now()),
        coalesce(old.editado_por, old.registrado_por, auth.uid())
      );
    end if;
    if old.idmovimiento_financiero_banco is not null then
      perform public.fn_movimientos_financieros_reversar(
        old.idmovimiento_financiero_banco,
        'Reembolso eliminado',
        coalesce(old.editado_at, old.registrado_at, now()),
        coalesce(old.editado_por, old.registrado_por, auth.uid())
      );
    end if;
    return old;
  end if;

  if new.idcuenta is null then
    raise exception 'Selecciona una cuenta bancaria para registrar el reembolso.';
  end if;

  select
    cli.nombre,
    cb.idcuenta_contable,
    cb.nombre
    into v_cliente, v_bank_account, v_bank_nombre
  from public.pedidos ped
  left join public.clientes cli on cli.id = ped.idcliente
  left join public.cuentas_bancarias cb on cb.id = new.idcuenta
  where ped.id = new.idpedido;

  if v_bank_account is null then
    raise exception
      'La cuenta bancaria seleccionada no tiene una cuenta contable asociada.';
  end if;

  v_descripcion := concat('Reembolso pedido ', coalesce(v_cliente, ''));
  v_monto := new.monto;
  v_reg_at := coalesce(new.registrado_at, now());
  v_reg_por := coalesce(new.registrado_por, auth.uid());
  v_observacion := coalesce(nullif(new.observacion, ''), 'Reembolso registrado en ERP.');

  if tg_op <> 'INSERT' and new.idmovimiento_financiero_cxc is not null then
    perform public.fn_movimientos_financieros_reversar(
      new.idmovimiento_financiero_cxc,
      'Reembolso actualizado',
      v_reg_at,
      v_reg_por
    );
  end if;

  insert into public.movimientos_financieros (
    tipo,
    origen,
    source_key,
    descripcion,
    monto,
    idpedido,
    idcuenta_contable,
    observacion,
    registrado_at,
    registrado_por
  )
  values (
    'gasto',
    concat('reembolso:', new.id::text, ':cxc'),
    concat('reembolso:', new.id::text, ':cxc'),
    v_descripcion,
    v_monto,
    new.idpedido,
    v_cxc_account,
    v_observacion,
    v_reg_at,
    v_reg_por
  )
  on conflict (source_key) where source_key is not null and estado <> 'reversed'
  do update set
    tipo = excluded.tipo,
    origen = excluded.origen,
    descripcion = excluded.descripcion,
    monto = excluded.monto,
    idpedido = excluded.idpedido,
    idcuenta_contable = excluded.idcuenta_contable,
    observacion = excluded.observacion,
    registrado_at = excluded.registrado_at,
    registrado_por = excluded.registrado_por
  where movimientos_financieros.estado = 'draft'
  returning id into new.idmovimiento_financiero_cxc;

  if tg_op <> 'INSERT' and new.idmovimiento_financiero_banco is not null then
    perform public.fn_movimientos_financieros_reversar(
      new.idmovimiento_financiero_banco,
      'Reembolso actualizado',
      v_reg_at,
      v_reg_por
    );
  end if;

  insert into public.movimientos_financieros (
    tipo,
    origen,
    source_key,
    descripcion,
    monto,
    idpedido,
    idcuenta_contable,
    observacion,
    registrado_at,
    registrado_por
  )
  values (
    'ingreso',
    concat('reembolso:', new.id::text, ':banco'),
    concat('reembolso:', new.id::text, ':banco'),
    v_descripcion,
    v_monto,
    new.idpedido,
    v_bank_account,
    concat('Cuenta bancaria: ', coalesce(v_bank_nombre, '')),
    v_reg_at,
    v_reg_por
  )
  on conflict (source_key) where source_key is not null and estado <> 'reversed'
  do update set
    tipo = excluded.tipo,
    origen = excluded.origen,
    descripcion = excluded.descripcion,
    monto = excluded.monto,
    idpedido = excluded.idpedido,
    idcuenta_contable = excluded.idcuenta_contable,
    observacion = excluded.observacion,
    registrado_at = excluded.registrado_at,
    registrado_por = excluded.registrado_por
  where movimientos_financieros.estado = 'draft'
  returning id into new.idmovimiento_financiero_banco;

  return new;
end;
$$;

create trigger trg_pedido_reembolsos_sync_movimientos
before insert or update or delete on public.pedido_reembolsos
for each row
execute function public.fn_pedido_reembolsos_sync_movimientos();

create trigger trg_viajesdetalles_sync_asientos
after insert or update or delete on public.viajesdetalles
for each row
execute function public.fn_viajesdetalles_evento_entrega();

create trigger trg_viajes_devueltos_sync_asientos
after insert or update or delete on public.viajes_devueltos
for each row
execute function public.fn_viajes_devueltos_evento_devolucion();

create trigger trg_viajes_devueltos_detalle_sync_asientos
after insert or update or delete on public.viajes_devueltos_detalle
for each row
execute function public.fn_viajes_devueltos_detalle_evento_devolucion();

-------------------------------------------------
-- 6. MÓDULO 2 · OPERACIONES (Compras / Ajustes / Transferencias / Fabricación)
-------------------------------------------------

-- ============================================
-- 6.1 PROVEEDORES
-- ============================================
create table if not exists proveedores (
  id uuid primary key default gen_random_uuid(),
  nombre  text not null,
  numero  text not null unique,
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id)
);

-- ============================================
-- 6.2 COMPRAS
-- ============================================
create sequence if not exists public.compras_correlativo_seq;

create table if not exists compras (
  id uuid primary key default gen_random_uuid(),
  correlativo bigint not null default nextval('public.compras_correlativo_seq'),
  idproveedor uuid not null references proveedores(id),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id),
  estado_contable text not null default 'draft'
    check (estado_contable in ('draft','posted')),
  estado text not null default 'activo'
    check (estado in ('activo','cancelado')),
  detalle_cerrado boolean not null default false,
  idasiento_transito uuid unique references gl_journal_entries(id) on delete set null,
  idasiento_inventario uuid unique references gl_journal_entries(id) on delete set null,
  idasiento_pasivo uuid unique references gl_journal_entries(id) on delete set null
);

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'compras'
      and column_name = 'correlativo'
  ) then
    alter table public.compras
      add column correlativo bigint;
  end if;
  alter table public.compras
    alter column correlativo
      set default nextval('public.compras_correlativo_seq');
  with base as (
    select coalesce(max(correlativo), 0) as offset
    from public.compras
    where correlativo is not null
  ),
  ordered as (
    select id, row_number() over (order by registrado_at, id) as rn
    from public.compras
    where correlativo is null
  )
  update public.compras c
  set correlativo = base.offset + ordered.rn
  from ordered, base
  where c.id = ordered.id;
  select coalesce(max(correlativo), 0)
    into v_max
  from public.compras;
  if v_max < 1 then
    perform setval('public.compras_correlativo_seq', 1, false);
  else
    perform setval('public.compras_correlativo_seq', v_max, true);
  end if;
  alter table public.compras
    alter column correlativo set not null;
end;
$$;

alter table if exists public.compras
  add column if not exists estado_contable text not null default 'draft'
    check (estado_contable in ('draft','posted'));

alter table if exists public.compras
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','cancelado'));

alter table if exists public.compras
  add column if not exists detalle_cerrado boolean not null default false;

update public.compras
set estado = 'activo'
where estado is null;

do $$
begin
  if to_regclass('public.compras_detalle') is not null then
    update public.compras
    set detalle_cerrado = true
    where detalle_cerrado = false
      and exists (
        select 1
        from public.compras_detalle cd
        where cd.idcompra = public.compras.id
      );
  end if;
end;
$$;

alter table if exists public.compras
  add column if not exists contable_version integer not null default 1;

create or replace function public.fn_compras_estado_contable_guard()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE'
      and new.estado_contable is distinct from old.estado_contable then
    if old.estado_contable = 'posted' then
      raise exception 'No se puede revertir el estado contable de compras.';
    end if;
    if new.estado_contable = 'posted'
        and current_setting('erp.compras_confirmar', true) is distinct from '1' then
      raise exception 'El estado contable de compras se gestiona automaticamente.';
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_compras_estado_contable_guard
before update on public.compras
for each row
execute function public.fn_compras_estado_contable_guard();

create or replace function public.fn_compras_detalle_cerrado_guard()
returns trigger
language plpgsql
as $$
begin
  if old.detalle_cerrado and new.detalle_cerrado is distinct from old.detalle_cerrado then
    raise exception 'No se puede reabrir el detalle de una compra.';
  end if;
  return new;
end;
$$;

create trigger trg_compras_detalle_cerrado_guard
before update of detalle_cerrado on public.compras
for each row
when (old.detalle_cerrado is distinct from new.detalle_cerrado)
execute function public.fn_compras_detalle_cerrado_guard();

create or replace function public.fn_compras_cancelada_guard()
returns trigger
language plpgsql
as $$
begin
  if old.estado = 'cancelado' and new.estado = old.estado then
    if current_setting('erp.compras_cancelar', true) = '1' then
      return new;
    end if;
    if new.idproveedor is distinct from old.idproveedor
        or new.observacion is distinct from old.observacion
        or new.estado_contable is distinct from old.estado_contable
        or new.contable_version is distinct from old.contable_version
        or new.detalle_cerrado is distinct from old.detalle_cerrado
        or new.idasiento_transito is distinct from old.idasiento_transito
        or new.idasiento_inventario is distinct from old.idasiento_inventario
        or new.idasiento_pasivo is distinct from old.idasiento_pasivo then
      raise exception 'No se puede editar una compra cancelada.';
    end if;
  elsif old.estado = 'cancelado' and new.estado is distinct from old.estado then
    raise exception 'No se puede cambiar el estado de una compra cancelada.';
  end if;
  return new;
end;
$$;

create trigger trg_compras_cancelada_guard
before update on public.compras
for each row
execute function public.fn_compras_cancelada_guard();

create table if not exists compras_detalle (
  id uuid primary key default gen_random_uuid(),
  idcompra   uuid not null references compras(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad     numeric(12,4) not null check (cantidad > 0),
  costo_total  numeric(14,6) not null check (costo_total >= 0),
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id),
  unique (idcompra, idproducto)
);

create table if not exists compras_pagos (
  id uuid primary key default gen_random_uuid(),
  idcompra uuid not null references compras(id) on delete cascade,
  idcuenta uuid references cuentas_bancarias(id),
  monto numeric(12,2) not null check (monto >= 0),
  estado text not null default 'activo'
    check (estado in ('activo','reversado')),
  idmovimiento_financiero uuid unique references movimientos_financieros(id) on delete set null,
  idmovimiento_financiero_banco uuid unique references movimientos_financieros(id) on delete set null,
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id)
);

alter table if exists public.compras_pagos
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','reversado'));

create or replace function public.fn_compras_pagos_sync_movimiento()
returns trigger
language plpgsql
as $$
declare
  v_cxp_account uuid;
  v_bank_account uuid;
  v_bank_nombre text;
  v_proveedor text;
  v_descripcion text;
  v_monto numeric(12,2);
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_source_prefix text := 'tesoreria_pago';
  v_source_key text;
  v_old record;
  v_motivo text;
  v_version integer;
  v_max_version integer;
begin
  select id into v_cxp_account
  from public.cuentas_contables
  where codigo = '40.01'
  limit 1;

  if v_cxp_account is null then
    raise exception 'No existe la cuenta contable 40.01 (Proveedores por pagar).';
  end if;

  if tg_op = 'DELETE' then
    raise exception 'No se permite eliminar pagos; usa una reversa.';
  end if;

  if tg_op = 'UPDATE' then
    if old.estado = 'reversado' then
      return new;
    end if;
    if new.estado = 'reversado' and old.estado is distinct from new.estado then
      if current_setting('erp.compras_pago_reversa', true) is distinct from '1' then
        raise exception 'Usa fn_compras_pagos_reversar para reversar pagos.';
      end if;
      v_motivo := nullif(current_setting('erp.compras_pago_motivo', true), '');
      if v_motivo is null then
        v_motivo := 'Pago compra reversado';
      end if;
      if old.idmovimiento_financiero is not null then
        perform public.fn_movimientos_financieros_reversar(
          old.idmovimiento_financiero,
          v_motivo,
          coalesce(new.editado_at, old.editado_at, old.registrado_at, now()),
          coalesce(new.editado_por, old.editado_por, old.registrado_por, auth.uid())
        );
      end if;
      if old.idmovimiento_financiero_banco is not null then
        perform public.fn_movimientos_financieros_reversar(
          old.idmovimiento_financiero_banco,
          v_motivo,
          coalesce(new.editado_at, old.editado_at, old.registrado_at, now()),
          coalesce(new.editado_por, old.editado_por, old.registrado_por, auth.uid())
        );
      end if;
      for v_old in
        select id
        from public.gl_journal_entries
        where source_id = old.id
          and source_prefix = v_source_prefix
          and estado = 'posted'
      loop
        perform public.fn_gl_reverse_entry(
          v_old.id,
          v_motivo,
          'current_period'
        );
      end loop;
      new.idmovimiento_financiero := null;
      new.idmovimiento_financiero_banco := null;
      return new;
    end if;
    raise exception 'No se permite editar pagos; usa una reversa.';
  end if;

  if new.idcuenta is null then
    raise exception 'Selecciona una cuenta bancaria para registrar el pago.';
  end if;

  select
    prov.nombre,
    cb.idcuenta_contable,
    cb.nombre
    into v_proveedor, v_bank_account, v_bank_nombre
  from public.compras c
  left join public.proveedores prov on prov.id = c.idproveedor
  left join public.cuentas_bancarias cb on cb.id = new.idcuenta
  where c.id = coalesce(new.idcompra, old.idcompra);

  if v_bank_account is null then
    raise exception
      'La cuenta bancaria seleccionada no tiene una cuenta contable asociada.';
  end if;

  v_descripcion := concat('Pago compra ', coalesce(v_proveedor, ''));

  v_monto := new.monto;
  v_reg_at := coalesce(new.registrado_at, now());
  v_reg_por := coalesce(new.registrado_por, auth.uid());
  v_motivo := case
    when tg_op = 'INSERT' then 'Pago proveedor registrado'
    else 'Pago proveedor actualizado'
  end;

  if tg_op <> 'INSERT' then
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = new.id
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(
        v_old.id,
        v_motivo,
        'current_period'
      );
    end loop;
  end if;

  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = new.id
    and source_prefix = v_source_prefix;

  v_version := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;
  v_source_key := case
    when v_version = 1 then concat(v_source_prefix, ':', new.id::text)
    else concat(v_source_prefix, ':', new.id::text, ':v', v_version::text)
  end;

  if tg_op <> 'INSERT' and new.idmovimiento_financiero is not null then
    perform public.fn_movimientos_financieros_reversar(
      new.idmovimiento_financiero,
      'Pago compra actualizado',
      v_reg_at,
      v_reg_por
    );
  end if;

  insert into public.movimientos_financieros (
    tipo,
    origen,
    source_key,
    descripcion,
    monto,
    idcuenta_origen,
    idcuenta_contable,
    observacion,
    registrado_at,
    registrado_por
  )
  values (
    'gasto',
    concat('compra_pago:', new.id::text, ':cxp'),
    concat('compra_pago:', new.id::text, ':cxp'),
    v_descripcion,
    v_monto,
    new.idcuenta,
    v_cxp_account,
    null,
    v_reg_at,
    v_reg_por
  )
  on conflict (source_key) where source_key is not null and estado <> 'reversed'
  do update set
    tipo = excluded.tipo,
    origen = excluded.origen,
    descripcion = excluded.descripcion,
    monto = excluded.monto,
    idcuenta_origen = excluded.idcuenta_origen,
    idcuenta_contable = excluded.idcuenta_contable,
    observacion = excluded.observacion,
    registrado_at = excluded.registrado_at,
    registrado_por = excluded.registrado_por
  where movimientos_financieros.estado = 'draft'
  returning id into new.idmovimiento_financiero;

  if tg_op <> 'INSERT' and new.idmovimiento_financiero_banco is not null then
    perform public.fn_movimientos_financieros_reversar(
      new.idmovimiento_financiero_banco,
      'Pago compra actualizado',
      v_reg_at,
      v_reg_por
    );
  end if;

  insert into public.movimientos_financieros (
    tipo,
    origen,
    source_key,
    descripcion,
    monto,
    idcuenta_contable,
    observacion,
    registrado_at,
    registrado_por
  )
  values (
    'ingreso',
    concat('compra_pago:', new.id::text, ':banco'),
    concat('compra_pago:', new.id::text, ':banco'),
    v_descripcion,
    v_monto,
    v_bank_account,
    concat('Cuenta bancaria: ', coalesce(v_bank_nombre, '')),
    v_reg_at,
    v_reg_por
  )
  on conflict (source_key) where source_key is not null and estado <> 'reversed'
  do update set
    tipo = excluded.tipo,
    origen = excluded.origen,
    descripcion = excluded.descripcion,
    monto = excluded.monto,
    idcuenta_contable = excluded.idcuenta_contable,
    observacion = excluded.observacion,
    registrado_at = excluded.registrado_at,
    registrado_por = excluded.registrado_por
  where movimientos_financieros.estado = 'draft'
  returning id into new.idmovimiento_financiero_banco;

  perform public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := new.id,
    p_source_key := v_source_key,
    p_descripcion := v_descripcion,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_cxp_account,
        'debit', v_monto,
        'credit', 0,
        'memo', v_descripcion,
        'line_source_key', 'proveedor'
      ),
      jsonb_build_object(
        'account_id', v_bank_account,
        'debit', 0,
        'credit', v_monto,
        'memo', v_descripcion,
        'line_source_key', 'banco'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  return new;
end;
$$;

create or replace function public.fn_compras_pagos_reversar(
  p_pago_id uuid,
  p_motivo text default null
)
returns uuid
language plpgsql
as $$
declare
  v_pago public.compras_pagos%rowtype;
  v_motivo text;
begin
  if p_pago_id is null then
    return null;
  end if;

  select *
    into v_pago
  from public.compras_pagos
  where id = p_pago_id
  for update;

  if not found then
    return null;
  end if;

  if v_pago.estado = 'reversado' then
    return v_pago.id;
  end if;

  v_motivo := coalesce(nullif(p_motivo, ''), 'Pago compra reversado');
  perform set_config('erp.compras_pago_reversa', '1', true);
  perform set_config('erp.compras_pago_motivo', v_motivo, true);

  update public.compras_pagos
    set estado = 'reversado',
        editado_at = now(),
        editado_por = coalesce(auth.uid(), v_pago.editado_por, v_pago.registrado_por)
  where id = v_pago.id;

  return v_pago.id;
end;
$$;

create trigger trg_compras_pagos_sync_movimiento
before insert or update or delete on public.compras_pagos
for each row
execute function public.fn_compras_pagos_sync_movimiento();

create or replace function public.fn_compras_sync_asientos(p_idcompra uuid)
returns void
language plpgsql
as $$
declare
  v_compra record;
  v_total numeric(18,4) := 0;
  v_transito_monto numeric(18,4) := 0;
  v_cuenta_transito uuid;
  v_cuenta_cxp uuid;
  v_desc text;
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_amount_total numeric(18,2);
  v_amount_transito numeric(18,2);
  v_source_prefix text := 'compra';
  v_source_key text;
  v_entry_id uuid;
  v_motivo text := 'Recalculo compra';
  v_version integer;
  v_max_version integer;
  v_old record;
begin
  select
    c.id,
    c.idasiento_transito,
    c.idasiento_inventario,
    c.idasiento_pasivo,
    c.contable_version,
    c.estado_contable,
    c.observacion,
    c.registrado_at,
    c.registrado_por,
    c.editado_por,
    prov.nombre as proveedor_nombre
  into v_compra
  from public.compras c
  left join public.proveedores prov on prov.id = c.idproveedor
  where c.id = p_idcompra;

  if not found then
    return;
  end if;

  select coalesce(sum(cd.costo_total), 0)::numeric(18,4)
    into v_total
  from public.compras_detalle cd
  where cd.idcompra = p_idcompra;

  v_transito_monto := coalesce(v_total, 0);

  select id into v_cuenta_transito
  from public.cuentas_contables
  where codigo = '20.02'
  limit 1;

  select id into v_cuenta_cxp
  from public.cuentas_contables
  where codigo = '40.01'
  limit 1;

  if v_cuenta_transito is null or v_cuenta_cxp is null then
    raise exception 'Configura las cuentas contables 20.02 y 40.01 antes de registrar compras.';
  end if;

  v_desc := concat('Compra ', coalesce(v_compra.proveedor_nombre, ''));
  v_reg_at := coalesce(v_compra.registrado_at, now());
  v_reg_por := coalesce(v_compra.registrado_por, auth.uid());

  v_amount_transito := round(v_transito_monto::numeric, 2);
  v_amount_total := round(v_amount_transito, 2);

  if v_amount_total <= 0 then
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = p_idcompra
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;
    delete from public.gl_journal_entries
    where source_id = p_idcompra
      and source_prefix = v_source_prefix
      and estado = 'draft';
    update public.compras
      set idasiento_transito = null,
          idasiento_inventario = null,
          idasiento_pasivo = null
    where id = p_idcompra;
    return;
  end if;

  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = p_idcompra
    and source_prefix = v_source_prefix;

  v_version := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;
  update public.compras
    set contable_version = v_version
  where id = p_idcompra;

  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = p_idcompra
      and source_prefix = v_source_prefix
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
  end loop;

  delete from public.gl_journal_entries
  where source_id = p_idcompra
    and source_prefix = v_source_prefix
    and estado = 'draft';

  v_source_key := case
    when v_version = 1 then concat(v_source_prefix, ':', p_idcompra::text)
    else concat(v_source_prefix, ':', p_idcompra::text, ':v', v_version::text)
  end;
  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := p_idcompra,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_cuenta_transito,
        'debit', v_amount_transito,
        'credit', 0,
        'memo', v_compra.observacion,
        'line_source_key', 'transito'
      ),
      jsonb_build_object(
        'account_id', v_cuenta_cxp,
        'debit', 0,
        'credit', v_amount_total,
        'memo', v_compra.observacion,
        'line_source_key', 'pasivo'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  perform set_config('erp.compras_confirmar', '1', true);
  update public.compras
    set estado_contable = 'posted',
        idasiento_transito = v_entry_id,
        idasiento_inventario = null,
        idasiento_pasivo = v_entry_id
  where id = p_idcompra;
end;
$$;

create or replace function public.fn_compras_confirmar(p_idcompra uuid)
returns uuid
language plpgsql
as $$
declare
  v_compra public.compras%rowtype;
  v_entry_id uuid;
begin
  if p_idcompra is null then
    return null;
  end if;

  select *
    into v_compra
  from public.compras
  where id = p_idcompra
  for update;

  if not found then
    return null;
  end if;

  if v_compra.estado_contable = 'posted' then
    return coalesce(v_compra.idasiento_pasivo, v_compra.idasiento_transito);
  end if;

  perform public.fn_compras_sync_asientos(p_idcompra);

  select id
    into v_entry_id
  from public.gl_journal_entries
  where source_id = p_idcompra
    and source_prefix = 'compra'
    and estado = 'posted'
  order by created_at desc
  limit 1;

  return v_entry_id;
end;
$$;

create or replace function public.fn_compras_corregir_asientos(
  p_idcompra uuid,
  p_motivo text default null
)
returns uuid
language plpgsql
as $$
declare
  v_compra record;
  v_total numeric(18,4) := 0;
  v_transito_monto numeric(18,4) := 0;
  v_cuenta_transito uuid;
  v_cuenta_cxp uuid;
  v_desc text;
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_amount_total numeric(18,2);
  v_amount_transito numeric(18,2);
  v_source_prefix text := 'compra';
  v_source_key text;
  v_entry_id uuid;
  v_old record;
  v_version integer;
  v_max_version integer;
  v_motivo text;
begin
  if p_idcompra is null then
    return null;
  end if;

  select
    c.id,
    c.idasiento_transito,
    c.idasiento_inventario,
    c.idasiento_pasivo,
    c.contable_version,
    c.estado_contable,
    c.observacion,
    c.registrado_at,
    c.registrado_por,
    c.editado_por,
    prov.nombre as proveedor_nombre
  into v_compra
  from public.compras c
  left join public.proveedores prov on prov.id = c.idproveedor
  where c.id = p_idcompra;

  if not found then
    return null;
  end if;

  if v_compra.estado_contable <> 'posted' then
    raise exception 'Compra % debe estar posteada para correccion.', p_idcompra;
  end if;

  select coalesce(sum(cd.costo_total), 0)::numeric(18,4)
    into v_total
  from public.compras_detalle cd
  where cd.idcompra = p_idcompra;

  v_transito_monto := coalesce(v_total, 0);

  select id into v_cuenta_transito
  from public.cuentas_contables
  where codigo = '20.02'
  limit 1;

  select id into v_cuenta_cxp
  from public.cuentas_contables
  where codigo = '40.01'
  limit 1;

  if v_cuenta_transito is null or v_cuenta_cxp is null then
    raise exception 'Configura las cuentas contables 20.02 y 40.01 antes de registrar compras.';
  end if;

  v_desc := concat('Compra ', coalesce(v_compra.proveedor_nombre, ''));
  v_reg_at := coalesce(v_compra.registrado_at, now());
  v_reg_por := coalesce(v_compra.registrado_por, auth.uid());
  v_motivo := coalesce(nullif(p_motivo, ''), 'Correccion compra');

  v_amount_transito := round(v_transito_monto::numeric, 2);
  v_amount_total := round(v_amount_transito, 2);

  if v_amount_total <= 0 then
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = p_idcompra
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;
    update public.compras
      set idasiento_transito = null,
          idasiento_inventario = null,
          idasiento_pasivo = null
    where id = p_idcompra;
    return null;
  end if;

  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = p_idcompra
    and source_prefix = v_source_prefix;

  v_version := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;
  update public.compras
    set contable_version = v_version
  where id = p_idcompra;

  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = p_idcompra
      and source_prefix = v_source_prefix
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
  end loop;

  v_source_key := case
    when v_version = 1 then concat(v_source_prefix, ':', p_idcompra::text)
    else concat(v_source_prefix, ':', p_idcompra::text, ':v', v_version::text)
  end;
  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := p_idcompra,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_cuenta_transito,
        'debit', v_amount_transito,
        'credit', 0,
        'memo', v_compra.observacion,
        'line_source_key', 'transito'
      ),
      jsonb_build_object(
        'account_id', v_cuenta_cxp,
        'debit', 0,
        'credit', v_amount_total,
        'memo', v_compra.observacion,
        'line_source_key', 'pasivo'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  update public.compras
    set idasiento_transito = v_entry_id,
        idasiento_inventario = null,
        idasiento_pasivo = v_entry_id
  where id = p_idcompra;

  return v_entry_id;
end;
$$;

create or replace function public.fn_compras_detalle_sync_asientos()
returns trigger
language plpgsql
as $$
begin
  perform public.fn_compras_sync_asientos(coalesce(new.idcompra, old.idcompra));
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create trigger trg_compras_detalle_sync_asientos
after insert or update or delete on public.compras_detalle
for each row
execute function public.fn_compras_detalle_sync_asientos();

create or replace function public.fn_compras_recepcion_sync_asiento(
  p_movimiento_id uuid
)
returns void
language plpgsql
as $$
declare
  v_mov record;
  v_total numeric(18,4) := 0;
  v_cuenta_inventario uuid;
  v_cuenta_transito uuid;
  v_desc text;
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_motivo text := 'Recalculo recepción compra';
  v_amount numeric(18,2);
  v_debit_account uuid;
  v_credit_account uuid;
  v_source_prefix text := 'recepcion_compra';
  v_source_key text;
  v_entry_id uuid;
  v_old record;
  v_version integer;
  v_max_version integer;
begin
  if p_movimiento_id is null then
    return;
  end if;

  select
    cm.id,
    cm.idcompra,
    cm.es_reversion,
    cm.observacion,
    cm.registrado_at,
    cm.registrado_por,
    prov.nombre as proveedor_nombre
  into v_mov
  from public.compras_movimientos cm
  left join public.compras c on c.id = cm.idcompra
  left join public.proveedores prov on prov.id = c.idproveedor
  where cm.id = p_movimiento_id;

  if not found then
    return;
  end if;

  select coalesce(sum(cmd.costo_total), 0)::numeric(18,4)
    into v_total
  from public.compras_movimiento_detalle cmd
  where cmd.idmovimiento = p_movimiento_id;

  v_amount := round(coalesce(v_total, 0)::numeric, 2);
  if v_amount < 0.01 then
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = p_movimiento_id
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;
    return;
  end if;

  select id into v_cuenta_inventario
  from public.cuentas_contables
  where codigo = '20.01'
  limit 1;

  select id into v_cuenta_transito
  from public.cuentas_contables
  where codigo = '20.02'
  limit 1;

  if v_cuenta_inventario is null or v_cuenta_transito is null then
    raise exception 'Configura las cuentas contables 20.01 y 20.02 antes de registrar recepciones.';
  end if;

  v_desc := concat('Recepción compra ', coalesce(v_mov.proveedor_nombre, ''));
  v_reg_at := coalesce(v_mov.registrado_at, now());
  v_reg_por := coalesce(v_mov.registrado_por, auth.uid());

  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = p_movimiento_id
      and source_prefix = v_source_prefix
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
  end loop;

  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = p_movimiento_id
    and source_prefix = v_source_prefix;

  v_version := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;
  v_source_key := case
    when v_version = 1 then concat(v_source_prefix, ':', p_movimiento_id::text)
    else concat(v_source_prefix, ':', p_movimiento_id::text, ':v', v_version::text)
  end;

  if coalesce(v_mov.es_reversion, false) then
    v_debit_account := v_cuenta_transito;
    v_credit_account := v_cuenta_inventario;
  else
    v_debit_account := v_cuenta_inventario;
    v_credit_account := v_cuenta_transito;
  end if;

  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := p_movimiento_id,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_debit_account,
        'debit', v_amount,
        'credit', 0,
        'memo', v_mov.observacion,
        'line_source_key', 'debit'
      ),
      jsonb_build_object(
        'account_id', v_credit_account,
        'debit', 0,
        'credit', v_amount,
        'memo', v_mov.observacion,
        'line_source_key', 'credit'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  return;
end;
$$;

create or replace function public.fn_compras_movimientos_sync_asientos()
returns trigger
language plpgsql
as $$
declare
  v_movimiento_id uuid;
begin
  v_movimiento_id := coalesce(new.idmovimiento, old.idmovimiento);
  if v_movimiento_id is not null then
    perform public.fn_compras_recepcion_sync_asiento(v_movimiento_id);
  end if;
  return case when tg_op = 'DELETE' then old else new end;
end;
$$;

create or replace function public.fn_compras_header_sync_asientos()
returns trigger
language plpgsql
as $$
begin
  perform public.fn_compras_sync_asientos(new.id);
  return new;
end;
$$;

create trigger trg_compras_header_sync_asientos
after update on public.compras
for each row
when (
  old.idproveedor is distinct from new.idproveedor or
  old.observacion is distinct from new.observacion
)
execute function public.fn_compras_header_sync_asientos();

-- ============================================
-- 6.2.1 COMPRAS · MOVIMIENTOS DE INGRESO
-- ============================================
create table if not exists compras_movimientos (
  id uuid primary key default gen_random_uuid(),
  idcompra uuid not null references compras(id) on delete cascade,
  idbase uuid not null references bases(id),
  observacion text,
  detalle_cerrado boolean not null default false,
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id)
);

create table if not exists compras_movimiento_detalle (
  id uuid primary key default gen_random_uuid(),
  idmovimiento uuid not null references compras_movimientos(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(12,4) not null check (cantidad > 0),
  costo_unitario numeric(18,6) not null default 0,
  costo_total numeric(18,4) not null default 0,
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id),
  unique (idmovimiento, idproducto)
);

create trigger trg_compras_movimientos_sync_asientos
after insert or update or delete on public.compras_movimiento_detalle
for each row
execute function public.fn_compras_movimientos_sync_asientos();

create table if not exists compras_reversiones (
  id uuid primary key default gen_random_uuid(),
  idcompra uuid not null references compras(id) on delete cascade,
  motivo text,
  observacion text,
  estado text not null default 'pendiente'
    check (estado in ('pendiente','completada','cancelada')),
  registrado_at timestamptz default now(),
  aplicado_at timestamptz,
  registrado_por uuid references auth.users(id),
  aplicado_por uuid references auth.users(id)
);

create table if not exists compras_reversion_movimientos (
  id uuid primary key default gen_random_uuid(),
  idreversion uuid not null references compras_reversiones(id) on delete cascade,
  idmovimiento_origen uuid not null references compras_movimientos(id),
  idmovimiento_reverso uuid references compras_movimientos(id),
  registrado_at timestamptz default now(),
  registrado_por uuid references auth.users(id)
);

create table if not exists compras_eventos (
  id uuid primary key default gen_random_uuid(),
  idcompra uuid not null references compras(id) on delete cascade,
  tipo text not null
    check (tipo in ('compra_cancelada','pago_reversado','movimiento_reversado')),
  referencia_id uuid,
  registrado_at timestamptz default now(),
  registrado_por uuid references auth.users(id)
);

create index if not exists idx_compras_eventos_compra
  on public.compras_eventos (idcompra);

alter table if exists public.compras_movimientos
  add column if not exists detalle_cerrado boolean not null default false;

update public.compras_movimientos
set detalle_cerrado = true
where detalle_cerrado = false
  and exists (
    select 1
    from public.compras_movimiento_detalle cmd
    where cmd.idmovimiento = public.compras_movimientos.id
  );

alter table public.compras_movimientos
  add column if not exists es_reversion boolean not null default false,
  add column if not exists idmovimiento_origen uuid references public.compras_movimientos(id),
  add column if not exists reversion_id uuid references public.compras_reversiones(id);

create or replace view public.v_contabilidad_historial as
select
  l.line_id as id,
  l.entry_id,
  e.source_prefix,
  e.source_id,
  e.source_key,
  e.estado,
  l.periodo_contable as periodo,
  timezone('America/Lima', l.posted_at) as fecha_at,
  to_char(
    timezone('America/Lima', l.posted_at),
    'YYYY-MM-DD HH24:MI:SS'
  ) as fecha,
  l.account_id as idcuenta_contable,
  l.cuenta_codigo as cuenta_contable_codigo,
  l.cuenta_nombre as cuenta_contable_nombre,
  l.cuenta_tipo as cuenta_tipo,
  case
    when e.source_prefix = 'reversal'
      or (
        e.source_prefix = 'recepcion_compra'
        and coalesce(cm.es_reversion, false)
      )
      then 'Correccion'
    else 'Evento'
  end as tipo,
  case
    when e.source_prefix = 'recepcion_compra'
      and coalesce(cm.es_reversion, false)
      then concat('Reversa: ', e.descripcion)
    else e.descripcion
  end as descripcion,
  l.memo,
  l.debit as debe,
  l.credit as haber,
  l.saldo_acumulado
from public.vw_gl_ledger l
join public.gl_journal_entries e on e.id = l.entry_id
left join public.compras_movimientos cm
  on cm.id = e.source_id
 and e.source_prefix = 'recepcion_compra'
where e.estado in ('posted','reversed')
order by l.posted_at desc, l.entry_id desc, l.line_id desc;

create or replace function public.fn_compras_evento_pago_reversado()
returns trigger
language plpgsql
as $$
begin
  if new.estado = 'reversado' and old.estado is distinct from new.estado then
    insert into public.compras_eventos (
      idcompra,
      tipo,
      referencia_id,
      registrado_at,
      registrado_por
    )
    values (
      new.idcompra,
      'pago_reversado',
      new.id,
      coalesce(new.editado_at, now()),
      coalesce(new.editado_por, new.registrado_por, auth.uid())
    );
  end if;
  return new;
end;
$$;

create trigger trg_compras_evento_pago_reversado
after update of estado on public.compras_pagos
for each row
when (old.estado is distinct from new.estado)
execute function public.fn_compras_evento_pago_reversado();

create or replace function public.fn_compras_evento_movimiento_reversado()
returns trigger
language plpgsql
as $$
begin
  if new.es_reversion then
    insert into public.compras_eventos (
      idcompra,
      tipo,
      referencia_id,
      registrado_at,
      registrado_por
    )
    values (
      new.idcompra,
      'movimiento_reversado',
      new.id,
      coalesce(new.registrado_at, now()),
      coalesce(new.registrado_por, auth.uid())
    );
  end if;
  return new;
end;
$$;

create trigger trg_compras_evento_movimiento_reversado
after insert on public.compras_movimientos
for each row
execute function public.fn_compras_evento_movimiento_reversado();

create or replace function public.fn_compras_movimiento_reversar(
  p_movimiento_id uuid,
  p_motivo text default null
)
returns uuid
language plpgsql
as $$
declare
  v_mov public.compras_movimientos%rowtype;
  v_reverso_id uuid;
  v_existing uuid;
  v_obs text;
  v_reg_at timestamptz;
  v_reg_por uuid;
begin
  if p_movimiento_id is null then
    return null;
  end if;

  select *
    into v_mov
  from public.compras_movimientos
  where id = p_movimiento_id
  for update;

  if not found then
    return null;
  end if;

  if v_mov.es_reversion then
    return v_mov.id;
  end if;

  select id
    into v_existing
  from public.compras_movimientos
  where idmovimiento_origen = v_mov.id
    and es_reversion = true
  limit 1;

  if v_existing is not null then
    return v_existing;
  end if;

  v_obs := coalesce(nullif(p_motivo, ''), 'Reversa movimiento compra');
  v_reg_at := now();
  v_reg_por := coalesce(auth.uid(), v_mov.editado_por, v_mov.registrado_por);

  insert into public.compras_movimientos (
    idcompra,
    idbase,
    observacion,
    es_reversion,
    idmovimiento_origen,
    registrado_at,
    registrado_por,
    detalle_cerrado
  )
  values (
    v_mov.idcompra,
    v_mov.idbase,
    v_obs,
    true,
    v_mov.id,
    v_reg_at,
    v_reg_por,
    false
  )
  returning id into v_reverso_id;

  insert into public.compras_movimiento_detalle (
    idmovimiento,
    idproducto,
    cantidad,
    registrado_at,
    registrado_por
  )
  select
    v_reverso_id,
    cmd.idproducto,
    cmd.cantidad,
    v_reg_at,
    v_reg_por
  from public.compras_movimiento_detalle cmd
  where cmd.idmovimiento = v_mov.id;

  update public.compras_movimientos
    set detalle_cerrado = true,
        editado_at = v_reg_at,
        editado_por = v_reg_por
  where id = v_reverso_id;

  return v_reverso_id;
end;
$$;

create or replace function public.fn_compras_movimiento_cerrado_guard()
returns trigger
language plpgsql
as $$
begin
  if old.detalle_cerrado and new.detalle_cerrado is distinct from old.detalle_cerrado then
    raise exception 'No se puede reabrir un movimiento de compra.';
  end if;
  if old.detalle_cerrado then
    if current_setting('erp.compras_cancelar', true) = '1' then
      if new.reversion_id is distinct from old.reversion_id
          and new.idbase is not distinct from old.idbase
          and new.observacion is not distinct from old.observacion
          and new.es_reversion is not distinct from old.es_reversion
          and new.idmovimiento_origen is not distinct from old.idmovimiento_origen then
        return new;
      end if;
    end if;
    if new.idbase is distinct from old.idbase
        or new.observacion is distinct from old.observacion
        or new.es_reversion is distinct from old.es_reversion
        or new.idmovimiento_origen is distinct from old.idmovimiento_origen
        or new.reversion_id is distinct from old.reversion_id then
      raise exception 'No se puede editar un movimiento de compra cerrado.';
    end if;
  end if;
  return new;
end;
$$;

create trigger trg_compras_movimiento_cerrado_guard
before update on public.compras_movimientos
for each row
execute function public.fn_compras_movimiento_cerrado_guard();

create or replace function public.compras_movimiento_detalle_set_cost()
returns trigger
language plpgsql
as $$
declare
  v_compra uuid;
  v_unit numeric(18,6);
begin
  select cm.idcompra
    into v_compra
  from public.compras_movimientos cm
  where cm.id = new.idmovimiento;
  if v_compra is null then
    raise exception
      'No se pudo determinar la compra para el movimiento %.',
      new.idmovimiento;
  end if;
  select
    case
      when cd.cantidad = 0 then 0
      else (cd.costo_total / nullif(cd.cantidad, 0))::numeric(18,6)
    end
    into v_unit
  from public.compras_detalle cd
  where cd.idcompra = v_compra
    and cd.idproducto = new.idproducto
  limit 1;
  if v_unit is null then
    raise exception
      'El producto % no existe en el detalle de la compra.',
      new.idproducto;
  end if;
  new.costo_unitario = v_unit;
  new.costo_total = (v_unit * new.cantidad)::numeric(18,4);
  return new;
end;
$$;

create trigger trg_compras_mov_detalle_cost
before insert or update on public.compras_movimiento_detalle
for each row
execute function public.compras_movimiento_detalle_set_cost();

create or replace function public.fn_costos_historial_from_compra_mov_detalle()
returns trigger
language plpgsql
as $$
declare
  v_mov record;
  v_cantidad numeric(18,6);
  v_total numeric(18,4);
  v_accion text;
  v_product uuid;
  v_cost_unit numeric(18,6);
  v_reg_at timestamptz;
begin
  if tg_op = 'UPDATE' then
    if new.idproducto is not distinct from old.idproducto
        and new.cantidad is not distinct from old.cantidad
        and new.costo_unitario is not distinct from old.costo_unitario
        and new.costo_total is not distinct from old.costo_total
        and new.idmovimiento is not distinct from old.idmovimiento then
      return new;
    end if;
  end if;

  select
    cm.idbase,
    cm.idcompra,
    cm.es_reversion
  into v_mov
  from public.compras_movimientos cm
  where cm.id = coalesce(new.idmovimiento, old.idmovimiento);
  if v_mov is null then
    return coalesce(new, old);
  end if;

  if tg_op = 'DELETE' or tg_op = 'UPDATE' then
    v_cantidad := coalesce(old.cantidad, 0);
    v_total := coalesce(old.costo_total, 0);
    if v_mov.es_reversion then
      v_cantidad := -v_cantidad;
      v_total := -v_total;
    end if;
    v_cost_unit := coalesce(old.costo_unitario, 0);
    v_reg_at := coalesce(old.editado_at, old.registrado_at, now());
    perform public.fn_costos_historial_upsert(
      p_origen_tipo => 'compra_movimiento',
      p_detalle_id => old.id,
      p_origen_id => v_mov.idcompra,
      p_idproducto => old.idproducto,
      p_idbase => v_mov.idbase,
      p_cantidad => -v_cantidad,
      p_costo_unitario => v_cost_unit,
      p_costo_total => -v_total,
      p_registrado_at => v_reg_at,
      p_accion => 'cancelar'
    );
    if tg_op = 'DELETE' then
      return old;
    end if;
  end if;

  v_cantidad := coalesce(new.cantidad, 0);
  v_total := coalesce(new.costo_total, 0);
  if v_mov.es_reversion then
    v_cantidad := -v_cantidad;
    v_total := -v_total;
  end if;
  v_accion := case when v_mov.es_reversion then 'cancelar' else 'insert' end;
  v_product := new.idproducto;
  v_cost_unit := coalesce(new.costo_unitario, 0);
  v_reg_at := coalesce(new.editado_at, new.registrado_at, now());
  perform public.fn_costos_historial_upsert(
    p_origen_tipo => 'compra_movimiento',
    p_detalle_id => new.id,
    p_origen_id => v_mov.idcompra,
    p_idproducto => v_product,
    p_idbase => v_mov.idbase,
    p_cantidad => v_cantidad,
    p_costo_unitario => v_cost_unit,
    p_costo_total => v_total,
    p_registrado_at => v_reg_at,
    p_accion => v_accion
  );
  return new;
end;
$$;

create trigger trg_costos_historial_compra_mov
after insert or update or delete on public.compras_movimiento_detalle
for each row
execute function public.fn_costos_historial_from_compra_mov_detalle();

create or replace function public.fn_compras_detalle_lock_when_moved()
returns trigger
language plpgsql
as $$
declare
  v_compra uuid := coalesce(new.idcompra, old.idcompra);
  v_estado text;
  v_detalle_cerrado boolean;
begin
  if v_compra is null then
    return case
      when tg_op = 'DELETE' then old
      else new
    end;
  end if;
  select estado, detalle_cerrado
    into v_estado, v_detalle_cerrado
  from public.compras
  where id = v_compra;
  if v_estado = 'cancelado' then
    raise exception 'No se puede modificar el detalle de una compra cancelada.';
  end if;
  if coalesce(v_detalle_cerrado, false) then
    raise exception 'No se puede modificar el detalle de una compra cerrada.';
  end if;
  if exists (
    select 1
    from public.compras_movimientos cm
    where cm.idcompra = v_compra
  ) then
    raise exception
      'No se puede modificar el detalle de una compra con movimientos registrados.';
  end if;
  return case
    when tg_op = 'DELETE' then old
    else new
  end;
end;
$$;

create trigger trg_compras_detalle_lock
before insert or update or delete on public.compras_detalle
for each row
execute function public.fn_compras_detalle_lock_when_moved();

create or replace function public.fn_compras_movimiento_detalle_lock()
returns trigger
language plpgsql
as $$
declare
  v_movimiento uuid := coalesce(new.idmovimiento, old.idmovimiento);
  v_detalle_cerrado boolean;
  v_estado_compra text;
  v_es_reversion boolean;
begin
  if v_movimiento is null then
    return case
      when tg_op = 'DELETE' then old
      else new
    end;
  end if;
  select
    cm.detalle_cerrado,
    c.estado,
    cm.es_reversion
  into v_detalle_cerrado, v_estado_compra, v_es_reversion
  from public.compras_movimientos cm
  join public.compras c on c.id = cm.idcompra
  where cm.id = v_movimiento;
  if v_estado_compra = 'cancelado' then
    if tg_op = 'INSERT' and v_es_reversion = true then
      return new;
    end if;
    if current_setting('erp.compras_cancelar', true) = '1' then
      return case
        when tg_op = 'DELETE' then old
        else new
      end;
    end if;
    raise exception
      'No se puede modificar movimientos de una compra cancelada.';
  end if;
  if coalesce(v_detalle_cerrado, false) then
    raise exception
      'No se puede modificar el detalle de un movimiento cerrado.';
  end if;
  return case
    when tg_op = 'DELETE' then old
    else new
  end;
end;
$$;

create trigger trg_compras_movimiento_detalle_lock
before insert or update or delete on public.compras_movimiento_detalle
for each row
execute function public.fn_compras_movimiento_detalle_lock();

create or replace function public.fn_compras_movimientos_prevent_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar movimientos de compra; usa reversa.';
end;
$$;

create trigger trg_compras_movimientos_prevent_delete
before delete on public.compras_movimientos
for each row
execute function public.fn_compras_movimientos_prevent_delete();

create or replace function public.fn_compras_prevent_delete_with_movimientos()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar compras; usa cancelar.';
end;
$$;

create trigger trg_compras_lock_delete
before delete on public.compras
for each row
execute function public.fn_compras_prevent_delete_with_movimientos();

create or replace function public.fn_compras_cancelar()
returns trigger
language plpgsql
as $$
declare
  v_pago record;
  v_mov record;
  v_entry record;
  v_reversion_id uuid;
  v_mov_reverso uuid;
  v_reg_por uuid;
  v_reg_at timestamptz;
begin
  if new.estado = 'cancelado' and old.estado is distinct from new.estado then
    perform set_config('erp.compras_cancelar', '1', true);
    v_reg_por := coalesce(new.editado_por, new.registrado_por, auth.uid());
    v_reg_at := coalesce(new.editado_at, now());

    insert into public.compras_reversiones (
      idcompra,
      observacion,
      estado,
      registrado_at,
      aplicado_at,
      registrado_por,
      aplicado_por
    )
    values (
      new.id,
      'Cancelacion de compra',
      'completada',
      v_reg_at,
      v_reg_at,
      v_reg_por,
      v_reg_por
    )
    returning id into v_reversion_id;

    for v_pago in
      select id
      from public.compras_pagos
      where idcompra = new.id
        and estado = 'activo'
    loop
      perform public.fn_compras_pagos_reversar(v_pago.id);
    end loop;

    for v_mov in
      select id
      from public.compras_movimientos
      where idcompra = new.id
        and es_reversion = false
    loop
      v_mov_reverso := public.fn_compras_movimiento_reversar(
        v_mov.id,
        'Reversa por cancelacion'
      );
      if v_mov_reverso is not null then
        update public.compras_movimientos
          set reversion_id = v_reversion_id
        where id = v_mov_reverso
          and reversion_id is null;
        insert into public.compras_reversion_movimientos (
          idreversion,
          idmovimiento_origen,
          idmovimiento_reverso,
          registrado_por
        )
        select
          v_reversion_id,
          v_mov.id,
          v_mov_reverso,
          v_reg_por
        where not exists (
          select 1
          from public.compras_reversion_movimientos crm
          where crm.idreversion = v_reversion_id
            and crm.idmovimiento_origen = v_mov.id
        );
      end if;
    end loop;

    for v_entry in
      select id
      from public.gl_journal_entries
      where source_id = new.id
        and source_prefix = 'compra'
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_entry.id, 'Compra cancelada');
    end loop;

    update public.compras
      set detalle_cerrado = true
    where id = new.id
      and detalle_cerrado is distinct from true;

    insert into public.compras_eventos (
      idcompra,
      tipo,
      referencia_id,
      registrado_at,
      registrado_por
    )
    values (
      new.id,
      'compra_cancelada',
      new.id,
      v_reg_at,
      v_reg_por
    );
  end if;
  return new;
end;
$$;

create trigger trg_compras_cancelar
after update of estado on public.compras
for each row
when (old.estado is distinct from new.estado)
execute function public.fn_compras_cancelar();

-- ============================================
-- 6.3 AJUSTES
-- ============================================
create table if not exists ajustes (
  id uuid primary key default gen_random_uuid(),
  idbase uuid not null references bases(id),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id)
);

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ajustes'
      and column_name = 'idasiento_inventario'
  ) then
    alter table public.ajustes
      add column idasiento_inventario uuid unique
        references gl_journal_entries(id) on delete set null;
  end if;
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'ajustes'
      and column_name = 'idasiento_gasto'
  ) then
    alter table public.ajustes
      add column idasiento_gasto uuid unique
        references gl_journal_entries(id) on delete set null;
  end if;
end;
$$;

alter table if exists public.ajustes
  add column if not exists contable_version integer not null default 1;

create table if not exists ajustes_detalle (
  id uuid primary key default gen_random_uuid(),
  idajuste   uuid not null references ajustes(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad   numeric(12,4) not null check (cantidad <> 0),
  cantidad_sistema numeric(12,4),
  cantidad_real    numeric(12,4),
  costo_unitario numeric(12,6) not null default 0,
  costo_total numeric(14,4) not null default 0,
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id),
  unique (idajuste, idproducto)
);

create or replace function public.fn_ajustes_detalle_set_diferencia()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_costo_unit numeric(12,6) := 0;
  v_cantidad numeric(12,4) := 0;
  v_recalc boolean := false;
begin
  if tg_op = 'INSERT' then
    v_recalc := true;
  elsif tg_op = 'UPDATE' then
    v_recalc := new.idproducto is distinct from old.idproducto
      or new.cantidad_real is distinct from old.cantidad_real
      or new.cantidad_sistema is distinct from old.cantidad_sistema;
  end if;

  if not v_recalc and tg_op = 'UPDATE' then
    new.cantidad := old.cantidad;
    new.cantidad_sistema := old.cantidad_sistema;
    new.costo_unitario := old.costo_unitario;
    new.costo_total := old.costo_total;
    new.editado_at := now();
    new.editado_por := coalesce(auth.uid(), new.editado_por, old.editado_por);
    return new;
  end if;

  new.cantidad_sistema := coalesce(new.cantidad_sistema, 0);
  if new.cantidad_real is null then
    new.cantidad := null;
  else
    new.cantidad := (new.cantidad_real - new.cantidad_sistema);
  end if;
  v_cantidad := coalesce(new.cantidad, 0);
  select coalesce(public.fn_producto_costo_promedio(new.idproducto), 0)
    into v_costo_unit;
  new.costo_unitario := v_costo_unit;
  new.costo_total := round(v_costo_unit * v_cantidad, 4);
  if tg_op = 'UPDATE' then
    new.editado_at := now();
    new.editado_por := coalesce(auth.uid(), new.editado_por, old.editado_por);
  end if;
  return new;
end;
$$;

create trigger ajustes_detalle_set_diferencia
before insert or update on public.ajustes_detalle
for each row
execute function public.fn_ajustes_detalle_set_diferencia();

create or replace view public.v_ajustes_detalle_vistageneral as
select
  ad.id,
  ad.idajuste,
  ad.idproducto,
  p.nombre as producto_nombre,
  ad.cantidad_sistema,
  ad.cantidad_real,
  ad.cantidad as diferencia,
  ad.costo_unitario,
  ad.costo_total,
  ad.registrado_at,
  ad.editado_at,
  ad.registrado_por,
  ad.editado_por
from public.ajustes_detalle ad
left join public.productos p on p.id = ad.idproducto;

create or replace view public.v_ajustes_vistageneral as
with detalle as (
  select
    ad.idajuste,
    count(*)::int as productos_registrados,
    count(*) filter (where ad.cantidad_real is null)::int as productos_pendientes,
    count(*) filter (where ad.cantidad_real is not null)::int as productos_conteo,
    coalesce(sum(ad.cantidad), 0)::numeric(14,4) as diferencia_total,
    coalesce(sum(ad.costo_total), 0)::numeric(14,4) as costo_total
  from public.ajustes_detalle ad
  group by ad.idajuste
)
select
  a.id,
  a.idbase,
  b.nombre as base_nombre,
  a.observacion,
  coalesce(det.productos_registrados, 0) as productos_registrados,
  coalesce(det.productos_pendientes, 0) as productos_pendientes,
  coalesce(det.productos_conteo, 0) as productos_conteo,
  coalesce(det.diferencia_total, 0)::numeric(14,4) as diferencia_total,
  coalesce(det.costo_total, 0)::numeric(14,4) as costo_total,
  a.registrado_at,
  a.editado_at,
  a.registrado_por,
  a.editado_por
from public.ajustes a
left join detalle det on det.idajuste = a.id
left join public.bases b on b.id = a.idbase;

create or replace function public.fn_ajustes_sync_asientos(p_idajuste uuid)
returns void
language plpgsql
as $$
declare
  v_ajuste ajustes%rowtype;
  v_total numeric(18,4) := 0;
  v_abs numeric(18,4) := 0;
  v_cuenta_inventario uuid;
  v_cuenta_gasto uuid;
  v_desc text;
  v_obs text;
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_inv_id uuid;
  v_gasto_id uuid;
  v_motivo text;
  v_amount numeric(18,2);
  v_debit_account uuid;
  v_credit_account uuid;
  v_source_prefix text;
  v_source_key text;
  v_entry_id uuid;
  v_old record;
  v_version integer;
  v_max_version integer;
begin
  select *
    into v_ajuste
  from public.ajustes
  where id = p_idajuste;
  if not found then
    return;
  end if;

  select coalesce(sum(ad.costo_total), 0)
    into v_total
  from public.ajustes_detalle ad
  where ad.idajuste = p_idajuste;

  v_abs := abs(v_total);
  v_source_prefix := 'ajuste';
  v_motivo := 'Recalculo ajuste';
  if v_abs < 0.01 then
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = p_idajuste
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;
    update public.ajustes
      set idasiento_inventario = null,
          idasiento_gasto = null
    where id = p_idajuste;
    return;
  end if;

  select id into v_cuenta_inventario
  from public.cuentas_contables
  where codigo = '20.01'
  limit 1;
  select id into v_cuenta_gasto
  from public.cuentas_contables
  where codigo = '80.01'
  limit 1;
  if v_cuenta_inventario is null or v_cuenta_gasto is null then
    return;
  end if;

  v_desc := concat('Ajuste inventario ', coalesce(v_ajuste.observacion, p_idajuste::text));
  v_reg_at := coalesce(v_ajuste.editado_at, v_ajuste.registrado_at, now());
  v_reg_por := coalesce(v_ajuste.editado_por, v_ajuste.registrado_por, auth.uid());

  v_amount := round(v_abs::numeric, 2);
  if v_total < 0 then
    v_debit_account := v_cuenta_gasto;
    v_credit_account := v_cuenta_inventario;
    v_obs := 'Faltante de inventario';
  else
    v_debit_account := v_cuenta_inventario;
    v_credit_account := v_cuenta_gasto;
    v_obs := 'Excedente de inventario';
  end if;

  v_version := coalesce(v_ajuste.contable_version, 1);
  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = p_idajuste
    and source_prefix = v_source_prefix;

  v_version := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;
  update public.ajustes
    set contable_version = v_version
  where id = p_idajuste;

  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = p_idajuste
      and source_prefix = v_source_prefix
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
  end loop;

  v_source_key := case
    when v_version = 1 then concat(v_source_prefix, ':', p_idajuste::text)
    else concat(v_source_prefix, ':', p_idajuste::text, ':v', v_version::text)
  end;
  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := p_idajuste,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_debit_account,
        'debit', v_amount,
        'credit', 0,
        'memo', v_obs,
        'line_source_key', 'debit'
      ),
      jsonb_build_object(
        'account_id', v_credit_account,
        'debit', 0,
        'credit', v_amount,
        'memo', v_obs,
        'line_source_key', 'credit'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  v_inv_id := v_entry_id;
  v_gasto_id := v_entry_id;

  update public.ajustes
    set idasiento_inventario = v_inv_id,
        idasiento_gasto = v_gasto_id
  where id = p_idajuste;
end;
$$;

create or replace function public.fn_ajustes_touch_asientos()
returns trigger
language plpgsql
as $$
declare
  v_id uuid;
begin
  v_id := coalesce(new.idajuste, old.idajuste);
  if v_id is not null then
    perform public.fn_ajustes_sync_asientos(v_id);
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger ajustes_touch_asientos
after insert or update or delete on public.ajustes_detalle
for each row
execute function public.fn_ajustes_touch_asientos();

create or replace function public.fn_ajustes_cleanup_movimientos()
returns trigger
language plpgsql
as $$
declare
  v_old record;
begin
  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = old.id
      and source_prefix = 'ajuste'
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, 'Ajuste eliminado');
  end loop;
  return old;
end;
$$;

create trigger ajustes_cleanup_movimientos
before delete on public.ajustes
for each row
execute function public.fn_ajustes_cleanup_movimientos();

create or replace function public.fn_ajustes_prevent_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar ajustes; registra un ajuste inverso.';
end;
$$;

create trigger trg_ajustes_prevent_delete
before delete on public.ajustes
for each row
execute function public.fn_ajustes_prevent_delete();

-- ============================================
-- 6.4 TRANSFERENCIAS ENTRE BASES
-- ============================================
create table if not exists transferencias (
  id uuid primary key default gen_random_uuid(),
  idbase_origen  uuid not null references bases(id),
  idbase_destino uuid not null references bases(id),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id),
  check (idbase_origen <> idbase_destino)
);

create table if not exists transferencias_detalle (
  id uuid primary key default gen_random_uuid(),
  idtransferencia uuid not null references transferencias(id) on delete cascade,
  idproducto      uuid not null references productos(id),
  cantidad numeric(12,4) not null check (cantidad > 0),
  registrado_at timestamptz default now(),
  editado_at     timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por    uuid references auth.users(id),
  unique (idtransferencia, idproducto)
);

create table if not exists transferencias_gastos (
  id uuid primary key default gen_random_uuid(),
  idtransferencia uuid not null references transferencias(id) on delete cascade,
  idcuenta uuid references cuentas_bancarias(id),
  idcuenta_contable uuid references cuentas_contables(id),
  concepto text not null,
  monto numeric(12,2) not null check (monto >= 0),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create or replace view public.v_transferencias_vistageneral as
with detalle as (
  select
    td.idtransferencia,
    count(*)::int as productos_registrados,
    coalesce(sum(td.cantidad), 0)::numeric(14,4) as total_cantidad
  from public.transferencias_detalle td
  group by td.idtransferencia
)
select
  t.id,
  t.idbase_origen,
  bo.nombre as base_origen_nombre,
  t.idbase_destino,
  bd.nombre as base_destino_nombre,
  t.observacion,
  coalesce(det.productos_registrados, 0) as productos_registrados,
  coalesce(det.total_cantidad, 0)::numeric(14,4) as total_cantidad,
  t.registrado_at,
  t.editado_at,
  t.registrado_por,
  t.editado_por
from public.transferencias t
left join detalle det on det.idtransferencia = t.id
left join public.bases bo on bo.id = t.idbase_origen
left join public.bases bd on bd.id = t.idbase_destino;

create or replace view public.v_transferencias_detalle_vistageneral as
select
  td.id,
  td.idtransferencia,
  td.idproducto,
  p.nombre as producto_nombre,
  td.cantidad,
  t.idbase_origen,
  bo.nombre as base_origen_nombre,
  t.idbase_destino,
  bd.nombre as base_destino_nombre,
  td.registrado_at,
  td.editado_at,
  td.registrado_por,
  td.editado_por
from public.transferencias_detalle td
join public.transferencias t on t.id = td.idtransferencia
left join public.productos p on p.id = td.idproducto
left join public.bases bo on bo.id = t.idbase_origen
left join public.bases bd on bd.id = t.idbase_destino;

create or replace function public.fn_transferencias_prevent_delete()
returns trigger
language plpgsql
as $$
begin
  raise exception 'No se permite eliminar transferencias; registra una transferencia inversa.';
end;
$$;

create trigger trg_transferencias_prevent_delete
before delete on public.transferencias
for each row
execute function public.fn_transferencias_prevent_delete();

-- ============================================
-- 6.5 FABRICACIONES
-- ============================================
create sequence if not exists public.fabricaciones_correlativo_seq;

create table if not exists fabricaciones (
  id uuid primary key default gen_random_uuid(),
  correlativo bigint not null default nextval('public.fabricaciones_correlativo_seq'),
  idbase uuid not null references bases(id),
  idreceta uuid references recetas(id),
  observacion text,
  estado text not null default 'activo'
    check (estado in ('activo','cancelado')),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'fabricaciones'
      and column_name = 'correlativo'
  ) then
    alter table public.fabricaciones
      add column correlativo bigint;
  end if;
  alter table public.fabricaciones
    alter column correlativo
      set default nextval('public.fabricaciones_correlativo_seq');
  with base as (
    select coalesce(max(correlativo), 0) as offset
    from public.fabricaciones
    where correlativo is not null
  ),
  ordered as (
    select id, row_number() over (order by registrado_at, id) as rn
    from public.fabricaciones
    where correlativo is null
  )
  update public.fabricaciones f
  set correlativo = base.offset + ordered.rn
  from ordered, base
  where f.id = ordered.id;
  select coalesce(max(correlativo), 0)
    into v_max
  from public.fabricaciones;
  if v_max < 1 then
    perform setval('public.fabricaciones_correlativo_seq', 1, false);
  else
    perform setval('public.fabricaciones_correlativo_seq', v_max, true);
  end if;
  alter table public.fabricaciones
    alter column correlativo set not null;
end;
$$;

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'fabricaciones'
      and column_name = 'idasiento_ajuste'
  ) then
    alter table public.fabricaciones
      add column idasiento_ajuste uuid unique
        references gl_journal_entries(id) on delete set null;
  end if;
end;
$$;

alter table if exists public.fabricaciones
  add column if not exists contable_version integer not null default 1;

alter table if exists public.fabricaciones
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','cancelado'));

create table if not exists fabricaciones_consumos (
  id uuid primary key default gen_random_uuid(),
  idfabricacion uuid not null references fabricaciones(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(12,4) not null check (cantidad > 0),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create index if not exists idx_fabricaciones_consumos_idfabricacion
  on public.fabricaciones_consumos(idfabricacion);

create table if not exists fabricaciones_resultados (
  id uuid primary key default gen_random_uuid(),
  idfabricacion uuid not null references fabricaciones(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(12,4) not null check (cantidad > 0),
  costo_unitario numeric(12,6) not null default 0,
  costo_total numeric(14,4) not null default 0,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create index if not exists idx_fabricaciones_resultados_idfabricacion
  on public.fabricaciones_resultados(idfabricacion);

create index if not exists idx_fabricaciones_resultados_idfabricacion_producto
  on public.fabricaciones_resultados(idfabricacion, idproducto);

create or replace function public.fn_fabricaciones_resultados_unique_producto()
returns trigger
language plpgsql
as $$
begin
  if exists (
    select 1
    from public.fabricaciones_resultados fr
    where fr.idfabricacion = new.idfabricacion
      and fr.idproducto = new.idproducto
      and fr.id <> coalesce(new.id, old.id)
  ) then
    raise exception 'El producto ya está registrado en los resultados de esta fabricación.';
  end if;
  return new;
end;
$$;

create trigger trg_fabricaciones_resultados_unique_producto
before insert or update on public.fabricaciones_resultados
for each row
execute function public.fn_fabricaciones_resultados_unique_producto();

create or replace function public.fn_fabricaciones_recalcular_costos(p_idfabricacion uuid)
returns void
language plpgsql
as $$
declare
  v_total_consumo numeric(18,6) := 0;
  v_total_resultado numeric(18,6) := 0;
begin
  perform set_config('erp.skip_costos_historial', '1', true);
  select
      coalesce(
        sum(
          fc.cantidad * coalesce(public.fn_producto_costo_promedio(fc.idproducto), 0)
        ),
        0
      )
    into v_total_consumo
  from public.fabricaciones_consumos fc
  where fc.idfabricacion = p_idfabricacion;

  select coalesce(sum(fr.cantidad), 0)
    into v_total_resultado
  from public.fabricaciones_resultados fr
  where fr.idfabricacion = p_idfabricacion;

  if v_total_resultado = 0 then
    update public.fabricaciones_resultados
      set costo_total = 0,
          costo_unitario = 0
    where idfabricacion = p_idfabricacion;
  else
    update public.fabricaciones_resultados fr
      set costo_total = round(
            case
              when v_total_consumo = 0 then 0
              else (fr.cantidad / v_total_resultado) * v_total_consumo
            end,
            4
          ),
          costo_unitario = case
            when fr.cantidad = 0 then 0
            else round(
              case
                when v_total_consumo = 0 then 0
                else ((fr.cantidad / v_total_resultado) * v_total_consumo) / fr.cantidad
              end,
              6
            )
          end
    where fr.idfabricacion = p_idfabricacion;
  end if;
  perform set_config('erp.skip_costos_historial', '0', true);
  perform public.fn_fabricaciones_sync_ajuste(p_idfabricacion);
end;
$$;

create or replace function public.fn_fabricaciones_sync_ajuste(p_idfabricacion uuid)
returns void
language plpgsql
as $$
declare
  v_total_consumo numeric(18,4) := 0;
  v_total_resultado numeric(18,4) := 0;
  v_fabricacion fabricaciones%rowtype;
  v_diff numeric(18,4);
  v_abs_diff numeric(18,4);
  v_account uuid;
  v_cuenta_inventario uuid;
  v_desc text;
  v_obs text;
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_motivo text;
  v_amount numeric(18,2);
  v_debit_account uuid;
  v_credit_account uuid;
  v_source_prefix text;
  v_source_key text;
  v_entry_id uuid;
  v_old record;
  v_version integer;
  v_max_version integer;
begin
  select *
    into v_fabricacion
  from public.fabricaciones
  where id = p_idfabricacion;
  if not found then
    return;
  end if;

  select
      coalesce(
        sum(
          fc.cantidad * coalesce(public.fn_producto_costo_promedio(fc.idproducto), 0)
        ),
        0
      )
    into v_total_consumo
  from public.fabricaciones_consumos fc
  where fc.idfabricacion = p_idfabricacion;

  select coalesce(sum(fr.costo_total), 0)
    into v_total_resultado
  from public.fabricaciones_resultados fr
  where fr.idfabricacion = p_idfabricacion;

  v_diff := v_total_resultado - v_total_consumo;
  v_abs_diff := abs(v_diff);
  v_source_prefix := 'fabricacion_ajuste';
  v_motivo := 'Recalculo fabricacion';
  if v_abs_diff < 0.01 then
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = p_idfabricacion
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;
    update public.fabricaciones
      set idasiento_ajuste = null
    where id = p_idfabricacion;
    return;
  end if;

  select id
    into v_account
  from public.cuentas_contables
  where codigo = '80.02'
  limit 1;
  select id
    into v_cuenta_inventario
  from public.cuentas_contables
  where codigo = '20.01'
  limit 1;
  if v_account is null or v_cuenta_inventario is null then
    return;
  end if;

  v_desc := concat('Ajuste fabricación ', coalesce(v_fabricacion.observacion, p_idfabricacion::text));
  v_obs := case when v_diff > 0 then 'Resultado mayor al consumo' else 'Consumo mayor al resultado' end;
  v_reg_at := coalesce(v_fabricacion.editado_at, v_fabricacion.registrado_at, now());
  v_reg_por := coalesce(v_fabricacion.editado_por, v_fabricacion.registrado_por, auth.uid());

  v_amount := round(v_abs_diff::numeric, 2);
  if v_diff > 0 then
    v_debit_account := v_cuenta_inventario;
    v_credit_account := v_account;
  else
    v_debit_account := v_account;
    v_credit_account := v_cuenta_inventario;
  end if;

  v_version := coalesce(v_fabricacion.contable_version, 1);
  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = p_idfabricacion
    and source_prefix = v_source_prefix;

  v_version := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;
  update public.fabricaciones
    set contable_version = v_version
  where id = p_idfabricacion;

  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = p_idfabricacion
      and source_prefix = v_source_prefix
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
  end loop;

  v_source_key := case
    when v_version = 1 then concat(v_source_prefix, ':', p_idfabricacion::text)
    else concat(v_source_prefix, ':', p_idfabricacion::text, ':v', v_version::text)
  end;
  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := p_idfabricacion,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_debit_account,
        'debit', v_amount,
        'credit', 0,
        'memo', v_obs,
        'line_source_key', 'debit'
      ),
      jsonb_build_object(
        'account_id', v_credit_account,
        'debit', 0,
        'credit', v_amount,
        'memo', v_obs,
        'line_source_key', 'credit'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  update public.fabricaciones
    set idasiento_ajuste = v_entry_id
  where id = p_idfabricacion;
end;
$$;

create or replace function public.fn_fabricaciones_touch_costos()
returns trigger
language plpgsql
as $$
declare
  v_idfabricacion uuid;
begin
  if pg_trigger_depth() > 1 then
    if tg_op = 'DELETE' then
      return old;
    else
      return new;
    end if;
  end if;

  v_idfabricacion := coalesce(new.idfabricacion, old.idfabricacion);
  if v_idfabricacion is not null then
    perform public.fn_fabricaciones_recalcular_costos(v_idfabricacion);
  end if;

  if tg_op = 'DELETE' then
    return old;
  else
    return new;
  end if;
end;
$$;

create trigger trg_fabricaciones_consumos_recalculo
after insert or update or delete on public.fabricaciones_consumos
for each row
execute function public.fn_fabricaciones_touch_costos();

create trigger trg_fabricaciones_resultados_recalculo
after insert or update or delete on public.fabricaciones_resultados
for each row
execute function public.fn_fabricaciones_touch_costos();

create or replace function public.fn_fabricaciones_block_edit_cancelada()
returns trigger
language plpgsql
as $$
begin
  if old.estado = 'cancelado' and pg_trigger_depth() = 1 then
    raise exception 'No se puede modificar una fabricación cancelada.';
  end if;
  return new;
end;
$$;

create trigger trg_fabricaciones_block_edit_cancelada
before update on public.fabricaciones
for each row
execute function public.fn_fabricaciones_block_edit_cancelada();

create or replace function public.fn_fabricaciones_detalle_block_cancelada()
returns trigger
language plpgsql
as $$
declare
  v_estado text;
  v_idfabricacion uuid;
begin
  v_idfabricacion := coalesce(new.idfabricacion, old.idfabricacion);
  if v_idfabricacion is null then
    if tg_op = 'DELETE' then
      return old;
    end if;
    return new;
  end if;
  select f.estado
    into v_estado
  from public.fabricaciones f
  where f.id = v_idfabricacion;
  if v_estado = 'cancelado' then
    raise exception 'No se puede modificar el detalle de una fabricación cancelada.';
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger trg_fabricaciones_consumos_block_cancelada
before insert or update or delete on public.fabricaciones_consumos
for each row
execute function public.fn_fabricaciones_detalle_block_cancelada();

create trigger trg_fabricaciones_resultados_block_cancelada
before insert or update or delete on public.fabricaciones_resultados
for each row
execute function public.fn_fabricaciones_detalle_block_cancelada();

create or replace function public.fn_fabricaciones_cleanup_movimientos()
returns trigger
language plpgsql
as $$
declare
  v_old record;
begin
  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = old.id
      and source_prefix = 'fabricacion_ajuste'
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, 'Fabricacion eliminada');
  end loop;
  return old;
end;
$$;

create trigger trg_fabricaciones_cleanup_movimientos
before delete on public.fabricaciones
for each row
execute function public.fn_fabricaciones_cleanup_movimientos();

create or replace function public.fn_costos_historial_from_fabricacion_resultado()
returns trigger
language plpgsql
as $$
declare
  v_base uuid;
  v_accion text;
  v_costo_unitario numeric(18,6);
  v_costo_total numeric(18,4);
begin
  if tg_op = 'UPDATE'
      and coalesce(current_setting('erp.skip_costos_historial', true), '') = '1' then
    return new;
  end if;
  if tg_op = 'UPDATE' then
    if new.idproducto is not distinct from old.idproducto
        and new.cantidad is not distinct from old.cantidad
        and new.idfabricacion is not distinct from old.idfabricacion
        and new.costo_unitario is not distinct from old.costo_unitario
        and new.costo_total is not distinct from old.costo_total then
      return new;
    end if;
  end if;

  if tg_op = 'DELETE' or tg_op = 'UPDATE' then
    select f.idbase
      into v_base
    from public.fabricaciones f
    where f.id = old.idfabricacion;
    perform public.fn_costos_historial_upsert(
      p_origen_tipo => 'fabricacion_resultado',
      p_detalle_id => old.id,
      p_origen_id => old.idfabricacion,
      p_idproducto => old.idproducto,
      p_idbase => v_base,
      p_cantidad => -coalesce(old.cantidad, 0),
      p_costo_unitario => coalesce(old.costo_unitario, 0),
      p_costo_total => -coalesce(old.costo_total, 0),
      p_registrado_at => coalesce(old.editado_at, old.registrado_at, now()),
      p_accion => 'cancelar'
    );
    if tg_op = 'DELETE' then
      return old;
    end if;
  end if;

  select f.idbase
    into v_base
  from public.fabricaciones f
  where f.id = new.idfabricacion;
  select fr.costo_unitario, fr.costo_total
    into v_costo_unitario, v_costo_total
  from public.fabricaciones_resultados fr
  where fr.id = new.id;
  v_costo_unitario := coalesce(v_costo_unitario, new.costo_unitario, 0);
  v_costo_total := coalesce(v_costo_total, new.costo_total, 0);
  v_accion := 'insert';
  perform public.fn_costos_historial_upsert(
    p_origen_tipo => 'fabricacion_resultado',
    p_detalle_id => new.id,
    p_origen_id => new.idfabricacion,
    p_idproducto => new.idproducto,
    p_idbase => v_base,
    p_cantidad => coalesce(new.cantidad, 0),
    p_costo_unitario => v_costo_unitario,
    p_costo_total => v_costo_total,
    p_registrado_at => coalesce(new.editado_at, new.registrado_at, now()),
    p_accion => v_accion
  );
  return new;
end;
$$;

drop trigger if exists trg_costos_historial_fabricacion_resultado
  on public.fabricaciones_resultados;
create trigger trg_z_costos_historial_fabricacion_resultado
after insert or update or delete on public.fabricaciones_resultados
for each row
execute function public.fn_costos_historial_from_fabricacion_resultado();

create sequence if not exists public.fabricaciones_maquila_correlativo_seq;

create table if not exists fabricaciones_maquila (
  id uuid primary key default gen_random_uuid(),
  correlativo bigint not null default nextval('public.fabricaciones_maquila_correlativo_seq'),
  idbase uuid not null references bases(id),
  idproveedor uuid references proveedores(id),
  observacion text,
  estado text not null default 'activo'
    check (estado in ('activo','cancelado')),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

do $$
declare
  v_max bigint;
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'fabricaciones_maquila'
      and column_name = 'correlativo'
  ) then
    alter table public.fabricaciones_maquila
      add column correlativo bigint;
  end if;
  alter table public.fabricaciones_maquila
    alter column correlativo
      set default nextval('public.fabricaciones_maquila_correlativo_seq');
  with base as (
    select coalesce(max(correlativo), 0) as offset
    from public.fabricaciones_maquila
    where correlativo is not null
  ),
  ordered as (
    select id, row_number() over (order by registrado_at, id) as rn
    from public.fabricaciones_maquila
    where correlativo is null
  )
  update public.fabricaciones_maquila f
  set correlativo = base.offset + ordered.rn
  from ordered, base
  where f.id = ordered.id;
  select coalesce(max(correlativo), 0)
    into v_max
  from public.fabricaciones_maquila;
  if v_max < 1 then
    perform setval('public.fabricaciones_maquila_correlativo_seq', 1, false);
  else
    perform setval('public.fabricaciones_maquila_correlativo_seq', v_max, true);
  end if;
  alter table public.fabricaciones_maquila
    alter column correlativo set not null;
end;
$$;

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'fabricaciones_maquila'
      and column_name = 'idasiento_inventario'
  ) then
    alter table public.fabricaciones_maquila
      add column idasiento_inventario uuid unique
        references gl_journal_entries(id) on delete set null;
  end if;
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'fabricaciones_maquila'
      and column_name = 'idasiento_pasivo'
  ) then
    alter table public.fabricaciones_maquila
      add column idasiento_pasivo uuid unique
        references gl_journal_entries(id) on delete set null;
  end if;
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'fabricaciones_maquila'
      and column_name = 'idasiento_ajuste'
  ) then
    alter table public.fabricaciones_maquila
      add column idasiento_ajuste uuid unique
        references gl_journal_entries(id) on delete set null;
  end if;
end;
$$;

alter table if exists public.fabricaciones_maquila
  add column if not exists contable_version integer not null default 1;

alter table if exists public.fabricaciones_maquila
  add column if not exists estado text not null default 'activo'
    check (estado in ('activo','cancelado'));

create table if not exists fabricaciones_maquila_consumos (
  id uuid primary key default gen_random_uuid(),
  idfabricacion uuid not null references fabricaciones_maquila(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(12,4) not null check (cantidad > 0),
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create index if not exists idx_fabricaciones_maquila_consumos_idfabricacion
  on public.fabricaciones_maquila_consumos(idfabricacion);

create table if not exists fabricaciones_maquila_resultados (
  id uuid primary key default gen_random_uuid(),
  idfabricacion uuid not null references fabricaciones_maquila(id) on delete cascade,
  idproducto uuid not null references productos(id),
  cantidad numeric(12,4) not null check (cantidad > 0),
  tipo_resultado text not null default 'principal'
    check (tipo_resultado in ('principal','secundario','subproducto','merma','producto')),
  costo_unitario numeric(12,6) not null default 0,
  costo_total numeric(14,4) not null default 0,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create index if not exists idx_fabricaciones_maquila_resultados_idfabricacion
  on public.fabricaciones_maquila_resultados(idfabricacion);

create index if not exists idx_fabricaciones_maquila_resultados_idfabricacion_producto
  on public.fabricaciones_maquila_resultados(idfabricacion, idproducto);

create or replace function public.fn_costos_historial_from_fabricacion_maquila_resultado()
returns trigger
language plpgsql
as $$
declare
  v_base uuid;
  v_accion text;
  v_costo_unitario numeric(18,6);
  v_costo_total numeric(18,4);
begin
  if tg_op = 'UPDATE'
      and coalesce(current_setting('erp.skip_costos_historial', true), '') = '1' then
    return new;
  end if;
  if tg_op = 'UPDATE' then
    if new.idproducto is not distinct from old.idproducto
        and new.cantidad is not distinct from old.cantidad
        and new.tipo_resultado is not distinct from old.tipo_resultado
        and new.idfabricacion is not distinct from old.idfabricacion
        and new.costo_unitario is not distinct from old.costo_unitario
        and new.costo_total is not distinct from old.costo_total then
      return new;
    end if;
  end if;

  if tg_op = 'DELETE' or tg_op = 'UPDATE' then
    select fm.idbase
      into v_base
    from public.fabricaciones_maquila fm
    where fm.id = old.idfabricacion;
    perform public.fn_costos_historial_upsert(
      p_origen_tipo => 'fabricacion_maquila_resultado',
      p_detalle_id => old.id,
      p_origen_id => old.idfabricacion,
      p_idproducto => old.idproducto,
      p_idbase => v_base,
      p_cantidad => -coalesce(old.cantidad, 0),
      p_costo_unitario => coalesce(old.costo_unitario, 0),
      p_costo_total => -coalesce(old.costo_total, 0),
      p_registrado_at => coalesce(old.editado_at, old.registrado_at, now()),
      p_accion => 'cancelar'
    );
    if tg_op = 'DELETE' then
      return old;
    end if;
  end if;

  select fm.idbase
    into v_base
  from public.fabricaciones_maquila fm
  where fm.id = new.idfabricacion;
  select fr.costo_unitario, fr.costo_total
    into v_costo_unitario, v_costo_total
  from public.fabricaciones_maquila_resultados fr
  where fr.id = new.id;
  v_costo_unitario := coalesce(v_costo_unitario, new.costo_unitario, 0);
  v_costo_total := coalesce(v_costo_total, new.costo_total, 0);
  v_accion := 'insert';
  perform public.fn_costos_historial_upsert(
    p_origen_tipo => 'fabricacion_maquila_resultado',
    p_detalle_id => new.id,
    p_origen_id => new.idfabricacion,
    p_idproducto => new.idproducto,
    p_idbase => v_base,
    p_cantidad => coalesce(new.cantidad, 0),
    p_costo_unitario => v_costo_unitario,
    p_costo_total => v_costo_total,
    p_registrado_at => coalesce(new.editado_at, new.registrado_at, now()),
    p_accion => v_accion
  );
  return new;
end;
$$;

drop trigger if exists trg_costos_historial_fabricacion_maquila_resultado
  on public.fabricaciones_maquila_resultados;
create trigger trg_z_costos_historial_fabricacion_maquila_resultado
after insert or update or delete on public.fabricaciones_maquila_resultados
for each row
execute function public.fn_costos_historial_from_fabricacion_maquila_resultado();

create table if not exists fabricaciones_maquila_costos (
  id uuid primary key default gen_random_uuid(),
  idfabricacion uuid not null references fabricaciones_maquila(id) on delete cascade,
  idcuenta uuid references cuentas_bancarias(id),
  idcuenta_contable uuid references cuentas_contables(id),
  concepto text not null,
  monto numeric(12,2) not null check (monto >= 0),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create or replace function public.fn_fabricaciones_maquila_recalcular_costos(
  p_idfabricacion uuid
)
returns void
language plpgsql
as $$
declare
  v_total_consumo numeric(18,6) := 0;
  v_total_resultado numeric(18,6) := 0;
  v_total_costos numeric(18,6) := 0;
  v_total_fuente numeric(18,6) := 0;
begin
  perform set_config('erp.skip_costos_historial', '1', true);
  select
      coalesce(
        sum(
          fc.cantidad * coalesce(public.fn_producto_costo_promedio(fc.idproducto), 0)
        ),
        0
      )
    into v_total_consumo
  from public.fabricaciones_maquila_consumos fc
  where fc.idfabricacion = p_idfabricacion;

  select coalesce(sum(g.monto), 0)
    into v_total_costos
  from public.fabricaciones_maquila_costos g
  where g.idfabricacion = p_idfabricacion;

  select coalesce(sum(fr.cantidad), 0)
    into v_total_resultado
  from public.fabricaciones_maquila_resultados fr
  where fr.idfabricacion = p_idfabricacion;

  v_total_fuente := v_total_consumo + v_total_costos;

  if v_total_resultado = 0 then
    update public.fabricaciones_maquila_resultados
      set costo_total = 0,
          costo_unitario = 0
    where idfabricacion = p_idfabricacion;
  else
    update public.fabricaciones_maquila_resultados fr
      set costo_total = round(
            case
              when v_total_fuente = 0 then 0
              else (fr.cantidad / v_total_resultado) * v_total_fuente
            end,
            4
          ),
          costo_unitario = case
            when fr.cantidad = 0 then 0
            else round(
              case
                when v_total_fuente = 0 then 0
                else ((fr.cantidad / v_total_resultado) * v_total_fuente) / fr.cantidad
              end,
              6
            )
          end
    where fr.idfabricacion = p_idfabricacion;
  end if;
  perform set_config('erp.skip_costos_historial', '0', true);
  perform public.fn_fabricaciones_maquila_sync_asientos(p_idfabricacion);
end;
$$;

create or replace function public.fn_fabricaciones_maquila_sync_asientos(
  p_idfabricacion uuid
)
returns void
language plpgsql
as $$
declare
  v_fabricacion fabricaciones_maquila%rowtype;
  v_total_consumo numeric(18,4) := 0;
  v_total_costos numeric(18,4) := 0;
  v_total_resultado numeric(18,4) := 0;
  v_total_fuente numeric(18,4) := 0;
  v_desc text;
  v_reg_at timestamptz;
  v_reg_por uuid;
  v_cuenta_inventario uuid;
  v_cuenta_pasivo uuid;
  v_cuenta_ajuste uuid;
  v_obs text;
  v_diff numeric(18,4);
  v_abs_diff numeric(18,4);
  v_amount numeric(18,4);
  v_inv_id uuid;
  v_pasivo_id uuid;
  v_ajuste_id uuid;
  v_motivo text;
  v_amount_total numeric(18,2);
  v_amount_diff numeric(18,2);
  v_source_prefix text;
  v_source_key text;
  v_entry_id uuid;
  v_debit_account uuid;
  v_credit_account uuid;
  v_old record;
  v_version_main integer;
  v_version_ajuste integer;
  v_max_version integer;
  v_contable_version integer;
begin
  select *
    into v_fabricacion
  from public.fabricaciones_maquila
  where id = p_idfabricacion;
  if not found then
    return;
  end if;

  select
      coalesce(
        sum(
          fc.cantidad * coalesce(public.fn_producto_costo_promedio(fc.idproducto), 0)
        ),
        0
      )
    into v_total_consumo
  from public.fabricaciones_maquila_consumos fc
  where fc.idfabricacion = p_idfabricacion;

  select coalesce(sum(g.monto), 0)
    into v_total_costos
  from public.fabricaciones_maquila_costos g
  where g.idfabricacion = p_idfabricacion;

  select coalesce(sum(fr.costo_total), 0)
    into v_total_resultado
  from public.fabricaciones_maquila_resultados fr
  where fr.idfabricacion = p_idfabricacion;

  v_total_fuente := v_total_consumo + v_total_costos;
  v_desc := concat('Fabricación maquila ', coalesce(v_fabricacion.observacion, p_idfabricacion::text));
  v_reg_at := coalesce(v_fabricacion.editado_at, v_fabricacion.registrado_at, now());
  v_reg_por := coalesce(v_fabricacion.editado_por, v_fabricacion.registrado_por, auth.uid());
  v_motivo := 'Recalculo fabricacion maquila';

  select id into v_cuenta_inventario
    from public.cuentas_contables
    where codigo = '20.01'
    limit 1;
  select id into v_cuenta_pasivo
    from public.cuentas_contables
    where codigo = '40.01'
    limit 1;
  select id into v_cuenta_ajuste
    from public.cuentas_contables
    where codigo = '80.02'
    limit 1;

  if v_total_resultado <= 0 then
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = p_idfabricacion
        and source_prefix in ('fabricacion_maquila', 'fabricacion_maquila_ajuste')
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;
    update public.fabricaciones_maquila
      set idasiento_inventario = null,
          idasiento_pasivo = null,
          idasiento_ajuste = null
    where id = p_idfabricacion;
    return;
  end if;

  v_version_main := coalesce(v_fabricacion.contable_version, 1);
  v_version_ajuste := v_version_main;
  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = p_idfabricacion
    and source_prefix = 'fabricacion_maquila';

  v_version_main := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;

  select coalesce(
      max(
        case
          when source_key ~ ':v[0-9]+$' then (regexp_match(source_key, ':v([0-9]+)$'))[1]::int
          else 1
        end
      ),
      0
    )
    into v_max_version
  from public.gl_journal_entries
  where source_id = p_idfabricacion
    and source_prefix = 'fabricacion_maquila_ajuste';

  v_version_ajuste := case
    when v_max_version >= 1 then v_max_version + 1
    else 1
  end;

  v_contable_version := greatest(v_version_main, v_version_ajuste);
  update public.fabricaciones_maquila
    set contable_version = v_contable_version
  where id = p_idfabricacion;

  v_amount_total := round(v_total_resultado::numeric, 2);
  v_source_prefix := 'fabricacion_maquila';
  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = p_idfabricacion
      and source_prefix = v_source_prefix
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
  end loop;
  v_source_key := case
    when v_version_main = 1 then concat(v_source_prefix, ':', p_idfabricacion::text)
    else concat(v_source_prefix, ':', p_idfabricacion::text, ':v', v_version_main::text)
  end;
  v_entry_id := public.fn_gl_create_entry(
    p_source_prefix := v_source_prefix,
    p_source_id := p_idfabricacion,
    p_source_key := v_source_key,
    p_descripcion := v_desc,
    p_lines := jsonb_build_array(
      jsonb_build_object(
        'account_id', v_cuenta_inventario,
        'debit', v_amount_total,
        'credit', 0,
        'memo', v_fabricacion.observacion,
        'line_source_key', 'inventario'
      ),
      jsonb_build_object(
        'account_id', v_cuenta_pasivo,
        'debit', 0,
        'credit', v_amount_total,
        'memo', v_fabricacion.observacion,
        'line_source_key', 'pasivo'
      )
    ),
    p_created_by := v_reg_por,
    p_post := true
  );

  v_inv_id := v_entry_id;
  v_pasivo_id := v_entry_id;

  v_diff := v_total_fuente - v_total_resultado;
  v_abs_diff := abs(v_diff);
  v_obs := case when v_diff > 0 then 'Fuente mayor al resultado' else 'Resultado mayor a la fuente' end;
  v_amount_diff := round(v_abs_diff::numeric, 2);

  v_source_prefix := 'fabricacion_maquila_ajuste';
  if v_abs_diff < 0.01 or v_cuenta_ajuste is null then
    v_ajuste_id := null;
    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = p_idfabricacion
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;
  else
    if v_diff > 0 then
      v_debit_account := v_cuenta_inventario;
      v_credit_account := v_cuenta_ajuste;
    else
      v_debit_account := v_cuenta_ajuste;
      v_credit_account := v_cuenta_inventario;
    end if;

    for v_old in
      select id
      from public.gl_journal_entries
      where source_id = p_idfabricacion
        and source_prefix = v_source_prefix
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_old.id, v_motivo);
    end loop;

    v_source_key := case
      when v_version_ajuste = 1 then concat(v_source_prefix, ':', p_idfabricacion::text)
      else concat(v_source_prefix, ':', p_idfabricacion::text, ':v', v_version_ajuste::text)
    end;
    v_ajuste_id := public.fn_gl_create_entry(
      p_source_prefix := v_source_prefix,
      p_source_id := p_idfabricacion,
      p_source_key := v_source_key,
      p_descripcion := v_desc,
      p_lines := jsonb_build_array(
        jsonb_build_object(
          'account_id', v_debit_account,
          'debit', v_amount_diff,
          'credit', 0,
          'memo', v_obs,
          'line_source_key', 'debit'
        ),
        jsonb_build_object(
          'account_id', v_credit_account,
          'debit', 0,
          'credit', v_amount_diff,
          'memo', v_obs,
          'line_source_key', 'credit'
        )
      ),
      p_created_by := v_reg_por,
      p_post := true
    );
  end if;

  update public.fabricaciones_maquila
    set idasiento_inventario = v_inv_id,
        idasiento_pasivo = v_pasivo_id,
        idasiento_ajuste = v_ajuste_id
  where id = p_idfabricacion;
end;
$$;

create or replace function public.fn_fabricaciones_maquila_touch_costos()
returns trigger
language plpgsql
as $$
declare
  v_idfabricacion uuid;
begin
  if pg_trigger_depth() > 1 then
    if tg_op = 'DELETE' then
      return old;
    else
      return new;
    end if;
  end if;

  v_idfabricacion := coalesce(new.idfabricacion, old.idfabricacion);
  if v_idfabricacion is not null then
    perform public.fn_fabricaciones_maquila_recalcular_costos(v_idfabricacion);
  end if;

  if tg_op = 'DELETE' then
    return old;
  else
    return new;
  end if;
end;
$$;

create trigger trg_fabricaciones_maquila_consumos_costos
after insert or update or delete on public.fabricaciones_maquila_consumos
for each row
execute function public.fn_fabricaciones_maquila_touch_costos();

create trigger trg_fabricaciones_maquila_resultados_costos
after insert or update or delete on public.fabricaciones_maquila_resultados
for each row
execute function public.fn_fabricaciones_maquila_touch_costos();

create trigger trg_fabricaciones_maquila_costos_costos
after insert or update or delete on public.fabricaciones_maquila_costos
for each row
execute function public.fn_fabricaciones_maquila_touch_costos();

create or replace function public.fn_fabricaciones_maquila_block_edit_cancelada()
returns trigger
language plpgsql
as $$
begin
  if old.estado = 'cancelado' and pg_trigger_depth() = 1 then
    raise exception 'No se puede modificar una fabricación maquila cancelada.';
  end if;
  return new;
end;
$$;

create trigger trg_fabricaciones_maquila_block_edit_cancelada
before update on public.fabricaciones_maquila
for each row
execute function public.fn_fabricaciones_maquila_block_edit_cancelada();

create or replace function public.fn_fabricaciones_maquila_detalle_block_cancelada()
returns trigger
language plpgsql
as $$
declare
  v_estado text;
  v_idfabricacion uuid;
begin
  v_idfabricacion := coalesce(new.idfabricacion, old.idfabricacion);
  if v_idfabricacion is null then
    if tg_op = 'DELETE' then
      return old;
    end if;
    return new;
  end if;
  select f.estado
    into v_estado
  from public.fabricaciones_maquila f
  where f.id = v_idfabricacion;
  if v_estado = 'cancelado' then
    raise exception
      'No se puede modificar el detalle de una fabricación maquila cancelada.';
  end if;
  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger trg_fabricaciones_maquila_consumos_block_cancelada
before insert or update or delete on public.fabricaciones_maquila_consumos
for each row
execute function public.fn_fabricaciones_maquila_detalle_block_cancelada();

create trigger trg_fabricaciones_maquila_resultados_block_cancelada
before insert or update or delete on public.fabricaciones_maquila_resultados
for each row
execute function public.fn_fabricaciones_maquila_detalle_block_cancelada();

create trigger trg_fabricaciones_maquila_costos_block_cancelada
before insert or update or delete on public.fabricaciones_maquila_costos
for each row
execute function public.fn_fabricaciones_maquila_detalle_block_cancelada();

create or replace function public.fn_fabricaciones_maquila_cleanup_movimientos()
returns trigger
language plpgsql
as $$
declare
  v_old record;
begin
  for v_old in
    select id
    from public.gl_journal_entries
    where source_id = old.id
      and source_prefix in ('fabricacion_maquila', 'fabricacion_maquila_ajuste')
      and estado = 'posted'
  loop
    perform public.fn_gl_reverse_entry(v_old.id, 'Fabricacion maquila eliminada');
  end loop;
  return old;
end;
$$;

create trigger trg_fabricaciones_maquila_cleanup_movimientos
before delete on public.fabricaciones_maquila
for each row
execute function public.fn_fabricaciones_maquila_cleanup_movimientos();

create or replace view public.v_fabricaciones_tipos as
select
  t.id,
  t.nombre,
  t.descripcion,
  t.icono,
  t.section_id,
  t.orden
from (
  values
    (
      'fabricacion_interna',
      'Fabricación interna',
      'Procesos internos que consumen un lote y generan múltiples productos.',
      'scatter_plot',
      'fabricaciones_internas',
      1
    ),
    (
      'fabricacion_maquila',
      'Fabricación por maquila',
      'Procesos tercerizados con costos adicionales y devoluciones variables.',
      'construction',
      'fabricaciones_maquila',
      2
    )
) as t(id, nombre, descripcion, icono, section_id, orden)
order by t.orden;

create or replace view public.v_fabricaciones_internas_vistageneral as
with consumos as (
  select
    c.idfabricacion,
    count(*)::int as consumos_registrados,
    coalesce(sum(c.cantidad), 0)::numeric(14,4) as total_consumido
  from public.fabricaciones_consumos c
  group by c.idfabricacion
),
resultados as (
  select
    r.idfabricacion,
    count(*)::int as productos_registrados,
    coalesce(sum(r.cantidad), 0)::numeric(14,4) as total_producido,
    coalesce(sum(r.costo_total), 0)::numeric(14,4) as total_valor
  from public.fabricaciones_resultados r
  group by r.idfabricacion
)
select
  f.id,
  f.idbase,
  b.nombre as base_nombre,
  f.idreceta,
  rec.nombre as receta_nombre,
  f.observacion,
  f.estado as estado_codigo,
  case
    when f.estado = 'cancelado' then 'Cancelado'
    else 'Activo'
  end as estado,
  coalesce(c.consumos_registrados, 0) as consumos_registrados,
  coalesce(c.total_consumido, 0)::numeric(14,4) as total_consumido,
  coalesce(r.productos_registrados, 0) as productos_registrados,
  coalesce(r.total_producido, 0)::numeric(14,4) as total_producido,
  coalesce(r.total_valor, 0)::numeric(14,4) as total_valor,
  f.registrado_at,
  f.editado_at,
  f.registrado_por,
  f.editado_por
from public.fabricaciones f
left join public.bases b on b.id = f.idbase
left join public.recetas rec on rec.id = f.idreceta
left join consumos c on c.idfabricacion = f.id
left join resultados r on r.idfabricacion = f.id;

create or replace view public.v_fabricaciones_internas_consumos as
select
  c.id,
  c.idfabricacion,
  c.idproducto,
  p.nombre as producto_nombre,
  c.cantidad,
  c.registrado_at,
  c.editado_at,
  c.registrado_por,
  c.editado_por
from public.fabricaciones_consumos c
left join public.productos p on p.id = c.idproducto;

create or replace view public.v_fabricaciones_internas_resultados as
select
  r.id,
  r.idfabricacion,
  r.idproducto,
  p.nombre as producto_nombre,
  r.cantidad,
  r.costo_unitario,
  r.costo_total,
  r.registrado_at,
  r.editado_at,
  r.registrado_por,
  r.editado_por
from public.fabricaciones_resultados r
left join public.productos p on p.id = r.idproducto;

create or replace view public.v_fabricaciones_maquila_vistageneral as
with consumos as (
  select
    c.idfabricacion,
    count(*)::int as consumos_registrados,
    coalesce(sum(c.cantidad), 0)::numeric(14,4) as total_consumido
  from public.fabricaciones_maquila_consumos c
  group by c.idfabricacion
),
resultados as (
  select
    r.idfabricacion,
    count(*)::int as productos_registrados,
    coalesce(sum(r.cantidad), 0)::numeric(14,4) as total_producido,
    coalesce(sum(r.costo_total), 0)::numeric(14,4) as total_valor
  from public.fabricaciones_maquila_resultados r
  group by r.idfabricacion
),
costos as (
  select
    g.idfabricacion,
    count(*)::int as costos_registrados,
    coalesce(sum(g.monto), 0)::numeric(14,2) as total_costos
  from public.fabricaciones_maquila_costos g
  group by g.idfabricacion
)
select
  f.id,
  f.idbase,
  b.nombre as base_nombre,
  f.idproveedor,
  p.nombre as proveedor_nombre,
  f.observacion,
  f.estado as estado_codigo,
  coalesce(c.consumos_registrados, 0) as consumos_registrados,
  coalesce(c.total_consumido, 0)::numeric(14,4) as total_consumido,
  coalesce(r.productos_registrados, 0) as productos_registrados,
  coalesce(r.total_producido, 0)::numeric(14,4) as total_producido,
  coalesce(r.total_valor, 0)::numeric(14,4) as total_valor,
  coalesce(g.costos_registrados, 0) as costos_registrados,
  coalesce(g.total_costos, 0)::numeric(14,2) as total_costos,
  case
    when f.estado = 'cancelado' then 'Cancelado'
    when coalesce(r.productos_registrados, 0) = 0 then 'Pendiente'
    else 'Completado'
  end as estado,
  f.registrado_at,
  f.editado_at,
  f.registrado_por,
  f.editado_por
from public.fabricaciones_maquila f
left join public.bases b on b.id = f.idbase
left join public.proveedores p on p.id = f.idproveedor
left join consumos c on c.idfabricacion = f.id
left join resultados r on r.idfabricacion = f.id
left join costos g on g.idfabricacion = f.id;

create or replace view public.v_fabricaciones_maquila_consumos as
select
  c.id,
  c.idfabricacion,
  c.idproducto,
  p.nombre as producto_nombre,
  c.cantidad,
  c.registrado_at,
  c.editado_at,
  c.registrado_por,
  c.editado_por
from public.fabricaciones_maquila_consumos c
left join public.productos p on p.id = c.idproducto;

create or replace view public.v_fabricaciones_maquila_resultados as
select
  r.id,
  r.idfabricacion,
  r.idproducto,
  p.nombre as producto_nombre,
  r.cantidad,
  r.tipo_resultado,
  r.costo_unitario,
  r.costo_total,
  r.registrado_at,
  r.editado_at,
  r.registrado_por,
  r.editado_por
from public.fabricaciones_maquila_resultados r
left join public.productos p on p.id = r.idproducto;


-------------------------------------------------
-- 7. MÓDULO 3 · FINANZAS / CONTABILIDAD
-------------------------------------------------

-------------------------------------------------
-- INVENTARIO · COSTO PROMEDIO PERPETUO
-------------------------------------------------

create table if not exists public.inventario_saldos (
  idproducto uuid primary key references productos(id),
  qty_saldo numeric(18,6) not null default 0,
  valor_saldo numeric(18,4) not null default 0,
  costo_promedio numeric(18,6) not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists public.inventario_eventos_valorizados (
  id uuid primary key default gen_random_uuid(),
  evento_tipo text not null,
  origen_tabla text not null,
  origen_id uuid,
  detalle_id uuid,
  fecha_evento timestamptz not null default now(),
  idproducto uuid not null references productos(id),
  idbase uuid references bases(id),
  qty numeric(18,6) not null,
  costo_unitario_aplicado numeric(18,6) not null,
  valor numeric(18,4) not null,
  created_at timestamptz not null default now(),
  anulado_at timestamptz,
  check (qty <> 0),
  check (costo_unitario_aplicado >= 0)
);

create index if not exists idx_inventario_eventos_producto_fecha
  on public.inventario_eventos_valorizados (idproducto, fecha_evento);

create index if not exists idx_inventario_eventos_origen
  on public.inventario_eventos_valorizados (origen_tabla, detalle_id);

create unique index if not exists idx_inventario_eventos_activo
  on public.inventario_eventos_valorizados (origen_tabla, detalle_id, evento_tipo)
  where anulado_at is null;

create or replace function public.fn_inventario_aplicar_evento(
  p_evento_tipo text,
  p_origen_tabla text,
  p_origen_id uuid,
  p_detalle_id uuid,
  p_fecha_evento timestamptz,
  p_idproducto uuid,
  p_idbase uuid default null,
  p_qty numeric default null,
  p_costo_unitario numeric default null,
  p_allow_negative boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event_id uuid;
  v_existing public.inventario_eventos_valorizados%rowtype;
  v_saldo public.inventario_saldos%rowtype;
  v_qty numeric(18,6);
  v_unit numeric(18,6);
  v_valor numeric(18,4);
  v_new_qty numeric(18,6);
  v_new_valor numeric(18,4);
  v_new_costo numeric(18,6);
begin
  if p_idproducto is null then
    raise exception 'idproducto requerido para evento de inventario.';
  end if;

  v_qty := coalesce(p_qty, 0);
  if v_qty = 0 then
    return null;
  end if;

  select *
    into v_existing
  from public.inventario_eventos_valorizados
  where origen_tabla = p_origen_tabla
    and detalle_id = p_detalle_id
    and evento_tipo = p_evento_tipo
    and anulado_at is null
  order by created_at desc
  limit 1
  for update;

  if found then
    if v_existing.idproducto = p_idproducto
        and v_existing.idbase is not distinct from p_idbase
        and v_existing.qty = v_qty
        and (
          p_costo_unitario is null
          or v_existing.costo_unitario_aplicado = p_costo_unitario
        ) then
      return v_existing.id;
    end if;
    perform public.fn_inventario_reversar_evento(
      p_origen_tabla,
      p_detalle_id,
      p_evento_tipo,
      p_allow_negative
    );
  end if;

  insert into public.inventario_saldos (idproducto)
  values (p_idproducto)
  on conflict (idproducto) do nothing;

  select *
    into v_saldo
  from public.inventario_saldos
  where idproducto = p_idproducto
  for update;

  if v_qty < 0 then
    v_unit := coalesce(v_saldo.costo_promedio, 0);
  else
    if p_costo_unitario is null then
      raise exception 'Costo unitario requerido para entradas de inventario.';
    end if;
    v_unit := p_costo_unitario;
  end if;

  v_valor := round(v_qty * v_unit, 4);
  v_new_qty := coalesce(v_saldo.qty_saldo, 0) + v_qty;
  v_new_valor := coalesce(v_saldo.valor_saldo, 0) + v_valor;

  if v_new_qty < 0 and not p_allow_negative then
    raise exception
      'Stock negativo no permitido para producto % (saldo %.6f, ajuste %.6f).',
      p_idproducto,
      coalesce(v_saldo.qty_saldo, 0),
      v_qty;
  end if;

  if v_new_qty = 0 then
    v_new_valor := 0;
    v_new_costo := 0;
  else
    v_new_costo := round(v_new_valor / v_new_qty, 6);
  end if;

  update public.inventario_saldos
    set qty_saldo = v_new_qty,
        valor_saldo = v_new_valor,
        costo_promedio = v_new_costo,
        updated_at = now()
  where idproducto = p_idproducto;

  insert into public.inventario_eventos_valorizados (
    evento_tipo,
    origen_tabla,
    origen_id,
    detalle_id,
    fecha_evento,
    idproducto,
    idbase,
    qty,
    costo_unitario_aplicado,
    valor
  )
  values (
    p_evento_tipo,
    p_origen_tabla,
    p_origen_id,
    p_detalle_id,
    coalesce(p_fecha_evento, now()),
    p_idproducto,
    p_idbase,
    v_qty,
    v_unit,
    v_valor
  )
  returning id into v_event_id;

  return v_event_id;
end;
$$;

create or replace function public.fn_inventario_reversar_evento(
  p_origen_tabla text,
  p_detalle_id uuid,
  p_evento_tipo text,
  p_allow_negative boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event public.inventario_eventos_valorizados%rowtype;
  v_saldo public.inventario_saldos%rowtype;
  v_new_qty numeric(18,6);
  v_new_valor numeric(18,4);
  v_new_costo numeric(18,6);
begin
  if p_detalle_id is null then
    return null;
  end if;

  select *
    into v_event
  from public.inventario_eventos_valorizados
  where origen_tabla = p_origen_tabla
    and detalle_id = p_detalle_id
    and evento_tipo = p_evento_tipo
    and anulado_at is null
  order by created_at desc
  limit 1
  for update;

  if not found then
    return null;
  end if;

  select *
    into v_saldo
  from public.inventario_saldos
  where idproducto = v_event.idproducto
  for update;

  v_new_qty := coalesce(v_saldo.qty_saldo, 0) - v_event.qty;
  v_new_valor := coalesce(v_saldo.valor_saldo, 0) - v_event.valor;

  if v_new_qty < 0 and not p_allow_negative then
    raise exception
      'Stock negativo no permitido al revertir evento % (producto %).',
      v_event.id,
      v_event.idproducto;
  end if;

  if v_new_qty = 0 then
    v_new_valor := 0;
    v_new_costo := 0;
  else
    v_new_costo := round(v_new_valor / v_new_qty, 6);
  end if;

  update public.inventario_saldos
    set qty_saldo = v_new_qty,
        valor_saldo = v_new_valor,
        costo_promedio = v_new_costo,
        updated_at = now()
  where idproducto = v_event.idproducto;

  update public.inventario_eventos_valorizados
    set anulado_at = now()
  where id = v_event.id;

  return v_event.id;
end;
$$;

create or replace function public.fn_inventario_evt_compras_mov_detalle()
returns trigger
language plpgsql
as $$
declare
  v_base uuid;
  v_es_reversion boolean;
  v_fecha timestamptz;
  v_qty numeric(18,6);
begin
  if tg_op = 'DELETE' then
    perform public.fn_inventario_reversar_evento(
      'compras_movimientos',
      old.id,
      'compra_recepcion'
    );
    return old;
  end if;

  if tg_op = 'UPDATE' then
    if new.idproducto is not distinct from old.idproducto
       and new.cantidad is not distinct from old.cantidad
       and new.costo_unitario is not distinct from old.costo_unitario
       and new.idmovimiento is not distinct from old.idmovimiento then
      return new;
    end if;
    perform public.fn_inventario_reversar_evento(
      'compras_movimientos',
      old.id,
      'compra_recepcion'
    );
  end if;

  select idbase, es_reversion, registrado_at
    into v_base, v_es_reversion, v_fecha
  from public.compras_movimientos
  where id = new.idmovimiento;

  if not found then
    return new;
  end if;

  v_qty := case when v_es_reversion then -new.cantidad else new.cantidad end;

  perform public.fn_inventario_aplicar_evento(
    p_evento_tipo := 'compra_recepcion',
    p_origen_tabla := 'compras_movimientos',
    p_origen_id := new.idmovimiento,
    p_detalle_id := new.id,
    p_fecha_evento := coalesce(new.editado_at, new.registrado_at, v_fecha),
    p_idproducto := new.idproducto,
    p_idbase := v_base,
    p_qty := v_qty,
    p_costo_unitario := new.costo_unitario,
    p_allow_negative := false
  );

  return new;
end;
$$;

create or replace function public.fn_inventario_evt_fabricaciones_resultados()
returns trigger
language plpgsql
as $$
declare
  v_base uuid;
  v_fecha timestamptz;
  v_costo_unitario numeric(18,6);
begin
  if tg_op = 'DELETE' then
    perform public.fn_inventario_reversar_evento(
      'fabricaciones',
      old.id,
      'fabricacion_resultado'
    );
    return old;
  end if;

  if tg_op = 'UPDATE' then
    if new.idproducto is not distinct from old.idproducto
       and new.cantidad is not distinct from old.cantidad
       and new.costo_unitario is not distinct from old.costo_unitario
       and new.idfabricacion is not distinct from old.idfabricacion then
      return new;
    end if;
    perform public.fn_inventario_reversar_evento(
      'fabricaciones',
      old.id,
      'fabricacion_resultado'
    );
  end if;

  select idbase, registrado_at
    into v_base, v_fecha
  from public.fabricaciones
  where id = new.idfabricacion;

  if not found then
    return new;
  end if;

  select fr.costo_unitario
    into v_costo_unitario
  from public.fabricaciones_resultados fr
  where fr.id = new.id;
  v_costo_unitario := coalesce(v_costo_unitario, new.costo_unitario, 0);

  perform public.fn_inventario_aplicar_evento(
    p_evento_tipo := 'fabricacion_resultado',
    p_origen_tabla := 'fabricaciones',
    p_origen_id := new.idfabricacion,
    p_detalle_id := new.id,
    p_fecha_evento := coalesce(new.editado_at, new.registrado_at, v_fecha),
    p_idproducto := new.idproducto,
    p_idbase := v_base,
    p_qty := new.cantidad,
    p_costo_unitario := v_costo_unitario,
    p_allow_negative := false
  );

  return new;
end;
$$;

create or replace function public.fn_inventario_evt_fabricaciones_maquila_resultados()
returns trigger
language plpgsql
as $$
declare
  v_base uuid;
  v_fecha timestamptz;
  v_costo_unitario numeric(18,6);
begin
  if tg_op = 'DELETE' then
    perform public.fn_inventario_reversar_evento(
      'fabricaciones_maquila',
      old.id,
      'fabricacion_maquila_resultado'
    );
    return old;
  end if;

  if tg_op = 'UPDATE' then
    if new.idproducto is not distinct from old.idproducto
       and new.cantidad is not distinct from old.cantidad
       and new.costo_unitario is not distinct from old.costo_unitario
       and new.idfabricacion is not distinct from old.idfabricacion then
      return new;
    end if;
    perform public.fn_inventario_reversar_evento(
      'fabricaciones_maquila',
      old.id,
      'fabricacion_maquila_resultado'
    );
  end if;

  select idbase, registrado_at
    into v_base, v_fecha
  from public.fabricaciones_maquila
  where id = new.idfabricacion;

  if not found then
    return new;
  end if;

  select fr.costo_unitario
    into v_costo_unitario
  from public.fabricaciones_maquila_resultados fr
  where fr.id = new.id;
  v_costo_unitario := coalesce(v_costo_unitario, new.costo_unitario, 0);

  perform public.fn_inventario_aplicar_evento(
    p_evento_tipo := 'fabricacion_maquila_resultado',
    p_origen_tabla := 'fabricaciones_maquila',
    p_origen_id := new.idfabricacion,
    p_detalle_id := new.id,
    p_fecha_evento := coalesce(new.editado_at, new.registrado_at, v_fecha),
    p_idproducto := new.idproducto,
    p_idbase := v_base,
    p_qty := new.cantidad,
    p_costo_unitario := v_costo_unitario,
    p_allow_negative := false
  );

  return new;
end;
$$;

create or replace function public.fn_inventario_evt_ajustes_detalle()
returns trigger
language plpgsql
as $$
declare
  v_base uuid;
  v_fecha timestamptz;
begin
  if tg_op = 'DELETE' then
    perform public.fn_inventario_reversar_evento(
      'ajustes',
      old.id,
      'ajuste'
    );
    return old;
  end if;

  if tg_op = 'UPDATE' then
    if new.idproducto is not distinct from old.idproducto
       and new.cantidad is not distinct from old.cantidad
       and new.costo_unitario is not distinct from old.costo_unitario
       and new.idajuste is not distinct from old.idajuste then
      return new;
    end if;
    perform public.fn_inventario_reversar_evento(
      'ajustes',
      old.id,
      'ajuste'
    );
  end if;

  if new.cantidad is null then
    return new;
  end if;

  select idbase, registrado_at
    into v_base, v_fecha
  from public.ajustes
  where id = new.idajuste;

  if not found then
    return new;
  end if;

  perform public.fn_inventario_aplicar_evento(
    p_evento_tipo := 'ajuste',
    p_origen_tabla := 'ajustes',
    p_origen_id := new.idajuste,
    p_detalle_id := new.id,
    p_fecha_evento := coalesce(new.editado_at, new.registrado_at, v_fecha),
    p_idproducto := new.idproducto,
    p_idbase := v_base,
    p_qty := new.cantidad,
    p_costo_unitario := new.costo_unitario,
    p_allow_negative := false
  );

  return new;
end;
$$;

create trigger trg_inventario_compras_mov_detalle
after insert or update or delete on public.compras_movimiento_detalle
for each row
execute function public.fn_inventario_evt_compras_mov_detalle();

drop trigger if exists trg_inventario_fabricaciones_resultados
  on public.fabricaciones_resultados;
create trigger trg_z_inventario_fabricaciones_resultados
after insert or update or delete on public.fabricaciones_resultados
for each row
execute function public.fn_inventario_evt_fabricaciones_resultados();

drop trigger if exists trg_inventario_fabricaciones_maquila_resultados
  on public.fabricaciones_maquila_resultados;
create trigger trg_z_inventario_fabricaciones_maquila_resultados
after insert or update or delete on public.fabricaciones_maquila_resultados
for each row
execute function public.fn_inventario_evt_fabricaciones_maquila_resultados();

create trigger trg_inventario_ajustes_detalle
after insert or update or delete on public.ajustes_detalle
for each row
execute function public.fn_inventario_evt_ajustes_detalle();

create or replace function public.fn_fabricaciones_cancelar()
returns trigger
language plpgsql
as $$
declare
  v_row record;
  v_motivo text := 'Fabricación cancelada';
begin
  if tg_op <> 'UPDATE' then
    return new;
  end if;

  if new.estado = 'cancelado' and old.estado is distinct from new.estado then
    for v_row in
      select
        fr.id,
        fr.idproducto,
        fr.cantidad,
        fr.costo_unitario,
        fr.costo_total
      from public.fabricaciones_resultados fr
      where fr.idfabricacion = new.id
    loop
      perform public.fn_inventario_reversar_evento(
        'fabricaciones',
        v_row.id,
        'fabricacion_resultado'
      );
      perform public.fn_costos_historial_upsert(
        p_origen_tipo => 'fabricacion_resultado',
        p_detalle_id => v_row.id,
        p_origen_id => new.id,
        p_idproducto => v_row.idproducto,
        p_idbase => new.idbase,
        p_cantidad => -coalesce(v_row.cantidad, 0),
        p_costo_unitario => coalesce(v_row.costo_unitario, 0),
        p_costo_total => -coalesce(v_row.costo_total, 0),
        p_registrado_at => coalesce(new.editado_at, now()),
        p_accion => 'cancelar'
      );
    end loop;

    for v_row in
      select id
      from public.gl_journal_entries
      where source_id = new.id
        and source_prefix = 'fabricacion_ajuste'
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_row.id, v_motivo);
    end loop;

    update public.fabricaciones
      set idasiento_ajuste = null
    where id = new.id;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_fabricaciones_cancelar
  on public.fabricaciones;
create trigger trg_fabricaciones_cancelar
after update of estado on public.fabricaciones
for each row
when (old.estado is distinct from new.estado)
execute function public.fn_fabricaciones_cancelar();

create or replace function public.fn_fabricaciones_maquila_cancelar()
returns trigger
language plpgsql
as $$
declare
  v_row record;
  v_motivo text := 'Fabricación maquila cancelada';
begin
  if tg_op <> 'UPDATE' then
    return new;
  end if;

  if new.estado = 'cancelado' and old.estado is distinct from new.estado then
    for v_row in
      select
        fmr.id,
        fmr.idproducto,
        fmr.cantidad,
        fmr.costo_unitario,
        fmr.costo_total
      from public.fabricaciones_maquila_resultados fmr
      where fmr.idfabricacion = new.id
    loop
      perform public.fn_inventario_reversar_evento(
        'fabricaciones_maquila',
        v_row.id,
        'fabricacion_maquila_resultado'
      );
      perform public.fn_costos_historial_upsert(
        p_origen_tipo => 'fabricacion_maquila_resultado',
        p_detalle_id => v_row.id,
        p_origen_id => new.id,
        p_idproducto => v_row.idproducto,
        p_idbase => new.idbase,
        p_cantidad => -coalesce(v_row.cantidad, 0),
        p_costo_unitario => coalesce(v_row.costo_unitario, 0),
        p_costo_total => -coalesce(v_row.costo_total, 0),
        p_registrado_at => coalesce(new.editado_at, now()),
        p_accion => 'cancelar'
      );
    end loop;

    for v_row in
      select id
      from public.gl_journal_entries
      where source_id = new.id
        and source_prefix in ('fabricacion_maquila', 'fabricacion_maquila_ajuste')
        and estado = 'posted'
    loop
      perform public.fn_gl_reverse_entry(v_row.id, v_motivo);
    end loop;

    update public.fabricaciones_maquila
      set idasiento_inventario = null,
          idasiento_pasivo = null,
          idasiento_ajuste = null
    where id = new.id;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_fabricaciones_maquila_cancelar
  on public.fabricaciones_maquila;
create trigger trg_fabricaciones_maquila_cancelar
after update of estado on public.fabricaciones_maquila
for each row
when (old.estado is distinct from new.estado)
execute function public.fn_fabricaciones_maquila_cancelar();

create or replace function public.fn_rebuild_inventario_saldos_desde_historico(
  p_allow_negative boolean default true
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row record;
begin
  truncate table public.inventario_eventos_valorizados;
  truncate table public.inventario_saldos;

  for v_row in
    select
      'compra_recepcion'::text as evento_tipo,
      'compras_movimientos'::text as origen_tabla,
      cm.id as origen_id,
      cmd.id as detalle_id,
      coalesce(cmd.editado_at, cmd.registrado_at, cm.registrado_at) as fecha_evento,
      cmd.idproducto,
      cm.idbase,
      case when cm.es_reversion then -cmd.cantidad else cmd.cantidad end
        as qty,
      cmd.costo_unitario as costo_unitario
    from public.compras_movimiento_detalle cmd
    join public.compras_movimientos cm on cm.id = cmd.idmovimiento
    union all
    select
      'fabricacion_resultado',
      'fabricaciones',
      fr.idfabricacion,
      fr.id,
      coalesce(fr.editado_at, fr.registrado_at, f.registrado_at),
      fr.idproducto,
      f.idbase,
      fr.cantidad,
      fr.costo_unitario
    from public.fabricaciones_resultados fr
    join public.fabricaciones f on f.id = fr.idfabricacion
    where f.estado = 'activo'
    union all
    select
      'fabricacion_maquila_resultado',
      'fabricaciones_maquila',
      fmr.idfabricacion,
      fmr.id,
      coalesce(fmr.editado_at, fmr.registrado_at, fm.registrado_at),
      fmr.idproducto,
      fm.idbase,
      fmr.cantidad,
      fmr.costo_unitario
    from public.fabricaciones_maquila_resultados fmr
    join public.fabricaciones_maquila fm on fm.id = fmr.idfabricacion
    where fm.estado = 'activo'
    union all
    select
      'ajuste',
      'ajustes',
      ad.idajuste,
      ad.id,
      coalesce(ad.editado_at, ad.registrado_at, a.registrado_at),
      ad.idproducto,
      a.idbase,
      ad.cantidad,
      ad.costo_unitario
    from public.ajustes_detalle ad
    join public.ajustes a on a.id = ad.idajuste
    where ad.cantidad is not null
    order by fecha_evento, origen_tabla, detalle_id
  loop
    perform public.fn_inventario_aplicar_evento(
      p_evento_tipo := v_row.evento_tipo,
      p_origen_tabla := v_row.origen_tabla,
      p_origen_id := v_row.origen_id,
      p_detalle_id := v_row.detalle_id,
      p_fecha_evento := v_row.fecha_evento,
      p_idproducto := v_row.idproducto,
      p_idbase := v_row.idbase,
      p_qty := v_row.qty,
      p_costo_unitario := v_row.costo_unitario,
      p_allow_negative := p_allow_negative
    );
  end loop;
end;
$$;

-------------------------------------------------
-- VISTA AUXILIAR · COSTO PROMEDIO POR PRODUCTO
-------------------------------------------------

create or replace view public.v_productos_costo_promedio as
select
  s.idproducto,
  s.qty_saldo as cantidad_total,
  s.valor_saldo as valor_total,
  s.costo_promedio
from public.inventario_saldos s;

-------------------------------------------------
-- FUNCIONES · MÓDULO 2 (Costos promedio)
-------------------------------------------------

create or replace function public.fn_producto_costo_promedio(p_idproducto uuid)
returns numeric
language sql
stable
set search_path = public
as $$
  select coalesce(
    (
      select s.costo_promedio
      from public.inventario_saldos s
      where s.idproducto = p_idproducto
    ),
    0
  );
$$;

-------------------------------------------------
-- FUNCIONES / TRIGGERS PARA DETALLEPEDIDOS
-------------------------------------------------
create or replace function detallepedidos_calcular_total()
returns trigger
language plpgsql
as $$
declare
  v_idlista uuid;
  v_unit    numeric(12,6);
begin
  -- Solo proceder si hay producto y cantidad
  if new.idproducto is null or new.cantidad is null then
    return new;
  end if;

  -- 1) Lista del pedido
  select p.idlista_precios
    into v_idlista
  from pedidos p
  where p.id = coalesce(new.idpedido, old.idpedido);

  -- Si el pedido no tiene lista, salimos sin modificar
  if v_idlista is null then
    return new;
  end if;

  -- 2) Escalón aplicable: mayor <= cantidad; si no hay, menor disponible
  select lpd.precio_unitario
    into v_unit
  from lista_precios_det lpd
  where lpd.idlista = v_idlista
    and lpd.idproducto = new.idproducto
    and lpd.cantidad_escalon <= new.cantidad
  order by lpd.cantidad_escalon desc
  limit 1;

  if v_unit is null then
    select lpd.precio_unitario
      into v_unit
    from lista_precios_det lpd
    where lpd.idlista = v_idlista
      and lpd.idproducto = new.idproducto
    order by lpd.cantidad_escalon asc
    limit 1;
  end if;

  if v_unit is null then
    -- No hay escalones cargados para ese producto en esa lista
    return new;
  end if;

  -- 3) Calcular TOTAL = unitario * cantidad
  if tg_op = 'INSERT' then
    if new.precioventa is null then
      new.precioventa := round(v_unit * new.cantidad, 2);
    end if;
    return new;
  end if;

  if tg_op = 'UPDATE' then
    if (new.idproducto is distinct from old.idproducto)
       or (new.cantidad   is distinct from old.cantidad) then
      -- Recalcula solo si no envías un nuevo total explícito
      if new.precioventa is null or new.precioventa = old.precioventa then
        new.precioventa := round(v_unit * new.cantidad, 2);
      end if;
    end if;
    return new;
  end if;

  return new;
end;
$$;

create trigger trg_detallepedidos_calcular_total
before insert or update on detallepedidos
for each row
execute function detallepedidos_calcular_total();
-------------------------------------------------
-- FIN TABLAS MAESTRAS / INICIO VISTAS
-- (de aquí hacia abajo solo definimos vistas/reportes)
-------------------------------------------------

-------------------------------------------------
-- 8. MÓDULO REPORTES / CAPA DE CONSULTA
-------------------------------------------------

-------------------------------------------------
-- VISTAS · MÓDULO 1 (Pedidos / Finanzas)
-------------------------------------------------

-- 7.1 Pedidos · Totales y estados básicos
-------------------------------------------------

create or replace view public.v_pedidoestadopago_detallepedido as
select  p.id as pedido_id,
        coalesce(sum(dp.precioventa), 0)::numeric(12,2) as total_pedido
from public.pedidos p
left join public.v_detallepedidos_ajustado dp on dp.idpedido = p.id
group by p.id;

-- Total pagado por el cliente
create or replace view public.v_pedidoestadopago_pagados as
select  p.id as pedido_id,
        coalesce(sum(pg.monto), 0)::numeric(12,2) as total_pagado
from public.pedidos p
left join public.pagos pg
  on pg.idpedido = p.id
 and pg.estado = 'activo'
group by p.id;

-- Total de cargos por devoluciones (penalidad + monto_ida + monto_vuelta)
create or replace view public.v_pedidosestadopago_cargo as
select  c.idpedido,
        c.total_penalidad,
        c.total_monto_ida,
        c.total_monto_vuelta,
        (
          c.total_penalidad
          + c.total_monto_ida
          + c.total_monto_vuelta
        )::numeric(12,2) as total_cargos_cliente
from (
  select  p.id as idpedido,
          coalesce(sum(coalesce(vd.penalidad,0)), 0)::numeric(12,2) as total_penalidad,
          coalesce(sum(coalesce(vd.monto_ida,0)), 0)::numeric(12,2) as total_monto_ida,
          coalesce(sum(coalesce(vd.monto_vuelta,0)), 0)::numeric(12,2) as total_monto_vuelta
  from public.pedidos p
  left join public.viajes_devueltos vd
    on vd.idpedido = p.id
   and vd.estado = 'devuelto_base'
  group by p.id
) c;

-- Recargo por provincia: S/ 50.00 por cada movimiento es_provincia = true
create or replace view public.v_pedidoestadopago_provincia as
with prov as (
  select m.idpedido, count(*)::int as n_movs_prov
  from public.movimientopedidos m
  where m.es_provincia = true
    and m.estado = 'activo'
  group by m.idpedido
)
select  p.id as pedido_id,
        (coalesce(prov.n_movs_prov,0) * 50.00)::numeric(12,2) as total_recargo_provincia
from public.pedidos p
left join prov on prov.idpedido = p.id;


-------------------------------------------------------------
-- CAPA 2: Estado financiero/pago integrado
-------------------------------------------------------------
create or replace view public.v_pedidoestadopago as
select  p.id as pedido_id,
        p.idcliente,
        p.registrado_at as fecharegistro,
        t.total_pedido,
        cp.total_penalidad,
        cp.total_monto_ida,
        cp.total_monto_vuelta,
        cp.total_cargos_cliente,
        rp.total_recargo_provincia,
        pg.total_pagado,
        (
          case
            when p.estado_admin <> 'activo' or p.estado <> 'activo' then 0
            else coalesce(t.total_pedido,0)
               + coalesce(cp.total_cargos_cliente,0)
               + coalesce(rp.total_recargo_provincia,0)
          end
        )::numeric(12,2) as total_con_cargos,
        (
          (
            case
              when p.estado_admin <> 'activo' or p.estado <> 'activo' then 0
              else coalesce(t.total_pedido,0)
                 + coalesce(cp.total_cargos_cliente,0)
                 + coalesce(rp.total_recargo_provincia,0)
            end
          )
        - coalesce(pg.total_pagado,0)
        )::numeric(12,2) as saldo,
        case
          when coalesce(pg.total_pagado,0) = 0 then 'pendiente'
          when (
            (
              case
                when p.estado_admin <> 'activo' or p.estado <> 'activo' then 0
                else coalesce(t.total_pedido,0)
                   + coalesce(cp.total_cargos_cliente,0)
                   + coalesce(rp.total_recargo_provincia,0)
              end
            )
            - coalesce(pg.total_pagado,0)
          ) = 0 then 'terminado'
          when (
            (
              case
                when p.estado_admin <> 'activo' or p.estado <> 'activo' then 0
                else coalesce(t.total_pedido,0)
                   + coalesce(cp.total_cargos_cliente,0)
                   + coalesce(rp.total_recargo_provincia,0)
              end
            )
            - coalesce(pg.total_pagado,0)
          ) < 0 then 'pagado_demas'
          else 'parcial'
        end::text as estado_pago
from public.pedidos p
left join public.v_pedidoestadopago_detallepedido     t  on t.pedido_id  = p.id
left join public.v_pedidosestadopago_cargo            cp on cp.idpedido = p.id
left join public.v_pedidoestadopago_provincia         rp on rp.pedido_id = p.id
left join public.v_pedidoestadopago_pagados           pg on pg.pedido_id = p.id;

-- 7.2 Pedidos · Seguimiento de envíos (unificado)
-------------------------------------------------
create or replace view public.v_pedidoestadoentrega as
with detalle_total as (
  select
    dp.idpedido as pedido_id,
    dp.idproducto,
    dp.cantidad
  from public.v_detallepedidos_ajustado dp
),
detalle_enviado as (
  select
    mp.idpedido  as pedido_id,
    dmp.idproducto,
    coalesce(
      sum(
        greatest(
          case
            when dev.estado = 'pendiente' then 0
            when dev.estado = 'resuelto_cliente' then
              dmp.cantidad - coalesce(inc.cantidad_incidente, 0)
            when dev.estado = 'devuelto_base' then
              dmp.cantidad - coalesce(inc.cantidad_incidente, 0)
              - coalesce(devdet.cantidad_devuelta, 0)
            else dmp.cantidad - coalesce(inc.cantidad_incidente, 0)
          end,
          0
        )
      ),
      0
    )::numeric(12,2) as cant_enviada
  from public.movimientopedidos mp
  join public.detallemovimientopedidos dmp
    on dmp.idmovimiento = mp.id
  left join (
    select
      iddetalle_movimiento,
      coalesce(sum(cantidad), 0)::numeric(12,2) as cantidad_incidente
    from public.viajes_incidentes_detalle
    group by iddetalle_movimiento
  ) inc on inc.iddetalle_movimiento = dmp.id
  left join public.viajesdetalles vd
    on vd.idmovimiento = mp.id
  left join public.viajes_devueltos dev
    on dev.idviaje_detalle = vd.id
  left join (
    select
      iddevuelto,
      iddetalle_movimiento,
      coalesce(sum(cantidad), 0)::numeric(12,2) as cantidad_devuelta
    from public.viajes_devueltos_detalle
    group by iddevuelto, iddetalle_movimiento
  ) devdet
    on devdet.iddevuelto = dev.id
   and devdet.iddetalle_movimiento = dmp.id
  where mp.estado = 'activo'
    and dmp.estado = 'activo'
  group by mp.idpedido, dmp.idproducto
),
estado_producto as (
  select
    s.pedido_id,
    s.idproducto,
    s.cantidad,
    least(coalesce(e.cant_enviada,0), s.cantidad)::numeric(12,2) as cant_enviada,
    (s.cantidad - least(coalesce(e.cant_enviada,0), s.cantidad))::numeric(12,2) as resta
  from detalle_total s
  left join detalle_enviado e
    on e.pedido_id  = s.pedido_id
   and e.idproducto = s.idproducto
)
select
  ep.pedido_id,
  count(*)                                    as n_items,
  sum( (ep.resta = 0)::int )                  as n_terminados,
  sum( (ep.resta = ep.cantidad)::int )        as n_pendientes,
  case
    when sum( (ep.resta = 0)::int ) = count(*) then 'terminado'
    when sum( (ep.resta = ep.cantidad)::int ) = count(*) then 'pendiente'
    else 'parcial'
  end                                         as estado_entrega
from estado_producto ep
join public.pedidos p on p.id = ep.pedido_id
group by ep.pedido_id;



-- 7.3 Movimientos/Viajes · Estados operativos
-------------------------------------------------
-- Movimientos en borrador (sin base)
create or replace view public.v_mov_borrador as
select m.id
from public.movimientopedidos m
where m.idbase is null
  and m.estado = 'activo';

-- Movimientos asignados (tienen al menos una fila en viajesdetalles)
create or replace view public.v_mov_asignados as
select dv.idmovimiento as id, count(*) as asignaciones
from public.viajesdetalles dv
join public.movimientopedidos m on m.id = dv.idmovimiento
where m.estado = 'activo'
group by dv.idmovimiento;

-- Movimientos con llegada (al menos una fila con llegada_at)
create or replace view public.v_mov_llegados as
select dv.idmovimiento as id, count(*) as llegadas
from public.viajesdetalles dv
join public.movimientopedidos m on m.id = dv.idmovimiento
where dv.llegada_at is not null
  and m.estado = 'activo'
group by dv.idmovimiento;

-- Marcas de tiempo útiles (solo asignado/llegada)
create or replace view public.v_mov_timestamps as
select
  m.id,
  (select min(dv.registrado_at)
     from public.viajesdetalles dv
     where dv.idmovimiento = m.id) as asignado_at,
  (select min(dv.llegada_at)
     from public.viajesdetalles dv
     where dv.idmovimiento = m.id
       and dv.llegada_at is not null) as llegada_at
from public.movimientopedidos m
where m.estado = 'activo';


create or replace view public.v_movimiento_estado as
select
  m.id,
  m.idpedido,
  /* idcliente derivado del pedido para evitar JOIN directo */
  (select p.idcliente
     from public.pedidos p
     where p.id = m.idpedido
     limit 1) as idcliente,
  m.idbase,
  case
    when m.estado = 'cancelado' then 0        -- cancelado
    when m.idbase is null then 1                 -- pendiente
    when inc.idmovimiento is not null then 7     -- incidente
    when db.idmovimiento is not null then 6      -- devuelto
    when rc.idmovimiento is not null then 4      -- llegado (cliente resolvió)
    when ds.idmovimiento is not null then 5      -- devolviendo
    when l.id is not null then 4                 -- llegado
    when a.id is not null then 3                 -- en camino
    else 2                                       -- asignado
  end as estado,
  case
    when m.estado = 'cancelado' then 'cancelado'
    when m.idbase is null then 'pendiente'
    when inc.idmovimiento is not null then 'incidente'
    when db.idmovimiento is not null then 'devuelto'
    when rc.idmovimiento is not null then 'llegado'
    when ds.idmovimiento is not null then 'devolviendo'
    when l.id is not null then 'llegado'
    when a.id is not null then 'en_camino'
    else 'asignado'
  end as estado_texto,
  t.asignado_at,
  t.llegada_at
from public.movimientopedidos m
left join public.v_mov_asignados  a on a.id = m.id
left join public.v_mov_llegados   l on l.id = m.id
left join public.v_mov_timestamps t on t.id = m.id
left join (
  select distinct idmovimiento
  from public.viajesdetalles
  where devuelto_solicitado_at is not null
) ds on ds.idmovimiento = m.id
left join (
  select distinct idmovimiento
  from public.viajes_devueltos
  where estado = 'devuelto_base'
) db on db.idmovimiento = m.id
left join (
  select distinct idmovimiento
  from public.viajes_devueltos
  where estado = 'resuelto_cliente'
) rc on rc.idmovimiento = m.id
left join (
  select distinct idmovimiento
  from public.viajes_incidentes_detalle
) inc on inc.idmovimiento = m.id;

-- 7.4 Pedidos · Estado general combinado
-------------------------------------------------
create or replace view public.v_pedido_estado_general as
select  p.id                                    as pedido_id,
        ep.estado_pago,
        ee.estado_entrega,
        case
          when p.estado = 'cancelado'
            then 'cancelado'
          when p.estado_admin = 'cancelado_cliente'
            then 'cancelado'
          when p.estado_admin <> 'activo'
            then p.estado_admin
          when coalesce(rr.cantidad_reembolsos, 0) > 0
            then 'devuelto_dinero'
          when ep.estado_pago = 'terminado' and ee.estado_entrega = 'terminado'
            then 'terminado'
          when ep.estado_pago = 'pendiente' or ee.estado_entrega = 'pendiente'
            then 'pendiente'
        else 'parcial'
        end as estado_general
from public.pedidos p
left join public.v_pedidoestadopago          ep on ep.pedido_id = p.id
left join public.v_pedidoestadoentrega       ee on ee.pedido_id = p.id
left join public.v_pedido_reembolsos_resumen rr on rr.idpedido = p.id;

-- 7.5 Pedidos · Vista general para UI
-------------------------------------------------
create or replace view public.v_pedido_vistageneral (
  id,
  codigo,
  fechapedido,
  observacion,
  idcliente,
  registrado_at,
  editado_at,
  registrado_por,
  editado_por,
  registrado_por_nombre,
  editado_por_nombre,
  cliente_nombre,
  cliente_numero,
  estado_admin,
  estado_pago,
  estado_entrega,
  estado_general,
  total_pedido,
  total_penalidad,
  total_monto_ida,
  total_monto_vuelta,
  total_recargo_provincia,
  total_pagado,
  total_con_cargos,
  saldo
) as
select
  p.id                                     as id,
  p.codigo                                 as codigo,
  timezone('America/Lima', coalesce(p.registrado_at, now())) as fechapedido,
  p.observacion                            as observacion,
  p.idcliente                              as idcliente,
  p.registrado_at                          as registrado_at,
  p.editado_at                             as editado_at,
  p.registrado_por                         as registrado_por,
  p.editado_por                            as editado_por,
  pr.nombre                                as registrado_por_nombre,
  pe.nombre                                as editado_por_nombre,
  c.nombre                                 as cliente_nombre,
  c.numero                                 as cliente_numero,
  coalesce(p.estado_admin, 'activo')       as estado_admin,
  ep.estado_pago,
  ee.estado_entrega,
  case
    when p.estado = 'cancelado'
      then 'cancelado'
    when coalesce(p.estado_admin, 'activo') = 'cancelado_cliente'
      then 'cancelado'
    when coalesce(p.estado_admin, 'activo') <> 'activo'
      then p.estado_admin
    when coalesce(rr.cantidad_reembolsos, 0) > 0
      then 'devuelto_dinero'
    when coalesce(ep.estado_pago, '') = 'terminado'
         and coalesce(ee.estado_entrega, '') = 'terminado'
      then 'terminado'
    when coalesce(ep.estado_pago, '') = 'pendiente'
         or coalesce(ee.estado_entrega, '') = 'pendiente'
      then 'pendiente'
    else 'parcial'
  end                                      as estado_general,
  ep.total_pedido                          as total_pedido,
  ep.total_penalidad                       as total_penalidad,
  ep.total_monto_ida                       as total_monto_ida,
  ep.total_monto_vuelta                    as total_monto_vuelta,
  ep.total_recargo_provincia               as total_recargo_provincia,
  ep.total_pagado                          as total_pagado,
  ep.total_con_cargos                      as total_con_cargos,
  ep.saldo                                 as saldo
from public.pedidos p
left join public.clientes                   c  on c.id = p.idcliente
left join public.perfiles                   pr on pr.user_id = p.registrado_por
left join public.perfiles                   pe on pe.user_id = p.editado_por
left join public.v_pedidoestadopago         ep on ep.pedido_id = p.id
left join public.v_pedidoestadoentrega      ee on ee.pedido_id = p.id
left join public.v_pedido_reembolsos_resumen rr on rr.idpedido = p.id;

-- 7.6 Movimientos · Resumen enriquecido
-------------------------------------------------
create or replace view public.v_movimiento_resumen as
select
  m.id,
  m.codigo                               as codigo,
  m.idpedido,
  p.codigo                               as pedido_codigo,
  p.idcliente                             as idcliente,
  m.fecharegistro,
  m.es_provincia,
  case
    when m.es_provincia then 'Provincia'
    else 'Lima'
  end                                       as destino_tipo,
  me.estado_texto                          as estado_texto,
  me.estado                                as estado_codigo,
  t.asignado_at,
  t.llegada_at,
  m.observacion                            as observacion,
  c.nombre                                  as cliente_nombre,
  case
    when m.es_provincia then null
    else coalesce(nr.numero, c.numero)
  end                                       as contacto_numero,
  case
    when m.es_provincia then null
    else nr.nombre_contacto
  end                                       as contacto_nombre,
  case
    when m.es_provincia then null
    else d.direccion
  end                                       as direccion_texto,
  case
    when m.es_provincia then null
    else d.referencia
  end                                       as direccion_referencia,
  dp.lugar_llegada                          as provincia_destino,
  dp.nombre_completo                        as provincia_destinatario,
  dp.dni                                    as provincia_dni,
  b.nombre                                  as base_nombre
  ,
  case
    when m.es_provincia then dp.lugar_llegada
    else d.direccion
  end as direccion_display,
  case
    when m.es_provincia then ''
    else coalesce(d.referencia, '')
  end as referencia_display,
  case
    when m.es_provincia then dp.dni
    else coalesce(nr.numero, c.numero)
  end as contacto_numero_display,
  case
    when m.es_provincia then coalesce(dp.nombre_completo, c.nombre)
    else coalesce(nr.nombre_contacto, c.nombre)
  end as contacto_nombre_display
from public.movimientopedidos m
left join public.pedidos              p   on p.id = m.idpedido
left join public.clientes             c   on c.id = p.idcliente
left join public.bases                b   on b.id = m.idbase
left join public.direccion            d   on d.id = m.destino_lima_iddireccion
left join public.numrecibe            nr  on nr.id = m.destino_lima_idnumrecibe
left join public.direccion_provincia  dp  on dp.id = m.destino_provincia_iddireccion
left join public.v_mov_asignados      a   on a.id = m.id
left join public.v_mov_llegados       l   on l.id = m.id
left join public.v_movimiento_estado  me  on me.id = m.id
left join public.v_mov_timestamps     t   on t.id = m.id
where m.estado = 'activo';

create or replace view public.v_movimiento_vistageneral as
select
  m.id,
  m.codigo                                 as codigo,
  m.idpedido,
  p.codigo                                 as pedido_codigo,
  m.fecharegistro,
  m.es_provincia,
  case
    when m.es_provincia then 'Provincia'
    else 'Lima'
  end                                       as destino_tipo,
  m.idbase,
  m.observacion                             as observacion,
  b.nombre                                  as base_nombre,
  p.idcliente,
  c.nombre                                  as cliente_nombre,
  c.numero                                  as cliente_numero,
  case
    when m.es_provincia then null
    else coalesce(nr.numero, c.numero)
  end                                       as contacto_numero,
  case
    when m.es_provincia then null
    else d.direccion
  end                                       as direccion_texto,
  case
    when m.es_provincia then null
    else d.referencia
  end                                       as direccion_referencia,
  dp.lugar_llegada                          as provincia_destino,
  dp.nombre_completo                        as provincia_destinatario,
  dp.dni                                    as provincia_dni,
  case
    when m.es_provincia then dp.lugar_llegada
    else d.direccion
  end                                       as direccion_display,
  case
    when m.es_provincia then concat_ws(
      ' / ',
      nullif(dp.nombre_completo, ''),
      nullif(dp.dni, '')
    )
    else coalesce(d.referencia, '')
  end                                       as referencia_display,
  case
    when m.es_provincia then dp.dni
    else coalesce(nr.numero, c.numero)
  end                                       as contacto_numero_display,
  case
    when m.es_provincia then dp.nombre_completo
    else coalesce(nr.nombre_contacto, c.nombre)
  end                                       as contacto_nombre_display,
  me.estado_texto                            as estado_texto,
  me.estado                                  as estado_codigo,
  concat_ws(
    ' / ',
    coalesce(c.nombre, ''),
    coalesce(coalesce(nr.numero, c.numero), ''),
    case
      when m.es_provincia then coalesce(dp.lugar_llegada, '')
      else coalesce(d.direccion, '')
    end,
    case
      when m.es_provincia then null
      else nullif(d.referencia, '')
    end
  ) as picker_label
from public.movimientopedidos m
left join public.pedidos              p   on p.id = m.idpedido
left join public.clientes             c   on c.id = p.idcliente
left join public.bases                b   on b.id = m.idbase
left join public.direccion            d   on d.id = m.destino_lima_iddireccion
left join public.numrecibe            nr  on nr.id = m.destino_lima_idnumrecibe
left join public.direccion_provincia  dp  on dp.id = m.destino_provincia_iddireccion
left join public.v_mov_asignados      a   on a.id = m.id
left join public.v_mov_llegados       l   on l.id = m.id
left join public.v_movimiento_estado  me  on me.id = m.id
where m.estado = 'activo';

create or replace view public.v_movimiento_vistageneral_bases as
select
  vm.*
from public.v_movimiento_vistageneral vm
where exists (
  select 1
  from public.perfiles pf
  where pf.user_id = auth.uid()
    and pf.activo = true
    and pf.idbase is not null
    and pf.idbase = vm.idbase
);

create or replace view public.v_movimientos_disponibles_viaje as
select
  vm.*
from public.v_movimiento_vistageneral vm
where vm.estado_texto = 'asignado'
  and not exists (
    select 1
    from public.viajesdetalles vd
    where vd.idmovimiento = vm.id
  );

-- 7.8 Viajes · Vista general
-------------------------------------------------
create or replace view public.v_viaje_vistageneral as
with stats as (
  select
    vd.idviaje,
    count(*)::int as total_items,
    sum(
      case
        when inc.idviaje_detalle is not null then 0
        when vd.llegada_at is null then 1
        else 0
      end
    )::int as pendientes
  from public.viajesdetalles vd
  left join (
    select distinct idviaje_detalle
    from public.viajes_incidentes
  ) inc on inc.idviaje_detalle = vd.id
  group by vd.idviaje
)
select
  v.id,
  v.nombre_motorizado,
  v.num_llamadas,
  v.num_wsp,
  v.num_pago,
  v.link,
  v.idbase,
  b.nombre as base_nombre,
  v.monto,
  v.registrado_at,
  v.editado_at,
  v.registrado_por,
  v.editado_por,
  coalesce(s.total_items, 0)      as total_items,
  coalesce(s.pendientes, 0)       as pendientes,
  case
    when coalesce(s.total_items, 0) > 0 and coalesce(s.pendientes, 0) = 0
      then 'terminado'
    else 'pendiente'
  end                              as estado_texto,
  case
    when coalesce(s.total_items, 0) > 0 and coalesce(s.pendientes, 0) = 0
      then 2
    else 1
  end                              as estado_codigo
from public.viajes v
left join stats s on s.idviaje = v.id
left join public.bases b on b.id = v.idbase;

-- 7.8.1 Viajes por base (filtrado por usuario)
-------------------------------------------------
create or replace view public.v_viaje_vistageneral_bases as
select
  vv.*
from public.v_viaje_vistageneral vv
where exists (
  select 1
  from public.perfiles pf
  where pf.user_id = auth.uid()
    and pf.activo = true
    and pf.idbase is not null
    and pf.idbase = vv.idbase
);

create or replace view public.v_viaje_detalle_vistageneral as
with incidente_detalle as (
  select
    idincidente,
    count(*)::int as items,
    coalesce(sum(cantidad), 0)::numeric(12,2) as total_cantidad
  from public.viajes_incidentes_detalle
  group by idincidente
)
select
  vd.id,
  vd.idviaje,
  vd.idmovimiento,
  m.codigo                               as movimiento_codigo,
  vd.idpacking,
  dev.id                              as devuelto_id,
  dev.estado                          as devuelto_estado,
  inc.id                                as incidente_id,
  inc.tipo                              as incidente_tipo,
  inc.observacion                       as incidente_observacion,
  inc.registrado_at                     as incidente_registrado_at,
  coalesce(inc_det.items, 0)            as incidente_items,
  coalesce(inc_det.total_cantidad, 0)   as incidente_cantidad,
  bp.nombre                             as packing_nombre,
  bp.tipo                               as packing_tipo,
  bp.observacion                        as packing_observacion,
  concat_ws(
    ' / ',
    bp.nombre,
    bp.tipo,
    nullif(bp.observacion, '')
  )                                     as packing_display,
  vd.registrado_at,
  vd.editado_at,
  vd.registrado_por,
  vd.editado_por,
  vd.llegada_at,
  vd.devuelto_solicitado_at,
  case
    when inc.id is not null then 'incidente'
    when dev.id is not null and dev.estado = 'devuelto_base' then 'devuelto_terminado'
    when dev.id is not null and dev.estado = 'resuelto_cliente' then 'llegado'
    when vd.devuelto_solicitado_at is not null then 'devuelto_pendiente'
    when vd.llegada_at is not null then 'llegado'
    else 'en_camino'
  end                                   as estado_detalle_key,
  case
    when inc.id is not null then 'Incidente'
    when dev.id is not null and dev.estado = 'devuelto_base' then 'Devuelto terminado'
    when dev.id is not null and dev.estado = 'resuelto_cliente' then 'Llegado'
    when vd.devuelto_solicitado_at is not null then 'Devuelto pendiente'
    when vd.llegada_at is not null then 'Llegado'
    else 'En camino'
  end                                   as estado_detalle,
  case
    when inc.id is not null then 5
    when dev.id is not null and dev.estado = 'devuelto_base' then 4
    when dev.id is not null and dev.estado = 'resuelto_cliente' then 2
    when vd.devuelto_solicitado_at is not null then 3
    when vd.llegada_at is not null then 2
    else 1
  end                                   as estado_detalle_codigo,
  m.es_provincia,
  m.idbase                              as base_id,
  b.nombre                              as base_nombre,
  p.codigo                              as pedido_codigo,
  c.nombre                              as cliente_nombre,
  c.numero                              as cliente_numero,
  case
    when m.es_provincia then null
    else nr.numero
  end                                   as contacto_numero,
  case
    when m.es_provincia then dp.nombre_completo
    else nr.nombre_contacto
  end                                   as contacto_nombre,
  case
    when m.es_provincia then null
    else d.direccion
  end                                   as direccion_texto,
  case
    when m.es_provincia then null
    else d.referencia
  end                                   as direccion_referencia,
  case
    when m.es_provincia then concat_ws(
      ' / ',
      nullif(dp.lugar_llegada, ''),
      nullif(dp.nombre_completo, ''),
      nullif(dp.dni, '')
    )
    else concat_ws(' / ', d.direccion, nullif(d.referencia, ''))
  end                                   as direccion_display,
  case
    when m.es_provincia then concat_ws(
      ' / ',
      nullif(dp.nombre_completo, ''),
      nullif(dp.dni, '')
    )
    else concat_ws(
      ' / ',
      nullif(nr.numero, ''),
      nullif(nr.nombre_contacto, '')
    )
  end                                   as contacto_display,
  dp.lugar_llegada                      as provincia_destino,
  dp.nombre_completo                    as provincia_destinatario,
  dp.dni                                as provincia_dni
from public.viajesdetalles vd
join public.viajes v on v.id = vd.idviaje
join public.movimientopedidos m on m.id = vd.idmovimiento
left join public.viajes_devueltos dev on dev.idviaje_detalle = vd.id
left join public.viajes_incidentes inc on inc.idviaje_detalle = vd.id
left join incidente_detalle inc_det on inc_det.idincidente = inc.id
left join public.bases b on b.id = m.idbase
left join public.pedidos p on p.id = m.idpedido
left join public.clientes c on c.id = p.idcliente
left join public.direccion            d   on d.id = m.destino_lima_iddireccion
left join public.numrecibe            nr  on nr.id = m.destino_lima_idnumrecibe
left join public.direccion_provincia  dp  on dp.id = m.destino_provincia_iddireccion
left join public.base_packings        bp  on bp.id = vd.idpacking;

create or replace view public.v_viajes_devueltos_vistageneral as
with detalle as (
  select
    iddevuelto,
    count(*)::int as productos_devueltos,
    coalesce(sum(cantidad), 0)::numeric(12,2) as cantidad_devuelta
  from public.viajes_devueltos_detalle
  group by iddevuelto
)
select
  vd.id,
  vd.idviaje_detalle,
  vd.idmovimiento,
  vd.idpedido,
  vd.idbase_retorno,
  base_ret.nombre           as base_retorno_nombre,
  det.idviaje,
  v.nombre_motorizado,
  mp.idbase                 as base_origen_id,
  base_origen.nombre        as base_origen_nombre,
  p.registrado_at           as pedido_registrado_at,
  cli.nombre                as cliente_nombre,
  cli.numero                as cliente_numero,
  coalesce(detalle.productos_devueltos, 0) as productos_devueltos,
  coalesce(detalle.cantidad_devuelta, 0)::numeric(12,2) as cantidad_devuelta,
  vd.monto_ida,
  vd.monto_vuelta,
  vd.penalidad,
  vd.estado,
  vd.cliente_resuelto_at,
  vd.devuelto_recibido_at,
  vd.link_evidencia,
  vd.observacion,
  vd.registrado_at,
  vd.editado_at,
  vd.registrado_por,
  vd.editado_por
from public.viajes_devueltos vd
left join public.viajesdetalles det on det.id = vd.idviaje_detalle
left join public.viajes v on v.id = det.idviaje
left join public.movimientopedidos mp on mp.id = vd.idmovimiento
left join public.bases base_origen on base_origen.id = mp.idbase
left join public.bases base_ret on base_ret.id = vd.idbase_retorno
left join public.pedidos p on p.id = vd.idpedido
left join public.clientes cli on cli.id = p.idcliente
left join detalle detalle on detalle.iddevuelto = vd.id;

create or replace view public.v_viajes_devueltos_detalle_vistageneral as
select
  vdd.id,
  vdd.iddevuelto,
  vdd.iddetalle_movimiento,
  vdd.idmovimiento,
  vdd.idproducto,
  prod.nombre                         as producto_nombre,
  vdd.cantidad,
  vdd.registrado_at,
  vdd.editado_at,
  vdd.registrado_por,
  vdd.editado_por,
  dev.idviaje_detalle,
  dev.estado                          as devuelto_estado,
  dev.idpedido,
  mp.idbase,
  p.idcliente,
  cli.nombre                          as cliente_nombre,
  cli.numero                          as cliente_numero,
  dmp.cantidad                        as cantidad_movimiento
from public.viajes_devueltos_detalle vdd
join public.viajes_devueltos dev on dev.id = vdd.iddevuelto
join public.movimientopedidos mp on mp.id = vdd.idmovimiento
left join public.pedidos p on p.id = mp.idpedido
left join public.clientes cli on cli.id = p.idcliente
left join public.detallemovimientopedidos dmp on dmp.id = vdd.iddetalle_movimiento
left join public.productos prod on prod.id = vdd.idproducto;

create or replace view public.v_viajes_incidentes_vistageneral as
with detalle as (
  select
    idincidente,
    count(*)::int as productos_afectados,
    coalesce(sum(cantidad), 0)::numeric(12,2) as cantidad_afectada
  from public.viajes_incidentes_detalle
  group by idincidente
)
select
  inc.id,
  inc.idviaje_detalle,
  inc.tipo,
  inc.observacion,
  inc.registrado_at,
  inc.editado_at,
  inc.registrado_por,
  inc.editado_por,
  vd.idviaje,
  vd.idmovimiento,
  mp.codigo                             as movimiento_codigo,
  vd.idpacking,
  mp.idpedido,
  p.codigo                              as pedido_codigo,
  mp.idbase,
  b.nombre as base_nombre,
  v.nombre_motorizado,
  p.registrado_at           as pedido_registrado_at,
  cli.nombre                as cliente_nombre,
  cli.numero                as cliente_numero,
  coalesce(detalle.productos_afectados, 0)    as productos_afectados,
  coalesce(detalle.cantidad_afectada, 0)::numeric(12,2) as cantidad_afectada,
  case
    when mp.es_provincia then null
    else d.direccion
  end                                   as direccion_texto,
  case
    when mp.es_provincia then null
    else d.referencia
  end                                   as direccion_referencia,
  case
    when mp.es_provincia then concat_ws(
      ' / ',
      nullif(dp.lugar_llegada, ''),
      nullif(dp.nombre_completo, ''),
      nullif(dp.dni, '')
    )
    else concat_ws(' / ', d.direccion, nullif(d.referencia, ''))
  end                                   as direccion_display,
  case
    when mp.es_provincia then concat_ws(
      ' / ',
      nullif(dp.nombre_completo, ''),
      nullif(dp.dni, '')
    )
    else concat_ws(
      ' / ',
      nullif(nr.numero, ''),
      nullif(nr.nombre_contacto, '')
    )
  end                                   as contacto_display
from public.viajes_incidentes inc
join public.viajesdetalles vd on vd.id = inc.idviaje_detalle
join public.viajes v on v.id = vd.idviaje
join public.movimientopedidos mp on mp.id = vd.idmovimiento
left join public.bases b on b.id = mp.idbase
left join public.pedidos p on p.id = mp.idpedido
left join public.clientes cli on cli.id = p.idcliente
left join public.direccion d on d.id = mp.destino_lima_iddireccion
left join public.numrecibe nr on nr.id = mp.destino_lima_idnumrecibe
left join public.direccion_provincia dp on dp.id = mp.destino_provincia_iddireccion
left join detalle detalle on detalle.idincidente = inc.id;

create or replace view public.v_viajes_incidentes_detalle_vistageneral as
select
  vid.id,
  vid.idincidente,
  vid.iddetalle_movimiento,
  vid.idmovimiento,
  mp.codigo                             as movimiento_codigo,
  vid.idproducto,
  prod.nombre                         as producto_nombre,
  vid.cantidad,
  vid.idasiento_inventario,
  vid.idasiento_gasto,
  vid.registrado_at,
  vid.editado_at,
  vid.registrado_por,
  vid.editado_por,
  inc.idviaje_detalle,
  inc.tipo                            as incidente_tipo,
  vd.idviaje,
  vd.idpacking,
  mp.idpedido,
  p.idcliente,
  cli.nombre                          as cliente_nombre,
  cli.numero                          as cliente_numero,
  dmp.cantidad                        as cantidad_movimiento
from public.viajes_incidentes_detalle vid
join public.viajes_incidentes inc on inc.id = vid.idincidente
join public.viajesdetalles vd on vd.id = inc.idviaje_detalle
join public.movimientopedidos mp on mp.id = vd.idmovimiento
left join public.pedidos p on p.id = mp.idpedido
left join public.clientes cli on cli.id = p.idcliente
left join public.detallemovimientopedidos dmp on dmp.id = vid.iddetalle_movimiento
left join public.productos prod on prod.id = vid.idproducto;

-------------------------------------------------
-- VISTAS · MÓDULO 2 (Operaciones / Inventario)
-------------------------------------------------

create or replace view public.v_kardex_operativo as
with movimientos as (
  select
    dmp.idproducto,
    (-dmp.cantidad)::numeric(14,4) as cantidad,
    mp.idbase,
    'movimiento'::text as tipomov,
    mp.id as idoperativo,
    mp.fecharegistro as registrado_at
  from public.movimientopedidos mp
  join public.detallemovimientopedidos dmp on dmp.idmovimiento = mp.id
  where mp.estado = 'activo'
    and dmp.estado = 'activo'
  union all
  select
    cmd.idproducto,
    case
      when cm.es_reversion then (-cmd.cantidad)
      else cmd.cantidad
    end::numeric(14,4),
    cm.idbase,
    'compra'::text as tipomov,
    cm.id as idoperativo,
    cm.registrado_at as registrado_at
  from public.compras_movimientos cm
  join public.compras_movimiento_detalle cmd on cmd.idmovimiento = cm.id
  union all
  select
    ad.idproducto,
    ad.cantidad::numeric(14,4),
    a.idbase,
    'ajuste'::text as tipomov,
    a.id as idoperativo,
    a.registrado_at as registrado_at
  from public.ajustes a
  join public.ajustes_detalle ad on ad.idajuste = a.id
  union all
  select
    td.idproducto,
    (-td.cantidad)::numeric(14,4),
    t.idbase_origen,
    'trans_origen'::text as tipomov,
    t.id as idoperativo,
    t.registrado_at as registrado_at
  from public.transferencias t
  join public.transferencias_detalle td on td.idtransferencia = t.id
  union all
  select
    td.idproducto,
    td.cantidad::numeric(14,4),
    t.idbase_destino,
    'trans_destino'::text as tipomov,
    t.id as idoperativo,
    t.registrado_at as registrado_at
  from public.transferencias t
  join public.transferencias_detalle td on td.idtransferencia = t.id
  union all
  select
    fc.idproducto,
    (-fc.cantidad)::numeric(14,4),
    f.idbase,
    'fabr_consumo'::text as tipomov,
    f.id as idoperativo,
    f.registrado_at as registrado_at
  from public.fabricaciones f
  join public.fabricaciones_consumos fc on fc.idfabricacion = f.id
  where f.estado = 'activo'
  union all
  select
    fr.idproducto,
    fr.cantidad::numeric(14,4),
    f.idbase,
    'fabr_fabricado'::text as tipomov,
    f.id as idoperativo,
    f.registrado_at as registrado_at
  from public.fabricaciones f
  join public.fabricaciones_resultados fr on fr.idfabricacion = f.id
  where f.estado = 'activo'
  union all
  select
    fmc.idproducto,
    (-fmc.cantidad)::numeric(14,4),
    f.idbase,
    'fabr_consumo'::text as tipomov,
    f.id as idoperativo,
    f.registrado_at as registrado_at
  from public.fabricaciones_maquila f
  join public.fabricaciones_maquila_consumos fmc on fmc.idfabricacion = f.id
  where f.estado = 'activo'
  union all
  select
    fmr.idproducto,
    fmr.cantidad::numeric(14,4),
    f.idbase,
    'fabr_fabricado'::text as tipomov,
    f.id as idoperativo,
    f.registrado_at as registrado_at
  from public.fabricaciones_maquila f
  join public.fabricaciones_maquila_resultados fmr on fmr.idfabricacion = f.id
  where f.estado = 'activo'
  union all
  select
    vdd.idproducto,
    vdd.cantidad::numeric(14,4),
    coalesce(dev.idbase_retorno, mp.idbase),
    'devuelto'::text as tipomov,
    dev.id as idoperativo,
    coalesce(dev.devuelto_recibido_at, dev.editado_at, dev.registrado_at)
      as registrado_at
  from public.viajes_devueltos_detalle vdd
  join public.viajes_devueltos dev on dev.id = vdd.iddevuelto
  join public.movimientopedidos mp on mp.id = dev.idmovimiento
  where dev.estado = 'devuelto_base'
)
select
  m.idproducto,
  p.nombre as producto_nombre,
  m.cantidad,
  m.idbase,
  b.nombre as base_nombre,
  m.tipomov,
  m.idoperativo,
  m.registrado_at
from movimientos m
left join public.productos p on p.id = m.idproducto
left join public.bases b on b.id = m.idbase;

create or replace view public.v_stock_por_base as
with movimientos_agrupados as (
  select
    m.idbase,
    m.idproducto,
    sum(m.cantidad)::numeric(14,4) as cantidad,
    public.fn_producto_costo_promedio(m.idproducto)::numeric(18,6) as costo_unitario,
    (
      sum(m.cantidad) * public.fn_producto_costo_promedio(m.idproducto)
    )::numeric(18,4) as valor_total
  from public.v_kardex_operativo m
  group by m.idbase, m.idproducto
),
movimientos_detalle as (
  select
    ma.idbase,
    b.nombre as base_nombre,
    ma.idproducto,
    p.nombre as producto_nombre,
    ma.cantidad,
    ma.costo_unitario,
    ma.valor_total
  from movimientos_agrupados ma
  left join public.bases b on b.id = ma.idbase
  left join public.productos p on p.id = ma.idproducto
),
bases_catalogo as (
  select b.id, b.nombre
  from public.bases b
),
stock_por_base as (
  select
    bc.id as idbase,
    bc.nombre as base_nombre,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'idproducto', md.idproducto,
          'producto_nombre', coalesce(md.producto_nombre, 'Sin producto'),
          'cantidad', coalesce(md.cantidad, 0),
          'costo_unitario', coalesce(md.costo_unitario, 0),
          'valor_total', coalesce(md.valor_total, 0)
        )
        order by coalesce(md.producto_nombre, '')
      ) filter (where md.idproducto is not null),
      '[]'::jsonb
    ) as productos,
    coalesce(sum(md.cantidad), 0)::numeric(18,4) as total_cantidad,
    coalesce(sum(md.valor_total), 0)::numeric(18,4) as total_valor
  from bases_catalogo bc
  left join movimientos_detalle md on md.idbase = bc.id
  group by bc.id, bc.nombre
),
stock_empresa_productos as (
  select
    md.idproducto,
    max(md.producto_nombre) as producto_nombre,
    sum(md.cantidad)::numeric(14,4) as cantidad,
    public.fn_producto_costo_promedio(md.idproducto)::numeric(18,6) as costo_unitario,
    (
      sum(md.cantidad) * public.fn_producto_costo_promedio(md.idproducto)
    )::numeric(18,4) as valor_total
  from movimientos_detalle md
  group by md.idproducto
),
stock_empresa as (
  select
    'all'::text as id,
    null::uuid as idbase,
    'Todas'::text as base_nombre,
    coalesce(sum(sep.cantidad), 0)::numeric(18,4) as total_cantidad,
    coalesce(sum(sep.valor_total), 0)::numeric(18,4) as total_valor,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'idproducto', sep.idproducto,
          'producto_nombre', sep.producto_nombre,
          'cantidad', sep.cantidad,
          'costo_unitario', sep.costo_unitario,
          'valor_total', sep.valor_total
        )
        order by sep.producto_nombre
      ) filter (where sep.idproducto is not null),
      '[]'::jsonb
    ) as productos
  from stock_empresa_productos sep
)
select
  se.id,
  se.idbase,
  se.base_nombre,
  se.total_cantidad,
  se.total_valor,
  coalesce(jsonb_array_length(se.productos), 0) as productos_registrados,
  se.productos,
  0 as orden
from stock_empresa se
union all
select
  coalesce(spb.idbase::text, concat('base_', spb.base_nombre)) as id,
  spb.idbase,
  spb.base_nombre,
  spb.total_cantidad,
  spb.total_valor,
  coalesce(jsonb_array_length(spb.productos), 0) as productos_registrados,
  spb.productos,
  1 as orden
from stock_por_base spb
order by orden, base_nombre;

create or replace view public.v_stock_disponible_por_base as
select
  m.idbase,
  b.nombre as base_nombre,
  m.idproducto as id,
  p.nombre,
  p.es_para_venta,
  p.es_para_compra,
  sum(m.cantidad)::numeric(14,4) as cantidad_disponible,
  coalesce(s.costo_promedio, 0)::numeric(18,6) as costo_unitario
from public.v_kardex_operativo m
left join public.bases b on b.id = m.idbase
left join public.productos p on p.id = m.idproducto
left join public.inventario_saldos s on s.idproducto = m.idproducto
group by
  m.idbase,
  b.nombre,
  m.idproducto,
  p.nombre,
  p.es_para_venta,
  p.es_para_compra,
  s.costo_promedio
having sum(m.cantidad) > 0;

create or replace view public.v_recetas_insumos_stock as
select
  ri.idreceta,
  sd.idbase,
  sd.id as id,
  sd.nombre,
  ri.cantidad as cantidad_receta,
  sd.cantidad_disponible,
  sd.costo_unitario
from public.recetas_insumos ri
join public.v_stock_disponible_por_base sd
  on sd.id = ri.idproducto;

create or replace view public.v_recetas_disponibles_por_base as
with stock as (
  select
    ri.idreceta,
    sd.idbase,
    min(sd.cantidad_disponible / nullif(ri.cantidad, 0))::numeric(18,6) as max_lotes
  from public.recetas_insumos ri
  join public.v_stock_disponible_por_base sd
    on sd.id = ri.idproducto
  group by ri.idreceta, sd.idbase
  having min(sd.cantidad_disponible / nullif(ri.cantidad, 0)) > 0
)
select
  rec.id,
  rec.nombre,
  stock.idreceta,
  stock.idbase,
  stock.max_lotes
from stock
join public.recetas rec on rec.id = stock.idreceta;

create or replace view public.v_transferencias_gastos as
select
  g.id,
  g.idtransferencia,
  t.idbase_origen,
  bo.nombre as base_origen_nombre,
  t.idbase_destino,
  bd.nombre as base_destino_nombre,
  g.concepto,
  g.monto,
  g.idcuenta,
  g.idcuenta_contable,
  cb.nombre as cuenta_nombre,
  g.observacion,
  g.registrado_at,
  g.registrado_por
from public.transferencias_gastos g
join public.transferencias t on t.id = g.idtransferencia
left join public.bases bo on bo.id = t.idbase_origen
left join public.bases bd on bd.id = t.idbase_destino
left join public.cuentas_bancarias cb on cb.id = g.idcuenta;
 
create or replace view public.v_fabricaciones_maquila_costos as
select
  g.id,
  g.idfabricacion,
  f.idbase,
  b.nombre as base_nombre,
  g.concepto,
  g.monto,
  g.idcuenta,
  g.idcuenta_contable,
  cb.nombre as cuenta_nombre,
  g.observacion,
  g.registrado_at,
  g.registrado_por
from public.fabricaciones_maquila_costos g
join public.fabricaciones_maquila f on f.id = g.idfabricacion
left join public.bases b on b.id = f.idbase
left join public.cuentas_bancarias cb on cb.id = g.idcuenta;

-- ============================================
-- 6.6 Ajustes · Vista de costos
-- ============================================
create or replace view public.v_ajustes_costos as
select
  ad.id,
  ad.idajuste,
  a.idbase,
  b.nombre as base_nombre,
  ad.idproducto,
  p.nombre as producto_nombre,
  ad.cantidad_sistema,
  ad.cantidad_real,
  ad.cantidad,
  coalesce(ad.costo_unitario, 0)::numeric(14,4) as costo_unitario,
  coalesce(ad.costo_total, 0)::numeric(14,2) as costo_ajuste,
  ad.registrado_at,
  ad.registrado_por
from public.ajustes_detalle ad
join public.ajustes a on a.id = ad.idajuste
left join public.bases b on b.id = a.idbase
left join public.productos p on p.id = ad.idproducto;

-- Verificacion: costos por ajuste vs detalle
-- select
--   ad.idajuste,
--   sum(ad.costo_total)::numeric(14,2) as costo_detalle,
--   sum(vac.costo_ajuste)::numeric(14,2) as costo_vista,
--   (sum(vac.costo_ajuste) - sum(ad.costo_total))::numeric(14,2) as diff
-- from public.ajustes_detalle ad
-- join public.v_ajustes_costos vac on vac.id = ad.id
-- group by ad.idajuste
-- having abs(sum(vac.costo_ajuste) - sum(ad.costo_total)) > 0.01;
--
-- Verificacion: bloqueo tras entrega/devuelto_base
-- with target_detalle as (
--   select dmp.id
--   from public.detallemovimientopedidos dmp
--   join public.viajesdetalles vd on vd.idmovimiento = dmp.idmovimiento
--   where vd.llegada_at is not null
--   limit 1
-- )
-- update public.detallemovimientopedidos
-- set cantidad = cantidad
-- where id in (select id from target_detalle);
--
-- with target_incidente as (
--   select vid.id
--   from public.viajes_incidentes_detalle vid
--   join public.viajesdetalles vd on vd.idmovimiento = vid.idmovimiento
--   where vd.llegada_at is not null
--   limit 1
-- )
-- update public.viajes_incidentes_detalle
-- set cantidad = cantidad
-- where id in (select id from target_incidente);
--
-- with target_devuelto as (
--   select vdd.id
--   from public.viajes_devueltos_detalle vdd
--   join public.viajes_devueltos vd on vd.id = vdd.iddevuelto
--   where vd.estado = 'devuelto_base'
--   limit 1
-- )
-- update public.viajes_devueltos_detalle
-- set cantidad = cantidad
-- where id in (select id from target_devuelto);

create or replace view public.v_operaciones_gastos_union as
select
  'transferencia'::text as origen,
  g.idtransferencia as idoperativo,
  t.idbase_origen as idbase,
  bo.nombre as base_nombre,
  null::uuid as idproducto,
  null::text as producto_nombre,
  coalesce(g.observacion, g.concepto) as descripcion,
  g.monto,
  g.idcuenta,
  g.idcuenta_contable,
  g.registrado_at,
  g.registrado_por
from public.transferencias_gastos g
join public.transferencias t on t.id = g.idtransferencia
left join public.bases bo on bo.id = t.idbase_origen
union all
select
  'ajuste'::text as origen,
  ac.idajuste as idoperativo,
  ac.idbase,
  ac.base_nombre,
  ac.idproducto,
  ac.producto_nombre,
  concat('Ajuste ', ac.producto_nombre) as descripcion,
  ac.costo_ajuste as monto,
  null::uuid as idcuenta,
  null::uuid as idcuenta_contable,
  ac.registrado_at,
  ac.registrado_por
from public.v_ajustes_costos ac;

-------------------------------------------------
-- Tabla de historial de costos por operación
-------------------------------------------------

create table if not exists costo_producto_historial (
  id uuid primary key default gen_random_uuid(),
  origen_tipo text not null check (
    origen_tipo in ('compra_movimiento','fabricacion_resultado','fabricacion_maquila_resultado')
  ),
  detalle_id uuid not null,
  origen_id uuid not null,
  idproducto uuid not null references productos(id),
  idbase uuid references bases(id),
  cantidad numeric(18,6) not null,
  costo_unitario numeric(18,6) not null,
  costo_total numeric(18,4) not null,
  accion text not null default 'insert'
    check (accion in ('insert','update','delete','cancelar')),
  registrado_at timestamptz not null default now()
);

alter table if exists public.costo_producto_historial
  drop constraint if exists costo_producto_historial_accion_check,
  add constraint costo_producto_historial_accion_check
    check (accion in ('insert','update','delete','cancelar'));

create or replace view public.v_costos_historial as
select
  ch.id,
  ch.origen_tipo,
  ch.detalle_id,
  ch.origen_id,
  ch.idproducto,
  p.nombre as producto_nombre,
  ch.idbase,
  ch.cantidad,
  ch.costo_unitario,
  ch.costo_total,
  case
    when ch.accion = 'delete' then 'cancelar'
    when ch.accion = 'update' then 'insert'
    when ch.origen_tipo = 'compra_movimiento'
      and cm.es_reversion then 'cancelar'
    else ch.accion
  end as accion,
  ch.registrado_at,
  case
    when ch.origen_tipo = 'fabricacion_resultado' then
      coalesce(nullif(btrim(f.observacion), ''), f.correlativo::text, f.id::text)
    when ch.origen_tipo = 'fabricacion_maquila_resultado' then
      coalesce(
        nullif(btrim(fm.observacion), ''),
        fm.correlativo::text,
        fm.id::text
      )
    when ch.origen_tipo = 'compra_movimiento' then
      coalesce(nullif(btrim(c.observacion), ''), c.correlativo::text, c.id::text)
    else ch.origen_id::text
  end as origen_referencia
from public.costo_producto_historial ch
left join public.productos p on p.id = ch.idproducto
left join public.fabricaciones f
  on f.id = ch.origen_id
 and ch.origen_tipo = 'fabricacion_resultado'
left join public.fabricaciones_maquila fm
  on fm.id = ch.origen_id
 and ch.origen_tipo = 'fabricacion_maquila_resultado'
left join public.compras c
  on c.id = ch.origen_id
 and ch.origen_tipo = 'compra_movimiento'
left join public.compras_movimiento_detalle cmd
  on cmd.id = ch.detalle_id
 and ch.origen_tipo = 'compra_movimiento'
left join public.compras_movimientos cm
  on cm.id = cmd.idmovimiento;

create or replace function public.fn_costos_historial_upsert(
  p_origen_tipo text,
  p_detalle_id uuid,
  p_origen_id uuid,
  p_idproducto uuid,
  p_idbase uuid,
  p_cantidad numeric,
  p_costo_unitario numeric,
  p_costo_total numeric,
  p_registrado_at timestamptz default now(),
  p_accion text default 'insert'
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_accion text := lower(coalesce(p_accion, 'insert'));
begin
  if v_accion not in ('insert','update','delete','cancelar') then
    v_accion := 'insert';
  end if;
  insert into public.costo_producto_historial (
    origen_tipo,
    detalle_id,
    origen_id,
    idproducto,
    idbase,
    cantidad,
    costo_unitario,
    costo_total,
    accion,
    registrado_at
  )
  values (
    p_origen_tipo,
    p_detalle_id,
    p_origen_id,
    p_idproducto,
    p_idbase,
    p_cantidad,
    p_costo_unitario,
    p_costo_total,
    v_accion,
    coalesce(p_registrado_at, now())
  );
end;
$$;

-- 7.10 Compras · Vistas operativas
-------------------------------------------------

create or replace view public.v_compras_total_detalle as
select
  c.id as compra_id,
  coalesce(sum(cd.costo_total), 0)::numeric(14,2) as total_detalle
from public.compras c
left join public.compras_detalle cd on cd.idcompra = c.id
group by c.id;

create or replace view public.v_compras_total_pagado as
select
  c.id as compra_id,
  coalesce(sum(cp.monto), 0)::numeric(14,2) as total_pagado
from public.compras c
left join public.compras_pagos cp
  on cp.idcompra = c.id
 and cp.estado = 'activo'
group by c.id;

create or replace view public.v_compras_estado_pago as
select
  c.id as compra_id,
  d.total_detalle,
  p.total_pagado,
  case
    when c.estado = 'cancelado' then 0
    else (coalesce(d.total_detalle,0) - coalesce(p.total_pagado,0))
  end::numeric(14,2) as saldo,
  case
    when c.estado = 'cancelado' then 'cancelado'
    when coalesce(d.total_detalle,0) <= 0 then 'pendiente'
    when coalesce(p.total_pagado,0) <= 0 then 'pendiente'
    when coalesce(p.total_pagado,0) >= coalesce(d.total_detalle,0)
      then 'completo'
    else 'parcial'
  end as estado_pago
from public.compras c
left join public.v_compras_total_detalle d on d.compra_id = c.id
left join public.v_compras_total_pagado  p on p.compra_id = c.id;

create or replace view public.v_compras_total_enviada as
with detalle as (
  select
    c.id as compra_id,
    coalesce(sum(cd.cantidad),0)::numeric(14,4) as cantidad_detalle
  from public.compras c
  left join public.compras_detalle cd on cd.idcompra = c.id
  group by c.id
),
movimientos as (
  select
    cm.idcompra as compra_id,
    coalesce(
      sum(
        case
          when cm.es_reversion then (-cmd.cantidad)
          else cmd.cantidad
        end
      ),
      0
    )::numeric(14,4) as cantidad_enviada
  from public.compras_movimientos cm
  join public.compras_movimiento_detalle cmd on cmd.idmovimiento = cm.id
  group by cm.idcompra
)
select
  d.compra_id,
  d.cantidad_detalle,
  coalesce(m.cantidad_enviada, 0)::numeric(14,4) as cantidad_enviada
from detalle d
left join movimientos m on m.compra_id = d.compra_id;

create or replace view public.v_compras_detalle_vistageneral as
select
  cd.id,
  cd.idcompra,
  cd.idproducto,
  p.nombre as producto_nombre,
  cd.cantidad,
  cd.costo_total,
  case
    when cd.cantidad = 0 then 0
    else (cd.costo_total / nullif(cd.cantidad, 0))::numeric(14,6)
  end as costo_unitario,
  cd.registrado_at
from public.compras_detalle cd
left join public.productos p on p.id = cd.idproducto;

create or replace view public.v_compras_pagos_vistageneral as
select
  cp.id,
  cp.idcompra,
  c.idproveedor,
  prov.nombre as proveedor_nombre,
  cp.idcuenta,
  cb.nombre as cuenta_nombre,
  cp.monto,
  cp.estado,
  cp.registrado_at,
  timezone('America/Lima', cp.registrado_at) as registrado_at_local,
  to_char(
    timezone('America/Lima', cp.registrado_at),
    'DD/MM/YYYY HH24:MI:SS'
  ) as registrado_display,
  cp.registrado_por
from public.compras_pagos cp
left join public.compras c on c.id = cp.idcompra
left join public.proveedores prov on prov.id = c.idproveedor
left join public.cuentas_bancarias cb on cb.id = cp.idcuenta;

create or replace view public.v_compras_historial_contable as
with base as (
  select
    e.id,
    e.source_prefix,
    e.source_id,
    e.descripcion,
    e.estado,
    e.posted_at,
    e.created_at,
    (e.source_prefix = 'reversal') as is_reversal
  from public.gl_journal_entries e
),
line_totals as (
  select
    l.entry_id,
    coalesce(sum(l.debit), 0)::numeric(14,2) as debe,
    coalesce(sum(l.credit), 0)::numeric(14,2) as haber
  from public.gl_journal_lines l
  group by l.entry_id
),
joined as (
  select
    b.*,
    lt.debe,
    lt.haber,
    orig.source_prefix as orig_source_prefix,
    orig.source_id as orig_source_id
  from base b
  left join line_totals lt on lt.entry_id = b.id
  left join public.gl_journal_entries orig
    on orig.id = b.source_id
   and b.source_prefix = 'reversal'
),
mapped as (
  select
    j.id,
    case
      when j.source_prefix = 'compra' then j.source_id
      when j.source_prefix = 'recepcion_compra' then cm.idcompra
      when j.source_prefix = 'tesoreria_pago' then cp.idcompra
      when j.source_prefix = 'reversal' then
        case
          when j.orig_source_prefix = 'compra' then j.orig_source_id
          when j.orig_source_prefix = 'recepcion_compra' then cm_orig.idcompra
          when j.orig_source_prefix = 'tesoreria_pago' then cp_orig.idcompra
          else null
        end
      else null
    end as idcompra,
    j.source_prefix,
    j.descripcion,
    j.estado,
    j.posted_at,
    j.created_at,
    j.is_reversal,
    coalesce(cm.es_reversion, false) as recepcion_es_reversion,
    j.debe,
    j.haber
  from joined j
  left join public.compras_movimientos cm
    on cm.id = j.source_id
   and j.source_prefix = 'recepcion_compra'
  left join public.compras_pagos cp
    on cp.id = j.source_id
   and j.source_prefix = 'tesoreria_pago'
  left join public.compras_movimientos cm_orig
    on cm_orig.id = j.orig_source_id
   and j.orig_source_prefix = 'recepcion_compra'
  left join public.compras_pagos cp_orig
    on cp_orig.id = j.orig_source_id
   and j.orig_source_prefix = 'tesoreria_pago'
)
select
  id,
  idcompra,
  coalesce(posted_at, created_at) as fecha_at,
  to_char(
    timezone('America/Lima', coalesce(posted_at, created_at)),
    'DD/MM/YYYY HH24:MI:SS'
  ) as fecha_display,
  source_prefix,
  case
    when source_prefix = 'recepcion_compra'
      and recepcion_es_reversion
      then concat('Reversa: ', descripcion)
    else descripcion
  end as descripcion,
  debe,
  haber,
  estado,
  case
    when source_prefix = 'reversal'
      or (
        source_prefix = 'recepcion_compra'
        and recepcion_es_reversion
      )
      then 'Correccion'
    else 'Evento'
  end as tipo,
  is_reversal,
  (
    is_reversal or
    (source_prefix = 'recepcion_compra' and recepcion_es_reversion)
  ) as is_correction,
  case
    when is_reversal
      or (source_prefix = 'recepcion_compra' and recepcion_es_reversion)
      then 'SI'
    else 'NO'
  end as reversa_label
from mapped
where idcompra is not null;

create or replace view public.v_compras_eventos as
select
  e.id,
  e.idcompra,
  e.tipo,
  case
    when e.tipo = 'compra_cancelada' then 'Compra cancelada'
    when e.tipo = 'pago_reversado' then 'Pago reversado'
    when e.tipo = 'movimiento_reversado' then 'Movimiento reversado'
    else e.tipo
  end as tipo_label,
  e.referencia_id,
  e.registrado_at,
  timezone('America/Lima', e.registrado_at) as registrado_at_local,
  to_char(
    timezone('America/Lima', e.registrado_at),
    'DD/MM/YYYY HH24:MI:SS'
  ) as registrado_display,
  e.registrado_por,
  case
    when e.tipo = 'pago_reversado' then
      concat(
        'Pago ',
        coalesce(cb.nombre, ''),
        ' ',
        to_char(coalesce(cp.monto, 0)::numeric(14,2), 'FM999999999.00')
      )
    when e.tipo = 'movimiento_reversado' then
      concat('Movimiento ', coalesce(b.nombre, ''))
    else 'Compra cancelada'
  end as detalle
from public.compras_eventos e
left join public.compras_pagos cp on cp.id = e.referencia_id
left join public.cuentas_bancarias cb on cb.id = cp.idcuenta
left join public.compras_movimientos cm on cm.id = e.referencia_id
left join public.bases b on b.id = cm.idbase;

create or replace view public.v_compras_movimientos_vistageneral as
select
  cm.id,
  cm.idcompra,
  cm.idbase,
  b.nombre as base_nombre,
  c.idproveedor,
  prov.nombre as proveedor_nombre,
  c.estado as compra_estado,
  cm.observacion,
  cm.detalle_cerrado,
  cm.es_reversion,
  cm.idmovimiento_origen,
  cm.reversion_id,
  coalesce(
    (
      select sum(
        case
          when cm.es_reversion then (-cmd.cantidad)
          else cmd.cantidad
        end
      )
      from public.compras_movimiento_detalle cmd
      where cmd.idmovimiento = cm.id
    ),
    0
  )::numeric(14,4) as cantidad_total,
  coalesce(
    (
      select sum(
        case
          when cm.es_reversion then (-cmd.costo_total)
          else cmd.costo_total
        end
      )
      from public.compras_movimiento_detalle cmd
      where cmd.idmovimiento = cm.id
    ),
    0
  )::numeric(18,4) as costo_total,
  (
    select count(*)
    from public.compras_movimiento_detalle cmd
    where cmd.idmovimiento = cm.id
  ) as productos_registrados,
  cm.registrado_at,
  cm.registrado_por
from public.compras_movimientos cm
left join public.bases b on b.id = cm.idbase
left join public.compras c on c.id = cm.idcompra
left join public.proveedores prov on prov.id = c.idproveedor;

create or replace view public.v_compras_movimiento_detalle_vistageneral as
select
  cmd.id,
  cmd.idmovimiento,
  cmd.idproducto,
  p.nombre as producto_nombre,
  cmd.cantidad,
  cmd.costo_unitario,
  cmd.costo_total,
  cm.es_reversion,
  cmd.registrado_at,
  cmd.registrado_por
from public.compras_movimiento_detalle cmd
join public.compras_movimientos cm on cm.id = cmd.idmovimiento
left join public.productos p on p.id = cmd.idproducto;

create or replace view public.v_compras_estado_entrega as
select
  c.id as compra_id,
  coalesce(env.cantidad_detalle,0)::numeric(14,4) as cantidad_detalle,
  coalesce(env.cantidad_enviada,0)::numeric(14,4) as cantidad_enviada,
  case
    when c.estado = 'cancelado' then 'cancelado'
    when coalesce(env.cantidad_detalle,0) = 0 then 'pendiente'
    when coalesce(env.cantidad_enviada,0) = 0 then 'pendiente'
    when coalesce(env.cantidad_enviada,0) >= coalesce(env.cantidad_detalle,0) then 'completo'
    else 'parcial'
  end as estado_entrega
from public.compras c
left join public.v_compras_total_enviada env on env.compra_id = c.id;

create or replace view public.v_compras_vistageneral as
select
  c.id,
  c.correlativo,
  c.idproveedor,
  prov.nombre as proveedor_nombre,
  prov.numero as proveedor_numero,
  baseinfo.idbase,
  baseinfo.base_nombre,
  c.observacion,
  c.registrado_at,
  c.editado_at,
  c.registrado_por,
  c.editado_por,
  case
    when c.estado = 'cancelado' then 'cancelado'
    when coalesce(ep.estado_pago, 'pendiente') = 'completo'
        and coalesce(ee.estado_entrega, 'pendiente') = 'completo'
      then 'completo'
    when coalesce(ep.estado_pago, 'pendiente') = 'pendiente'
        and coalesce(ee.estado_entrega, 'pendiente') = 'pendiente'
      then 'pendiente'
    else 'parcial'
  end as estado,
  c.detalle_cerrado,
  ep.total_detalle,
  ep.total_pagado,
  ep.saldo,
  ep.estado_pago,
  ee.cantidad_detalle as cantidad_total,
  ee.cantidad_enviada,
  ee.estado_entrega,
  exists (
    select 1
    from public.compras_movimientos cm_exists
    where cm_exists.idcompra = c.id
  ) as tiene_movimientos
from public.compras c
left join public.proveedores prov on prov.id = c.idproveedor
left join lateral (
  select
    min(cm_dist.idbase::text)::uuid as idbase,
    string_agg(
      b.nombre,
      ', ' order by b.nombre
    ) filter (where b.nombre is not null) as base_nombre
  from (
    select distinct cm.idbase
    from public.compras_movimientos cm
    where cm.idcompra = c.id
  ) cm_dist
  left join public.bases b on b.id = cm_dist.idbase
) baseinfo on true
left join public.v_compras_estado_pago ep on ep.compra_id = c.id
left join public.v_compras_estado_entrega ee on ee.compra_id = c.id;

-------------------------------------------------
-- VISTAS · MÓDULO 3 (Finanzas / Caja)
-------------------------------------------------

create or replace view public.v_pagos_vistageneral as
select
  pg.id,
  pg.codigo,
  pg.idpedido,
  ped.codigo as pedido_codigo,
  timezone('America/Lima', ped.registrado_at) as pedido_registrado_at,
  cli.nombre as cliente_nombre,
  pg.monto,
  to_char(timezone('America/Lima', pg.fechapago), 'YYYY-MM-DD HH24:MI:SS') as fechapago,
  pg.idcuenta,
  cb.nombre as cuenta_nombre,
  pg.registrado_at,
  pg.registrado_por
from public.pagos pg
left join public.pedidos ped on ped.id = pg.idpedido
left join public.clientes cli on cli.id = ped.idcliente
left join public.cuentas_bancarias cb on cb.id = pg.idcuenta
where pg.estado = 'activo'
  and ped.estado = 'activo';

create or replace view public.v_movimientos_financieros_vistageneral as
select
  mf.id,
  mf.tipo,
  mf.descripcion,
  mf.monto,
  case
    when mf.tipo in ('gasto','ajuste') then mf.monto
    else 0
  end::numeric(14,2) as monto_debe,
  case
    when mf.tipo = 'ingreso' then mf.monto
    else 0
  end::numeric(14,2) as monto_haber,
  case
    when mf.tipo in ('gasto','ajuste') then (-mf.monto)
    else mf.monto
  end::numeric(14,2) as monto_signed,
  timezone('America/Lima', mf.registrado_at) as registrado_at_local,
  to_char(
    timezone('America/Lima', mf.registrado_at),
    'DD/MM/YYYY HH24:MI:SS'
  ) as registrado_display,
  mf.idcuenta_origen,
  cb_orig.nombre as cuenta_origen_nombre,
  mf.idcuenta_destino,
  cb_dest.nombre as cuenta_destino_nombre,
  coalesce(cb_dest.nombre, cb_orig.nombre) as cuenta_bancaria_nombre,
  mf.idcuenta_contable,
  cc.codigo as cuenta_contable_codigo,
  cc.nombre as cuenta_contable_nombre,
  cc.tipo as cuenta_contable_tipo,
  mf.observacion,
  mf.registrado_at,
  mf.registrado_por
from public.movimientos_financieros mf
left join public.cuentas_bancarias cb_dest on cb_dest.id = mf.idcuenta_destino
left join public.cuentas_bancarias cb_orig on cb_orig.id = mf.idcuenta_origen
left join public.cuentas_contables cc on cc.id = mf.idcuenta_contable;

create or replace view public.v_cuentas_contables_gasto_tipos as
select
  cc.id,
  cc.codigo,
  cc.nombre,
  cc.parent_id,
  parent.codigo as tipo_codigo,
  parent.nombre as tipo_nombre,
  concat(coalesce(parent.nombre, 'Otros'), ' · ', cc.nombre) as nombre_display
from public.cuentas_contables cc
left join public.cuentas_contables parent on parent.id = cc.parent_id
where cc.es_gasto_operativo is true
order by parent.codigo, cc.codigo;

create or replace view public.v_finanzas_gastos_pedidos as
select
  go.id,
  go.idpedido,
  cli.nombre as cliente_nombre,
  p.registrado_at as pedido_registrado_at,
  go.idcuenta_contable_tipo,
  cc_tipo.codigo as tipo_codigo,
  cc_tipo.nombre as tipo,
  go.descripcion,
  go.monto,
  go.idcuenta,
  cb.nombre as cuenta_nombre,
  go.idcuenta_contable,
  cc.codigo as cuenta_contable_codigo,
  cc.nombre as cuenta_contable_nombre,
  go.registrado_at,
  go.registrado_por
from public.gastos_operativos go
join public.pedidos p on p.id = go.idpedido
left join public.clientes cli on cli.id = p.idcliente
left join public.cuentas_bancarias cb on cb.id = go.idcuenta
left join public.cuentas_contables cc on cc.id = go.idcuenta_contable
left join public.cuentas_contables cc_tipo on cc_tipo.id = go.idcuenta_contable_tipo;

create or replace view public.v_finanzas_movimientos_ingresos_gastos as
select
  mf.id,
  mf.tipo,
  mf.descripcion,
  case when mf.tipo in ('gasto','ajuste') then -mf.monto else mf.monto end as monto,
  mf.idcuenta_contable,
  mf.cuenta_contable_codigo,
  mf.cuenta_contable_nombre,
  mf.idcuenta_origen,
  mf.idcuenta_destino,
  mf.cuenta_bancaria_nombre,
  mf.registrado_at,
  mf.registrado_por
from public.v_movimientos_financieros_vistageneral mf
where mf.tipo in ('ingreso','gasto','ajuste')
union all
select
  gen_random_uuid() as id,
  'gasto'::text as tipo,
  og.descripcion,
  -og.monto as monto,
  og.idcuenta_contable,
  cc.codigo as cuenta_contable_codigo,
  cc.nombre as cuenta_contable_nombre,
  og.idcuenta as idcuenta_origen,
  null::uuid as idcuenta_destino,
  cb.nombre as cuenta_bancaria_nombre,
  og.registrado_at,
  og.registrado_por
from public.v_operaciones_gastos_union og
left join public.cuentas_contables cc on cc.id = og.idcuenta_contable
left join public.cuentas_bancarias cb on cb.id = og.idcuenta;

create or replace view public.v_finanzas_ajustes_dinero as
select
  mf.id,
  mf.descripcion,
  mf.monto,
  mf.idcuenta_contable,
  cc.codigo as cuenta_contable_codigo,
  cc.nombre as cuenta_contable_nombre,
  coalesce(cb_dest.nombre, cb_orig.nombre) as cuenta_bancaria_nombre,
  mf.observacion,
  mf.registrado_at,
  mf.registrado_por
from public.movimientos_financieros mf
left join public.cuentas_contables cc on cc.id = mf.idcuenta_contable
left join public.cuentas_bancarias cb_dest on cb_dest.id = mf.idcuenta_destino
left join public.cuentas_bancarias cb_orig on cb_orig.id = mf.idcuenta_origen
where mf.tipo = 'ajuste';

create or replace view public.v_finanzas_transferencias_dinero as
select
  mf.id,
  mf.descripcion,
  mf.monto,
  mf.idcuenta_origen,
  cb_orig.nombre as cuenta_origen_nombre,
  mf.idcuenta_destino,
  cb_dest.nombre as cuenta_destino_nombre,
  mf.observacion,
  mf.registrado_at,
  mf.registrado_por
from public.movimientos_financieros mf
left join public.cuentas_bancarias cb_dest on cb_dest.id = mf.idcuenta_destino
left join public.cuentas_bancarias cb_orig on cb_orig.id = mf.idcuenta_origen
where mf.tipo = 'transferencia';

create or replace view public.v_finanzas_historial_cuentas as
with union_data as (
  select
    pg.id as id,
    'pedido_pago'::text as origen,
    pg.idpedido as referencia_id,
    'pedido'::text as referencia_tipo,
    pg.idcuenta,
    null::uuid as contracuenta_id,
    null::text as contracuenta_nombre,
    null::uuid as idcuenta_contable,
    null::text as cuenta_contable_codigo,
    null::text as cuenta_contable_nombre,
    concat('Cobro pedido ', coalesce(cli.nombre, ''))::text as descripcion,
    pg.monto::numeric(14,2) as monto,
    'entrada'::text as sentido,
    pg.registrado_at,
    pg.registrado_por
  from public.pagos pg
  left join public.pedidos ped on ped.id = pg.idpedido
  left join public.clientes cli on cli.id = ped.idcliente
  where pg.idcuenta is not null
  union all
  select
    tg.id,
    'transferencia_operativa'::text as origen,
    tg.idtransferencia,
    'transferencia'::text as referencia_tipo,
    tg.idcuenta,
    null::uuid as contracuenta_id,
    null::text as contracuenta_nombre,
    tg.idcuenta_contable,
    cc.codigo as cuenta_contable_codigo,
    cc.nombre as cuenta_contable_nombre,
    coalesce(tg.observacion, tg.concepto) as descripcion,
    (-tg.monto)::numeric(14,2) as monto,
    'salida'::text as sentido,
    tg.registrado_at,
    tg.registrado_por
  from public.transferencias_gastos tg
  left join public.cuentas_contables cc on cc.id = tg.idcuenta_contable
  where tg.idcuenta is not null
  union all
  select
    fmc.id,
    'fabricacion_maquila_costo'::text as origen,
    fmc.idfabricacion,
    'fabricacion_maquila'::text as referencia_tipo,
    fmc.idcuenta,
    null::uuid as contracuenta_id,
    null::text as contracuenta_nombre,
    fmc.idcuenta_contable,
    cc.codigo as cuenta_contable_codigo,
    cc.nombre as cuenta_contable_nombre,
    coalesce(fmc.observacion, fmc.concepto) as descripcion,
    (-fmc.monto)::numeric(14,2) as monto,
    'salida'::text as sentido,
    fmc.registrado_at,
    fmc.registrado_por
  from public.fabricaciones_maquila_costos fmc
  left join public.cuentas_contables cc on cc.id = fmc.idcuenta_contable
  where fmc.idcuenta is not null
  union all
  select
    mf.id,
    concat('movimiento_', mf.tipo)::text as origen,
    null::uuid as referencia_id,
    'movimiento_financiero'::text as referencia_tipo,
    case
      when mf.tipo = 'ingreso' then mf.idcuenta_destino
      else mf.idcuenta_origen
    end as idcuenta,
    null::uuid as contracuenta_id,
    null::text as contracuenta_nombre,
    mf.idcuenta_contable,
    cc.codigo as cuenta_contable_codigo,
    cc.nombre as cuenta_contable_nombre,
    mf.descripcion as descripcion,
    case
      when mf.tipo = 'ingreso' then mf.monto
      else (-mf.monto)
    end::numeric(14,2) as monto,
    case when mf.tipo = 'ingreso' then 'entrada' else 'salida' end::text as sentido,
    mf.registrado_at,
    mf.registrado_por
  from public.movimientos_financieros mf
  left join public.cuentas_contables cc on cc.id = mf.idcuenta_contable
  where mf.tipo in ('ingreso','gasto','ajuste')
    and (
      (mf.tipo = 'ingreso' and mf.idcuenta_destino is not null)
      or (mf.tipo in ('gasto','ajuste') and mf.idcuenta_origen is not null)
    )
  union all
  select
    gen_random_uuid(),
    'movimiento_transferencia_salida'::text as origen,
    mf.id as referencia_id,
    'movimiento_financiero'::text as referencia_tipo,
    mf.idcuenta_origen,
    mf.idcuenta_destino as contracuenta_id,
    cb_dest.nombre as contracuenta_nombre,
    null::uuid as idcuenta_contable,
    null::text as cuenta_contable_codigo,
    null::text as cuenta_contable_nombre,
    mf.descripcion as descripcion,
    (-mf.monto)::numeric(14,2) as monto,
    'salida'::text as sentido,
    mf.registrado_at,
    mf.registrado_por
  from public.movimientos_financieros mf
  left join public.cuentas_bancarias cb_dest on cb_dest.id = mf.idcuenta_destino
  where mf.tipo = 'transferencia'
    and mf.idcuenta_origen is not null
  union all
  select
    gen_random_uuid(),
    'movimiento_transferencia_entrada'::text as origen,
    mf.id as referencia_id,
    'movimiento_financiero'::text as referencia_tipo,
    mf.idcuenta_destino,
    mf.idcuenta_origen as contracuenta_id,
    cb_orig.nombre as contracuenta_nombre,
    null::uuid as idcuenta_contable,
    null::text as cuenta_contable_codigo,
    null::text as cuenta_contable_nombre,
    mf.descripcion as descripcion,
    mf.monto::numeric(14,2) as monto,
    'entrada'::text as sentido,
    mf.registrado_at,
    mf.registrado_por
  from public.movimientos_financieros mf
  left join public.cuentas_bancarias cb_orig on cb_orig.id = mf.idcuenta_origen
  where mf.tipo = 'transferencia'
    and mf.idcuenta_destino is not null
)
select
  data.id,
  data.origen,
  data.referencia_id,
  data.referencia_tipo,
  data.idcuenta,
  cb.nombre as cuenta_nombre,
  cb.banco as cuenta_banco,
  data.contracuenta_id,
  data.contracuenta_nombre,
  data.idcuenta_contable,
  data.cuenta_contable_codigo,
  data.cuenta_contable_nombre,
  data.descripcion,
  data.monto,
  data.sentido,
  data.registrado_at,
  data.registrado_por
from union_data data
left join public.cuentas_bancarias cb on cb.id = data.idcuenta
where data.idcuenta is not null;

create or replace view public.v_finanzas_saldo_cuentas as
select
  cb.id as idcuenta,
  cb.nombre as cuenta_nombre,
  cb.banco as cuenta_banco,
  cb.activa,
  coalesce(sum(hist.monto), 0)::numeric(14,2) as saldo,
  max(hist.registrado_at) as ultimo_movimiento_at
from public.cuentas_bancarias cb
left join public.v_finanzas_historial_cuentas hist on hist.idcuenta = cb.id
group by cb.id, cb.nombre, cb.banco, cb.activa;

create or replace view public.v_movimientos_financieros_historial as
with ordered as (
  select
    h.*,
    lag(h.monto) over (
      partition by h.movimiento_id
      order by h.version
    ) as prev_monto
  from public.movimientos_financieros_historial h
),
delta as (
  select
    ordered.*,
    case
      when ordered.operacion = 'delete' then
        (0 - coalesce(ordered.prev_monto, ordered.monto))::numeric(14,2)
      else
        (ordered.monto - coalesce(ordered.prev_monto, 0))::numeric(14,2)
    end as diff_monto
  from ordered
),
filtered as (
  select *
  from delta
  where diff_monto is distinct from 0
)
select
  h.historial_id,
  h.movimiento_id as id,
  h.version,
  h.operacion,
  h.tipo,
  h.descripcion,
  abs(h.diff_monto)::numeric(14,2) as monto,
  case
    when h.tipo in ('gasto','ajuste') then greatest(h.diff_monto, 0)
    when h.tipo = 'ingreso' then greatest(-h.diff_monto, 0)
    else case when h.diff_monto < 0 then -h.diff_monto else 0 end
  end::numeric(14,2) as monto_debe,
  case
    when h.tipo in ('gasto','ajuste') then greatest(-h.diff_monto, 0)
    when h.tipo = 'ingreso' then greatest(h.diff_monto, 0)
    else case when h.diff_monto >= 0 then h.diff_monto else 0 end
  end::numeric(14,2) as monto_haber,
  case
    when h.tipo in ('gasto','ajuste') then (-h.diff_monto)
    else h.diff_monto
  end::numeric(14,2) as monto_signed,
  timezone('America/Lima', coalesce(h.logged_at, h.registrado_at)) as registrado_at_local,
  to_char(
    timezone('America/Lima', coalesce(h.logged_at, h.registrado_at)),
    'DD/MM/YYYY HH24:MI:SS'
  ) as registrado_display,
  h.idcuenta_origen,
  cb_orig.nombre as cuenta_origen_nombre,
  h.idcuenta_destino,
  cb_dest.nombre as cuenta_destino_nombre,
  coalesce(cb_dest.nombre, cb_orig.nombre) as cuenta_bancaria_nombre,
  h.idcuenta_contable,
  cc.codigo as cuenta_contable_codigo,
  cc.nombre as cuenta_contable_nombre,
  cc.tipo as cuenta_contable_tipo,
  h.observacion,
  coalesce(h.logged_at, h.registrado_at) as registrado_at,
  h.registrado_por,
  h.logged_at
from filtered h
left join public.cuentas_bancarias cb_dest on cb_dest.id = h.idcuenta_destino
left join public.cuentas_bancarias cb_orig on cb_orig.id = h.idcuenta_origen
left join public.cuentas_contables cc on cc.id = h.idcuenta_contable
order by registrado_at desc, version desc;

-------------------------------------------------
-- 8. MÓDULO 5 · ASISTENCIAS
-------------------------------------------------

create table if not exists asistencias_slots (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  hora time not null,
  descripcion text,
  activo boolean not null default true,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id)
);

create table if not exists asistencias_base_slots (
  id uuid primary key default gen_random_uuid(),
  idbase uuid not null references bases(id) on delete cascade,
  idslot uuid not null references asistencias_slots(id) on delete cascade,
  dia_semana text not null default 'lunes'
    check (dia_semana in ('lunes','martes','miercoles','jueves','viernes','sabado','domingo')),
  activo boolean not null default true,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  unique (idbase, idslot, dia_semana)
);

create table if not exists asistencias_excepciones (
  id uuid primary key default gen_random_uuid(),
  idbase uuid not null references bases(id) on delete cascade,
  idslot uuid not null references asistencias_slots(id) on delete cascade,
  fecha date,
  dia_semana text
    check (dia_semana in ('lunes','martes','miercoles','jueves','viernes','sabado','domingo')),
  tipo text not null default 'ausencia' check (tipo in ('ausencia','reemplazo')),
  motivo text,
  activo boolean not null default true,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  check (fecha is not null or dia_semana is not null)
);

create table if not exists asistencias_registro (
  id uuid primary key default gen_random_uuid(),
  idbase uuid not null references bases(id) on delete cascade,
  idslot uuid not null references asistencias_slots(id) on delete cascade,
  fecha date not null,
  estado text not null default 'falta' check (estado in ('falta','asistio','justificado')),
  observacion text,
  registrado_at timestamptz default now(),
  editado_at timestamptz,
  registrado_por uuid references auth.users(id),
  editado_por uuid references auth.users(id),
  unique (idbase, idslot, fecha)
);

create or replace view public.v_asistencias_slots as
select
  s.id,
  s.nombre,
  s.hora,
  s.descripcion,
  s.activo,
  s.registrado_at,
  s.registrado_por,
  s.editado_at,
  s.editado_por
from asistencias_slots s;

create or replace view public.v_asistencias_base_slots as
select
  abs.id,
  abs.idbase,
  b.nombre as base_nombre,
  abs.idslot,
  s.nombre as slot_nombre,
  s.hora as slot_hora,
  abs.dia_semana,
  abs.activo,
  abs.registrado_at,
  abs.registrado_por,
  abs.editado_at,
  abs.editado_por
from asistencias_base_slots abs
join bases b on b.id = abs.idbase
join asistencias_slots s on s.id = abs.idslot;

create or replace view public.v_asistencias_pendientes as
with params as (
  select
    current_date as fecha,
    trim(translate(lower(to_char(current_date, 'TMDay')), 'áéíóú', 'aeiou')) as dia
),
agenda as (
  select
    abs.idbase,
    abs.idslot,
    abs.dia_semana
  from asistencias_base_slots abs
  join asistencias_slots s on s.id = abs.idslot
  cross join params p
  where abs.activo = true
    and s.activo = true
    and abs.dia_semana = p.dia
    and not exists (
      select 1
      from asistencias_excepciones e
      where e.activo = true
        and e.tipo = 'ausencia'
        and e.idbase = abs.idbase
        and e.idslot = abs.idslot
        and (
          (e.fecha is not null and e.fecha = p.fecha)
          or (e.fecha is null and e.dia_semana is not null and e.dia_semana = p.dia)
        )
    )
  union
  select
    e.idbase,
    e.idslot,
    coalesce(e.dia_semana, p.dia) as dia_semana
  from asistencias_excepciones e
  join asistencias_slots s on s.id = e.idslot
  cross join params p
  where e.activo = true
    and e.tipo = 'reemplazo'
    and s.activo = true
    and (
      (e.fecha is not null and e.fecha = p.fecha)
      or (e.fecha is null and e.dia_semana is not null and e.dia_semana = p.dia)
    )
)
select
  ag.idbase,
  b.nombre as base_nombre,
  ag.idslot,
  s.nombre as slot_nombre,
  s.hora as slot_hora,
  ag.dia_semana,
  p.fecha,
  coalesce(ar.estado, 'falta'::text) as estado,
  ar.observacion,
  ar.id as id
from agenda ag
join bases b on b.id = ag.idbase
join asistencias_slots s on s.id = ag.idslot
cross join params p
left join asistencias_registro ar
  on ar.idbase = ag.idbase
 and ar.idslot = ag.idslot
 and ar.fecha = p.fecha;

create or replace view public.v_asistencias_historial as
select
  ar.id,
  ar.idbase,
  b.nombre as base_nombre,
  ar.idslot,
  s.nombre as slot_nombre,
  s.hora as slot_hora,
  ar.fecha,
  trim(translate(lower(to_char(ar.fecha, 'TMDay')), 'áéíóú', 'aeiou')) as dia_semana,
  ar.estado,
  ar.observacion,
  ar.registrado_at,
  ar.registrado_por,
  ar.editado_at,
  ar.editado_por
from asistencias_registro ar
join bases b on b.id = ar.idbase
join asistencias_slots s on s.id = ar.idslot;

create or replace view public.v_asistencias_permisos as
select
  e.id,
  e.idbase,
  b.nombre as base_nombre,
  e.idslot,
  s.nombre as slot_nombre,
  s.hora as slot_hora,
  e.fecha,
  e.dia_semana,
  e.tipo,
  e.motivo,
  e.activo,
  e.registrado_at,
  e.registrado_por,
  e.editado_at,
  e.editado_por
from asistencias_excepciones e
join bases b on b.id = e.idbase
join asistencias_slots s on s.id = e.idslot;

-------------------------------------------------
-- 9. MÓDULO 6 · COMUNICACIONES / INCIDENCIAS
-------------------------------------------------

create table if not exists incidentes (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  descripcion text,
  categoria text,
  severidad text not null default 'media' check (severidad in ('baja','media','alta','critica')),
  estado text not null default 'abierto' check (estado in ('abierto','investigacion','resuelto','cerrado')),
  responsabilidad text check (responsabilidad in ('cliente','base','operador','externo')),
  idpedido uuid references pedidos(id) on delete set null,
  idmovimiento uuid references movimientopedidos(id) on delete set null,
  idcliente uuid references clientes(id) on delete set null,
  idbase uuid references bases(id) on delete set null,
  idusuario uuid references auth.users(id) on delete set null,
  registrado_at timestamptz default now(),
  registrado_por uuid references auth.users(id),
  editado_at timestamptz,
  editado_por uuid references auth.users(id)
);

create table if not exists incidentes_historial (
  id uuid primary key default gen_random_uuid(),
  idincidente uuid not null references incidentes(id) on delete cascade,
  comentario text,
  estado text,
  registrado_at timestamptz default now(),
  registrado_por uuid references auth.users(id)
);

create table if not exists comunicaciones_internas (
  id uuid primary key default gen_random_uuid(),
  idbase uuid references bases(id) on delete set null,
  asunto text not null,
  mensaje text not null,
  prioridad text not null default 'media' check (prioridad in ('baja','media','alta')),
  estado text not null default 'pendiente' check (estado in ('pendiente','en_proceso','atendido','cerrado','finalizado')),
  registrado_at timestamptz default now(),
  registrado_por uuid references auth.users(id),
  editado_at timestamptz,
  editado_por uuid references auth.users(id)
);

create table if not exists comunicaciones_internas_respuestas (
  id uuid primary key default gen_random_uuid(),
  idcomunicacion uuid not null references comunicaciones_internas(id) on delete cascade,
  mensaje text not null,
  registrado_at timestamptz default now(),
  registrado_por uuid references auth.users(id)
);

create or replace view public.v_incidencias_general as
select
  i.id,
  i.titulo,
  i.descripcion,
  i.categoria,
  i.severidad,
  i.estado,
  i.responsabilidad,
  i.idpedido,
  p.idcliente,
  cli.nombre as cliente_nombre,
  i.idmovimiento,
  i.idbase,
  b.nombre as base_nombre,
  i.idusuario,
  i.registrado_at,
  i.registrado_por,
  i.editado_at,
  i.editado_por
from incidentes i
left join pedidos p on p.id = i.idpedido
left join clientes cli on cli.id = coalesce(i.idcliente, p.idcliente)
left join bases b on b.id = i.idbase;

create or replace view public.v_incidencias_historial as
select
  h.id,
  h.idincidente,
  h.comentario,
  h.estado,
  h.registrado_at,
  h.registrado_por,
  i.titulo,
  i.estado as estado_actual
from incidentes_historial h
join incidentes i on i.id = h.idincidente;

create or replace view public.v_comunicaciones_internas as
select
  c.id,
  c.idbase,
  b.nombre as base_nombre,
  c.asunto,
  c.mensaje,
  c.prioridad,
  c.estado,
  c.registrado_at,
  c.registrado_por,
  c.editado_at,
  c.editado_por
from comunicaciones_internas c
left join bases b on b.id = c.idbase;

create or replace view public.v_comunicaciones_internas_bases as
select
  vc.*
from public.v_comunicaciones_internas vc
where exists (
  select 1
  from public.perfiles pf
  where pf.user_id = auth.uid()
    and pf.activo = true
    and pf.idbase is not null
    and pf.idbase = vc.idbase
);

create or replace view public.v_comunicaciones_respuestas as
select
  r.id,
  r.idcomunicacion,
  c.asunto,
  r.mensaje,
  r.registrado_at,
  r.registrado_por
from comunicaciones_internas_respuestas r
join comunicaciones_internas c on c.id = r.idcomunicacion;

create or replace function public.fn_asistencias_generar_registros(p_fecha date default current_date)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_inserted integer;
  v_dia text;
begin
  v_dia := trim(translate(lower(to_char(p_fecha, 'TMDay')), 'áéíóú', 'aeiou'));
  insert into public.asistencias_registro (idbase, idslot, fecha, estado, registrado_por, editado_por)
  select
    agenda.idbase,
    agenda.idslot,
    p_fecha,
    'falta',
    coalesce(auth.uid(), agenda.registrado_por),
    coalesce(auth.uid(), agenda.registrado_por)
  from (
    select
      abs.idbase,
      abs.idslot,
      abs.registrado_por
    from public.asistencias_base_slots abs
    join public.asistencias_slots s on s.id = abs.idslot
    where abs.activo = true
      and s.activo = true
      and abs.dia_semana = v_dia
      and not exists (
        select 1
        from public.asistencias_excepciones e
        where e.activo = true
          and e.tipo = 'ausencia'
          and e.idbase = abs.idbase
          and e.idslot = abs.idslot
          and (
            (e.fecha is not null and e.fecha = p_fecha)
            or (e.fecha is null and e.dia_semana is not null and e.dia_semana = v_dia)
          )
      )
    union
    select
      e.idbase,
      e.idslot,
      e.registrado_por
    from public.asistencias_excepciones e
    join public.asistencias_slots s on s.id = e.idslot
    where e.activo = true
      and e.tipo = 'reemplazo'
      and s.activo = true
      and (
        (e.fecha is not null and e.fecha = p_fecha)
        or (e.fecha is null and e.dia_semana is not null and e.dia_semana = v_dia)
      )
  ) as agenda
  where not exists (
    select 1
    from public.asistencias_registro ar
    where ar.idbase = agenda.idbase
      and ar.idslot = agenda.idslot
      and ar.fecha = p_fecha
  );

  get diagnostics v_inserted = row_count;
  return coalesce(v_inserted, 0);
end;
$$;

-------------------------------------------------
-- 10. MÓDULO 7 · REPORTES / GANANCIAS
-------------------------------------------------

create or replace view public.v_reportes_pedidos_detalle_costos as
select
  p.id as pedido_id,
  p.idcliente,
  cli.nombre as cliente_nombre,
  p.registrado_at,
  dp.idproducto,
  dp.cantidad,
  dp.precioventa,
  dp.precio_unitario,
  coalesce(public.fn_producto_costo_promedio(dp.idproducto), 0)::numeric(18,6)
    as costo_unitario
from public.pedidos p
join public.v_detallepedidos_ajustado dp on dp.idpedido = p.id
left join public.clientes cli on cli.id = p.idcliente
where p.estado = 'activo';

create or replace view public.v_reportes_pedidos_ganancia as
with resumen as (
  select
    d.pedido_id,
    sum(d.precioventa)::numeric(14,2) as total_venta,
    sum(d.cantidad * d.costo_unitario)::numeric(14,2) as total_costo
  from public.v_reportes_pedidos_detalle_costos d
  group by d.pedido_id
)
select
  p.id as id,
  p.codigo,
  p.fechapedido,
  p.registrado_at,
  p.idcliente,
  p.cliente_nombre,
  p.cliente_numero,
  p.estado_general,
  r.total_venta,
  r.total_costo,
  (r.total_venta - r.total_costo)::numeric(14,2) as ganancia,
  case
    when r.total_venta = 0 then 0
    else (
      (r.total_venta - r.total_costo) / nullif(r.total_venta, 0)
    ) * 100
  end::numeric(9,4) as margen_porcentaje
from public.v_pedido_vistageneral p
join resumen r on r.pedido_id = p.id;

create or replace view public.v_reportes_pedidos_detalle_ganancia as
select
  concat_ws('::', d.pedido_id::text, d.idproducto::text) as id,
  d.pedido_id,
  p.codigo as pedido_codigo,
  p.registrado_at,
  d.idcliente,
  d.cliente_nombre,
  d.idproducto,
  prod.nombre as producto_nombre,
  d.cantidad,
  d.precio_unitario,
  d.precioventa,
  d.costo_unitario,
  (d.cantidad * d.costo_unitario)::numeric(14,2) as costo_total,
  (d.precioventa - (d.cantidad * d.costo_unitario))::numeric(14,2) as ganancia,
  case
    when d.precioventa = 0 then 0
    else (
      (d.precioventa - (d.cantidad * d.costo_unitario))
      / nullif(d.precioventa, 0)
    ) * 100
  end::numeric(9,4) as margen_porcentaje
from public.v_reportes_pedidos_detalle_costos d
join public.v_pedido_vistageneral p on p.id = d.pedido_id
left join public.productos prod on prod.id = d.idproducto;

create or replace view public.v_reportes_ganancia_diaria as
select
  date_trunc('day', d.registrado_at)::date as fecha,
  count(distinct d.pedido_id)::bigint as pedidos,
  sum(d.precioventa)::numeric(14,2) as total_venta,
  sum(d.cantidad * d.costo_unitario)::numeric(14,2) as total_costo,
  (
    sum(d.precioventa) - sum(d.cantidad * d.costo_unitario)
  )::numeric(14,2) as ganancia,
  case
    when sum(d.precioventa) = 0 then 0
    else (
      (sum(d.precioventa) - sum(d.cantidad * d.costo_unitario))
      / nullif(sum(d.precioventa), 0)
    ) * 100
  end::numeric(9,4) as margen_porcentaje
from public.v_reportes_pedidos_detalle_costos d
group by fecha
order by fecha desc;

create or replace view public.v_reportes_ganancia_mensual as
select
  date_trunc('month', d.registrado_at)::date as periodo,
  count(distinct d.pedido_id)::bigint as pedidos,
  sum(d.precioventa)::numeric(14,2) as total_venta,
  sum(d.cantidad * d.costo_unitario)::numeric(14,2) as total_costo,
  (
    sum(d.precioventa) - sum(d.cantidad * d.costo_unitario)
  )::numeric(14,2) as ganancia,
  case
    when sum(d.precioventa) = 0 then 0
    else (
      (sum(d.precioventa) - sum(d.cantidad * d.costo_unitario))
      / nullif(sum(d.precioventa), 0)
    ) * 100
  end::numeric(9,4) as margen_porcentaje
from public.v_reportes_pedidos_detalle_costos d
group by periodo
order by periodo desc;

create or replace view public.v_reportes_ganancia_mensual_clientes as
select
  date_trunc('month', d.registrado_at)::date as periodo,
  d.idcliente,
  d.cliente_nombre,
  count(distinct d.pedido_id)::bigint as pedidos,
  sum(d.precioventa)::numeric(14,2) as total_venta,
  sum(d.cantidad * d.costo_unitario)::numeric(14,2) as total_costo,
  (
    sum(d.precioventa) - sum(d.cantidad * d.costo_unitario)
  )::numeric(14,2) as ganancia,
  case
    when sum(d.precioventa) = 0 then 0
    else (
      (sum(d.precioventa) - sum(d.cantidad * d.costo_unitario))
      / nullif(sum(d.precioventa), 0)
    ) * 100
  end::numeric(9,4) as margen_porcentaje
from public.v_reportes_pedidos_detalle_costos d
group by periodo, d.idcliente, d.cliente_nombre
order by periodo desc, d.cliente_nombre;

create or replace view public.v_reportes_ganancia_mensual_productos as
select
  date_trunc('month', d.registrado_at)::date as periodo,
  d.idproducto,
  prod.nombre as producto_nombre,
  count(distinct d.pedido_id)::bigint as pedidos,
  sum(d.precioventa)::numeric(14,2) as total_venta,
  sum(d.cantidad * d.costo_unitario)::numeric(14,2) as total_costo,
  (
    sum(d.precioventa) - sum(d.cantidad * d.costo_unitario)
  )::numeric(14,2) as ganancia,
  case
    when sum(d.precioventa) = 0 then 0
    else (
      (sum(d.precioventa) - sum(d.cantidad * d.costo_unitario))
      / nullif(sum(d.precioventa), 0)
    ) * 100
  end::numeric(9,4) as margen_porcentaje
from public.v_reportes_pedidos_detalle_costos d
left join public.productos prod on prod.id = d.idproducto
group by periodo, d.idproducto, prod.nombre
order by periodo desc, prod.nombre;

create or replace view public.v_reportes_ganancia_mensual_bases as
with detalle as (
  select
    pedido_id as idpedido,
    idproducto,
    cantidad,
    precioventa,
    precio_unitario,
    costo_unitario
  from public.v_reportes_pedidos_detalle_costos
),
movimientos as (
  select
    m.idpedido,
    m.idbase,
    b.nombre as base_nombre,
    m.fecharegistro,
    dmp.idproducto,
    dmp.cantidad
  from public.movimientopedidos m
  join public.detallemovimientopedidos dmp on dmp.idmovimiento = m.id
  left join public.bases b on b.id = m.idbase
  where m.idbase is not null
    and m.estado = 'activo'
    and dmp.estado = 'activo'
)
select
  date_trunc('month', mv.fecharegistro)::date as periodo,
  mv.idbase,
  mv.base_nombre,
  count(distinct mv.idpedido)::bigint as pedidos,
  sum(mv.cantidad * det.precio_unitario)::numeric(14,2) as total_venta,
  sum(mv.cantidad * det.costo_unitario)::numeric(14,2) as total_costo,
  (
    sum(mv.cantidad * det.precio_unitario) - sum(mv.cantidad * det.costo_unitario)
  )::numeric(14,2) as ganancia,
  case
    when sum(mv.cantidad * det.precio_unitario) = 0 then 0
    else (
      (
        sum(mv.cantidad * det.precio_unitario)
        - sum(mv.cantidad * det.costo_unitario)
      ) / nullif(sum(mv.cantidad * det.precio_unitario), 0)
    ) * 100
  end::numeric(9,4) as margen_porcentaje
from movimientos mv
join detalle det
  on det.idpedido = mv.idpedido
 and det.idproducto = mv.idproducto
group by periodo, mv.idbase, mv.base_nombre
order by periodo desc, mv.base_nombre;

create or replace view public.v_reportes_meses as
select
  to_char(periodo, 'YYYY-MM') as id,
  periodo,
  to_char(periodo, 'YYYY-MM') as mes,
  pedidos,
  total_venta,
  total_costo,
  ganancia,
  margen_porcentaje
from public.v_reportes_ganancia_mensual
order by periodo desc;

-------------------------------------------------
-- 11. MÓDULO CONFIGURACIÓN · Vista de configuración
-------------------------------------------------

create table if not exists ui_section_field_overrides (
  section_id text references ui_sections(id) on delete cascade,
  field text not null,
  label text,
  orden int,
  read_only boolean,
  requerido boolean,
  widget_type text,
  reference_schema text,
  reference_relation text,
  reference_label_column text,
  default_value text,
  primary key (section_id, field)
);

create or replace view public.v_ui_section_fields as
select
  s.section_id,
  c.table_schema as form_schema,
  c.table_name as form_relation,
  c.column_name as field,
  coalesce(o.label, initcap(replace(c.column_name, '_', ' '))) as label,
  c.data_type,
  coalesce(o.requerido, (c.is_nullable = 'NO')) as requerido,
  (c.column_default is not null) as has_default,
  coalesce(o.read_only, (c.column_name = 'id')) as read_only,
  coalesce(o.orden, c.ordinal_position) as orden,
  o.widget_type,
  coalesce(o.reference_schema, 'public') as reference_schema,
  o.reference_relation,
  o.reference_label_column,
  o.default_value
from public.ui_section_data_sources s
join information_schema.columns c
  on c.table_schema = coalesce(nullif(s.form_schema, ''), 'public')
 and c.table_name = s.form_relation
left join public.ui_section_field_overrides o
  on o.section_id = s.section_id
 and o.field = c.column_name
where coalesce(s.form_relation, '') <> '';

insert into public.ui_section_field_overrides (
  section_id,
  field,
  label,
  orden,
  read_only,
  requerido,
  widget_type,
  reference_schema,
  reference_relation,
  reference_label_column,
  default_value
) values
  ('pedidos_tabla', 'registrado_at', 'Fecha de registro', 1, true, false, null, null, null, null, 'now'),
  ('pedidos_tabla', 'idcliente', 'Cliente', 2, false, true, 'reference', 'public', 'clientes', 'nombre', null),
  ('usuarios', 'rol', 'Rol', 3, false, true, 'reference', 'public', 'v_security_roles', 'descripcion', 'atencion')
on conflict (section_id, field) do update set
  label = excluded.label,
  orden = excluded.orden,
  read_only = excluded.read_only,
  requerido = excluded.requerido,
  widget_type = excluded.widget_type,
  reference_schema = excluded.reference_schema,
  reference_relation = excluded.reference_relation,
  reference_label_column = excluded.reference_label_column,
  default_value = excluded.default_value;

-------------------------------------------------
-- Contabilidad (desde posgres_contabilidad.sql)

-------------------------------------------------
-- Inserts manuales para catálogos (ambiente local)
-------------------------------------------------

-- Plan de cuentas mínimo para operar finanzas.
-- Plan de cuentas mínimo para operar finanzas.
-- Consulta docs/contabilidad.md para ver qué procesos disparan cada cuenta.
insert into public.cuentas_contables (id, codigo, nombre, tipo, es_terminal)
values
  ('11111111-0000-0000-0000-000000000010', '10', 'Caja y Bancos', 'activo', false),
  ('11111111-0000-0000-0000-000000000015', '12', 'Cuentas por cobrar', 'activo', false),
  ('11111111-0000-0000-0000-000000000020', '20', 'Inventarios', 'activo', false),
  ('11111111-0000-0000-0000-000000000050', '50', 'Patrimonio', 'patrimonio', false),
  ('11111111-0000-0000-0000-000000000069', '69', 'Costo de ventas', 'gasto', false),
  ('11111111-0000-0000-0000-000000000048', '48', 'Ingresos diferidos', 'pasivo', false),
  ('11111111-0000-0000-0000-000000000040', '40', 'Cuentas por pagar', 'pasivo', false),
  ('11111111-0000-0000-0000-000000000060', '60', 'Gastos operativos', 'gasto', false),
  ('11111111-0000-0000-0000-000000000070', '70', 'Ingresos', 'ingreso', false),
  ('11111111-0000-0000-0000-000000000080', '80', 'Ajustes', 'gasto', false),
  ('11111111-0000-0000-0000-000000000090', '90', 'Compras', 'gasto', false),
  ('11111111-0000-0000-0000-000000000095', '95', 'Fabricación', 'gasto', false)
on conflict (codigo) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  es_terminal = excluded.es_terminal;

insert into public.cuentas_contables (id, codigo, nombre, tipo, parent_id, es_terminal)
values
  (
    '55555555-0000-0000-0000-000000000010',
    '12.01',
    'Clientes por cobrar',
    'activo',
    (select id from public.cuentas_contables where codigo = '12'),
    true
  ),
  (
    '55555555-0000-0000-0000-000000000020',
    '48.01',
    'Pedidos por entregar',
    'pasivo',
    (select id from public.cuentas_contables where codigo = '48'),
    true
  ),
  (
    '22222222-0000-0000-0000-000000000010',
    '10.01',
    'Cuenta bancaria - Operaciones',
    'activo',
    '11111111-0000-0000-0000-000000000010',
    true
  ),
  (
    '22222222-0000-0000-0000-000000000020',
    '20.01',
    'Inventario de mercaderías',
    'activo',
    '11111111-0000-0000-0000-000000000020',
    true
  ),
  (
    '22222222-0000-0000-0000-000000000022',
    '20.03',
    'Producción en proceso',
    'activo',
    '11111111-0000-0000-0000-000000000020',
    true
  ),
  (
    '22222222-0000-0000-0000-000000000021',
    '20.02',
    'Mercaderías en tránsito',
    'activo',
    '11111111-0000-0000-0000-000000000020',
    true
  ),
  (
    '22222222-0000-0000-0000-000000000040',
    '40.01',
    'Proveedores por pagar',
    'pasivo',
    '11111111-0000-0000-0000-000000000040',
    true
  ),
  (
    '55555555-0000-0000-0000-000000000050',
    '50.01',
    'Ganancia del mes',
    'patrimonio',
    (select id from public.cuentas_contables where codigo = '50'),
    true
  ),
  (
    '55555555-0000-0000-0000-000000000051',
    '50.02',
    'Ganancia acumulada',
    'patrimonio',
    (select id from public.cuentas_contables where codigo = '50'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000010',
    '60.01',
    'Movilidad',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60'),
    false
  ),
  (
    '33333333-0000-0000-0000-000000000016',
    '60.02',
    'Comidas',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60'),
    false
  ),
  (
    '33333333-0000-0000-0000-000000000019',
    '60.03',
    'Packing',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60'),
    false
  ),
  (
    '33333333-0000-0000-0000-000000000031',
    '60.04',
    'Financieros',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60'),
    false
  ),
  (
    '33333333-0000-0000-0000-000000000035',
    '60.05',
    'Envíos y logística',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60'),
    false
  ),
  (
    '33333333-0000-0000-0000-000000000045',
    '60.06',
    'Otros operativos',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60'),
    false
  ),
  (
    '44444444-0000-0000-0000-000000000001',
    '70.01',
    'Ingresos - Ingreso',
    'ingreso',
    (select id from public.cuentas_contables where codigo = '70'),
    true
  ),
  (
    '44444444-0000-0000-0000-000000000002',
    '80.01',
    'Ajustes - Ajuste',
    'gasto',
    (select id from public.cuentas_contables where codigo = '80'),
    true
  ),
  (
    '44444444-0000-0000-0000-000000000004',
    '80.02',
    'Ajuste fabricación',
    'gasto',
    (select id from public.cuentas_contables where codigo = '80'),
    true
  ),
  (
    '66666666-0000-0000-0000-000000000010',
    '69.01',
    'Costo de mercaderías vendidas',
    'gasto',
    (select id from public.cuentas_contables where codigo = '69'),
    true
  ),
  (
    '44444444-0000-0000-0000-000000000003',
    '95.01',
    'Fabricación - Fabricación',
    'gasto',
    (select id from public.cuentas_contables where codigo = '95'),
    true
  )
on conflict (codigo) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  parent_id = excluded.parent_id,
  es_terminal = excluded.es_terminal;

insert into public.cuentas_contables (id, codigo, nombre, tipo, parent_id, es_terminal)
values
  (
    '33333333-0000-0000-0000-000000000011',
    '60.01.01',
    'Movilidad - Transferencias',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.01'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000012',
    '60.01.02',
    'Movilidad - Compras',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.01'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000013',
    '60.01.03',
    'Movilidad - Representación',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.01'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000014',
    '60.01.04',
    'Movilidad - Otros',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.01'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000015',
    '60.01.05',
    'Movilidad - Recargas celulares',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.01'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000017',
    '60.02.01',
    'Comida - Representación',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.02'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000018',
    '60.02.02',
    'Comida - Otros',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.02'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000020',
    '60.03.01',
    'Packing - Cajas',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000021',
    '60.03.02',
    'Packing - Bolsas',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000022',
    '60.03.03',
    'Packing - Selladora',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000023',
    '60.03.04',
    'Packing - Plástico',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000024',
    '60.03.05',
    'Packing - Balanzas',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000025',
    '60.03.06',
    'Packing - Ziplocs',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000026',
    '60.03.07',
    'Packing - Trilaminados',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000027',
    '60.03.08',
    'Packing - Impresora',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000028',
    '60.03.09',
    'Packing - Microondas',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000029',
    '60.03.10',
    'Packing - Tappers apoyo',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000030',
    '60.03.11',
    'Packing - Otros',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.03'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000032',
    '60.04.01',
    'Financieros - Comisiones',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.04'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000033',
    '60.04.02',
    'Financieros - Intereses',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.04'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000034',
    '60.04.03',
    'Financieros - Otros',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.04'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000036',
    '60.05.01',
    'Logística - Delivery provincia',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.05'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000037',
    '60.05.02',
    'Logística - Taxi / Courier',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.05'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000038',
    '60.05.03',
    'Logística - Pagos agencia',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.05'),
    true
  ),
  (
    '33333333-0000-0000-0000-000000000039',
    '60.05.04',
    'Logística - Otros',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.05'),
    true
  )
on conflict (codigo) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  parent_id = excluded.parent_id,
  es_terminal = excluded.es_terminal;

insert into public.cuentas_contables (id, codigo, nombre, tipo, parent_id, es_terminal)
values
  (
    '33333333-0000-0000-0000-000000000046',
    '60.06.01',
    'Otros operativos - Generales',
    'gasto',
    (select id from public.cuentas_contables where codigo = '60.06'),
    true
  )
on conflict (codigo) do update set
  nombre = excluded.nombre,
  tipo = excluded.tipo,
  parent_id = excluded.parent_id,
  es_terminal = excluded.es_terminal;

update public.cuentas_contables
set es_gasto_operativo = true
where es_terminal = true and codigo like '60.%';
-- Operaciones (desde posgres_operaciones.sql)



-------------------------------------------------
-- Inserts manuales para catálogos operativos
-------------------------------------------------

-- Categoría principal para los nuevos productos.
insert into public.categorias (id, nombre)
values
  ('11111111-1111-1111-1111-111111111111', 'weed')
on conflict (id) do update set
  nombre = excluded.nombre;

-------------------------------------------------
-- Productos base (propiedades de compra/venta/fabricación)
-------------------------------------------------
insert into public.productos (
  id,
  nombre,
  idcategoria,
  activo,
  es_para_venta,
  es_para_compra
)
values
  -- Stand Mp (producto fabricado y también se puede comprar)
  (
    '22222222-1111-1111-1111-111111111111',
    'Stand Mp',
    '11111111-1111-1111-1111-111111111111',
    true,
    false,
    true
  ),
  -- Stand (venta)
  (
    '22222222-2222-2222-2222-222222222222',
    'Stand',
    '11111111-1111-1111-1111-111111111111',
    true,
    true,
    false
  ),
  -- Maldi (venta)
  (
    '22222222-3333-3333-3333-333333333333',
    'Maldi',
    '11111111-1111-1111-1111-111111111111',
    true,
    true,
    false
  ),
  -- Tierra (resultado adicional)
  (
    '22222222-4444-4444-4444-444444444444',
    'Tierra',
    '11111111-1111-1111-1111-111111111111',
    true,
    false,
    false
  ),
  -- Ak47 (compra y venta)
  (
    '22222222-5555-5555-5555-555555555555',
    'Ak47',
    '11111111-1111-1111-1111-111111111111',
    true,
    true,
    true
  ),
  -- Agua (compra y venta, se usa como insumo)
  (
    '22222222-6666-6666-6666-666666666666',
    'Agua',
    null,
    true,
    true,
    true
  ),
  -- Tutu (resultado de la receta de Agua)
  (
    '22222222-7777-7777-7777-777777777777',
    'Tutu',
    null,
    true,
    true,
    false
  )
on conflict (id) do update set
  nombre = excluded.nombre,
  idcategoria = excluded.idcategoria,
  activo = excluded.activo,
  es_para_venta = excluded.es_para_venta,
  es_para_compra = excluded.es_para_compra;

-------------------------------------------------
-- Recetas para los productos fabricados
-------------------------------------------------
insert into public.recetas (id, nombre, activo, notas)
values
  ('33333333-1111-1111-1111-111111111111', 'Proceso Stand Mp', true, 'Stand Mp se separa en Stand, Maldi y Tierra.'),
  ('33333333-2222-2222-2222-222222222222', 'Agua hacia Tutu', true, 'Transforma agua en tutu.')
on conflict (id) do update set
  nombre = excluded.nombre,
  activo = excluded.activo,
  notas = excluded.notas;

-- Insumos de las recetas (entradas)
insert into public.recetas_insumos (id, idreceta, idproducto, cantidad)
values
  ('44444444-1111-1111-1111-111111111111', '33333333-1111-1111-1111-111111111111', '22222222-1111-1111-1111-111111111111', 1),
  ('44444444-2222-2222-2222-222222222222', '33333333-2222-2222-2222-222222222222', '22222222-6666-6666-6666-666666666666', 1)
on conflict (id) do update set
  idreceta = excluded.idreceta,
  idproducto = excluded.idproducto,
  cantidad = excluded.cantidad;

-- Resultados de las recetas (salidas)
insert into public.recetas_resultados (id, idreceta, idproducto, cantidad)
values
  ('55555555-1111-1111-1111-111111111111', '33333333-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 1),
  ('55555555-2222-2222-2222-222222222222', '33333333-1111-1111-1111-111111111111', '22222222-3333-3333-3333-333333333333', 1),
  ('55555555-3333-3333-3333-333333333333', '33333333-1111-1111-1111-111111111111', '22222222-4444-4444-4444-444444444444', 1),
  ('55555555-4444-4444-4444-444444444444', '33333333-2222-2222-2222-222222222222', '22222222-7777-7777-7777-777777777777', 1)
on conflict (id) do update set
  idreceta = excluded.idreceta,
  idproducto = excluded.idproducto,
  cantidad = excluded.cantidad;

-------------------------------------------------
-- Proveedor y cuenta bancaria auxiliar
-------------------------------------------------
insert into public.proveedores (id, nombre, numero)
values
  ('66666666-1111-1111-1111-111111111111', 'David', '999999999')
on conflict (id) do update set
  nombre = excluded.nombre,
  numero = excluded.numero;

insert into public.cuentas_bancarias (id, nombre, banco, activa, idcuenta_contable)
values
  (
    '77777777-1111-1111-1111-111111111111',
    'Luis Evaristo',
    'BBVA',
    true,
    '22222222-0000-0000-0000-000000000010'  -- 10.01 Cuenta bancaria - Operaciones
  )
on conflict (id) do update set
  nombre = excluded.nombre,
  banco = excluded.banco,
  activa = excluded.activa,
  idcuenta_contable = excluded.idcuenta_contable;

-------------------------------------------------
-- Bases operativas
-------------------------------------------------
insert into public.bases (id, nombre)
values
  ('88888888-1111-1111-1111-111111111111', 'Cusco'),
  ('88888888-2222-2222-2222-222222222222', 'Leviatan'),
  ('88888888-3333-3333-3333-333333333333', 'Thunder'),
  ('88888888-4444-4444-4444-444444444444', 'Persefone')
on conflict (id) do update set
  nombre = excluded.nombre;

-------------------------------------------------
-- Clientes de prueba con direcciones/contactos
-------------------------------------------------
insert into public.clientes (id, nombre, numero, canal)
values
  ('90000000-0000-0000-0000-000000000001', 'Pedro', '999111222', 'telegram'),
  ('90000000-0000-0000-0000-000000000002', 'Jorge', '999333444', 'telegram'),
  ('90000000-0000-0000-0000-000000000003', 'Alan', '999555666', 'telegram')
on conflict (id) do update set
  nombre = excluded.nombre,
  numero = excluded.numero,
  canal = excluded.canal;

insert into public.direccion (id, idcliente, direccion, referencia)
values
  (
    '91000000-0000-0000-0000-000000000001',
    '90000000-0000-0000-0000-000000000001',
    'Av. Lima 123',
    'Puerta negra'
  ),
  (
    '91000000-0000-0000-0000-000000000002',
    '90000000-0000-0000-0000-000000000002',
    'Jr. Amazonas 456',
    'Frente a la bodega'
  )
on conflict (id) do update set
  idcliente = excluded.idcliente,
  direccion = excluded.direccion,
  referencia = excluded.referencia;

insert into public.numrecibe (id, idcliente, numero, nombre_contacto)
values
  (
    '92000000-0000-0000-0000-000000000001',
    '90000000-0000-0000-0000-000000000001',
    '+51999111222',
    'Pedro Recepción'
  ),
  (
    '92000000-0000-0000-0000-000000000002',
    '90000000-0000-0000-0000-000000000002',
    '+51999333444',
    'Jorge Contacto'
  )
on conflict (id) do update set
  idcliente = excluded.idcliente,
  numero = excluded.numero,
  nombre_contacto = excluded.nombre_contacto;

insert into public.direccion_provincia (
  id,
  idcliente,
  lugar_llegada,
  nombre_completo,
  dni
)
values (
  '93000000-0000-0000-0000-000000000001',
  '90000000-0000-0000-0000-000000000003',
  'Terminal terrestre Cusco',
  'Alan Provincia',
  '12345678'
)
on conflict (id) do update set
  idcliente = excluded.idcliente,
  lugar_llegada = excluded.lugar_llegada,
  nombre_completo = excluded.nombre_completo,
  dni = excluded.dni;

-- Nota: compra demo y su pago se movieron a posgres_seeds_compras_demo.sql.
-- Nota: ingresos de compra y fabricacion demo se movieron a posgres_seeds_ingresos_fabricacion.sql.

-------------------------------------------------
-- Asistencias demo (slots y horarios por base)
-------------------------------------------------
insert into public.asistencias_slots (
  id,
  nombre,
  hora,
  descripcion,
  activo
)
values
  ('d1000000-0000-0000-0000-000000000001', '10:30', '10:30', 'Turno 10:30', true),
  ('d1000000-0000-0000-0000-000000000002', '11:30', '11:30', 'Turno 11:30', true),
  ('d1000000-0000-0000-0000-000000000003', '12:30', '12:30', 'Turno 12:30', true),
  ('d1000000-0000-0000-0000-000000000004', '13:30', '13:30', 'Turno 13:30', true),
  ('d1000000-0000-0000-0000-000000000005', '14:30', '14:30', 'Turno 14:30', true),
  ('d1000000-0000-0000-0000-000000000006', '15:30', '15:30', 'Turno 15:30', true),
  ('d1000000-0000-0000-0000-000000000007', '16:30', '16:30', 'Turno 16:30', true),
  ('d1000000-0000-0000-0000-000000000008', '17:30', '17:30', 'Turno 17:30', true),
  ('d1000000-0000-0000-0000-000000000009', '18:30', '18:30', 'Turno 18:30', true),
  ('d1000000-0000-0000-0000-00000000000a', '19:30', '19:30', 'Turno 19:30', true),
  ('d1000000-0000-0000-0000-00000000000b', '20:30', '20:30', 'Turno 20:30', true),
  ('d1000000-0000-0000-0000-00000000000c', '21:30', '21:30', 'Turno 21:30', true)
on conflict (id) do update set
  nombre = excluded.nombre,
  hora = excluded.hora,
  descripcion = excluded.descripcion,
  activo = excluded.activo;

insert into public.asistencias_base_slots (
  id,
  idbase,
  idslot,
  dia_semana,
  activo
)
values
  (
    'd2000000-0000-0000-0000-000000000001',
    '88888888-1111-1111-1111-111111111111',
    'd1000000-0000-0000-0000-000000000001',
    'lunes',
    true
  ),
  (
    'd2000000-0000-0000-0000-000000000002',
    '88888888-1111-1111-1111-111111111111',
    'd1000000-0000-0000-0000-000000000001',
    'miercoles',
    true
  ),
  (
    'd2000000-0000-0000-0000-000000000003',
    '88888888-1111-1111-1111-111111111111',
    'd1000000-0000-0000-0000-000000000001',
    'viernes',
    true
  ),
  (
    'd2000000-0000-0000-0000-000000000004',
    '88888888-1111-1111-1111-111111111111',
    'd1000000-0000-0000-0000-000000000003',
    'martes',
    true
  ),
  (
    'd2000000-0000-0000-0000-000000000005',
    '88888888-1111-1111-1111-111111111111',
    'd1000000-0000-0000-0000-000000000003',
    'jueves',
    true
  ),
  (
    'd2000000-0000-0000-0000-000000000006',
    '88888888-2222-2222-2222-222222222222',
    'd1000000-0000-0000-0000-000000000005',
    'lunes',
    true
  ),
  (
    'd2000000-0000-0000-0000-000000000007',
    '88888888-2222-2222-2222-222222222222',
    'd1000000-0000-0000-0000-000000000005',
    'miercoles',
    true
  ),
  (
    'd2000000-0000-0000-0000-000000000008',
    '88888888-3333-3333-3333-333333333333',
    'd1000000-0000-0000-0000-000000000002',
    'sabado',
    true
  ),
  (
    'd2000000-0000-0000-0000-000000000009',
    '88888888-4444-4444-4444-444444444444',
    'd1000000-0000-0000-0000-000000000006',
    'domingo',
    true
  )
on conflict (id) do update set
  idbase = excluded.idbase,
  idslot = excluded.idslot,
  dia_semana = excluded.dia_semana,
  activo = excluded.activo;

-- Nota: resultados de fabricacion demo se movieron a posgres_seeds_ingresos_fabricacion.sql.
