import 'package:erp_app/src/shell/ui/mobile_shell.dart';
import 'package:erp_app/src/shell/ui/shell_content.dart';
import 'package:erp_app/src/shell/viewmodels/shell_view_model.dart';
import 'package:erp_app/src/shell/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late final ShellViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ShellViewModel(contextProvider: () => context);
    _viewModel.addListener(_handleViewModelChanged);
    _viewModel.init();
  }

  void _handleViewModelChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoadingModules) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_viewModel.loadingError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No se pudieron cargar los módulos.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _viewModel.loadingError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _viewModel.init,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final activeModule = _viewModel.activeModule;
    if (activeModule == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No hay módulos configurados.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _viewModel.init,
                child: const Text('Sincronizar nuevamente'),
              ),
            ],
          ),
        ),
      );
    }

    final selectedSection = _viewModel.currentSection;
    final tableConfig = _viewModel.tableConfig;
    final detailConfig = _viewModel.detailConfig;
    final formConfig = _viewModel.formConfig;
    final isSectionLoading = _viewModel.isSectionLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        if (isCompact) {
          return MobileShell(
            modules: _viewModel.modules,
            activeModule: activeModule,
            activeSectionId: _viewModel.activeSectionId,
            selectedSection: selectedSection,
            showModulePicker: _viewModel.showMobileModulePicker,
            onModuleSelected: (module) =>
                _viewModel.openModule(module, fromMobile: true),
            onSectionSelected: (sectionId) =>
                _viewModel.openSection(sectionId),
            globalActions: _viewModel.showDesktopModulePicker
                ? []
                : _viewModel.visibleGlobalActions,
            onGlobalAction: (action) => _viewModel.handleGlobalAction(action),
            onShowModulePicker: () =>
                _viewModel.showModulePicker(isMobile: true, visible: true),
            contentMode: _viewModel.currentMode,
            onContentModeChanged: _viewModel.setContentMode,
            tableConfig: tableConfig,
            detailConfig: detailConfig,
            formConfig: formConfig,
            onRowSelected: (row) => _viewModel.openDetail(row),
            isSectionLoading: isSectionLoading,
            onCreate: () => _viewModel.openForm(),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              if (!_viewModel.showDesktopModulePicker)
                Sidebar(
                  module: activeModule,
                  selectedSectionId: _viewModel.activeSectionId,
                  onSectionSelected: (sectionId) =>
                      _viewModel.openSection(sectionId),
                  globalActions: _viewModel.visibleGlobalActions,
                  onGlobalAction: (action) =>
                      _viewModel.handleGlobalAction(action),
                ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F6FB),
                  child: ShellContent(
                    modules: _viewModel.modules,
                    selectedSection: selectedSection,
                    activeModule: activeModule,
                    activeSectionId: _viewModel.activeSectionId,
                    onModuleSelected: (module) =>
                        _viewModel.openModule(module, fromMobile: false),
                    showModulePicker: _viewModel.showDesktopModulePicker,
                    onShowModulePicker: () => _viewModel.showModulePicker(
                      isMobile: false,
                      visible: true,
                    ),
                    contentMode: _viewModel.currentMode,
                    onContentModeChanged: _viewModel.setContentMode,
                    globalActions: _viewModel.visibleGlobalActions,
                    onGlobalAction: (action) =>
                        _viewModel.handleGlobalAction(action),
                    tableConfig: tableConfig,
                    detailConfig: detailConfig,
                    formConfig: formConfig,
                    isSectionLoading: isSectionLoading,
                    onRowSelected: (row) => _viewModel.openDetail(row),
                    onCreate: () => _viewModel.openForm(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
