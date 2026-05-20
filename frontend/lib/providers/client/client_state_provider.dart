import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/providers/security/current_user_provider.dart';
import '../../models/client/client_state.dart';

/*
      Instance statique du ClientStateProvider
      C'est à travers cette instance qu'il est possible
      - d'observer les changements sur les données du client connecté (avec la methode .watch)
      - d'utiliser les fonctions du notifier pour faire des action spécifiques (avec la methode .read)
 */
final clientStateProvider = AsyncNotifierProvider<ClientStateNotifier, ClientState>(
      () => ClientStateNotifier(),
);

/*
    Notifier du provider.
    Il contient les fonctions intermédiaires qui appellent les fonctions du
    ClientState qui à leur tour vont interagir avec le backend pour traiter les info
    du client connecté
 */
class ClientStateNotifier extends AsyncNotifier<ClientState> {
  @override
  Future<ClientState> build() async {
    // on écoute et on surveille l'état de l'utilisateur connecté pour reconstruire le widget si cet utilisateur change
    ref.watch(currentUserProvider);

    // on récupère le contrôleur (notifier) de l'utilisateur actuel pour pouvoir utiliser ses fonctions et propriétés (comme vérifier son rôle)
    final userNotifier = ref.watch(currentUserProvider.notifier);

    // on vérifie si l'utilisateur connecté n'est PAS un client
    if(!userNotifier.isClient) {
      // on bloque l'accès et on génère une erreur sécurisée si l'utilisateur n'est pas un client
      throw Exception("Access Denied: You must be logged in as a client.");
    }

    // on définit le filtre de recherche par défaut sur "En attente" lors du premier chargement de l'écran
    const defaultFilter = 'pending';

    // on lance l'appel API asynchrone pour récupérer les réservations du client correspondant à ce filtre par défaut
    final initialReservations = await ClientState.fetchReservations(defaultFilter);

    // on crée et on retourne l'état initial de l'écran avec le filtre par défaut et la liste des réservations récupérées
    return ClientState(
      currentFilter: defaultFilter,
      reservations: initialReservations,
    );
  }

  // Fonction qui permet de récupérer les  réservations du client connecté..
  // selon un filtre choisis (si aucun filtre, on récupère tout)
  Future<void> changeFilter(String newFilter) async { // newFilter c'est le status des nouvelles réservations qu'on veut afficher

    // on met le state en MODE "LOADING" pour que ceux qui l'observent..
    // ex: vues ou providers soient notifiés
    state = const AsyncLoading();

    // on lance le processus pour récupérer les réservations du client connecté..
    // qui ont le status du filtre renseigné
    try {
      // on nettoie l'input avant de le passer à la fonction
      final String? filterSanitized = (newFilter == 'all' || newFilter.isEmpty) ? null : newFilter;
      // on récupère la nouvelle liste selon le nouveau filtre
      final fetchedReservations = await ClientState.fetchReservations(filterSanitized);
      // on met à jour l'état du client connecté avec les nouvelles données (nouveau filtre selectionné + nouvelle liste)
      // MODE "DATA"
      state = AsyncData(ClientState(
        currentFilter: newFilter,
        reservations: fetchedReservations,
      ));
    } catch (e, stackTrace) { // MODE "ERREUR"
      state = AsyncError(e, stackTrace);
    }
  }
} // à chaque transition d'état tous les observateurs de l'état du client connecté sont notifiés et agissent en conséquence