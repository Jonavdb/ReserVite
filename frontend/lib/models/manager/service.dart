import 'dart:convert';

import 'package:prbd_2526_f03/core/services/api_client.dart';
import 'package:prbd_2526_f03/models/manager/time_only.dart';

class Service {
  final int id;
  final int dayOfWeek;
  final int restaurant;
  final TimeOnly startTime;
  final TimeOnly endTime;

  Service({
    required this.id, required this.dayOfWeek, required this.restaurant, required this.startTime, required this.endTime
  });

  factory Service.fromJson(Map<String, dynamic> json){
    return Service(id: json['service_id'], dayOfWeek: json['dayOfWeek'], restaurant: json['service_restaurant'], startTime: TimeOnly.fromString(json['startTime']), endTime: TimeOnly.fromString(json['endTime']));
  }

  static Future<List<Service>> getServiceForResturant(int restaurantId) async {
    final response = await ApiClient.post('get_services_for_restaurant', body: json.encode({'restaurant_id' : restaurantId,}));
    if (response.statusCode == 200){
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Service.fromJson(item)).toList();
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');    }
  }
}