import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../patients/data/patients_repository.dart';
import '../../patients/domain/patient.dart';

/// Шапка колонки ПАЦИЕНТ: ФИО, возраст (из birthDate), пол, телефоны,
/// источник обращения. Данные тянутся из [patientByIdProvider].
class PatientInfoCard extends ConsumerWidget {
  const PatientInfoCard({super.key, required this.patientId});

  final String patientId;

  static String _genderLabel(String? g) => switch (g) {
    'male' => 'Мужской',
    'female' => 'Женский',
    'other' => 'Другое',
    _ => '—',
  };

  static String _leadSourceLabel(String? s) => switch (s) {
    'instagram' => 'Instagram',
    'telegram' => 'Telegram',
    'google' => 'Google',
    'referral' => 'Рекомендация',
    'banner' => 'Баннер',
    'walk_in' => 'Проходил мимо',
    'other' => 'Другое',
    _ => '—',
  };

  /// Возраст полными годами из строки ISO `YYYY-MM-DD`; null если не задана
  /// или не парсится.
  static int? ageFromBirthDate(String? birthDate, {DateTime? now}) {
    if (birthDate == null || birthDate.isEmpty) return null;
    final dob = DateTime.tryParse(birthDate);
    if (dob == null) return null;
    final today = now ?? DateTime.now();
    var age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age -= 1;
    }
    return age < 0 ? null : age;
  }

  /// «35 лет», «1 год», «22 года» — корректное русское склонение.
  static String _ageLabel(int age) {
    final mod100 = age % 100;
    final mod10 = age % 10;
    final String word;
    if (mod100 >= 11 && mod100 <= 14) {
      word = 'лет';
    } else if (mod10 == 1) {
      word = 'год';
    } else if (mod10 >= 2 && mod10 <= 4) {
      word = 'года';
    } else {
      word = 'лет';
    }
    return '$age $word';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientByIdProvider(patientId));
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: patient.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text(
            'Не удалось загрузить пациента: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          data: (p) => _body(context, p),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Patient p) {
    final theme = Theme.of(context);
    final age = ageFromBirthDate(p.birthDate);
    final phones = [
      if (p.phone != null && p.phone!.isNotEmpty) p.phone!,
      if (p.phone2 != null && p.phone2!.isNotEmpty) p.phone2!,
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                p.initials,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.fullName, style: theme.textTheme.titleMedium),
                  Text(
                    '№ карты: ${p.mrn}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        _row(context, Icons.cake_outlined, 'Возраст',
            age == null ? '—' : _ageLabel(age)),
        _row(context, Icons.wc_outlined, 'Пол', _genderLabel(p.gender)),
        _row(
          context,
          Icons.phone_outlined,
          'Телефон',
          phones.isEmpty ? '—' : phones,
        ),
        _row(
          context,
          Icons.campaign_outlined,
          'Источник',
          _leadSourceLabel(p.leadSource),
        ),
        if (p.address != null && p.address!.isNotEmpty)
          _row(context, Icons.home_outlined, 'Адрес', p.address!),
      ],
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
