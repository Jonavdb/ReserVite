import 'dart:convert';

import '../core/services/api_client.dart';

class ClientState {
  final String currentFilter;
  final List<dynamic> reservations;

  ClientState({
      required this.currentFilter,
      required this.reservations
  });

  static Future<List<dynamic>> fetchReservations(String? status) async {
    final Map<String, dynamic> params = {};
    if (status != null) {
      params['status_filter'] = status;
    }

    final response = await ApiClient.post(
      'get_user_reservations',
      body: params.isNotEmpty ? json.encode(params) : null,
      anonymous: false,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load reservations from database');
    }

    final dynamic body = json.decode(response.body);
    return body as List<dynamic>;
  }


}