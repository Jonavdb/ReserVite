import 'package:prbd_2526_f03/models/manager/reservation_detail.dart';
import 'package:prbd_2526_f03/models/manager/restaurant.dart';
import 'package:prbd_2526_f03/models/manager/table.dart';
import 'package:prbd_2526_f03/models/manager/service.dart';

// Composite qui contient plusieurs variables concernant le restaurant
class ManagerState {
  final int? currentRestaurantId;
  final List<Restaurant> restaurants;
  final List<ReservationDetail> reservations;
  final List<RestaurantTable> restaurantTables;
  final List<Service> services;
  List<RestaurantTable> get availableTables => restaurantTables;

  ManagerState({this.currentRestaurantId, this.restaurants = const [], this.reservations = const [], this.restaurantTables = const [], this.services = const[]});

  ManagerState copyWith({
    int? currentRestaurantId,
    List<Restaurant>? restaurants,
    List<ReservationDetail>? reservations,
    List<RestaurantTable>? restaurantTables,
    List<Service>? services
  }) {
    return ManagerState(
      currentRestaurantId: currentRestaurantId ?? this.currentRestaurantId,
      restaurants: restaurants ?? this.restaurants,
      reservations: reservations ?? this.reservations,
      restaurantTables: restaurantTables ?? this.restaurantTables,
      services: services ?? this.services
    );
  }
}
