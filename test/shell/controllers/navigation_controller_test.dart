import 'package:erp_app/src/shell/controllers/navigation_controller.dart';
import 'package:erp_app/src/shell/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationController', () {
    late NavigationController controller;
    late ModuleConfig moduleA;
    late ModuleConfig moduleB;

    setUp(() {
      controller = NavigationController();
      moduleA = ModuleConfig(
        id: 'a',
        name: 'Module A',
        icon: Icons.list,
        description: 'First',
        sections: const [
          ModuleSection(id: 'a1', label: 'Section 1', icon: Icons.person),
          ModuleSection(id: 'a2', label: 'Section 2', icon: Icons.print),
        ],
      );
      moduleB = const ModuleConfig(
        id: 'b',
        name: 'Module B',
        icon: Icons.settings,
        description: 'Second',
        sections: [ModuleSection(id: 'b1', label: 'Section B1', icon: Icons.map)],
      );
    });

    test('setModules initializes active module/section and pickers', () {
      controller.setModules([moduleA, moduleB]);
      expect(controller.modules.length, 2);
      expect(controller.activeModule, equals(moduleA));
      expect(controller.activeSectionId, equals('a1'));
      expect(controller.activeContentMode, SectionContentMode.table);
      expect(controller.showMobileModulePicker, isTrue);
      expect(controller.showDesktopModulePicker, isTrue);
    });

    test('selectModule toggles pickers depending on source', () {
      controller.setModules([moduleA]);
      controller.selectModule(moduleA, fromMobile: true);
      expect(controller.showMobileModulePicker, isFalse);
      expect(controller.showDesktopModulePicker, isTrue);
      controller.selectModule(moduleA, fromMobile: false);
      expect(controller.showDesktopModulePicker, isFalse);
    });

    test('selectSection resets content mode and stack', () {
      controller.setModules([moduleA]);
      controller.pushSnapshot(
        const NavigationSnapshot(
          moduleId: 'a',
          sectionId: 'a1',
          contentMode: SectionContentMode.detail,
        ),
      );
      controller.selectSection('a2');
      expect(controller.activeSectionId, 'a2');
      expect(controller.activeContentMode, SectionContentMode.table);
      expect(controller.hasSnapshots, isFalse);
    });

    test('push/pop snapshot restores previous state', () {
      controller.setModules([moduleA]);
      controller.pushSnapshot(
        const NavigationSnapshot(
          moduleId: 'a',
          sectionId: 'a1',
          contentMode: SectionContentMode.detail,
          selectedRow: {'id': 1},
        ),
      );
      final popped = controller.popSnapshot();
      expect(popped, isNotNull);
      expect(popped!.sectionId, 'a1');
      expect(controller.hasSnapshots, isFalse);
    });

    test('sectionExists respects active module context', () {
      controller.setModules([moduleA]);
      expect(controller.sectionExists('a2'), isTrue);
      controller.setModules(const []);
      expect(controller.sectionExists('a2'), isFalse);
    });
  });
}
