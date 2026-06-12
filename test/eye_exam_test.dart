// EyeExam model: snake_case JSON round-trip + display helpers.
import 'package:flutter_test/flutter_test.dart';
import 'package:kozshifo/features/doctor/domain/eye_exam.dart';

void main() {
  const json = <String, dynamic>{
    'id': 'e1',
    'visit_id': 'v1',
    'patient_id': 'p1',
    'doctor_id': 'd1',
    'exam_date': '2026-06-12',
    'complaints': 'Снижение зрения вдаль',
    'anamnesis': 'Миопия с детства',
    'od_va': '0.6',
    'od_sph': '-1.25',
    'od_cyl': '-0.50',
    'od_axis': 170,
    'od_va_cc': '1.0',
    'os_va': '0.7',
    'os_sph': '-1.00',
    'os_cyl': '-0.25',
    'os_axis': 10,
    'os_va_cc': '1.0',
    'iop_od': '16.0',
    'iop_os': '17.0',
    'cornea': 'прозрачная',
    'lens': 'прозрачный',
    'fundus': 'ДЗН бледно-розовый',
    'ab_scan_note': 'без отслойки',
    'diagnosis': 'Миопия слабой степени OU',
    'icd10': 'H52.1',
    'recommendations': 'очковая коррекция',
  };

  group('EyeExam', () {
    test('fromJson reads snake_case backend payload', () {
      final exam = EyeExam.fromJson(json);
      expect(exam.visitId, 'v1');
      expect(exam.odSph, '-1.25'); // clinical decimal stays a string
      expect(exam.odAxis, 170);
      expect(exam.iopOs, '17.0');
      expect(exam.anteriorChamber, isNull);
      expect(exam.diagnosis, 'Миопия слабой степени OU');
    });

    test('toJson round-trips every populated field', () {
      final exam = EyeExam.fromJson(json);
      final out = exam.toJson();
      for (final entry in json.entries) {
        expect(out[entry.key], entry.value, reason: 'field ${entry.key}');
      }
      // And a full cycle is lossless.
      expect(EyeExam.fromJson(out), exam);
    });

    test('visusLine builds the form-style summary', () {
      final exam = EyeExam.fromJson(json);
      expect(exam.visusLine('OD'), 'Visus OD 0.6 ; sph -1.25 cyl -0.50 ax 170° = 1.0');
      expect(exam.visusLine('OS'), contains('sph -1.00'));
    });
  });
}
