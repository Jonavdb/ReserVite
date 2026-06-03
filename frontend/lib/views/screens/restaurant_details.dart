import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/restaurant/restaurant_services.dart';
import '../../providers/client/client_state_provider.dart';

class RestaurantDetailsScreen extends ConsumerStatefulWidget {
  final int restaurantId;

  const RestaurantDetailsScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends ConsumerState<RestaurantDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientStateProvider.notifier).loadRestaurantDetails(widget.restaurantId));
  }

  @override
  Widget build(BuildContext context) {
    final clientState = ref.watch(clientStateProvider);
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Détails du restaurant'),
        automaticallyImplyLeading: false,
        // TODO : btn refreshRestaurantDetails
        actions: [IconButton(icon: const Icon(Icons.refresh), tooltip: 'Rafraîchir les données', onPressed: () {
            ref.read(clientStateProvider.notifier).loadRestaurantDetails(widget.restaurantId);
        })],
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
        child: clientState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erreur : $error')),
          data: (clientState) {
            final restaurant = clientState.selectedRestaurant;
            if (restaurant == null) return const Center(child: Text("Restaurant introuvable"));

            final formattedServices = _formatServicesByDay(restaurant.services);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(restaurant.rating != null ? restaurant.rating!.toStringAsFixed(1) : 'N/A'),
                      const SizedBox(width: 16),
                      Text('€' * (restaurant.priceRange ?? 1)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(restaurant.city),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(restaurant.address, style: TextStyle(color: Colors.grey[600])),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(restaurant.description ?? "Aucune description."),
                  const SizedBox(height: 24),
                  const Text('Horaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // COLONNE DE GAUCHE (Lundi à Jeudi)
                      Expanded(
                        child: Column(
                          children: [
                            _DayScheduleRow(dayName: 'Lundi', schedule: formattedServices[1] ?? 'Fermé'),
                            _DayScheduleRow(dayName: 'Mardi', schedule: formattedServices[2] ?? 'Fermé'),
                            _DayScheduleRow(dayName: 'Mercredi', schedule: formattedServices[3] ?? 'Fermé'),
                            _DayScheduleRow(dayName: 'Jeudi', schedule: formattedServices[4] ?? 'Fermé'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // COLONNE DE DROITE (Vendredi à Dimanche)
                      Expanded(
                        child: Column(
                          children: [
                            _DayScheduleRow(dayName: 'Vendredi', schedule: formattedServices[5] ?? 'Fermé'),
                            _DayScheduleRow(dayName: 'Samedi', schedule: formattedServices[6] ?? 'Fermé'),
                            _DayScheduleRow(dayName: 'Dimanche', schedule: formattedServices[7] ?? 'Fermé'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/add_reservation',
                          arguments: {'restaurantId': restaurant.id},
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Réserver'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Cette fonction transforme la liste brute de services en un dictionnaire {1: "12:00 - 14:00, 19:00 - 22:00", 2: ...}
  Map<int, String> _formatServicesByDay(List<RestaurantService> services) {
    final Map<int, List<String>> grouped = {};

    for (var service in services) {
      grouped.putIfAbsent(service.dayOfWeek, () => []);
      // nettoie les secondes (08:00:00 -> 08:00) si besoin
      final start = service.startTime.substring(0, 5);
      final end = service.endTime.substring(0, 5);
      grouped[service.dayOfWeek]!.add('$start - $end');
    }

    // transforme la liste des horaires d'un jour en une seule string séparée par des virgules
    return grouped.map((day, times) => MapEntry(day, times.join(',\n')));
  }
}

// Widget pour les jours et les services de ces jours
class _DayScheduleRow extends StatelessWidget {
  final String dayName;
  final String schedule;

  const _DayScheduleRow({required this.dayName, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(dayName, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(schedule, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
