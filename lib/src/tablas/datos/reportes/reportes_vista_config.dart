import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource reporteAsistenciaTableroDataSource = SectionDataSource(
  sectionId: 'reporte_asistencia_tablero',
  listSchema: 'public',
  listRelation: 'v_asistencias_pendientes',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'asistencias_registro',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_asistencias_pendientes',
  detailIsView: true,
  listOrderBy: 'slot_hora',
  listOrderAscending: true,
);

const SectionDataSource reportesPedidosDataSource = SectionDataSource(
  sectionId: 'reportes_pedidos',
  listSchema: 'public',
  listRelation: 'v_reportes_pedidos_ganancia',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_reportes_pedidos_ganancia',
  detailIsView: true,
  listOrderBy: 'fechapedido',
  listOrderAscending: false,
);

const SectionDataSource reportesPedidosDetalleDataSource = SectionDataSource(
  sectionId: 'reportes_pedidos_detalle',
  listSchema: 'public',
  listRelation: 'v_reportes_pedidos_detalle_ganancia',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_reportes_pedidos_detalle_ganancia',
  detailIsView: true,
  listOrderBy: 'registrado_at',
  listOrderAscending: false,
);

const SectionDataSource reportesGananciaDiariaDataSource = SectionDataSource(
  sectionId: 'reportes_ganancia_diaria',
  listSchema: 'public',
  listRelation: 'v_reportes_ganancia_diaria',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_reportes_ganancia_diaria',
  detailIsView: true,
  listOrderBy: 'fecha',
  listOrderAscending: false,
);

const SectionDataSource reportesGananciaMensualDataSource = SectionDataSource(
  sectionId: 'reportes_ganancia_mensual',
  listSchema: 'public',
  listRelation: 'v_reportes_ganancia_mensual',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_reportes_ganancia_mensual',
  detailIsView: true,
  listOrderBy: 'periodo',
  listOrderAscending: false,
);

const SectionDataSource reportesGananciaClientesMesesDataSource =
    SectionDataSource(
      sectionId: 'reportes_ganancia_clientes_meses',
      listSchema: 'public',
      listRelation: 'v_reportes_meses',
      listIsView: true,
      formSchema: 'public',
      formRelation: '',
      formIsView: false,
      detailSchema: 'public',
      detailRelation: 'v_reportes_meses',
      detailIsView: true,
      listOrderBy: 'periodo',
      listOrderAscending: false,
    );

const SectionDataSource reportesGananciaProductosMesesDataSource =
    SectionDataSource(
      sectionId: 'reportes_ganancia_productos_meses',
      listSchema: 'public',
      listRelation: 'v_reportes_meses',
      listIsView: true,
      formSchema: 'public',
      formRelation: '',
      formIsView: false,
      detailSchema: 'public',
      detailRelation: 'v_reportes_meses',
      detailIsView: true,
      listOrderBy: 'periodo',
      listOrderAscending: false,
    );

const SectionDataSource reportesGananciaBasesMesesDataSource =
    SectionDataSource(
      sectionId: 'reportes_ganancia_bases_meses',
      listSchema: 'public',
      listRelation: 'v_reportes_meses',
      listIsView: true,
      formSchema: 'public',
      formRelation: '',
      formIsView: false,
      detailSchema: 'public',
      detailRelation: 'v_reportes_meses',
      detailIsView: true,
      listOrderBy: 'periodo',
      listOrderAscending: false,
    );

const List<TableColumnConfig> reporteAsistenciaTableroColumnas = [
  TableColumnConfig(key: 'base_nombre', label: 'Base'),
  TableColumnConfig(key: 'dia_semana', label: 'Dia'),
  TableColumnConfig(key: 'fecha', label: 'Fecha'),
  TableColumnConfig(key: 'slot_nombre', label: 'Slot'),
  TableColumnConfig(key: 'slot_hora', label: 'Hora'),
  TableColumnConfig(key: 'estado', label: 'Estado'),
  TableColumnConfig(key: 'observacion', label: 'Observacion'),
];

