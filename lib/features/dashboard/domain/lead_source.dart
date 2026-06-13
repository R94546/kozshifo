// «Источники пациентов» — распределение привлечения по каналам.
// PLAIN Dart-классы с ручным fromJson (без freezed/codegen — см. AGENTS.md).
// Зеркалит backend GET /dashboard/lead-sources:
//   { "total": int, "sources": [ {"source","label","count"}, … ] }

/// Один канал привлечения: машинный ключ, человекочитаемая метка, кол-во.
class LeadSourceStat {
  const LeadSourceStat({
    required this.source,
    required this.label,
    required this.count,
  });

  /// Машинный ключ канала (`instagram`, `unknown`, …).
  final String source;

  /// Готовая метка с бэкенда (`Instagram`, `Не указан`, …).
  final String label;

  /// Число пациентов/визитов с этим источником за период.
  final int count;

  factory LeadSourceStat.fromJson(Map<String, dynamic> json) => LeadSourceStat(
        source: (json['source'] ?? '').toString(),
        label: (json['label'] ?? '').toString(),
        count: (json['count'] as num?)?.toInt() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      other is LeadSourceStat &&
      other.source == source &&
      other.label == label &&
      other.count == count;

  @override
  int get hashCode => Object.hash(source, label, count);
}

/// Отчёт за период: суммарно + список каналов (порядок с бэкенда сохраняем —
/// он уже отсортирован по count desc и включает нулевые каналы).
class LeadSourceReport {
  const LeadSourceReport({required this.total, required this.sources});

  /// Сумма по всем каналам (включая «Не указан»).
  final int total;

  /// Каналы в порядке, заданном бэкендом.
  final List<LeadSourceStat> sources;

  factory LeadSourceReport.fromJson(Map<String, dynamic> json) =>
      LeadSourceReport(
        total: (json['total'] as num?)?.toInt() ?? 0,
        sources: ((json['sources'] as List<dynamic>?) ?? const [])
            .map((e) => LeadSourceStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Все каналы пусты — показываем «Пока нет данных».
  bool get isEmpty => total == 0;
}
