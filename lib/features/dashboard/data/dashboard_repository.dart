import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/dashboard_summary.dart';
import '../domain/insight.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) => DashboardRepository(ref.watch(dioProvider)));

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardSummary> summary() async {
    try {
      final resp = await _dio.get('/dashboard/summary');
      return DashboardSummary.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// «Что требует внимания» — backend отдаёт уже отсортированным
  /// critical → warning → info; пустой список = всё в порядке.
  Future<List<Insight>> insights() async {
    try {
      final resp = await _dio.get('/dashboard/insights');
      return (resp.data as List<dynamic>)
          .map((e) => Insight.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}

final dashboardSummaryProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).summary();
});

final insightsProvider = FutureProvider.autoDispose<List<Insight>>((ref) {
  return ref.watch(dashboardRepositoryProvider).insights();
});