const List<TableColumnConfig> reportesPedidosColumnas = [
  TableColumnConfig(key: 'codigo', label: 'Codigo'),
  TableColumnConfig(key: 'fechapedido', label: 'Fecha'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
  TableColumnConfig(key: 'total_venta', label: 'Total venta'),
  TableColumnConfig(key: 'total_costo', label: 'Total costo'),
  TableColumnConfig(key: 'ganancia', label: 'Ganancia'),
  TableColumnConfig(key: 'margen_porcentaje', label: 'Margen %'),
  TableColumnConfig(key: 'estado_general', label: 'Estado'),
];

const List<TableColumnConfig> reportesPedidosDetalleColumnas = [
  TableColumnConfig(key: 'pedido_codigo', label: 'Pedido'),
  TableColumnConfig(key: 'cliente_nombre', label: 'Cliente'),
  TableColumnConfig(key: 'producto_nombre', label: 'Producto'),
  TableColumnConfig(key: 'cantidad', label: 'Cantidad'),
  TableColumnConfig(key: 'precioventa', label: 'Total venta'),
  TableColumnConfig(key: 'costo_total', label: 'Total costo'),
  TableColumnConfig(key: 'ganancia', label: 'Ganancia'),
  TableColumnConfig(key: 'margen_porcentaje', label: 'Margen %'),
];

const List<TableColumnConfig> reportesGananciaDiariaColumnas = [
  TableColumnConfig(key: 'fecha', label: 'Fecha'),
  TableColumnConfig(key: 'pedidos', label: 'Pedidos'),
  TableColumnConfig(key: 'total_venta', label: 'Total venta'),
  TableColumnConfig(key: 'total_costo', label: 'Total costo'),
  TableColumnConfig(key: 'ganancia', label: 'Ganancia'),
  TableColumnConfig(key: 'margen_porcentaje', label: 'Margen %'),
];

const List<TableColumnConfig> reportesGananciaMensualColumnas = [
  TableColumnConfig(key: 'periodo', label: 'Periodo'),
  TableColumnConfig(key: 'pedidos', label: 'Pedidos'),
  TableColumnConfig(key: 'total_venta', label: 'Total venta'),
  TableColumnConfig(key: 'total_costo', label: 'Total costo'),
  TableColumnConfig(key: 'ganancia', label: 'Ganancia'),
  TableColumnConfig(key: 'margen_porcentaje', label: 'Margen %'),
];

const List<TableColumnConfig> reportesMesesColumnas = [
  TableColumnConfig(key: 'mes', label: 'Mes'),
  TableColumnConfig(key: 'pedidos', label: 'Pedidos'),
  TableColumnConfig(key: 'total_venta', label: 'Total venta'),
  TableColumnConfig(key: 'total_costo', label: 'Total costo'),
  TableColumnConfig(key: 'ganancia', label: 'Ganancia'),
  TableColumnConfig(key: 'margen_porcentaje', label: 'Margen %'),
];

const List<DetailFieldOverride> reporteAsistenciaTableroDetalle = [
  DetailFieldOverride(key: 'base_nombre', label: 'Base'),
  DetailFieldOverride(key: 'dia_semana', label: 'Dia'),
  DetailFieldOverride(key: 'fecha', label: 'Fecha'),
  DetailFieldOverride(key: 'slot_nombre', label: 'Slot'),
  DetailFieldOverride(key: 'slot_hora', label: 'Hora'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
  DetailFieldOverride(key: 'observacion', label: 'Observacion'),
];

const List<DetailFieldOverride> reportesPedidosDetalle = [
  DetailFieldOverride(key: 'codigo', label: 'Pedido'),
  DetailFieldOverride(key: 'cliente_nombre', label: 'Cliente'),
  DetailFieldOverride(key: 'total_venta', label: 'Total venta'),
  DetailFieldOverride(key: 'total_costo', label: 'Total costo'),
  DetailFieldOverride(key: 'ganancia', label: 'Ganancia'),
  DetailFieldOverride(key: 'margen_porcentaje', label: 'Margen %'),
  DetailFieldOverride(key: 'estado_general', label: 'Estado'),
  DetailFieldOverride(key: 'fechapedido', label: 'Fecha'),
];

const List<DetailFieldOverride> reportesPedidosDetalleDetalle = [
  DetailFieldOverride(key: 'pedido_codigo', label: 'Pedido'),
  DetailFieldOverride(key: 'cliente_nombre', label: 'Cliente'),
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
  DetailFieldOverride(key: 'precioventa', label: 'Total venta'),
  DetailFieldOverride(key: 'costo_total', label: 'Total costo'),
  DetailFieldOverride(key: 'ganancia', label: 'Ganancia'),
  DetailFieldOverride(key: 'margen_porcentaje', label: 'Margen %'),
];

const List<DetailFieldOverride> reportesGananciaDetalle = [
  DetailFieldOverride(key: 'periodo', label: 'Periodo'),
  DetailFieldOverride(key: 'fecha', label: 'Fecha'),
  DetailFieldOverride(key: 'pedidos', label: 'Pedidos'),
  DetailFieldOverride(key: 'total_venta', label: 'Total venta'),
  DetailFieldOverride(key: 'total_costo', label: 'Total costo'),
  DetailFieldOverride(key: 'ganancia', label: 'Ganancia'),
  DetailFieldOverride(key: 'margen_porcentaje', label: 'Margen %'),
];

const List<DetailFieldOverride> reportesMesesDetalle = [
  DetailFieldOverride(key: 'mes', label: 'Mes'),
  DetailFieldOverride(key: 'pedidos', label: 'Pedidos'),
  DetailFieldOverride(key: 'total_venta', label: 'Total venta'),
  DetailFieldOverride(key: 'total_costo', label: 'Total costo'),
  DetailFieldOverride(key: 'ganancia', label: 'Ganancia'),
  DetailFieldOverride(key: 'margen_porcentaje', label: 'Margen %'),
];

const InlineSectionConfig reportesClientesInlineSection = InlineSectionConfig(
  id: 'reportes_ganancia_clientes_detalle',
  title: 'Ganancia por cliente',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_reportes_ganancia_mensual_clientes',
    orderBy: 'cliente_nombre',
  ),
  foreignKeyColumn: 'periodo',
  foreignKeyParentField: 'periodo',
  columns: [
    InlineSectionColumn(key: 'cliente_nombre', label: 'Cliente'),
    InlineSectionColumn(key: 'pedidos', label: 'Pedidos'),
    InlineSectionColumn(key: 'total_venta', label: 'Total venta'),
    InlineSectionColumn(key: 'total_costo', label: 'Total costo'),
    InlineSectionColumn(key: 'ganancia', label: 'Ganancia'),
    InlineSectionColumn(key: 'margen_porcentaje', label: 'Margen %'),
  ],
  showInForm: false,
  enableCreate: false,
);

const InlineSectionConfig reportesProductosInlineSection = InlineSectionConfig(
  id: 'reportes_ganancia_productos_detalle',
  title: 'Ganancia por producto',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_reportes_ganancia_mensual_productos',
    orderBy: 'producto_nombre',
  ),
  foreignKeyColumn: 'periodo',
  foreignKeyParentField: 'periodo',
  columns: [
    InlineSectionColumn(key: 'producto_nombre', label: 'Producto'),
    InlineSectionColumn(key: 'pedidos', label: 'Pedidos'),
    InlineSectionColumn(key: 'total_venta', label: 'Total venta'),
    InlineSectionColumn(key: 'total_costo', label: 'Total costo'),
    InlineSectionColumn(key: 'ganancia', label: 'Ganancia'),
    InlineSectionColumn(key: 'margen_porcentaje', label: 'Margen %'),
  ],
  showInForm: false,
  enableCreate: false,
);

const InlineSectionConfig reportesBasesInlineSection = InlineSectionConfig(
  id: 'reportes_ganancia_bases_detalle',
  title: 'Ganancia por base',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_reportes_ganancia_mensual_bases',
    orderBy: 'base_nombre',
  ),
  foreignKeyColumn: 'periodo',
  foreignKeyParentField: 'periodo',
  columns: [
    InlineSectionColumn(key: 'base_nombre', label: 'Base'),
    InlineSectionColumn(key: 'pedidos', label: 'Pedidos'),
    InlineSectionColumn(key: 'total_venta', label: 'Total venta'),
    InlineSectionColumn(key: 'total_costo', label: 'Total costo'),
    InlineSectionColumn(key: 'ganancia', label: 'Ganancia'),
    InlineSectionColumn(key: 'margen_porcentaje', label: 'Margen %'),
  ],
  showInForm: false,
  enableCreate: false,
);
