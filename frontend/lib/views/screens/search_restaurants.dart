import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/providers/client/client_state_provider.dart';
import '../../core/tools/date_utils.dart';
import '../../core/tools/debounce.dart';

class SearchRestaurants extends ConsumerStatefulWidget {
  const SearchRestaurants({super.key});

  @override
  ConsumerState<SearchRestaurants> createState() => _SearchRestaurantsState();
}

class _SearchRestaurantsState extends ConsumerState<SearchRestaurants> {
  final Debouncer _debouncer = Debouncer();
  late TextEditingController _searchController; // late car on l'init dans initstate

  @override
  void initState() {
    super.initState();
    // Propagation
    final savedText = ref.read(clientStateProvider).value?.searchedInput ?? ''; // lis la valeur stockée
    _searchController = TextEditingController(
      text: savedText, // injecte ce texte directement dans le champ de recherche
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(clientStateProvider);
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/list_reservation_client');
          },
        ),
        title: const Text('Rechercher un restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => {_searchController.clear(), ref.read(clientStateProvider.notifier).refreshRestaurants()},
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom, ville, description...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _debouncer.call(() {
                    // minuteur de 500ms sur chaque recherche au serveur
                    ref.read(clientStateProvider.notifier).searchRestaurants(value);
                  });
                },
              ),
            ),
            Expanded(
              child: clientState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Erreur : $error')),
                data: (clientState) {
                  final filteredRestaurants = clientState.displayedRestaurants;

                  return Column(
                    children: [
                      if (clientState.hasMoreRestaurantsThanLimit)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          color: Colors.orange.shade50,
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 20, color: Colors.orange.shade800),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Trop de résultats trouvés. Veuillez affiner votre recherche pour voir plus de restaurants.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = filteredRestaurants[index];

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
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(restaurant.city),
                                        if (hasRating) ...[
                                          const SizedBox(width: 12),
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          const SizedBox(width: 2),
                                          Text(
                                            restaurant.rating.toString(),
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                        if (hasPrice) ...[
                                          const SizedBox(width: 12),
                                          Text(
                                            restaurant.priceSymbol,
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ],
                                    ),
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
                                    if (pendingCount > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.pending, size: 14, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$pendingCount demande${pendingCount > 1 ? 's' : ''} en attente',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/list_reservations_manager',
                                    arguments: {'restaurantId': restaurant.id, 'restaurantName': restaurant.name},
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
