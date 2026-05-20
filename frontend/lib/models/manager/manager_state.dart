import 'package:prbd_2526_f03/models/manager/reservation_detail.dart';
import 'package:prbd_2526_f03/models/manager/restaurant.dart';

// Composite qui contient plusieurs variables concernant le restaurant
class ManagerState {
  final int? currentRestaurantId;
  final List<Restaurant> restaurants;
  final List<ReservationDetail> reservations;

  ManagerState({this.currentRestaurantId, this.restaurants = const [], this.reservations = const []});

  ManagerState copyWith({
    int? currentRestaurantId,
    List<Restaurant>? restaurants,
    List<ReservationDetail>? reservations,
  }) {
    return ManagerState(
      currentRestaurantId: currentRestaurantId ?? this.currentRestaurantId,
      restaurants: restaurants ?? this.restaurants,
      reservations: reservations ?? this.reservations,
    );
  }
}
