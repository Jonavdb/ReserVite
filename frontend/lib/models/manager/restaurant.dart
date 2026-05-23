import 'dart:convert';
import 'package:prbd_2526_f03/core/services/api_client.dart';

class Restaurant {
  final int id;
  final String name;
  final String city;
  final double? rating; // optionnel
  final int? priceRange; // optionnel
  final DateTime? lastReservationDate; // optionnel
  final int pendingReservationsCount;

  Restaurant({
    required this.id,
    required this.name,
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
      city: json['city'],
      rating: json['rating'] != null
          ? (json['rating'])
                .toDouble() // gère les cas où le backend renvoie 4 au lieu de 4.0
          : null,
      priceRange: json['price_range'],
      lastReservationDate: json['last_reservation_date'] != null ? DateTime.parse(json['last_reservation_date']) : null,
      pendingReservationsCount: json['pending_reservation_count'] ?? 0,
    );
  }

  // Helper pour transformer le prix entier en symboles €
  String get priceSymbol {
    if (priceRange == null) return '';
    return '€' * priceRange!;
  }

  static Future<int> getRestaurantGap(int restaurant_id) async {
    final response = await ApiClient.post('get_restaurant_gap', body: json.encode ({'restaurant_id': restaurant_id}));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    } else {
      throw Exception(
        'Failed to get restaurant gap',
      );
    }
  }

  static Future<List<Restaurant>> getManagerRestaurants() async {
    final response = await ApiClient.post('get_restaurants_manager', body: json.encode({}));

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to get manager'
        's restaurants',
      );
    }
  }
}
