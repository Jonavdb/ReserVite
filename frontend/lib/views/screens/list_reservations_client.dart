import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/providers/client/client_state_provider.dart';
import '../../providers/security/current_user_provider.dart';

class ListReservationsClient extends ConsumerWidget {
  const ListReservationsClient({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // notifier de l'utilisateur connecté (pour interagir avec l'état de ses données)
    final userNotifier = ref.read(currentUserProvider.notifier);
    final userName = userNotifier.loggedUserName; // nom d'utilisateur

    // on stock l'état courant des données du client connecté
    final clientStateAsync = ref.watch(clientStateProvider);

    // theme de la page
    final theme = Theme.of(context);

    return Scaffold(
      // HEADER (titre, date simulée, boutons)
      appBar: AppBar(
        title: const Text('Mes réservations'),
        automaticallyImplyLeading: false,
        // Liste boutons (recherche, rafraichir les données, deconnexion)
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/search_restaurants');
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Rafraîchir les données', onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion ($userName)',
            onPressed: () {
              ref.read(currentUserProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        // Date simulée
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Tooltip(
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  'mercredi 04/12/2024 16:00',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ),
      ),

      // CONTENU (liste des réservations du client connecté)
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                // Barre horizontale des icones de filtre de réservation
                // ('all', 'en attente', 'confirmées', 'terminées', 'annulées'
                segments: const [
                  ButtonSegment(
                    // point d'entrée : affichage de toutes les réservations
                    value: '',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    // point d'entrée : affichage des réservations en attente
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    // point d'entrée : affichage des réservations confirmées
                    value: 'confirmed',
                    icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    // point d'entrée : affichage des réservations complétées
                    value: 'completed',
                    icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    // point d'entrée : affichage des réservations annumlées
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],

                // on récupère le filtre selectionné
                selected: {
                  clientStateAsync.maybeWhen(
                    data: (data) => data.currentFilter,
                    orElse: () => 'pending', // pending par défaut
                    // première ouverture de la page
                  ),
                },
                // quand on clique sur un filtre, ça appelle la fonction 'changeFilter' du notifier
                onSelectionChanged: (Set<String> newSelection) {
                  // appel au notifier du client connecté
                  ref.read(clientStateProvider.notifier).changeFilter(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              // on indique ce qui s'affiche en fonction de l'état du client connecté
              child: clientStateAsync.when(
                // l'état charge -> affichage icone de chargement circulaire
                loading: () => const Center(child: CircularProgressIndicator()),

                // erreur dans la récupération des réservations -> affichage message d'erreur
                error: (err, stack) => Center(child: Text(err.toString())),

                // récupération effectuée  -> affichage de chaque réservation du client connecté
                data: (clientState) {
                  // liste de ses réservations récupérées via l'état courant initialisée au debut de la page
                  final list = clientState.reservations;

                  // Cas : liste vide
                  if (list.isEmpty) {
                    // Détermine le texte en fonction du filtre actif pour correspondre parfaitement à l'écran
                    String emptyMessage = 'Aucune réservation trouvée.';
                    switch (clientState.currentFilter) {
                      case 'all':
                        emptyMessage = 'Aucune réservation';
                        break;
                      case 'pending':
                        emptyMessage = 'Aucune réservation en attente';
                        break;
                      case 'confirmed':
                        emptyMessage = 'Aucune réservation confirmée';
                        break;
                      case 'completed':
                        emptyMessage = 'Aucune réservation terminée';
                        break;
                      case 'cancelled':
                        emptyMessage = 'Aucune réservation annulée';
                        break;
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 90, color: Colors.grey[350]),
                          const SizedBox(height: 24),
                          Text(
                            emptyMessage,
                            style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Créez votre première réservation !',
                            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Cas : liste non vide
                  // Modèle d'affichage de chaque réservation client
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final reservation = list[index];

                      IconData? statusIcon;
                      Color? statusColor;
                      String? statusTooltip;

                      // mise en place des données de l'icone correspondante au status de la réservation
                      switch (reservation.status) {
                        case 'pending':
                          statusIcon = Icons.pending;
                          statusColor = Colors.orange;
                          statusTooltip = 'En attente';
                          break;
                        case 'confirmed':
                          statusIcon = Icons.check_circle;
                          statusColor = Colors.green;
                          statusTooltip = 'Confirmée';
                          break;
                        case 'completed':
                          statusIcon = Icons.event_available;
                          statusColor = Colors.blue;
                          statusTooltip = 'Terminée';
                          break;
                        case 'cancelled':
                          statusIcon = Icons.cancel;
                          statusColor = Colors.red;
                          statusTooltip = 'Annulée';
                          break;
                        default:
                          break;
                      }

                      // récupération et formattage de la date de réservation
                      final DateTime parsedDate = reservation.datetime;
                      final String formattedDate =
                          "${parsedDate.day.toString().padLeft(2, '0')}/"
                          "${parsedDate.month.toString().padLeft(2, '0')}/"
                          "${parsedDate.year} à "
                          "${parsedDate.hour.toString().padLeft(2, '0')}:"
                          "${parsedDate.minute.toString().padLeft(2, '0')}";

                      // récupération  du texte du nombre de convives
                      final int guestCount = reservation.numberOfGuests;
                      final String guestsText = "$guestCount convive${guestCount > 1 ? 's' : ''}";

                      // récupération du texte nom du restaurant
                      final String restaurantName = reservation.restaurantName;

                      // récupération  du texte ville du restaurant
                      final String restaurantCity = reservation.restaurantCity;

                      // affichage de toutes les données précécentes dans un widget Card
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            // Action quand on clique sur le carte
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Tooltip(
                                  message: statusTooltip,
                                  child: Icon(statusIcon, size: 32, color: statusColor),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurantName,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14),
                                          const SizedBox(width: 4),
                                          Text(restaurantCity, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Icone temps + texte date + icone convives + texte nombre de convives
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16),
                                          const SizedBox(width: 4),
                                          Text(formattedDate, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.people, size: 16),
                                          const SizedBox(width: 4),
                                          Text(guestsText, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FOOTER (bouton 'nouvelle réservation')
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }
}
