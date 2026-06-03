import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/models/manager/manager_state.dart';
import 'package:prbd_2526_f03/models/manager/time_only.dart';
import 'package:prbd_2526_f03/models/restaurant/restaurant.dart';
import 'package:prbd_2526_f03/providers/simulated_time_provider.dart';
import '../../core/tools/abstract_async_notifier.dart';
import '../../models/manager/reservation_detail.dart';
import '../../models/manager/service.dart';
import '../../models/manager/table.dart';
import '../security/current_user_provider.dart';

final managerStateProvider = AsyncNotifierProvider<ManagerStateNotifier, ManagerState>(() => ManagerStateNotifier());

class ManagerStateNotifier extends AbstractAsyncNotifier<ManagerState> {
  // ==========================================
  // INITIALISATION & CORE (Restaurants)
  // ==========================================

  @override
  Future<ManagerState> build() async {
    // on charge les restaurants au démarrage
    ref.watch(simulatedTimeProvider);
    ref.watch(currentUserProvider);
    final userNotifier = ref.watch(currentUserProvider.notifier);

    if (!userNotifier.isManager) {
      throw Exception("Access Denied: You must be logged in as a manager.");
    }
    final previous = state.value;
    final currentId = previous?.currentRestaurantId;

    final restaurants = await Restaurant.getManagerRestaurants();

    if (currentId == null) {
      return ManagerState(restaurants: restaurants);
    }

    final reservations = await ReservationDetail.getReservations(currentId);
    final services = await Service.getServiceForResturant(currentId);
    final tables = await RestaurantTable.getTables(currentId);
    final gap = await Restaurant.getRestaurantGap(currentId);

    return ManagerState(
      restaurants: restaurants,
      currentRestaurantId: currentId,
      reservations: reservations,
      services: services,
      restaurantTables: tables,
      currentRestaurantGap: gap,
    );
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

  Future<void> getRestaurantGap(int restaurantId) async {
    final currentState = state.value ?? ManagerState();
    state = const AsyncValue.loading();
    try {
      final gap = await Restaurant.getRestaurantGap(restaurantId);
      state = AsyncData(currentState.copyWith(currentRestaurantGap: gap));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // ==========================================
  // RÉSERVATIONS
  // ==========================================

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

  Future<void> confirmReservation(ReservationDetail res, List<int> tableIds) async {
    state = const AsyncValue.loading();
    try {
      await res.confirmReservation(res.id, tableIds);
      await getReservation(res.id);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> completeReservation(ReservationDetail res, DateTime simulatedTime) async {
    state = const AsyncValue.loading();
    try {
      await res.completeReservation(res.id, simulatedTime);
      await getReservation(res.id);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> cancelledReservation(ReservationDetail res) async {
    state = const AsyncValue.loading();
    try {
      await res.cancelReservation(res.id);
      await getReservation(res.id);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // ==========================================
  // SERVICES (CRUDLS)
  // ==========================================

  // --- Create ---
  Future<void> createService(int restaurantId, int dayOfWeek, TimeOnly startTime, TimeOnly endTime) async {
    state = const AsyncValue.loading();
    try {
      final newId = await Service.createService(restaurantId, dayOfWeek, startTime, endTime);
      await getService(newId);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Read (Single) ---
  Future<void> getService(int serviceId) async {
    final currentState = state.value ?? ManagerState();
    final currentList = state.value?.services ?? [];
    final currentId = state.value?.currentRestaurantId;

    state = const AsyncValue.loading();
    try {
      final updatedService = await Service.getSpecificService(serviceId, currentId!);
      bool found = false;

      final newList = currentList.map((service) {
        if (service.id == serviceId) {
          found = true;
          return updatedService;
        }
        return service;
      }).toList();

      if (!found) {
        newList.add(updatedService);
      }
      state = AsyncData(currentState.copyWith(services: newList, impactedReservations: 0));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Read (List) ---
  Future<void> loadServices(int restaurantId) async {
    state = const AsyncValue.loading();
    try {
      final service = await Service.getServiceForResturant(restaurantId);
      final gap = await Restaurant.getRestaurantGap(restaurantId);
      final currentState = state.value ?? ManagerState();
      state = AsyncData(currentState.copyWith(services: service, currentRestaurantGap: gap, impactedReservations: 0));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Update ---
  Future<void> updateService(Service service, int dayOfWeek, TimeOnly newStartTime, TimeOnly newEndTime) async {
    state = const AsyncValue.loading();
    try {
      await service.updateService(service.id, dayOfWeek, newStartTime, newEndTime);
      await getService(service.id);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Delete ---
  Future<void> deleteService(Service service) async {
    final currentState = state.value ?? ManagerState();
    state = const AsyncValue.loading();
    try {
      await service.deleteService(service.id);
      final updatedList = currentState.services.where((s) => s.id != service.id).toList();
      state = AsyncData(currentState.copyWith(services: updatedList));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Validation / Helpers (Impacts) ---
  Future<void> countImpactedReservations(
    int restaurantId,
    int dayOfWeek,
    TimeOnly newStartTime,
    TimeOnly newEndTime,
    int serviceId,
  ) async {
    final currentState = state.value ?? ManagerState();
    try {
      final impactedReservations = await Service.countReservationsOutsideNewSlot(
        restaurantId,
        dayOfWeek,
        newStartTime,
        newEndTime,
        serviceId,
      );
      state = AsyncData(currentState.copyWith(impactedReservations: impactedReservations));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> countImpactedServices(
    int restaurantId,
    int dayOfWeek,
    TimeOnly newStartTime,
    TimeOnly newEndTime,
    int serviceId,
  ) async {
    final currentState = state.value ?? ManagerState();
    try {
      final impactedServices = await Service.countImpactedServices(
        restaurantId,
        dayOfWeek,
        newStartTime,
        newEndTime,
        serviceId,
      );
      state = AsyncData(currentState.copyWith(impactedServices: impactedServices));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> resetImpacts() async {
    final currentState = state.value ?? ManagerState();
    state = AsyncData(currentState.copyWith(impactedReservations: 0, impactedServices: 0));
  }

  // ==========================================
  // TABLES (CRUDL)
  // ==========================================

  // --- Create ---
  Future<void> createTable(int capacity, int number) async {
    final currentState = state.value ?? ManagerState();
    final currentId = state.value?.currentRestaurantId;

    state = const AsyncValue.loading();
    try {
      await RestaurantTable.createTable(currentId!, capacity, number);
      final List<RestaurantTable> listOfTables = await RestaurantTable.getTables(currentId);
      state = AsyncData(currentState.copyWith(restaurantTables: listOfTables));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Read (Single) ---
  Future<void> getTable(int tableId) async {
    final currentState = state.value ?? ManagerState();
    final currentList = state.value?.availableTables ?? [];

    state = const AsyncValue.loading();
    try {
      final updatedTable = await RestaurantTable.getSpecificTable(tableId);
      bool found = false;

      final newList = currentList.map((table) {
        if (table.id == tableId) {
          found = true;
          return updatedTable;
        }
        return table;
      }).toList();

      if (!found) {
        newList.add(updatedTable);
      }

      state = AsyncData(currentState.copyWith(restaurantTables: newList));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Read (List) ---
  Future<void> getTables(int restaurantId) async {
    state = const AsyncValue.loading();
    try {
      final tables = await RestaurantTable.getTables(restaurantId);
      final currentState = state.value ?? ManagerState();
      state = AsyncData(currentState.copyWith(restaurantTables: tables));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> loadRestaurantTables(int restaurantId) async {
    state = const AsyncValue.loading();
    try {
      final availableTables = await RestaurantTable.getTables(restaurantId);
      final currentState = state.value ?? ManagerState();
      state = AsyncData(currentState.copyWith(restaurantTables: availableTables));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  Future<void> loadAvailableTables(int restaurantId, DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final availableTables = await RestaurantTable.getAvailableTables(restaurantId, date);
      final currentState = state.value ?? ManagerState();
      state = AsyncData(currentState.copyWith(restaurantTables: availableTables));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Update ---
  Future<void> updateTable(RestaurantTable table, int capacity, int number) async {
    final currentState = state.value ?? ManagerState();
    final currentId = state.value?.currentRestaurantId;

    state = const AsyncValue.loading();
    try {
      await table.updateTable(table.id, capacity, number);
      final List<RestaurantTable> listOfTables = await RestaurantTable.getTables(currentId!);
      state = AsyncData(currentState.copyWith(restaurantTables: listOfTables));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }

  // --- Validation / Helpers ---
  Future<bool> validateTableCapacity(int tableId, int newCapacity) async {
    try {
      return await RestaurantTable.validateCapacity(tableId, newCapacity);
    } catch (e) {
      return false;
    }
  }
}
