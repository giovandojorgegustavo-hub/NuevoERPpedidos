import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';

const SectionDataSource pedidoRectificacionesDataSource = SectionDataSource(
  sectionId: 'pedido_rectificaciones',
  listSchema: 'public',
  listRelation: 'v_pedido_rectificaciones_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'pedido_rectificaciones',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<SectionField> pedidoRectificacionesFormFields = [
  SectionField(
    sectionId: 'pedido_rectificaciones',
    id: 'idproducto',
    label: 'Producto',
    required: true,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'productos',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'productos',
  ),
  SectionField(
    sectionId: 'pedido_rectificaciones',
    id: 'cantidad',
    label: 'Cantidad',
    widgetType: 'number',
    required: true,
  ),
  SectionField(
    sectionId: 'pedido_rectificaciones',
    id: 'motivo',
    label: 'Motivo',
  ),
  SectionField(
    sectionId: 'pedido_rectificaciones',
    id: 'estado',
    label: 'Estado',
    widgetType: 'select',
    staticOptions: ['pendiente', 'en_proceso', 'completado', 'cancelado'],
    defaultValue: 'pendiente',
  ),
  SectionField(
    sectionId: 'pedido_rectificaciones',
    id: 'idmovimiento',
    label: 'Movimiento asociado',
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'movimientopedidos',
    referenceLabelColumn: 'id',
    referenceSectionId: 'movimientos',
  ),
  SectionField(
    sectionId: 'pedido_rectificaciones',
    id: 'observacion',
    label: 'Observación',
  ),
];

const List<DetailFieldOverride> pedidoRectificacionesCamposDetalle = [
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
  DetailFieldOverride(key: 'motivo', label: 'Motivo'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
];
