import 'dart:convert';

import 'package:prbd_2526_f03/core/services/api_client.dart';

class Restaurant {
  final int id;
  final String name;
  final String address;
  final String city;
  final double? rating; // optionnel
  final int? priceRange; // optionnel
  final DateTime? lastReservationDate; // optionnel
  final int pendingReservationsCount;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.rating,
    this.priceRange,
    this.lastReservationDate,
    required this.pendingReservationsCount,
  });

  // lit les valeurs dans la map json et crée une nouvelle instance de Restaurant avec ces données
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      rating: json['rating'] != null
          ? (json['rating'])
                .toDouble() // gère les cas où le backend renvoie 4 au lieu de 4.0
          : null,
      priceRange: json['price_range'],
      lastReservationDate: json['last_reservation_date'] != null ? DateTime.parse(json['last_reservation_date']) : null,
      pendingReservationsCount: json['pending_reservations_count'] ?? 0,
    );
  }

  static Future<List<Restaurant>> getManagerRestaurants() async {
    final response = await ApiClient.post('get_restaurants_manager', body: json.encode({}));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);

      print('=== JSON REÇU : $body ===');

      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    } else {
      print('🚨 MESSAGE DU BACKEND : ${response.body}');
      throw Exception(
        'Failed to get manager'
        's restaurants',
      );
    }
  }
}
