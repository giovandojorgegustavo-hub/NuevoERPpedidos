# Vistas y flujo funcional en PedidosERP

Este documento describe cómo funcionan las vistas **Table**, **Detail** y **Form** dentro de PedidosERP, qué botones incorpora cada una y cuál es el flujo estándar para navegar entre ellas. Son las vistas base que necesitamos hoy; más adelante podremos extenderlas o crear variantes personalizadas (Gallery, Map, Dashboard, etc.) según los requerimientos operativos.

## Alcance actual

1. **Table View** (`lib/src/shared/table_view/table_view_template.dart`)  
   Lista registros de una tabla maestra, permite buscar, ordenar, filtrar y ejecutar acciones por fila o en lote.
2. **Detail View** (`lib/src/shared/detail_view/detail_view_template.dart`)  
   Muestra toda la información de un registro específico y expone acciones contextuales (ver historial, duplicar, editar).
3. **Form View** (`lib/src/shared/form_view/form_view_template.dart`)  
   Captura o edita registros con validación, helper text y navegación posterior al guardar.

Con estas tres vistas podemos cubrir la mayoría de los flujos maestros del ERP; cualquier vista adicional será un archivo aparte que siga la misma filosofía declarativa.

## Flujo base por tabla maestra

1. **Ingreso**: El usuario entra por la Table View del módulo (Pedidos, Clientes, Productos, etc.). La vista se alimenta de la tabla o vista de Supabase asignada al módulo.
2. **Selección de registro**:  
   - Al hacer click/tap en una fila se ejecuta la `rowTapAction`, que por defecto abre la Detail View del mismo registro.  
   - Si la vista define acciones de fila (por ejemplo “Completar” o “Imprimir”), estas aparecen como botones en cada fila.
3. **Detalle**: La Detail View carga el registro seleccionado, muestra los campos clave y, si aplica, subtablas (detalles, historial de movimientos, comentarios). En el encabezado se muestran acciones como **Editar**, **Duplicar**, **Eliminar** o cualquier acción personalizada.
4. **Edición**: Al presionar **Editar** en el detalle (o el botón principal “Nuevo” desde la tabla) se abre la Form View correspondiente. Allí el usuario modifica datos y confirma con **Guardar**.
5. **Retorno**: Tras guardar, la Form View ejecuta `finishAction` (volver al detalle, regresar a la tabla o redirigir a otra vista). Si se cancela, se vuelve a la vista anterior sin cambios.

Este comportamiento debe mantenerse consistente en todas las tablas maestras para que la experiencia sea predecible.

## TableViewTemplate

- **Estructura visual**
  - **Header/Toolbar**: título de la vista, descripción (opcional), buscador global, botón de filtros por columna y `primaryAction` (usamos “Nuevo” o “Agregar”).
  - **Tabla**: columnas definidas en `TableViewConfig.columns` y filas en `TableViewConfig.rows`. Cada fila puede mostrar acciones individuales (`rowActions`).
  - **Footer**: cuando hay selección múltiple se habilitan botones de acciones masivas (`bulkActions`).
- **Botones y acciones**
  - `primaryAction`: botón prominente en la esquina derecha (ej. “Registrar pedido”). Suele abrir la Form View en modo alta.
  - `rowTapAction`: se ejecuta al tocar una fila; por defecto abre la Detail View correspondiente usando el ID de la fila.
  - `rowActions`: iconos o menús dentro de cada fila (ej. “Cerrar pedido”, “Imprimir guía”).
  - `bulkActions`: aparecen sólo al seleccionar varias filas (ej. “Exportar”, “Asignar transportista”).
  - `onRefresh`: botón de recarga para sincronizar datos con Supabase.
- **Notas funcionales**
  - Si un módulo no requiere selección múltiple o acciones bulk, basta con dejar esas listas vacías: la UI oculta automáticamente la barra de selección.
  - Podemos deshabilitar filtros por columna marcando `isFilterable = false` en la configuración de la columna.
  - Para personalizaciones futuras (Deck/Card) se puede extender este mismo widget añadiendo un `displayStyle`.

## DetailViewTemplate

- **Estructura visual**
  - **Header**: título (principal) y subtítulo (estatus, código, etc.), botón “atrás” opcional y menú de acciones (tres puntos).
  - **Botones principales**: `headerActions` se renderiza como chips con ícono (por ejemplo “Editar”, “Duplicar”, “Cambiar estado”).  
  - **Campos**: cada `DetailFieldConfig` dibuja una tarjeta con label y valor; puede actuar como referencia (`isReference = true`), mostrando un ícono de flecha que abre otra vista.
  - **Secciones inline**: lista de `InlineTableConfig` para mostrar detalles hijos (detalle del pedido, historial, tareas). Cada sección puede plegarse/expandirse.
  - **Floating Action Button (opcional)**: botón grande al final del detalle, útil para acciones clave (“Crear incidencia”, “Generar viaje”).
