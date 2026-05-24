import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/models/client/reservation_client.dart';
import 'package:prbd_2526_f03/providers/security/current_user_provider.dart';
import '../../models/client/client_state.dart';
import '../../models/manager/restaurant.dart';

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
      searchedInput: '',
      restaurants: results[1] as List<Restaurant>,
    );
  }

  // Fonction qui permet de récupérer les  réservations du client connecté..
  // selon un filtre choisis (si aucun filtre, on récupère tout)
  Future<void> changeFilter(String newFilter) async {
    final currentState = state.value!; // sauvegarde l'état actuel des restaurants affichés
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
}
