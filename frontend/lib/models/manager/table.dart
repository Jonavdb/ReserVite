import 'dart:convert';

import 'package:prbd_2526_f03/core/services/api_client.dart';

class RestaurantTable {
  final int id;
  final int number;
  final int restaurant;
  final int capacity;
  final bool? isAvailable;

  RestaurantTable({
    required this.id, required this.number, required this.restaurant, required this.capacity, this.isAvailable
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json){
    return RestaurantTable(id: json['table_id'], number: json['table_number'], restaurant: json['table_restaurant'], capacity: json['table_capacity'], isAvailable: json['table_is_available']);
  }

  static Future<List<RestaurantTable>> getAvailableTables(int restaurantId, DateTime date) async {
    final response = await ApiClient.post('get_availables_tables', body: json.encode({'restaurant_id' : restaurantId, 'reservation_datetime' : date.toIso8601String()}));
    if (response.statusCode == 200){
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => RestaurantTable.fromJson(item)).toList();
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');    }
  }
}