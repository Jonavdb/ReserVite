import 'dart:convert';
import 'package:prbd_2526_f03/core/services/api_client.dart';

class ReservationDetail {
  final int id;
  final int client;
  final int restaurant;
  final String restaurantName;
  final DateTime datetime;
  final int numberOfGuests;
  final String status;
  final String? specialRequests;
  final String clientName;
  final String clientEmail;
  final String? clientPhone;
  final List<int>? tableNumbers;
  final List<int>? tableCapacities;

  ReservationDetail({
    required this.id,
    required this.client,
    required this.datetime,
    required this.numberOfGuests,
    required this.restaurant,
    required this.status,
    required this.clientName,
    this.specialRequests,
    required this.restaurantName,
    this.clientPhone,
    required this.clientEmail,
    this.tableCapacities,
    this.tableNumbers,
  });

  factory ReservationDetail.fromJson(Map<String, dynamic> json) {
    return ReservationDetail(
      id: json['id'],
      client: json['client'],
      restaurant: json['restaurant'],
      datetime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'],
      status: json['status'],
      specialRequests: json['special_requests'],
      clientName: json['client_name'],
      restaurantName: json['restaurant_name'],
      clientEmail: json['client_email'],
      clientPhone: json['client_phone'],
      tableCapacities: json['table_capacities'] != null ? List<int>.from(
          json['table_capacities']) : null,
      tableNumbers: json['table_numbers'] != null ? List<int>.from(
          json['table_numbers']) : null,
    );
  }

  // Pour caster ma liste dynamique en liste d'entiers, on utilise List<int>.from() qui convertit chaque élément de ma liste dynamique en enteirs.
  static Future<ReservationDetail> getReservation(int reservationId) async {
    final response = await ApiClient.post(
      'get_reservation_manager',
      body: jsonEncode({'reservation_id': reservationId}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return ReservationDetail.fromJson(body.first);
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    final response = await ApiClient.post(
      'cancel_reservation_manager',
      body: jsonEncode({'reservation_id': reservationId}),
    );
    if (response.statusCode != 204) {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<ReservationDetail>> getReservations(
      int restaurantId) async {
    final response = await ApiClient.post(
      'get_reservations_manager',
      body: json.encode({'restaurant_id': restaurantId}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic item) => ReservationDetail.fromJson(item))
          .toList();
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> confirmReservation(int reservationId, List<int> tableIds) async {
    final response = await ApiClient.post('confirm_reservation_manager',
        body: jsonEncode(
            {'reservation_id': reservationId, 'table_ids': tableIds}));
    if (response.statusCode != 204) {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> completeReservation(int reservationId, DateTime date) async {
    final response = await ApiClient.post('complete_reservation_manager',
        body: jsonEncode({
          'reservation_id': reservationId,
          'date_simulated': date.toIso8601String()
        }));
    if (response.statusCode != 204) {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }
}