- **Botones y acciones típicas**
  - **Editar**: definido en `headerActions` o `floatingAction`, redirige a la Form View en modo edición con los valores iniciales del registro.
  - **Eliminar/Baja**: se puede configurar en `deleteAction`; aparece como icono de basura en el header.
  - **Acciones contextuales**: `moreActions` se muestran en el menú desplegable para mantener limpio el header.
- **Notas funcionales**
  - Si no se requieren subtablas, simplemente no se agrega `inlineSections`.
  - Para View Ref (abrir cliente desde un pedido) basta con marcar el campo como `isReference` y pasar el callback `onReferenceTap`.

## FormViewTemplate

- **Estructura visual**
  - **Header**: título y subtítulo del formulario (ej. “Editar pedido #123”).  
  - **Descripción**: texto opcional para guiar al usuario (restricciones, SLA, etc.).  
  - **Formulario**: lista de controles generados a partir de `FormFieldConfig` (texto, número, fecha/hora, dropdown). Cada campo puede tener helper text, bandera `required`, modo `readOnly`.
  - **Secciones inline**: igual que en Detail, pero aquí nos permiten capturar subregistros (líneas del pedido) dentro del mismo flujo.
  - **Cierre**: botones `Cancelar` y `Guardar`, y opcionalmente un `finishAction` (tile) para navegar a otra vista al terminar.
- **Botones y acciones**
  - **Guardar**: valida el formulario; si todo está correcto ejecuta `onSubmit` con los valores `{campoId: valor}`. Desde ahí se llama a Supabase para insertar/actualizar.
  - **Cancelar**: ejecuta `onCancel` y regresa a la vista anterior sin modificar datos.
  - **Finish action**: aparece después del formulario y antes de los botones; al tocarlo navega a la vista configurada (ej. “Ir al pedido creado”).
- **Notas funcionales**
  - Si no se define `onCancel`, el botón no se muestra (útil para formularios obligatorios).
  - Para edición, basta con pasar `initialValue` en cada campo con el dato existente y reutilizar la misma vista.
  - Cuando se requieran campos especiales (firma, archivos, geolocalización) se pueden añadir nuevos `FormFieldType` sin reescribir el layout.

## Componentes auxiliares

### InlineTableTemplate

- Ubicación: `lib/src/shared/inline_table/inline_table_template.dart`.  
- Emula las vistas de referencia dentro de Detail y Form. Cada sección tiene:
  - Título y botón para colapsar/expandir.
  - Tabla simple (`DataTable`) con columnas y filas provistas por la configuración.
  - Acciones `primary` y `secondary` (ej. “Agregar línea”, “Ver todo”). Si no se definen, la sección muestra sólo la información.
- Cuando el registro aún está en borrador, las filas capturadas se mantienen en memoria (`_pendingInlineRows`) y la plantilla las muestra igual que si ya hubieran sido persistidas.
- Si una sección necesita abrir una vista completa, `ShellPage` usa la misma plantilla de tabla (`TableViewTemplate`) para renderizarla en pantalla completa con buscador, filtros, selección múltiple y acciones `TableAction`.

### ShellPage

- Ubicación: `lib/src/shell/shell_page.dart`.  
- Es el contenedor general de la interfaz:
  - Selecciona el módulo activo, lista sus secciones y permite cambiar el `SectionContentMode` (table/detail/form) en escritorio o móvil.
  - Mantiene el estado de qué registro está seleccionado para que el flujo Tabla → Detalle → Form sea consistente.
  - Incluye acciones globales (ej. cerrar sesión) mediante `GlobalNavAction`.
- También decide cómo renderizar cada inline:
  - Si el `InlineSectionConfig` tiene `renderAsFormFields: true`, los campos de esa tabla hija se renderizan embebidos en el formulario padre, se almacenan como borradores y se insertan en su tabla real al guardar.
  - Si `renderAsFormFields` es `false`, la sección se muestra como una tabla inline clásica y puede abrir la vista completa reutilizando la misma plantilla de tabla.

## Vistas personalizadas a futuro

Aunque hoy sólo utilizamos Table, Detail y Form, el diseño modular nos permite agregar vistas especializadas (Gallery, Map, Calendar, Dashboard, Kanban) cuando sea necesario. La idea es que cada nueva vista:

1. Viva en `lib/src/shared/<tipo>_view`.
2. Exponga una configuración declarativa similar (columns, actions, etc.).
3. Se pueda invocar desde `ShellPage` y compartir el mismo flujo maestro-detalle-formulario.

Mientras no existan esos requerimientos, nos enfocamos en pulir las tres vistas base y en que el flujo descrito arriba sea consistente y funcional en todos los módulos del ERP.
