import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/models/client/client_state.dart';
import 'package:prbd_2526_f03/models/client/reservation_client.dart';
import 'package:prbd_2526_f03/models/restaurant/restaurant.dart';
import 'package:prbd_2526_f03/models/restaurant/restaurant_details.dart';
import 'package:prbd_2526_f03/providers/security/current_user_provider.dart';

final clientStateProvider = AsyncNotifierProvider<ClientStateNotifier, ClientState>(() => ClientStateNotifier());

class ClientStateNotifier extends AsyncNotifier<ClientState> {
  @override
  Future<ClientState> build() async {
    ref.watch(currentUserProvider);
    final userNotifier = ref.watch(currentUserProvider.notifier);

    if (!userNotifier.isClient) {
      throw Exception("Access Denied: You must be logged in as a client.");
    }

    const defaultFilter = 'pending';

    // Future.wait pour tout charger en parallèle
    final results = await Future.wait([
      ClientState.fetchReservations(defaultFilter),
      Restaurant.getFilteredRestaurants(''), // une recherche vide ramène tous les restos
    ]);

    return ClientState(
      currentFilter: defaultFilter,
      reservations: results[0] as List<ReservationClient>,
      restaurants: results[1] as List<Restaurant>,
      searchedInput: '',
    );
  }

  /*
   * RESTAURANTS
  */
  Future<void> refreshRestaurants() async {
    final currentState = state.value ?? ClientState(currentFilter: '', reservations: [], restaurants: []);

    state = AsyncValue.loading();
    try {
      final restaurants = await Restaurant.getRestaurants();
      state = AsyncData(currentState.copyWith(restaurants: restaurants, searchedInput: ''));
    } catch (e) {
      state = AsyncValue.error("Failed to refresh manger's restaurants", StackTrace.current);
    }
  }

  Future<void> searchRestaurants(String term) async {
    final currentState = state.value!;

    state = AsyncValue.loading();
    try {
      final filteredRestaurants = await Restaurant.getFilteredRestaurants(term);
      state = AsyncData(currentState.copyWith(searchedInput: term, restaurants: filteredRestaurants));
    } catch (e) {
      state = AsyncValue.error("Failed to filter restaurants", StackTrace.current);
    }
  }

  Future<void> loadRestaurantDetails(int id) async {
    final currentState = state.value!;

    try {
      final restaurantDetails = await RestaurantDetails.getDetails(id);
      state = AsyncData(currentState.copyWith(selectedRestaurant: restaurantDetails));
    } catch (e) {
      state = AsyncValue.error("Failed to get restaurant details", StackTrace.current);
    }
  }

  /*
   * RESERVATIONS
   */
  // Fonction qui permet de récupérer les  réservations du client connecté.. selon un filtre choisis (si aucun filtre, on récupère tout)
  Future<void> changeFilter(String newFilter) async {
    final currentState = state.value!; // sauvegarde l'état actuel
    state = const AsyncLoading();

    // on lance le processus pour récupérer les réservations du client connecté..
    // qui ont le status du filtre renseigné
    try {
      final String? filterSanitized = (newFilter == 'all' || newFilter.isEmpty)
          ? null
          : newFilter; // on nettoie l'input avant de le passer à la fonction
      final fetchedReservations = await ClientState.fetchReservations(filterSanitized);

      state = AsyncData(currentState.copyWith(currentFilter: newFilter, reservations: fetchedReservations));
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  } // à chaque transition d'état tous les observateurs de l'état du client connecté sont notifiés et agissent en conséquence

  Future<void> refreshSingleReservation(int? id) async {
    final currentState = state.value!; // sauvegarde l'état actuel
    state = const AsyncLoading();

    // swap : dans la liste originale, on remplace la reservation avec l'id renseigné
    // par celle récupérée dans le backend
    // résultat : on conserve la liste originale avec la même réservation sauf que là ses données sont à jour
    try {

      final fetchedReservation = await ClientState.fetchReservationById(id);
      final newList = currentState.reservations.map((reservation) {
        if (reservation.id == fetchedReservation.id) {
          return fetchedReservation;
        }
        return reservation;
      }).toList();
      state = AsyncData(currentState.copyWith(reservations: newList));
      print("succes !");
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      print("error ");
    }
  }

  Future<void> getAvailableTimeSlots(
      int restaurantId,
      DateTime datePendingReservation,
      {int? ignoreReservationId} // AJOUT : Paramètre optionnel pour l'édition
      ) async {
    final currentState = state.value!; // sauvegarde l'état actuel
    state = const AsyncLoading();

    try {
      // AJOUT : Transmission de l'ID à ignorer lors de l'appel au modèle
      final availableTimeSlots = await ClientState.fetchAvailableTimeSlots(
        restaurantId,
        datePendingReservation,
        ignoreReservationId: ignoreReservationId,
      );

      state = AsyncData(currentState.copyWith(availableTimeSlots: availableTimeSlots));
      print("succes !");
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      print("error ");
    }
  }

  Future<bool> checkSlotCapacity(
      int restaurantId,
      DateTime fullTimestamp,
      int requestedGuests,
      {int? ignoreReservationId} // AJOUT : Paramètre optionnel pour l'édition
      ) async {
    try {
      // AJOUT : Transmission de l'ID à ignorer lors de l'appel au modèle
      return await ClientState.fetchSlotCapacityCheck(
        restaurantId,
        fullTimestamp,
        requestedGuests,
        ignoreReservationId: ignoreReservationId,
      );
    } catch (e) {
      print("Capacity check error: $e");
      return false;
    }
  }

  Future<bool> createNewReservation(
      int restaurantId,
      DateTime reservationTime,
      int nbGuests,
      String specialRequests,
      ) async {
    final currentState = state.value!;
    state = const AsyncLoading();

    try {
      final success = await ClientState.createReservation(
        restaurantId,
        reservationTime,
        nbGuests,
        specialRequests,
      );

      state = AsyncData(currentState);
      return success;
    } catch (e, stackTrace) {
      state = AsyncData(currentState);
      print("Erreur lors de la création de la réservation : $e");
      return false;
    }
  }

  Future<bool> editReservation(
      int reservationId,
      int restaurantId,
      DateTime reservationTime,
      int nbGuests,
      String specialRequests,
      ) async {
    final currentState = state.value!;
    state = const AsyncLoading();

    try {
      final success = await ClientState.updateReservation(
        reservationId,
        restaurantId,
        reservationTime,
        nbGuests,
        specialRequests,
      );

      state = AsyncData(currentState);
      return success;
    } catch (e, stackTrace) {
      state = AsyncData(currentState);
      print("Erreur lors de la modification de la réservation : $e");
      return false;
    }
  }
}

