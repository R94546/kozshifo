// DashboardSummary model: snake_case parsing of director KPIs,
// including the Phase-4 operation/stock counters with safe defaults.
import 'package:flutter_test/flutter_test.dart';
import 'package:kozshifo/features/dashboard/domain/dashboard_summary.dart';

void main() {
  const baseJson = <String, dynamic>{
    'revenue_today': '150000.00',
    'revenue_month': '4200000.00',
    'payments_today': 12,
    'average_check_today': '12500.00',
    'visits_today': 14,
    'new_patients_today': 5,
    'patients_total': 1023,
    'queue_waiting': 3,
  };

  test('parses the four new KPI fields from snake_case JSON', () {
    final s = DashboardSummary.fromJson({
      ...baseJson,
      'operations_today': 2,
      'operations_month': 31,
      'low_stock_count': 4,
      'expiring_soon_count': 7,
    });
    expect(s.operationsToday, 2);
    expect(s.operationsMonth, 31);
    expect(s.lowStockCount, 4);
    expect(s.expiringSoonCount, 7);
    // Pre-existing fields still parse.
    expect(s.revenueToday, '150000.00');
    expect(s.queueWaiting, 3);
  });

  test('defaults the new fields to 0 when an older backend omits them', () {
    final s = DashboardSummary.fromJson(baseJson);
    expect(s.operationsToday, 0);
    expect(s.operationsMonth, 0);
    expect(s.lowStockCount, 0);
    expect(s.expiringSoonCount, 0);
  });
}
