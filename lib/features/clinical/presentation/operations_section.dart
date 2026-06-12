import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../../auth/application/auth_controller.dart';
import '../data/clinical_repository.dart';
import '../domain/operation.dart';

/// Секция «Операции» карты пациента: операции визита со статусами,
/// выполнение (со списанием расходников) и назначение новой операции —
/// назначение автоматически добавляет связанную услугу в счёт визита.
class OperationsSection extends ConsumerWidget {
  const OperationsSection(
      {super.key, required this.visitId, required this.patientId, this.branchId});

  final String visitId;
  final String patientId;

  /// Филиал визита — склад, с которого perform реально спишет расходники.
  final String? branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(visitOperationsProvider(visitId));
    final user = ref.watch(authControllerProvider).user;
    final canPrescribe = user?.can('operations.prescribe') ?? false;
    final canPerform = user?.can('operations.perform') ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Операции', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            AsyncValueWidget<List<Operation>>(
              value: operations,
              onRetry: () => ref.invalidate(visitOperationsProvider(visitId)),
              builder: (items) {
                if (items.isEmpty) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Операций по этому визиту нет.'),
                  );
                }
                return Column(
                  children: [
                    for (final op in items)
                      _operationTile(context, ref, op, canPerform, canPrescribe),
                  ],
                );
              },
            ),
            if (canPrescribe) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _prescribe(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Назначить операцию'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _operationTile(BuildContext context, WidgetRef ref, Operation op,
      bool canPerform, bool canPrescribe) {
    final statusColor = switch (op.status) {
      'planned' => Colors.orange,
      'done' => Colors.green,
      _ => Colors.grey,
    };
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.medical_services_outlined),
      title: Text('${op.typeName} · ${op.eyeLabel}'),
      subtitle: op.notes == null
          ? null
          : Text(op.notes!, style: Theme.of(context).textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (op.priority == 'urgent')
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(
                label: const Text('срочная'),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.red.withValues(alpha: 0.12),
                labelStyle: const TextStyle(color: Colors.red, fontSize: 12),
                side: BorderSide.none,
              ),
            ),
          Chip(
            label: Text(op.statusLabel),
            backgroundColor: statusColor.withValues(alpha: 0.15),
            labelStyle: TextStyle(color: statusColor),
            side: BorderSide.none,
          ),
          if (canPerform && op.isPlanned)
            TextButton(
              onPressed: () => _perform(context, ref, op),
              child: const Text('Выполнить'),
            ),
          if (canPrescribe && op.isPlanned)
            TextButton(
              onPressed: () => _cancel(context, ref, op),
              child: const Text('Отменить'),
            ),
        ],
      ),
    );
  }

  Future<void> _perform(
      BuildContext context, WidgetRef ref, Operation op) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(op.typeName),
        content: const Text('Списать расходники и отметить выполненной?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Выполнить')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(clinicalRepositoryProvider).performOperation(op.id);
      if (!context.mounted) return;
      ref.invalidate(visitOperationsProvider(visitId));
      _snack(context, 'Операция выполнена, расходники списаны');
    } catch (e) {
      // 409 несёт сообщение «не хватает …» — показываем его как есть.
      if (context.mounted) _snack(context, e.toString(), error: true);
    }
  }

  Future<void> _cancel(
      BuildContext context, WidgetRef ref, Operation op) async {
    try {
      await ref.read(clinicalRepositoryProvider).cancelOperation(op.id);
      if (!context.mounted) return;
      ref.invalidate(visitOperationsProvider(visitId));
      _snack(context, 'Операция отменена');
    } catch (e) {
      if (context.mounted) _snack(context, e.toString(), error: true);
    }
  }

  Future<void> _prescribe(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _PrescribeOperationDialog(visitId: visitId, branchId: branchId),
    );
    if (ok == true && context.mounted) {
      ref.invalidate(visitOperationsProvider(visitId));
      _snack(context, 'Операция назначена и добавлена в счёт визита');
    }
  }

  void _snack(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
    ));
  }
}

/// Диалог назначения: тип операции (с ценой), приоритет, глаз, примечание +
/// живая проверка наличия расходников по филиалу визита (advisory).
class _PrescribeOperationDialog extends ConsumerStatefulWidget {
  const _PrescribeOperationDialog({required this.visitId, this.branchId});

  final String visitId;
  final String? branchId;

  @override
  ConsumerState<_PrescribeOperationDialog> createState() =>
      _PrescribeOperationDialogState();
}

