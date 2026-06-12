// QueueTicket model: snake_case parsing, status helpers.
import 'package:flutter_test/flutter_test.dart';
import 'package:kozshifo/features/queue/domain/queue_ticket.dart';

void main() {
  const json = <String, dynamic>{
    'id': 't1',
    'ticket_number': 'A-001',
    'patient_id': 'p1',
    'branch_id': 'b1',
    'visit_id': 'v1',
    'room': 'Каб. 1',
    'status': 'called',
    'priority': 0,
    'called_at': '2026-06-12T10:00:00Z',
    'created_at': '2026-06-12T09:55:00Z',
  };

  test('QueueTicket round-trips backend payload', () {
    final t = QueueTicket.fromJson(json);
    expect(t.ticketNumber, 'A-001');
    expect(t.isActive, isTrue);
    expect(t.isWaiting, isFalse);
    expect(t.statusLabel, 'вызван');
    expect(QueueTicket.fromJson(t.toJson()), t);
  });

  test('status helpers cover the whole flow', () {
    QueueTicket at(String status) =>
        QueueTicket.fromJson({...json, 'status': status});
    expect(at('waiting').isWaiting, isTrue);
    expect(at('serving').isActive, isTrue);
    expect(at('done').isActive, isFalse);
    expect(at('skipped').statusLabel, 'пропущен');
  });
}
