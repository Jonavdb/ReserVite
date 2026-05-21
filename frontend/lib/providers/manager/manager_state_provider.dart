import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/models/manager/manager_state.dart';
import 'package:prbd_2526_f03/models/manager/restaurant.dart';
import '../../core/tools/abstract_async_notifier.dart';
import '../../models/manager/reservation_detail.dart';

final managerStateProvider = AsyncNotifierProvider<ManagerStateNotifier, ManagerState>(() => ManagerStateNotifier());

class ManagerStateNotifier extends AbstractAsyncNotifier<ManagerState> {
  @override
  Future<ManagerState> build() async {
    // on charge les restaurants au démarrage
    final restaurants = await Restaurant.getManagerRestaurants();
    return ManagerState(restaurants: restaurants);
  }

  @override
  Future<void> refresh() async {
    await refreshRestaurants();
    if (state.value?.currentRestaurantId != null) {
      await refreshReservations(); // refresh ses reservations si un resto est sélectionné
    }
  }

  Future<void> refreshRestaurants() async {
    final currentState = state.value ?? ManagerState();

    state = AsyncValue.loading();
    try {
      final restaurants = await Restaurant.getManagerRestaurants();
      state = AsyncData(currentState.copyWith(restaurants: restaurants));
    } catch (e) {
      state = AsyncValue.error("Failed to refresh manger's restaurants", StackTrace.current);
    }
  }

  Future<void> refreshReservations() async {
    final currentId = state.value?.currentRestaurantId;
    if (currentId == null) return;

    state = AsyncValue.loading();
    try {
      await getReservations(currentId);
    } catch (e) {
      state = AsyncValue.error("Failed to refresh reservations", StackTrace.current);
    }
  }

  Future<void> getReservation(int reservationId) async {
    final currentState = state.value ?? ManagerState();
    final currentList = state.value?.reservations ?? [];

    state = const AsyncValue.loading();
    try {
      final updatedRes = await ReservationDetail.getReservation(reservationId);
      bool found = false;

      final newList = currentList.map((res) {
        if (res.id == reservationId) {
          found = true;
          return updatedRes;
        }
        return res;
      }).toList();

      if (!found) {
        newList.add(updatedRes);
      }

      // on renvoie la liste complète en mettant à jour le ManagerState
      state = AsyncData(currentState.copyWith(reservations: newList));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> cancelledReservation(ReservationDetail res) async {
    final currentState = state.value ?? ManagerState();
    final currentId = state.value?.currentRestaurantId;
    if (currentId == null) return;

    state = const AsyncValue.loading();
    try {
      await res.cancelReservation(res.id);
      final List<ReservationDetail> reservationDetails = await ReservationDetail.getReservations(currentId);
      state = AsyncData(currentState.copyWith(reservations: reservationDetails));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> getReservations(int restaurantId) async {
    final currentState = state.value ?? ManagerState();
    state = const AsyncValue.loading();

    try {
      final reservations = await ReservationDetail.getReservations(restaurantId);
      state = AsyncData(currentState.copyWith(currentRestaurantId: restaurantId, reservations: reservations));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}
