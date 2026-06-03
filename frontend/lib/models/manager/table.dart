import 'dart:convert';
import 'package:prbd_2526_f03/core/services/api_client.dart';

class RestaurantTable {
  final int id;
  final int number;
  final int restaurant;
  final int capacity;
  final bool? isAvailable;

  RestaurantTable({
    required this.id,
    required this.number,
    required this.restaurant,
    required this.capacity,
    this.isAvailable,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['table_id'],
      number: json['table_number'],
      restaurant: json['table_restaurant'],
      capacity: json['table_capacity'],
      isAvailable: json['table_is_available'],
    );
  }

  static Future<List<RestaurantTable>> getAvailableTables(int restaurantId, DateTime date) async {
    final response = await ApiClient.post(
      'get_availables_tables',
      body: json.encode({'restaurant_id': restaurantId, 'reservation_datetime': date.toIso8601String()}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => RestaurantTable.fromJson(item)).toList();
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<List<RestaurantTable>> getTables(int restaurantId) async {
    final response = await ApiClient.post('get_tables', body: json.encode({'restaurant_id': restaurantId}));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => RestaurantTable.fromJson(item)).toList();
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createTable(int restaurantId, int newCapacity, int newNumber) async {
    final response = await ApiClient.post(
      'create_table',
      body: jsonEncode({'restaurant_id': restaurantId, 'new_capacity': newCapacity, 'new_number': newNumber}),
    );
    if (response.statusCode != 201) {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updateTable(int tableId, int capacity, int number) async {
    final response = await ApiClient.post(
      'update_table',
      body: jsonEncode({'table_id': tableId, 'new_capacity': capacity, 'new_number': number}),
    );
    if (response.statusCode != 204) {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<RestaurantTable> getSpecificTable(int tableId) async {
    final response = await ApiClient.post('get_specific_table', body: jsonEncode({'table_id': tableId}));
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return RestaurantTable.fromJson(body);
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<bool> validateCapacity(int tableId, int newCapacity) async {
    final response = await ApiClient.post(
      'check_table_capacity',
      body: json.encode({'table_id': tableId, 'new_capacity': newCapacity}),
    );

    if (response.statusCode == 200) {
      // (true = autorisé, false = bloqué)
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Erreur lors de la vérification de la capacité');
    }
  }
}
