import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';

/// Configuración estática para listar y detallar pagos de pedidos.
const SectionDataSource pedidosPagosDataSource = SectionDataSource(
  sectionId: 'pedidos_pagos',
  listSchema: 'public',
  listRelation: 'v_pagos_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'pagos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<DetailFieldOverride> pagosCamposDetalle = [
  DetailFieldOverride(key: 'codigo', label: 'Código'),
  DetailFieldOverride(key: 'registrado_at', label: 'Fecha de registro'),
  DetailFieldOverride(key: 'fechapago', label: 'Fecha de pago'),
  DetailFieldOverride(key: 'monto', label: 'Monto'),
  DetailFieldOverride(key: 'cuenta_nombre', label: 'Cuenta bancaria'),
];
