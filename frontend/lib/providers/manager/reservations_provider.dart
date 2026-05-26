import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_f03/models/manager/reservation.dart';

final reservationProvider = AsyncNotifierProvider<ReservationsNotifier, List<Reservation>>(
  () => ReservationsNotifier(),
);

class ReservationsNotifier extends AbstractAsyncNotifier<List<Reservation>> {
  int? _restaurantId;
  @override
  Future<List<Reservation>> build() async {
    return [];
  }

  Future<void> refresh() async {
    await getReservations(_restaurantId!);
  }

  Future<void> getReservations(int restaurantId) async {
    _restaurantId = restaurantId;
    state = const AsyncValue.loading();
    try {
      final reservations = await Reservation.getReservations(restaurantId);
      state = AsyncData(reservations);
    } catch (e) {
      state = AsyncValue.error("Something went wrong", StackTrace.current);
    }
  }
}
