import 'dart:convert';

import 'package:prbd_2526_f03/core/services/api_client.dart';

class ReservationDetail {
  final int id;
  final int client;
  final int restaurant;
  final String restaurantName;
  final DateTime datetime;
  final int number_of_guests;
  final String status;
  final String? special_requests;
  final String clientName;
  final String clientEmail;
  final String? clientPhone;
  final List<int>? tableNumbers;
  final List<int>? tableCapacities;


  ReservationDetail({
    required this.id, required this.client, required this.datetime, required this.number_of_guests, required this.restaurant, required this.status, required this.clientName, this.special_requests, required this.restaurantName, this.clientPhone, required this.clientEmail, this.tableCapacities, this.tableNumbers
  });

  factory ReservationDetail.fromJson(Map<String, dynamic> json){
    return ReservationDetail(id: json['id'], client: json['client'], restaurant: json['restaurant'], datetime: DateTime.parse(json['datetime']), number_of_guests: json['number_of_guests'], status: json['status'], special_requests: json['special_requests'], clientName: json['client_name'], restaurantName: json['restaurant_name'], clientEmail: json['client_email'], clientPhone: json['client_phone'], tableCapacities: json['table_capacities'] != null ? List<int>.from(json['table_capacities']) : null , tableNumbers: json['table_numbers'] != null ? List<int>.from(json['table_numbers']) : null);
  }
// Pour caster ma liste dynamique en liste d'entiers, on utilise List<int>.from() qui convertit chaque élément de ma liste dynamique en enteirs.
  static Future<ReservationDetail> getReservation(int reservationId) async {
    final response = await ApiClient.post('get_reservation_manager', body: jsonEncode({'reservation_id' : reservationId}));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return ReservationDetail.fromJson(body.first);
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');    }
  }

}