import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/models/client/reservation_client.dart';
import 'package:prbd_2526_f03/models/restaurant/restaurant_details.dart';
import '../../core/services/api_client.dart';
import '../restaurant/restaurant.dart';

class ClientState {
  final String currentFilter;
  final List<ReservationClient> reservations;
  final List<Restaurant> restaurants;
  final String? searchedInput;
  final RestaurantDetails? selectedRestaurant;
  final List<DateTime>? availableTimeSlots;

  ClientState({
    required this.currentFilter, // filtre d'affichage des réservations du client connecté ('pending', 'confirmed' etc)
    required this.reservations, // liste des réservations du client connecté
    required this.restaurants,
    this.searchedInput = '',
    this.selectedRestaurant,
    this.availableTimeSlots,
  });

  ClientState copyWith({
    String? currentFilter,
    List<ReservationClient>? reservations,
    List<Restaurant>? restaurants,
    String? searchedInput,
    RestaurantDetails? selectedRestaurant,
    List<DateTime>? availableTimeSlots
  }) {
    return ClientState(
      currentFilter: currentFilter ?? this.currentFilter,
      reservations: reservations ?? this.reservations,
      restaurants: restaurants ?? this.restaurants,
      searchedInput: searchedInput ?? this.searchedInput,
      selectedRestaurant: selectedRestaurant ?? this.selectedRestaurant,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots
    );
  }

  static const maxRestaurants = 5;
  late final bool hasMoreRestaurantsThanLimit = restaurants.length > maxRestaurants;

  // liste coupée à la limite pour l'affichage
  late final List<Restaurant> displayedRestaurants = restaurants.take(maxRestaurants).toList();

  static Future<List<ReservationClient>> fetchReservations(String? status) async {
    // on formatte le paramètre status pour l'appel au backend
    final Map<String, String?> params = {};
    if (status != null) {
      params['status_filter'] = status;
    }

    final response = await ApiClient.post(
      'get_client_reservations',
      body: params.isNotEmpty ? json.encode(params) : null,
      anonymous: false,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load reservations from database');
    }

    final dynamic body = json.decode(response.body);

    List<ReservationClient> reservations = [];
    for (var res in body) {
      var myRes = ReservationClient.fromJson(res);
      reservations.add(myRes);
    }
    return reservations;
  }

  static Future<ReservationClient> fetchReservationById(int? id) async {
    final Map<String, int> params = {};
    if (id != null) {
      params['resid'] = id;
    }

    final response = await ApiClient.post(
      'get_client_reservation_by_id',
      body: params.isNotEmpty ? json.encode(params) : null,
      anonymous: false,
    );

    if (response.statusCode != 200) {
      throw Exception("Réservation introuvable. ID: $id");
    }

    final dynamic body = json.decode(response.body);

    return ReservationClient.fromJson(body);
  }

  static Future<List<DateTime>> fetchAvailableTimeSlots(int restaurantId, DateTime datePendingReservation) async {
    final Map<String, dynamic> params = {};
    params['p_resdate'] = datePendingReservation.toIso8601String();
    params['p_restaurant_id'] = restaurantId;

    final response = await ApiClient.post(
      'get_slots_available_for_potential_reservation',
      body: params.isNotEmpty ? json.encode(params) : null,
      anonymous: false,
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur récupération créneaux horaires disponibles : ${response.reasonPhrase}");
    }

    final List<String> decodedList = List<String>.from(json.decode(response.body));

    return decodedList.map((timeString) {
      final dateStr = DateFormat('yyyy-MM-dd').format(datePendingReservation);
      return DateTime.parse('${dateStr}T$timeString');
    }).toList();
  }

  static Future<bool> fetchSlotCapacityCheck(int restaurantId, DateTime targetTimestamp, int requestedGuests) async {
    final Map<String, dynamic> params = {
      'p_target_timestamp': targetTimestamp.toIso8601String(),
      'p_restaurant_id': restaurantId,
      'p_requested_guests': requestedGuests,
    };

    final response = await ApiClient.post(
      'check_capacity_for_potential_reservation',
      body: json.encode(params),
      anonymous: false,
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur vérification capacité : ${response.reasonPhrase}");
    }

    return json.decode(response.body) as bool;
  }
}
