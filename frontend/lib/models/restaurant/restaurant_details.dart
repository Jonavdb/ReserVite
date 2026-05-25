import 'dart:convert';
import 'package:prbd_2526_f03/models/restaurant/restaurant_services.dart';
import '../../core/services/api_client.dart';

class RestaurantDetails {
  final int id;
  final String name;
  final String address;
  final String city;
  final double? rating;
  final int? priceRange;
  final String? description;
  final List<RestaurantService> services;

  RestaurantDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.rating,
    this.priceRange,
    this.description,
    required this.services,
  });

  factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
    // Parsing de la liste des horaires imbriquée
    var list = json['services'] as List? ?? [];

    List<RestaurantService> serviceList = list
        .map((s) => RestaurantService.fromJson(s as Map<String, dynamic>))
        .toList();

    return RestaurantDetails(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      rating: json['rating'],
      description: json['description'],
      services: serviceList,
    );
  }

  static Future<RestaurantDetails> getDetails(int id) async {
    final response = await ApiClient.post('get_restaurant_details', body: json.encode({'restaurant_id': id}));

    if (response.statusCode == 200) {
      return RestaurantDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load restaurant details');
    }
  }
}
