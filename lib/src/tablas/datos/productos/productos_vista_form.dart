import 'package:erp_app/src/shell/models.dart';

const List<SectionField> productosVistaFormFields = [
  SectionField(
    sectionId: 'productos_form',
    id: 'nombre',
    label: 'Nombre',
    required: true,
    order: 1,
  ),
  SectionField(
    sectionId: 'productos_form',
    id: 'idcategoria',
    label: 'Categoría',
    widgetType: 'reference',
    referenceSchema: 'public',
    referenceRelation: 'categorias',
    referenceLabelColumn: 'nombre',
    referenceSectionId: 'categorias_form',
    order: 2,
  ),
  SectionField(
    sectionId: 'productos_form',
    id: 'activo',
    label: 'Activo',
    staticOptions: ['true', 'false'],
    defaultValue: 'true',
    order: 3,
  ),
  SectionField(
    sectionId: 'productos_form',
    id: 'es_para_venta',
    label: 'Disponible para ventas',
    staticOptions: ['true', 'false'],
    defaultValue: 'false',
    order: 4,
  ),
  SectionField(
    sectionId: 'productos_form',
    id: 'es_para_compra',
    label: 'Disponible para compras',
    staticOptions: ['true', 'false'],
    defaultValue: 'false',
    order: 5,
  ),
];
