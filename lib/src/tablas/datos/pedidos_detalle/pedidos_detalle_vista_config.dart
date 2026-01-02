import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';

/// Data source y overrides reutilizados para la sección `pedidos_detalle`.
const SectionDataSource pedidosDetalleDataSource = SectionDataSource(
  sectionId: 'pedidos_detalle',
  listSchema: 'public',
  listRelation: 'v_detallepedidos_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'detallepedidos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<DetailFieldOverride> pedidosDetalleCamposDetalle = [
  DetailFieldOverride(key: 'producto_nombre', label: 'Nombre'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
  DetailFieldOverride(key: 'precioventa', label: 'Precio total'),
];
