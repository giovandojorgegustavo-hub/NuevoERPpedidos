import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';

const SectionDataSource comprasPagosDataSource = SectionDataSource(
  sectionId: 'compras_pagos',
  listSchema: 'public',
  listRelation: 'v_compras_pagos_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'compras_pagos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<DetailFieldOverride> comprasPagosCamposDetalle = [
  DetailFieldOverride(key: 'cuenta_nombre', label: 'Cuenta bancaria'),
  DetailFieldOverride(key: 'monto', label: 'Monto'),
  DetailFieldOverride(key: 'registrado_display', label: 'Registrado en'),
  DetailFieldOverride(key: 'estado', label: 'Estado'),
];
