import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/providers/client_state_provider.dart';
import '../../providers/current_user_provider.dart';

class ListReservationsClient extends ConsumerWidget {
  const ListReservationsClient({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(currentUserProvider.notifier);
    final userName = notifier.loggedUserName;

    final clientStateAsync = ref.watch(clientStateProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
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
                    orElse: () => 'pending',
                  )
                },
                onSelectionChanged: (Set<String> newSelection) {
                  ref.read(clientStateProvider.notifier).changeFilter(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: clientStateAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text(err.toString())),
                data: (clientState) {
                  final list = clientState.reservations;

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
                          // Icône centrale stylisée gris clair
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 90,
                            color: Colors.grey[350],
                          ),
                          const SizedBox(height: 24),
                          // Titre principal de l'état vide
                          Text(
                            emptyMessage,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Sous-titre d'invitation à l'action
                          Text(
                            'Créez votre première réservation !',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final reservation = list[index];
                      // 1. DYNAMIC STATUS MAPPER (Switch Case)
                      IconData? statusIcon;
                      Color? statusColor;
                      String? statusTooltip;

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

                      // 2. DATETIME FORMATTING
                      final DateTime parsedDate = reservation.datetime;
                      final String formattedDate = "${parsedDate.day.toString().padLeft(2, '0')}/"
                          "${parsedDate.month.toString().padLeft(2, '0')}/"
                          "${parsedDate.year} à "
                          "${parsedDate.hour.toString().padLeft(2, '0')}:"
                          "${parsedDate.minute.toString().padLeft(2, '0')}";

                      // 3. PLURAL GUESTS HANDLING
                      final int guestCount = reservation.numberOfGuests ?? 0;
                      final String guestsText = "$guestCount convive${guestCount > 1 ? 's' : ''}";

                      // 4. RESTAURANT DATA FALLBACKS
                      final String restaurantName = reservation.restaurantName;
                      final String restaurantCity = reservation.restaurantCity;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            // Action when clicking a specific reservation card
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Dynamic Tooltip and Icon Status
                                Tooltip(
                                  message: statusTooltip,
                                  child: Icon(statusIcon, size: 32, color: statusColor),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Dynamic Restaurant Title
                                      Text(
                                        restaurantName,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      // Dynamic Location Subtitle
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            restaurantCity,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Dynamic Info Footer (Time + Guests)
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            formattedDate,
                                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.people, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            guestsText,
                                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }
}
