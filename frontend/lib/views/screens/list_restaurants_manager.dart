import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/providers/manager/manager_state_provider.dart';
import 'package:prbd_2526_f03/providers/security/current_user_provider.dart';

import '../../core/tools/date_utils.dart';

class ListRestaurantsManager extends ConsumerWidget {
  const ListRestaurantsManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managerState = ref.watch(managerStateProvider);
    final notifier = ref.read(currentUserProvider.notifier);
    final userName = notifier.loggedUserName;

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes restaurants'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => ref.read(managerStateProvider.notifier).refreshRestaurants(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion ($userName)',
            onPressed: () {
              ref.invalidate(managerStateProvider); // détruit le cache du manager courant
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
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(simulatedTime),
                  style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: managerState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erreur : $error')),
          data: (managerState) {
            final restaurants = managerState.restaurants;

            if (restaurants.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Vous ne gérez aucun restaurant pour le moment.",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Veuillez contacter un administrateur pour être assigné à un restaurant.",
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // si on a des restaurants, on génère la liste
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];

                // préparation des conditions d'affichage
                final hasRating = restaurant.rating != null;
                final hasPrice = restaurant.priceRange != null;
                final hasLastReservation = restaurant.lastReservationDate != null;
                final relativeDate = formatRelativeDate(restaurant.lastReservationDate, simulatedTime);
                final pendingCount = restaurant.pendingReservationsCount;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant, size: 40),
                    title: Text(restaurant.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LIGNE 1 : Ville, Note et Prix
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(restaurant.city),
                            // affichage du rating
                            if (hasRating) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                restaurant.rating.toString(),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                            // affichage du prix
                            if (hasPrice) ...[
                              const SizedBox(width: 12),
                              Text(restaurant.priceSymbol, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ],
                        ),
                        // LIGNE 2 : Dernière réservation (uniquement si connue)
                        if (hasLastReservation) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Dernière réservation: $relativeDate',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                        // LIGNE 3 : Demandes en attente
                        if (pendingCount > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.pending, size: 14, color: Colors.orange),
                              SizedBox(width: 4),
                              Text(
                                '$pendingCount demande${pendingCount > 1 ? 's' : ''} en attente',
                                style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(managerStateProvider.notifier).getReservations(restaurant.id);

                      Navigator.pushNamed(
                        context,
                        '/list_reservations_manager',
                        arguments: {'restaurantId': restaurant.id, 'restaurantName': restaurant.name},
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
