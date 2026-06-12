import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../domain/queue_ticket.dart';

final queueRepositoryProvider =
    Provider<QueueRepository>((ref) => QueueRepository(ref.watch(dioProvider)));

class QueueRepository {
  QueueRepository(this._dio);

  final Dio _dio;

  Future<List<QueueTicket>> list(String branchId, {bool activeOnly = true}) async {
    try {
      final resp = await _dio.get('/queue', queryParameters: {
        'branch_id': branchId,
        'active_only': activeOnly,
      });
      return (resp.data as List<dynamic>)
          .map((e) => QueueTicket.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<QueueTicket> callNext({required String branchId, required String room}) async {
    try {
      final resp = await _dio.post('/queue/call-next',
          data: {'branch_id': branchId, 'room': room});
      return QueueTicket.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<QueueTicket> _transition(String ticketId, String action) async {
    try {
      final resp = await _dio.post('/queue/$ticketId/$action');
      return QueueTicket.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<QueueTicket> serve(String ticketId) => _transition(ticketId, 'serve');
  Future<QueueTicket> done(String ticketId) => _transition(ticketId, 'done');
  Future<QueueTicket> skip(String ticketId) => _transition(ticketId, 'skip');
}

final queueListProvider = FutureProvider.autoDispose
    .family<List<QueueTicket>, String>((ref, branchId) =>
        ref.watch(queueRepositoryProvider).list(branchId));