class _PrescribeOperationDialogState
    extends ConsumerState<_PrescribeOperationDialog> {
  final _notes = TextEditingController();
  String? _typeId;
  String _eye = 'od';
  String _priority = 'normal';
  bool _saving = false;

  // Advisory consumables check for the selected type: null → panel hidden
  // (no type yet / no branch / fetch failed). Never blocks prescribing.
  OperationAvailability? _availability;
  bool _checkingAvailability = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  /// Filiал врача — операционный филиал по конвенции проекта (как на
  /// ресепшене). Без филиала проверка молча пропускается; ошибка сети —
  /// просто прячем панель: advisory не должен ломать назначение.
  Future<void> _checkAvailability(String typeId) async {
    // Склад проверяется по филиалу ВИЗИТА (perform списывает именно там);
    // филиал врача — только fallback для старых записей без branch_id.
    final branchId =
        widget.branchId ?? ref.read(authControllerProvider).user?.branchId;
    if (branchId == null) return;
    setState(() {
      _checkingAvailability = true;
      _availability = null;
    });
    try {
      final result = await ref
          .read(clinicalRepositoryProvider)
          .availability(typeId, branchId);
      if (!mounted || _typeId != typeId) return; // тип уже сменили
      setState(() => _availability = result);
    } catch (_) {
      // advisory — скрываем панель, назначение остаётся доступным
    } finally {
      if (mounted && _typeId == typeId) {
        setState(() => _checkingAvailability = false);
      }
    }
  }

  Future<void> _save() async {
    final typeId = _typeId;
    if (typeId == null) return;
    setState(() => _saving = true);
    try {
      final notes = _notes.text.trim();
      await ref.read(clinicalRepositoryProvider).prescribeOperation(
            visitId: widget.visitId,
            operationTypeId: typeId,
            eye: _eye,
            priority: _priority,
            notes: notes.isEmpty ? null : notes,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = ref.watch(operationTypesProvider);

    return AlertDialog(
      title: const Text('Назначить операцию'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              types.when(
                data: (items) {
                  final active = items.where((t) => t.isActive).toList();
                  return DropdownButtonFormField<String>(
                    initialValue: _typeId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Операция'),
                    items: [
                      for (final t in active)
                        DropdownMenuItem(
                          value: t.id,
                          child: Text('${t.name} — ${formatMoney(t.price)}',
                              overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _typeId = v;
                        _availability = null;
                      });
                      if (v != null) _checkAvailability(v);
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Text('$e',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              if (_checkingAvailability)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                )
              else if (_availability != null)
                _availabilityPanel(context, _availability!),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'normal', label: Text('Обычная')),
                  ButtonSegment(value: 'urgent', label: Text('Срочная')),
                ],
                selected: {_priority},
                onSelectionChanged: (s) => setState(() => _priority = s.first),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'od', label: Text('OD')),
                  ButtonSegment(value: 'os', label: Text('OS')),
                  ButtonSegment(value: 'ou', label: Text('OU')),
                ],
                selected: {_eye},
                onSelectionChanged: (s) => setState(() => _eye = s.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notes,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Примечание (необязательно)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: (_saving || _typeId == null) ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Назначить'),
        ),
      ],
    );
  }

  /// Компактная панель наличия расходников: строка на каждый расходник
  /// («название — требуется X, на складе Y») + итоговая строка. Дефицит —
  /// янтарное предупреждение: назначать МОЖНО, заблокируется лишь выполнение.
  Widget _availabilityPanel(BuildContext context, OperationAvailability a) {
    if (a.items.isEmpty) return const SizedBox.shrink(); // нет шаблона — нечего показывать
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;
    final accent = a.ok ? Colors.green : Colors.amber;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: accent.withValues(alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in a.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    item.ok ? Icons.check_circle_outline : Icons.cancel_outlined,
                    size: 16,
                    color: item.ok ? Colors.green : errorColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${item.name} — требуется ${item.required}, '
                      'на складе ${item.available}',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Icon(
                a.ok
                    ? Icons.inventory_2_outlined
                    : Icons.warning_amber_outlined,
                size: 16,
                color: a.ok ? Colors.green.shade700 : Colors.amber.shade900,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  a.ok
                      ? 'Расходников достаточно'
                      : 'Не хватает расходников — выполнение будет заблокировано',
                  style: textTheme.bodySmall?.copyWith(
                    color: a.ok ? Colors.green.shade700 : Colors.amber.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
