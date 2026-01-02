import 'package:erp_app/src/shell/models.dart';

/// Configuración del formulario principal de pedidos.
const List<SectionField> pedidosVistaFormFields = [
  SectionField(
    sectionId: 'pedidos_tabla',
    id: 'registrado_at',
    label: 'Fecha de registro',
    readOnly: true,
    order: 1,
    defaultValue: 'now',
  ),
  SectionField(
    sectionId: 'pedidos_tabla',
    id: 'codigo',
    label: 'Código',
    readOnly: true,
    order: 2,
  ),
  SectionField(
    sectionId: 'pedidos_tabla',
    id: 'idcliente',
    label: 'Cliente',
    required: true,
    order: 3,
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'clientes',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'clientes_form',
  ),
  SectionField(
    sectionId: 'pedidos_tabla',
    id: 'observacion',
    label: 'Observación',
    order: 4,
  ),
  SectionField(
    sectionId: 'pedidos_tabla',
    id: 'idlista_precios',
    label: 'Lista de precios',
    order: 5,
  ),
  SectionField(
    sectionId: 'pedidos_tabla',
    id: 'registrado_por',
    label: 'Registrado por',
    visible: false,
  ),
  SectionField(
    sectionId: 'pedidos_tabla',
    id: 'editado_por',
    label: 'Editado por',
    visible: false,
  ),
  SectionField(
    sectionId: 'pedidos_tabla',
    id: 'editado_at',
    label: 'Editado el',
    visible: false,
  ),
];
