import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/page.dart';
import '../../../core/widgets/async_value_widget.dart';
import '../data/devices_repository.dart';
import '../domain/device.dart';
import '../domain/device_result.dart';

/// Реестр медицинского оборудования (директорский экран): приборы клиники
/// и их последние результаты.
class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(devicesListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Оборудование')),
      body: AsyncValueWidget<Page<Device>>(
        value: devices,
        onRetry: () => ref.invalidate(devicesListProvider),
        builder: (page) {
          if (page.items.isEmpty) {
            return const Center(child: Text('Приборы не зарегистрированы'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Всего приборов: ${page.total}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              for (final d in page.items) _DeviceTile(device: d),
            ],
          );
        },
      ),
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  const _DeviceTile({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = switch (device.status) {
      'active' => Colors.green,
      'maintenance' => Colors.orange,
      _ => Colors.grey,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          device.deviceType == 'refractometer'
              ? Icons.remove_red_eye_outlined
              : Icons.monitor_heart_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(device.name),
        subtitle: Text([
          device.typeLabel,
          'S/N ${device.serialNo}',
          if (device.assetCode != null) 'инв. ${device.assetCode}',
          if (device.branchName != null) device.branchName!,
          device.connectionType,
        ].join('  ·  ')),
        trailing: Chip(
          label: Text(device.status),
          backgroundColor: statusColor.withValues(alpha: 0.15),
          labelStyle: TextStyle(color: statusColor),
          side: BorderSide.none,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          if (device.manufacturer != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Производитель: ${device.manufacturer}',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: 8),
          _RecentResults(deviceId: device.id),
        ],
      ),
    );
  }
}

class _RecentResults extends ConsumerWidget {
  const _RecentResults({required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(deviceRecentResultsProvider(deviceId));
    return AsyncValueWidget<List<DeviceResult>>(
      value: results,
      onRetry: () => ref.invalidate(deviceRecentResultsProvider(deviceId)),
      builder: (items) {
        if (items.isEmpty) {
          return const Align(
              alignment: Alignment.centerLeft,
              child: Text('Результатов пока нет.'));
        }
        return Column(
          children: [
            for (final r in items)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(r.isRefraction
                    ? Icons.tune
                    : r.isScan
                        ? Icons.image_outlined
                        : Icons.description_outlined),
                title: Text(r.summary),
                subtitle: Text(
                    '${r.resultType} · ${r.measuredAt.replaceFirst('T', ' ').split('.').first} · ${r.source}'),
              ),
          ],
        );
      },
    );
  }
}
