import 'package:erp_app/src/shared/table_view/table_view_template.dart';
import 'package:erp_app/src/shell/models.dart';

class NavigationSnapshot {
  const NavigationSnapshot({
    required this.moduleId,
    required this.sectionId,
    required this.contentMode,
    this.selectedRow,
  });

  final String moduleId;
  final String sectionId;
  final SectionContentMode contentMode;
  final TableRowData? selectedRow;
}

class NavigationController {
  List<ModuleConfig> _modules = const [];
  ModuleConfig? _activeModule;
  String? _activeSectionId;
  bool _showMobileModulePicker = true;
  bool _showDesktopModulePicker = true;
  SectionContentMode _activeContentMode = SectionContentMode.table;
  final List<NavigationSnapshot> _navigationStack = [];

  List<ModuleConfig> get modules => _modules;
  ModuleConfig? get activeModule => _activeModule;
  String? get activeSectionId => _activeSectionId;
  bool get showMobileModulePicker => _showMobileModulePicker;
  bool get showDesktopModulePicker => _showDesktopModulePicker;
  SectionContentMode get activeContentMode => _activeContentMode;
  bool get hasSnapshots => _navigationStack.isNotEmpty;

  void setModules(List<ModuleConfig> modules) {
    _modules = modules;
    _navigationStack.clear();
    if (modules.isNotEmpty) {
      _activeModule = modules.first;
      _activeSectionId = _activeModule!.sections.isNotEmpty
          ? _activeModule!.sections.first.id
          : null;
    } else {
      _activeModule = null;
      _activeSectionId = null;
    }
    _activeContentMode = SectionContentMode.table;
    _showMobileModulePicker = true;
    _showDesktopModulePicker = true;
  }

  void selectModule(ModuleConfig module, {required bool fromMobile}) {
    _activeModule = module;
    _activeSectionId = module.sections.isNotEmpty ? module.sections.first.id : null;
    _activeContentMode = SectionContentMode.table;
    _navigationStack.clear();
    if (fromMobile) {
      _showMobileModulePicker = false;
    } else {
      _showDesktopModulePicker = false;
    }
  }

  void selectSection(String sectionId) {
    _activeSectionId = sectionId;
    _activeContentMode = SectionContentMode.table;
    _navigationStack.clear();
  }

  void setActiveContentMode(SectionContentMode mode) {
    _activeContentMode = mode;
  }

  void showModulePicker({required bool isMobile, required bool visible}) {
    if (isMobile) {
      _showMobileModulePicker = visible;
    } else {
      _showDesktopModulePicker = visible;
    }
  }

  void resetNavigationStack() {
    _navigationStack.clear();
  }

  void pushSnapshot(NavigationSnapshot snapshot) {
    _navigationStack.add(snapshot);
  }

  NavigationSnapshot? popSnapshot() {
    if (_navigationStack.isEmpty) return null;
    return _navigationStack.removeLast();
  }

  void setActiveModule(ModuleConfig? module) {
    _activeModule = module;
  }

  void setActiveSectionId(String? sectionId) {
    _activeSectionId = sectionId;
  }

  ModuleSection? findModuleSectionById(String sectionId) {
    for (final module in _modules) {
      for (final section in module.sections) {
        if (section.id == sectionId) return section;
      }
    }
    return null;
  }

  ModuleConfig? findModuleById(String? moduleId) {
    if (moduleId == null) return null;
    for (final module in _modules) {
      if (module.id == moduleId) return module;
    }
    return null;
  }

  bool sectionExists(String sectionId) {
    final module = _activeModule;
    if (module == null) return false;
    return module.sections.any((section) => section.id == sectionId);
  }
}
