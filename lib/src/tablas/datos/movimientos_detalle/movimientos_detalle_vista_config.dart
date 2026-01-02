import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';

/// Data source correspondiente a la sección `movimientos_detalle`.
const SectionDataSource movimientosDetalleDataSource = SectionDataSource(
  sectionId: 'movimientos_detalle',
  listSchema: 'public',
  listRelation: 'v_movimiento_detalle_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'detallemovimientopedidos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<DetailFieldOverride> movimientosDetalleCamposDetalle = [
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
];
