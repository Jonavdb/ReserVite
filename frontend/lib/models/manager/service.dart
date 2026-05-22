import 'dart:convert';

import 'package:prbd_2526_f03/core/services/api_client.dart';
import 'package:prbd_2526_f03/models/manager/time_only.dart';

class Service {
  final int id;
  final int dayOfWeek;
  final int restaurant;
  final TimeOnly startTime;
  final TimeOnly endTime;
  final String day;
  bool isDeletable;

  Service({
    required this.id, required this.dayOfWeek, required this.restaurant, required this.startTime, required this.endTime, required this.day, required this.isDeletable
  });

  factory Service.fromJson(Map<String, dynamic> json){
    return Service(id: json['id'], dayOfWeek: json['day_of_week'], restaurant: json['restaurant'], startTime: TimeOnly.fromString(json['start_time']), endTime: TimeOnly.fromString(json['end_time']), day: getDayOfWeek(json['day_of_week']), isDeletable: (json['can_be_deleted']));
  }

  static Future<List<Service>> getServiceForResturant(int restaurantId) async {
    final response = await ApiClient.post('get_services_for_restaurant', body: json.encode({'restaurant_id' : restaurantId,}));
    if (response.statusCode == 200){
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Service.fromJson(item)).toList();
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');    }
  }
  static String getDayOfWeek(int dayOfWeek){
    switch(dayOfWeek){
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5 : return 'Vendredi';
      case 6 : return 'Samedi';
      case 7 : return 'Dimanche';
      default: return 'Inconnu';
    }
  }
}