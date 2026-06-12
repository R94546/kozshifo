// Owner-automation models: dashboard insights, patient timeline events,
// and the read-only flow-status labels (the backend flow engine owns the value).
import 'package:flutter_test/flutter_test.dart';
import 'package:kozshifo/core/utils/flow_labels.dart';
import 'package:kozshifo/features/dashboard/domain/insight.dart';
import 'package:kozshifo/features/doctor/domain/timeline_event.dart';
import 'package:kozshifo/features/doctor/domain/visit_summary.dart';

void main() {
  group('Insight', () {
    test('parses a critical insight and flags it', () {
      final i = Insight.fromJson(const {
        'code': 'stuck_visits',
        'severity': 'critical',
        'title': 'Зависшие визиты',
        'detail': '3 визита открыты дольше 24 часов',
        'value': '3',
      });
      expect(i.code, 'stuck_visits');
      expect(i.isCritical, isTrue);
      expect(i.isWarning, isFalse);
      expect(i.value, '3');
    });

    test('value is optional; warning severity sets only isWarning', () {
      final i = Insight.fromJson(const {
        'code': 'low_stock',
        'severity': 'warning',
        'title': 'Дефицит склада',
        'detail': 'Остаток ниже минимума',
      });
      expect(i.value, isNull);
      expect(i.isWarning, isTrue);
      expect(i.isCritical, isFalse);
    });

    test('info severity is neither critical nor warning', () {
      final i = Insight.fromJson(const {
        'code': 'fyi',
        'severity': 'info',
        'title': 'К сведению',
        'detail': 'Информационный сигнал',
      });
      expect(i.isCritical, isFalse);
      expect(i.isWarning, isFalse);
    });
  });

  group('TimelineEvent', () {
    test('parses snake_case JSON including optional refs', () {
      final e = TimelineEvent.fromJson(const {
        'ts': '2026-06-12T10:15:00',
        'kind': 'payment',
        'title': 'Оплата 150000.00',
        'detail': 'Чек R-000123',
        'visit_id': 'v1',
        'ref_id': 'p1',
      });
      expect(e.kind, 'payment');
      expect(e.detail, 'Чек R-000123');
      expect(e.visitId, 'v1');
      expect(e.refId, 'p1');
      expect(e.dateLabel, '2026-06-12');
    });

    test('optional fields default to null; dateLabel strips the time part', () {
      final e = TimelineEvent.fromJson(const {
        'ts': '2026-06-01T08:00:00',
        'kind': 'visit_opened',
        'title': 'Визит открыт',
      });
      expect(e.detail, isNull);
      expect(e.visitId, isNull);
      expect(e.refId, isNull);
      expect(e.dateLabel, '2026-06-01');
    });
  });

  group('flowStatusLabel', () {
    test('maps known statuses to RU labels', () {
      expect(flowStatusLabel('registered'), 'зарегистрирован');
      expect(flowStatusLabel('waiting_doctor'), 'ждёт врача');
      expect(flowStatusLabel('completed'), 'завершён');
    });

    test('passes an unknown status through unchanged', () {
      expect(flowStatusLabel('mystery_state'), 'mystery_state');
    });
  });

  group('VisitSummary.flowStatus', () {
    test('defaults to registered when an older backend omits it', () {
      final v = VisitSummary.fromJson(const {
        'id': 'v1',
        'visit_no': 'V-000001',
        'status': 'open',
        'opened_at': '2026-06-12T09:00:00',
      });
      expect(v.flowStatus, 'registered');
    });

    test('parses flow_status when present', () {
      final v = VisitSummary.fromJson(const {
        'id': 'v1',
        'visit_no': 'V-000001',
        'status': 'open',
        'flow_status': 'in_doctor',
        'opened_at': '2026-06-12T09:00:00',
      });
      expect(v.flowStatus, 'in_doctor');
    });
  });
}
