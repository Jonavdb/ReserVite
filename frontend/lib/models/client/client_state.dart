import 'dart:convert';
import 'package:prbd_2526_f03/models/client/reservation_client.dart';
import '../../core/services/api_client.dart';
import '../manager/restaurant.dart';

class ClientState {
  final String currentFilter;
  final List<ReservationClient> reservations;
  final List<Restaurant> restaurants;
  final String? searchedInput;

  ClientState({
    required this.currentFilter, // filtre d'affichage des réservations du client connecté ('pending', 'confirmed' etc)
    required this.reservations, // liste des réservations du client connecté
    required this.restaurants,
    this.searchedInput = '',
  });

  ClientState copyWith({
    String? currentFilter,
    List<ReservationClient>? reservations,
    String? searchedInput,
    List<Restaurant>? restaurants,
  }) {
    return ClientState(
      currentFilter: currentFilter ?? this.currentFilter,
      reservations: reservations ?? this.reservations,
      searchedInput: searchedInput ?? this.searchedInput,
      restaurants: restaurants ?? this.restaurants,
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
}
