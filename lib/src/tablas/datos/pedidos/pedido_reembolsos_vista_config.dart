import 'package:erp_app/src/navegacion/detail_field_override.dart';
import 'package:erp_app/src/shell/models.dart';

const SectionDataSource pedidoReembolsosDataSource = SectionDataSource(
  sectionId: 'pedido_reembolsos',
  listSchema: 'public',
  listRelation: 'v_pedido_reembolsos_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'pedido_reembolsos',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<SectionField> pedidoReembolsosFormFields = [
  SectionField(
    sectionId: 'pedido_reembolsos',
    id: 'monto',
    label: 'Monto',
    widgetType: 'number',
    required: true,
  ),
  SectionField(
    sectionId: 'pedido_reembolsos',
    id: 'idcuenta',
    label: 'Cuenta bancaria',
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'v_cuentas_bancarias_visibles',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'cuentas_bancarias_form',
    required: true,
  ),
  SectionField(
    sectionId: 'pedido_reembolsos',
    id: 'observacion',
    label: 'Observación',
  ),
  SectionField(
    sectionId: 'pedido_reembolsos',
    id: 'link_evidencia',
    label: 'Link evidencia',
  ),
];

const List<DetailFieldOverride> pedidoReembolsosCamposDetalle = [
  DetailFieldOverride(key: 'monto', label: 'Monto'),
  DetailFieldOverride(key: 'cuenta_nombre', label: 'Cuenta bancaria'),
  DetailFieldOverride(key: 'observacion', label: 'Observación'),
  DetailFieldOverride(key: 'link_evidencia', label: 'Link evidencia'),
  DetailFieldOverride(key: 'registrado_at', label: 'Registrado'),
];
