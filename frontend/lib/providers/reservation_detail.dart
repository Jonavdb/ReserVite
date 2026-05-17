import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/reservation.dart';

final reservationDetailProvider = AsyncNotifierProvider<ReservationDetailNotifier, Reservation?>(() => ReservationDetailNotifier());

class ReservationDetailNotifier extends AbstractAsyncNotifier<Reservation?> {
  int? _reservationId;
  @override
  Future<Reservation?> build () async {
    return null;
  }

  @override
  Future<void> refresh() async {
    await getReservation(_reservationId!);
  }

  Future<void> getReservation(int reservationId) async {
    _reservationId = reservationId;
    state = const AsyncValue.loading();
    try {
      final reservation = await Reservation.getReservation(reservationId);
      state = AsyncData(reservation);
    } catch(e) {
      state = AsyncValue.error("Something went wrong", StackTrace.current);
    }
  }
}