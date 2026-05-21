import 'package:prbd_2526_f03/models/manager/reservation_detail.dart';
import 'package:prbd_2526_f03/models/manager/restaurant.dart';
import 'package:prbd_2526_f03/models/manager/table.dart';

// Composite qui contient plusieurs variables concernant le restaurant
class ManagerState {
  final int? currentRestaurantId;
  final List<Restaurant> restaurants;
  final List<ReservationDetail> reservations;
  final List<RestaurantTable> restaurantTables;
  List<RestaurantTable> get availableTables => restaurantTables;

  ManagerState({this.currentRestaurantId, this.restaurants = const [], this.reservations = const [], this.restaurantTables = const []});

  ManagerState copyWith({
    int? currentRestaurantId,
    List<Restaurant>? restaurants,
    List<ReservationDetail>? reservations,
    List<RestaurantTable>? restaurantTables
  }) {
    return ManagerState(
      currentRestaurantId: currentRestaurantId ?? this.currentRestaurantId,
      restaurants: restaurants ?? this.restaurants,
      reservations: reservations ?? this.reservations,
      restaurantTables: restaurantTables ?? this.restaurantTables
    );
  }
}
