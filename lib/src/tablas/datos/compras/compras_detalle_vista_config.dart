import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';

const SectionDataSource comprasDetalleDataSource = SectionDataSource(
  sectionId: 'compras_detalle',
  listSchema: 'public',
  listRelation: 'v_compras_detalle_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'compras_detalle',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<DetailFieldOverride> comprasDetalleCamposDetalle = [
  DetailFieldOverride(key: 'producto_nombre', label: 'Producto'),
  DetailFieldOverride(key: 'cantidad', label: 'Cantidad'),
  DetailFieldOverride(key: 'costo_unitario', label: 'Costo unitario'),
  DetailFieldOverride(key: 'costo_total', label: 'Costo total'),
];
