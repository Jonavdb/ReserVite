import 'dart:convert';

import 'package:prbd_2526_f03/models/reservation_client.dart';

import '../core/services/api_client.dart';

class ClientState {
  final String currentFilter;
  final List<ReservationClient> reservations;

  ClientState({
      required this.currentFilter,
      required this.reservations
  });

  static Future<List<ReservationClient>> fetchReservations(String? status) async {
    final Map<String, String?> params = {};
    if (status != null) {
      params['status_filter'] = status;
    }

    final response = await ApiClient.post(
      'get_client_reservations',
      body: params.isNotEmpty ? json.encode(params) : null,
      anonymous: false,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load reservations from database');
    }

    final dynamic body = json.decode(response.body);
    List<ReservationClient> reservations = [];
    for (var res in body) {
      var myRes = ReservationClient.fromJson(res);
      reservations.add(myRes);
    }
    return reservations;
  }


}