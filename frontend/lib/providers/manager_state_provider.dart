import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/manager/reservation_detail.dart';
import '../models/manager/reservation.dart';
import '../models/manager/reservation_detail.dart';

final managerStateProvider = AsyncNotifierProvider<ManagerStateNotifier, List<ReservationDetail>>(() => ManagerStateNotifier());

class ManagerStateNotifier extends AbstractAsyncNotifier<List<ReservationDetail>> {
  int? _restaurantId;

  @override
  Future<List<ReservationDetail>> build () async {
    return [];
  }

  @override
  Future<void> refresh() async {
    await getReservations(_restaurantId!);
  }

  Future<void> getReservation(int reservationId) async {
    final currentList = state.value ?? [];
    state = const AsyncValue.loading();
    try {
      final updatedRes =  await ReservationDetail.getReservation(reservationId);

      bool found = false;
      final newList = currentList.map((res) {
        if (res.id == reservationId){
          found = true;
          return updatedRes;
        }
        return res;
      }).toList();

      if (!found){
        newList.add(updatedRes);
      }

      // 3. On renvoie la liste complète
      state = AsyncData(newList);
    } catch(e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }


  Future<void> cancelledReservation(ReservationDetail res) async {
    state = const AsyncValue.loading();
    try {
      await res.cancelReservation(res.id);
      final List<ReservationDetail> list = await ReservationDetail.getReservations(_restaurantId!);
      state = AsyncData(list);
    } catch (e) {
      state = AsyncValue.error(
        e.toString(),
        StackTrace.current,
      );
    }
  }

  Future<void> getReservations(int restaurantId) async {
    _restaurantId = restaurantId;
    state = const AsyncValue.loading();
    try {
      final reservations = await ReservationDetail.getReservations(restaurantId);
      state = AsyncData(reservations);
    } catch(e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}