import 'dart:convert';
import 'package:prbd_2526_f03/core/services/api_client.dart';

class Reservation {
  final int id;
  final int client;
  final int restaurant;
  final DateTime datetime;
  final int numberOfGuests;
  final String status;
  final String? specialRequests;
  final String clientName;

  Reservation({
    required this.id,
    required this.client,
    required this.datetime,
    required this.numberOfGuests,
    required this.restaurant,
    required this.status,
    required this.clientName,
    this.specialRequests,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      client: json['client'],
      restaurant: json['restaurant'],
      datetime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'],
      status: json['status'],
      specialRequests: json['special_requests'],
      clientName: json['client_name'],
    );
  }

  static Future<List<Reservation>> getReservations(int restaurantId) async {
    final response = await ApiClient.post(
      'get_reservations_manager',
      body: json.encode({'restaurant_id': restaurantId}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Reservation.fromJson(item)).toList();
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Reservation> getReservation(int reservationId) async {
    final response = await ApiClient.post('get_reservation', body: jsonEncode({'reservation_id': reservationId}));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return Reservation.fromJson(body.first);
    } else {
      throw Exception('Failed to get reservation');
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    final response = await ApiClient.post(
      'cancel_reservation_manager',
      body: jsonEncode({'reservation_id': reservationId}),
    );
    if (response.statusCode != 204) {
      throw Exception('failed to cancel the reservation');
    }
  }
}
