import 'package:prbd_2526_f03/models/manager/reservation_detail.dart';
import 'package:prbd_2526_f03/models/restaurant/restaurant.dart';
import 'package:prbd_2526_f03/models/manager/table.dart';
import 'package:prbd_2526_f03/models/manager/service.dart';

// Composite qui contient plusieurs variables concernant le restaurant
class ManagerState {
  final int? currentRestaurantId;
  final int? currentRestaurantGap;
  final List<Restaurant> restaurants;
  final List<ReservationDetail> reservations;
  final List<RestaurantTable> restaurantTables;
  final List<Service> services;
  final int impactedReservations;
  final int impactedServices;
  List<RestaurantTable> get availableTables => restaurantTables;

  ManagerState({this.currentRestaurantId, this.currentRestaurantGap = 0, this.restaurants = const [], this.reservations = const [], this.restaurantTables = const [], this.services = const[], this.impactedReservations = 0, this.impactedServices = 0});

  ManagerState copyWith({
    int? currentRestaurantId,
    int? currentRestaurantGap,
    List<Restaurant>? restaurants,
    List<ReservationDetail>? reservations,
    List<RestaurantTable>? restaurantTables,
    List<Service>? services,
    int? impactedReservations,
    int? impactedServices,
  }) {
    return ManagerState(
      currentRestaurantId: currentRestaurantId ?? this.currentRestaurantId,
      currentRestaurantGap: currentRestaurantGap ?? this.currentRestaurantGap,
      restaurants: restaurants ?? this.restaurants,
      reservations: reservations ?? this.reservations,
      restaurantTables: restaurantTables ?? this.restaurantTables,
      services: services ?? this.services,
      impactedReservations: impactedReservations ?? this.impactedReservations,
      impactedServices: impactedServices ?? this.impactedServices
    );
  }
}
