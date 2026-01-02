import 'package:erp_app/src/shell/models.dart';
import 'package:erp_app/src/shared/table_view/table_view_template.dart';

const SectionDataSource basesSectionDataSource = SectionDataSource(
  sectionId: 'bases',
  listSchema: 'public',
  listRelation: 'v_bases_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'bases',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_bases_vistageneral',
  detailIsView: true,
);

const SectionDataSource basesLecturaSectionDataSource = SectionDataSource(
  sectionId: 'bases_lectura',
  listSchema: 'public',
  listRelation: 'v_bases_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: '',
  formIsView: false,
  detailSchema: 'public',
  detailRelation: 'v_bases_vistageneral',
  detailIsView: true,
);

const SectionDataSource basesDataSource = SectionDataSource(
  sectionId: 'bases_form',
  listSchema: 'public',
  listRelation: 'bases',
  listIsView: false,
  formSchema: 'public',
  formRelation: 'bases',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const SectionDataSource basePackingsDataSource = SectionDataSource(
  sectionId: 'base_packings_form',
  listSchema: 'public',
  listRelation: 'v_base_packings_vistageneral',
  listIsView: true,
  formSchema: 'public',
  formRelation: 'base_packings',
  formIsView: false,
  detailSchema: null,
  detailRelation: null,
  detailIsView: null,
);

const List<TableColumnConfig> basesColumnas = [
  TableColumnConfig(key: 'nombre', label: 'Nombre'),
  TableColumnConfig(key: 'packings_activos', label: 'Packings activos'),
  TableColumnConfig(key: 'packings_totales', label: 'Packings totales'),
  TableColumnConfig(key: 'registrado_at', label: 'Creada en'),
];

const InlineSectionConfig basePackingsInlineSection = InlineSectionConfig(
  id: 'base_packings',
  title: 'Packings de la base',
  dataSource: InlineSectionDataSource(
    schema: 'public',
    relation: 'v_base_packings_vistageneral',
    orderBy: 'nombre',
  ),
  foreignKeyColumn: 'idbase',
  columns: [
    InlineSectionColumn(key: 'nombre', label: 'Nombre de marca'),
    InlineSectionColumn(key: 'tipo', label: 'Tipo de packing'),
    InlineSectionColumn(key: 'observacion', label: 'Observación'),
    InlineSectionColumn(key: 'activo', label: 'Activo'),
  ],
  showInForm: true,
  enableCreate: true,
  formSectionId: 'base_packings_form',
  formForeignKeyField: 'idbase',
  pendingFieldMapping: {
    'nombre': 'nombre',
    'tipo': 'tipo',
    'observacion': 'observacion',
    'activo': 'activo',
  },
);
