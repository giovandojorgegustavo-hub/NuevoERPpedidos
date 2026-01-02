# Visión del proyecto al replicar AppSheet

Este documento resume la intención del proyecto **PedidosERP**: construir en Flutter + Supabase la misma lógica modular que ofrece AppSheet (Datos, Vistas, Acciones y Bots) para administrar pedidos, logística y finanzas sin depender de la plataforma propietaria.

## Qué replica cada sesión

| Sesión AppSheet | Qué significa aquí | Cómo se implementa |
| --- | --- | --- |
| **Datos** | Tablas maestras y vistas de reporting. | PostgreSQL/Supabase (`posgres.sql`). |
| **Vistas (UX)** | Listas, formularios, detail views y relaciones. | Widgets reutilizables en `lib/src/shared` y navegación en `lib/src/shell`. |
| **Acciones (Behavior)** | Botones contextualizados por vista y por fila. | `TableAction`, `GlobalNavAction` y procesos en Supabase (RPC o APIs). |
| **Bots (Automation)** | Automatizaciones basadas en eventos. | Triggers/funciones en PostgreSQL + Supabase Functions programadas. |

### 1. Datos

- La capa de datos vive en Supabase (PostgreSQL). Los catálogos, pedidos y módulos operativos se definen en `posgres.sql`. Este script ya incluye seguridad por roles (`security_roles`, `role_modules`) para imitar los permisos de AppSheet.
- Cada módulo expone **tablas maestras** (por ejemplo `pedidos`, `clientes`, `productos`) para registro y **vistas consolidadas** (por ejemplo `v_pedidos_vistageneral`) para lectura completa, como AppSheet diferencia entre tablas y slices/virtual tables.
- Las vistas se registran en `security_resource_modules` para controlar los accesos por rol y permitir que la UI consulte `select` desde Supabase sin exponer más operaciones que las necesarias.
- A futuro, cualquier nueva entidad debe documentarse con:
  1. Tabla física (registro).
  2. Vista enriquecida (lectura y joins).
  3. Roles permitidos y operaciones (`ops` array) para mantener el comportamiento declarativo.

### 2. Vistas (UX)

- AppSheet ofrece Views tipo **Table, Deck, Detail, Form**. En Flutter replicamos esos layouts en `lib/src/shared/table_view`, `detail_view`, `form_view` e `inline_table`. Cada carpeta tiene un `*_template.dart` reutilizable que recibe una configuración (`TableViewConfig`, etc.) igual que AppSheet recibe columnas y acciones.
- `lib/src/shell/shell_page.dart` actúa como el editor UX: lista módulos, secciones y cambia entre modos **table/detail/form** mediante `SectionContentMode`. Así podemos tener, por ejemplo, la vista "Pedidos" mostrando una tabla resumida, un detail view y un formulario de alta en la misma pantalla.
- `lib/src/shell/models.dart` define `ModuleConfig` y `ModuleSection`, equivalente a las pestañas/módulos del editor AppSheet. Allí se asignan íconos, descripciones y se configurarán las vistas reales cuando conectemos la API.
- Para soportar `View Ref`:
  - `InlineTableTemplate` ya permite renderizar colecciones hijas dentro de un detail view.
  - Sólo hay que conectar la configuración a consultas Supabase (`Supabase.instance.client.from(...)`) para filtrar por relación padre–hijo.

### 3. Acciones (Behavior)

- AppSheet separa acciones **globales**, **por vista** y **por fila**. En Flutter:
  - `GlobalNavAction` (definido en `lib/src/shell/models.dart`) maneja acciones de nivel aplicación, como cerrar sesión o saltar a un dashboard.
  - `TableAction` (en `lib/src/shared/table_view/table_view_template.dart`) expone acciones por fila o masivas (bulk). Su `onSelected` recibe la fila/selección para decidir si abre un formulario, ejecuta una llamada RPC o navega a otra vista.
  - `FormViewTemplate` admite `primaryAction` para guardar/validar, replicando acciones tipo “Guardar registro” o “Ejecutar proceso”.
- La lógica de cada acción debe residir en un **servicio Supabase**:
  - Para cambios directos usar `client.from('tabla').insert/update`.
  - Para procesos complejos (por ejemplo cerrar pedido → generar viaje → disparar notificación) crear funciones RPC o Supabase Edge Functions y llamarlas desde la acción.
  - Documentar en una tabla `app_actions` (pendiente) el mapeo vista → acción → permiso, para que sea configurable como AppSheet.

### 4. Bots y automatización

- AppSheet Bots reaccionan a eventos/horarios. En este proyecto la capa de automatización vive en PostgreSQL/Supabase:
  - **Triggers** definidos en `posgres.sql` (por ejemplo `fn_perfiles_handle_new_user`) ejecutan lógica inmediatamente después de `insert`/`update`.
  - **Schedulers**: Supabase Edge Functions o Cron jobs pueden consumir vistas como `v_pedidos_vistageneral` y generar tareas (envío de correo, actualización de estados).
  - **Integraciones externas**: Al igual que AppSheet Bots, cada bot debe tener *disparador* (tabla/vista/evento), *proceso* (función PL/pgSQL o Function) y *tareas* (notificación, inserción, llamada HTTP).
- Recomendación: crear una carpeta `automation/` (pendiente) con definición YAML/Markdown por bot: trigger, condiciones, pasos. Así mantenemos trazabilidad equivalente al Automation editor de AppSheet.

## Intención general del proyecto

1. **Mantener lo declarativo**: la UI no debería contener reglas de negocio, sólo leer configuraciones (tablas/vistas, columnas, acciones habilitadas). Todo se debe poder cambiar modificando datos en Supabase, igual que AppSheet.
2. **Seguridad integrada**: cada componente (vista, acción, bot) consulta los roles declarados en PostgreSQL antes de ejecutarse.
3. **Productividad sin vendor lock-in**: se reemplaza AppSheet pero se conserva su modelo mental para que el equipo operativo pueda documentar la app igual que lo haría en AppSheet, ahora gestionando Flutter + Supabase.

## Próximos pasos sugeridos

1. Crear tablas de configuración (`ui_views`, `ui_sections`, `ui_actions`) en PostgreSQL para almacenar la misma metadata que ahora está hardcodeada en `_mockModules`.
2. Conectar los templates a Supabase usando `StreamBuilder`/`FutureBuilder` para que cada vista consulte las tablas/vistas correspondientes.
3. Añadir documentación de cada bot en `docs/automation/` y scripts SQL que implementen triggers/funciones asociadas.
4. Publicar este documento en el README o en la wiki para que todos entiendan el objetivo al abrir el repo.

Con estas piezas el equipo tendrá una guía clara de cómo replicar cada sesión de AppSheet en el stack Flutter + Supabase.
