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
    required this.id, required this.dayOfWeek, required this.restaurant, required this.startTime, required this.endTime, required this.day,required this.isDeletable
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

  static Future<Service> getSpecificService(int serviceId, int restaurantId) async {
    final response = await ApiClient.post(
      'get_specific_service',
      body: jsonEncode({'service_id': serviceId, 'restaurant_id': restaurantId}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Service.fromJson(body);
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteService(int serviceId) async {
    final response = await ApiClient.post('delete_service',
        body: jsonEncode(
            {'service_id': serviceId}));
    if (response.statusCode != 204) {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }
  static Future<int> countReservationsOutsideNewSlot(int restaurantId, int dayOfWeek, TimeOnly newStartTime, TimeOnly newEndTime, int serviceId) async {
    final response = await ApiClient.post('count_reservations_outside_new_slot',
        body: jsonEncode(
            {'restaurant_id': restaurantId,
              'new_day_of_week': dayOfWeek,
              'new_start_time': newStartTime.toFullString(),
              'new_end_time': newEndTime.toFullString(),
              'service_id': serviceId,
            })
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<int> countImpactedServices(int restaurantId, int dayOfWeek, TimeOnly newStartTime, TimeOnly newEndTime, int serviceId) async {
    final response = await ApiClient.post('count_impacted_services',
        body: jsonEncode(
            {'restaurant_id': restaurantId,
              'new_day_of_week': dayOfWeek,
              'new_start_time': newStartTime.toFullString(),
              'new_end_time': newEndTime.toFullString(),
              'service_id': serviceId,
            })
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updateService(int serviceId, int dayOfWeek, TimeOnly newStartTime, TimeOnly newEndTime) async {
    final response = await ApiClient.post('update_service',
        body: jsonEncode(
                {'service_id': serviceId,
                 'new_day_of_week': dayOfWeek,
                 'new_start_time': newStartTime.toFullString(),
                 'new_end_time': newEndTime.toFullString(),
                })
        );
    if (response.statusCode != 204) {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> createService(int restaurantId, int dayOfWeek, TimeOnly newStartTime, TimeOnly newEndTime) async {
    final response = await ApiClient.post('create_service',
        body : jsonEncode(
                {'restaurant_id': restaurantId,
                  'new_day_of_week': dayOfWeek,
                  'new_start_time': newStartTime.toFullString(),
                  'new_end_time': newEndTime.toFullString(),
                })
        );
    if (response.statusCode != 201) {
      throw Exception('Status: ${response.statusCode} - ${response.body}');
    }
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

  static int getDayNumber(String day){
    switch(day){
      case 'Lundi': return 1;
      case 'Mardi': return 2;
      case 'Mercredi': return 3;
      case 'Jeudi': return 4;
      case 'Vendredi' : return 5;
      case 'Samedi' : return 6;
      case 'Dimanche' : return 7;
      default: return 0;
    }
  }
}