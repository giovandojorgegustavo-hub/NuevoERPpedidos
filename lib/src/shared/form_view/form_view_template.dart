import 'dart:async';

import 'package:erp_app/src/shared/inline_table/inline_table_template.dart';
import 'package:flutter/material.dart';

const _kAddReferenceValue = '__add_reference_option__';
const String kFormViewChangeSourceKey = '__form_change_source';
const String kFormViewChangeSourceProgrammatic = 'programmatic';

/// Removes the internal change-source marker (if present) and reports whether
/// the change originated from a programmatic rebuild instead of user input.
bool consumeFormProgrammaticChangeFlag(Map<String, String> values) {
  final source = values.remove(kFormViewChangeSourceKey);
  return source == kFormViewChangeSourceProgrammatic;
}

enum FormFieldType { text, number, dateTime, dropdown, display }

class FormFieldOption {
  const FormFieldOption({required this.value, required this.label});

  final String value;
  final String label;
}

class FormFieldConfig {
  const FormFieldConfig({
    required this.id,
    required this.label,
    this.initialValue,
    this.helperText,
    this.helperBuilder,
    this.required = false,
    this.readOnly = false,
    this.fieldType = FormFieldType.text,
    this.options,
    this.onAddReference,
    this.visibleWhen,
    this.sectionId,
  });

  final String id;
  final String label;
  final String? initialValue;
  final String? helperText;
  final String? Function(String?)? helperBuilder;
  final bool required;
  final bool readOnly;
  final FormFieldType fieldType;
  final List<FormFieldOption>? options;
  final Future<FormFieldOption?> Function()? onAddReference;
  final bool Function(Map<String, String>)? visibleWhen;
  final String? sectionId;
}

class FormFinishAction {
  const FormFinishAction({
    required this.label,
    required this.description,
    required this.onNavigate,
  });

  final String label;
  final String description;
  final VoidCallback onNavigate;
}

class FormViewConfig {
  const FormViewConfig({
    required this.title,
    required this.fields,
    this.subtitle,
    this.description,
    this.inlineTables = const [],
    this.onSubmit,
    this.onCancel,
    this.finishAction,
    this.saveLabel = 'Guardar',
    this.cancelLabel = 'Cancelar',
    this.onChanged,
    this.overrideValues,
  });

  final String title;
  final String? subtitle;
  final String? description;
  final List<FormFieldConfig> fields;
  final List<InlineTableConfig> inlineTables;
  final ValueChanged<Map<String, String>>? onSubmit;
  final VoidCallback? onCancel;
  final FormFinishAction? finishAction;
  final String saveLabel;
  final String cancelLabel;
  final ValueChanged<Map<String, String>>? onChanged;
  final Map<String, String>? overrideValues;

  FormViewConfig copyWith({
    String? title,
    String? subtitle,
    String? description,
    List<FormFieldConfig>? fields,
    List<InlineTableConfig>? inlineTables,
    ValueChanged<Map<String, String>>? onSubmit,
    VoidCallback? onCancel,
    FormFinishAction? finishAction,
    String? saveLabel,
    String? cancelLabel,
    ValueChanged<Map<String, String>>? onChanged,
    Map<String, String>? overrideValues,
  }) {
    return FormViewConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      inlineTables: inlineTables ?? this.inlineTables,
      onSubmit: onSubmit ?? this.onSubmit,
      onCancel: onCancel ?? this.onCancel,
      finishAction: finishAction ?? this.finishAction,
      saveLabel: saveLabel ?? this.saveLabel,
      cancelLabel: cancelLabel ?? this.cancelLabel,
      onChanged: onChanged ?? this.onChanged,
      overrideValues: overrideValues ?? this.overrideValues,
    );
  }
}

class FormViewTemplate extends StatefulWidget {
  const FormViewTemplate({super.key, required this.config});

  final FormViewConfig config;

  @override
  State<FormViewTemplate> createState() => _FormViewTemplateState();
}

