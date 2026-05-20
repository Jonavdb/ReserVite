import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/models/manager/reservation_detail.dart';

import '../../core/tools/abstract_async_notifier.dart';

final reservationDetailProvider = AsyncNotifierProvider<ReservationDetailNotifier, ReservationDetail?>(
  () => ReservationDetailNotifier(),
);

class ReservationDetailNotifier extends AbstractAsyncNotifier<ReservationDetail?> {
  int? _reservationId;
  @override
  Future<ReservationDetail?> build() async {
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
      final reservation = await ReservationDetail.getReservation(reservationId);
      state = AsyncData(reservation);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> cancelledReservation(ReservationDetail res) async {
    state = const AsyncValue.loading();
    try {
      await res.cancelReservation(res.id);
      state = AsyncData(res);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}