class _FormViewTemplateState extends State<FormViewTemplate> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, List<FormFieldOption>> _dynamicDropdownOptions = {};

  @override
  void initState() {
    super.initState();
    for (final field in widget.config.fields) {
      final override = widget.config.overrideValues?[field.id];
      _controllers[field.id] = TextEditingController(
        text: override ?? field.initialValue ?? '',
      );
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _notifyChange(userInitiated: false));
  }

  @override
  void didUpdateWidget(covariant FormViewTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKeys = oldWidget.config.fields.map((f) => f.id).toSet();
    final newKeys = widget.config.fields.map((f) => f.id).toSet();
    final oldInitialValues = <String, String>{};
    for (final field in oldWidget.config.fields) {
      oldInitialValues[field.id] = field.initialValue ?? '';
    }

    for (final key in oldKeys.difference(newKeys)) {
      _controllers.remove(key)?.dispose();
      _dynamicDropdownOptions.remove(key);
    }

    for (final field in widget.config.fields) {
      final controller = _controllers[field.id];
      if (controller == null) {
        final override = widget.config.overrideValues?[field.id];
        _controllers[field.id] = TextEditingController(
          text: override ?? field.initialValue ?? '',
        );
      } else {
        final previousInitial = oldInitialValues[field.id];
        final newInitial = field.initialValue ?? '';
        final newOverride = widget.config.overrideValues?[field.id];
        if (newOverride != null) {
          if (controller.text != newOverride) {
            controller.text = newOverride;
          }
          continue;
        }
        if (previousInitial != newInitial) {
          controller.text = newInitial;
        }
      }
    }
    for (final field in widget.config.fields) {
      final existingOptions =
          field.options?.map((option) => option.value).toSet() ??
          const <String>{};
      final dynamicOptions = _dynamicDropdownOptions[field.id];
      if (dynamicOptions == null) continue;
      dynamicOptions.removeWhere(
        (option) => existingOptions.contains(option.value),
      );
      if (dynamicOptions.isEmpty) {
        _dynamicDropdownOptions.remove(field.id);
      }
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _notifyChange(userInitiated: false));
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _dynamicDropdownOptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight =
            constraints.hasBoundedHeight &&
            constraints.maxHeight != double.infinity;
        final content = _buildScrollableContent();
        final actionBar = _buildActionBar();

        if (!hasBoundedHeight) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [content, const SizedBox(height: 16), actionBar],
              ),
            ),
          );
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: content,
                ),
              ),
              Positioned(left: 16, right: 16, bottom: 16, child: actionBar),
            ],
          ),
        );
      },
    );
  }

  Column _buildScrollableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.config.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (widget.config.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.config.subtitle!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ],
        if (widget.config.description != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.config.description!,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              for (final field in widget.config.fields) ...[
                _buildFormField(field),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        for (final inline in widget.config.inlineTables) ...[
          const SizedBox(height: 16),
          InlineTableTemplate(config: inline),
        ],
        if (widget.config.finishAction != null) ...[
          const SizedBox(height: 16),
          ListTile(
            tileColor: const Color(0xFFF7F8FC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(widget.config.finishAction!.label),
            subtitle: Text(widget.config.finishAction!.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.config.finishAction!.onNavigate,
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 34,
              child: OutlinedButton(
                onPressed: widget.config.onCancel,
                child: Text(widget.config.cancelLabel),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 34,
              child: FilledButton(
                onPressed: _handleSubmit,
                child: Text(widget.config.saveLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(FormFieldConfig field) {
    if (field.visibleWhen != null && !field.visibleWhen!(_currentValues())) {
      return const SizedBox.shrink();
    }
    switch (field.fieldType) {
      case FormFieldType.display:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              field.label,
              textAlign: TextAlign.left,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        );
      case FormFieldType.dropdown:
        final List<FormFieldOption> options =
            field.options ?? const <FormFieldOption>[];
        final List<DropdownMenuItem<String>> items = [
          for (final option in options)
            DropdownMenuItem(value: option.value, child: Text(option.label)),
        ];
        final extraOptions =
            _dynamicDropdownOptions[field.id] ?? const <FormFieldOption>[];
        for (final option in extraOptions) {
          final exists = items.any((item) => item.value == option.value);
          if (!exists) {
            items.add(
              DropdownMenuItem(value: option.value, child: Text(option.label)),
            );
          }
        }
        final currentValue = _controllers[field.id]?.text;
        final selectedValue = _sanitizeDropdownValue(
          items,
          currentValue,
          field,
        );
        final customHelper = field.helperBuilder?.call(selectedValue);
        final decorationHelper = customHelper == null ? field.helperText : null;
        final canAddReference = !field.readOnly && field.onAddReference != null;
        if (canAddReference) {
          items.add(
            DropdownMenuItem(
              value: _kAddReferenceValue,
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 8),
                  Text('Agregar ${field.label}'),
                ],
              ),
            ),
          );
        }
        final dropdown = DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: selectedValue,
          items: items,
          onChanged: field.readOnly
              ? null
              : (value) async {
                  if (value == _kAddReferenceValue &&
                      field.onAddReference != null) {
                    await _handleAddReferenceTap(field);
                    return;
                  }
                  _controllers[field.id]?.text = value ?? '';
                  setState(() {});
                  _notifyChange(userInitiated: true);
                },
          decoration: _buildInputDecoration(
            field,
            helperText: decorationHelper,
          ),
          validator: field.required
              ? (value) =>
                    value == null ||
                        value.isEmpty ||
                        value == _kAddReferenceValue
                    ? 'Campo requerido'
                    : null
              : null,
        );
        if (customHelper == null || customHelper.isEmpty) {
          return dropdown;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dropdown,
            const SizedBox(height: 4),
            Text(
              customHelper,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        );
      case FormFieldType.dateTime:
        final helperText =
            field.helperBuilder?.call(_controllers[field.id]?.text) ??
            field.helperText;
        return TextFormField(
          controller: _controllers[field.id],
          readOnly: true,
          enabled: !field.readOnly,
          decoration: _buildInputDecoration(
            field,
            helperText: helperText,
          ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
          onTap: field.readOnly ? null : () => _pickDate(field),
          validator: field.required
              ? (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null
              : null,
        );
      default:
        final helperText =
            field.helperBuilder?.call(_controllers[field.id]?.text) ??
            field.helperText;
        return TextFormField(
          controller: _controllers[field.id],
          readOnly: field.readOnly,
          enabled: !field.readOnly,
          keyboardType: field.fieldType == FormFieldType.number
              ? TextInputType.number
              : TextInputType.text,
          decoration: _buildInputDecoration(field, helperText: helperText),
          onChanged: (_) {
            setState(() {});
            _notifyChange(userInitiated: true);
          },
          validator: field.required
              ? (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null
              : null,
        );
    }
  }

  Map<String, String> _currentValues() {
    return {
      for (final entry in _controllers.entries) entry.key: entry.value.text,
    };
  }

  String? _sanitizeDropdownValue(
    List<DropdownMenuItem<String>> items,
    String? value,
    FormFieldConfig field,
  ) {
    if (value == null || value.isEmpty || value == _kAddReferenceValue) {
      return null;
    }
    final exists = items.any((item) => item.value == value);
    return exists ? value : null;
  }

  Future<void> _handleAddReferenceTap(FormFieldConfig field) async {
    final callback = field.onAddReference;
    if (callback == null) return;
    final previousValue = _controllers[field.id]?.text ?? '';
    final newOption = await callback();
    if (!mounted) return;
    if (newOption == null) {
      _controllers[field.id]?.text = previousValue;
      setState(() {});
      return;
    }
    final fieldId = field.id;
    final extraList = _dynamicDropdownOptions.putIfAbsent(
      fieldId,
      () => <FormFieldOption>[],
    );
    final alreadyExists = (field.options ?? const <FormFieldOption>[]).any(
      (option) => option.value == newOption.value,
    );
    final dynamicExists = extraList.any(
      (option) => option.value == newOption.value,
    );
    if (!alreadyExists && !dynamicExists) {
      extraList.add(newOption);
    }
    _controllers[field.id]?.text = newOption.value;
    setState(() {});
    _notifyChange(userInitiated: true);
  }

  InputDecoration _buildInputDecoration(
    FormFieldConfig field, {
    String? helperText,
  }) {
    return InputDecoration(
      labelText: field.label,
      helperText: helperText ?? field.helperText,
      filled: field.readOnly,
      fillColor: field.readOnly ? const Color(0xFFF1F1F5) : null,
      border: const OutlineInputBorder(),
    );
  }

  String _formatDateTimeDisplay(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }

  Future<void> _pickDate(FormFieldConfig field) async {
    final now = DateTime.now();
    final currentValue = _controllers[field.id]?.text;
    final existing = currentValue == null || currentValue.isEmpty
        ? null
        : DateTime.tryParse(currentValue);
    final initialDate = existing ?? now;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: initialDate,
    );
    if (!mounted) return;
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: existing != null
            ? TimeOfDay(hour: existing.hour, minute: existing.minute)
            : TimeOfDay.now(),
      );
      final result = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
      _controllers[field.id]?.text = _formatDateTimeDisplay(result);
      setState(() {});
    }
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final data = <String, String>{};
    for (final entry in _controllers.entries) {
      data[entry.key] = entry.value.text;
    }
    widget.config.onSubmit?.call(data);
  }

  void _notifyChange({bool userInitiated = true}) {
    final callback = widget.config.onChanged;
    if (callback == null) return;
    final values = _currentValues();
    if (!userInitiated) {
      values[kFormViewChangeSourceKey] = kFormViewChangeSourceProgrammatic;
    }
    callback(values);
  }
}
