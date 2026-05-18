import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/providers/manager/reservations_provider.dart';

class ListReservationsManager extends ConsumerStatefulWidget {
  final int restaurantId;
  final String restaurantName;

  const ListReservationsManager({
    super.key,
    required this.restaurantId,
    required this.restaurantName
  });

  @override
  ConsumerState<ListReservationsManager> createState() =>
      _ListReservationsManagerScreenState();
}

class _ListReservationsManagerScreenState
    extends ConsumerState<ListReservationsManager> {
    String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // charger les réservations au démarrage
    // ref n'est pas encore disponible dans InitState donc on utilise Future.microTask
    Future.microtask(() => ref
        .read(reservationProvider.notifier)
        .getReservations(widget.restaurantId));
  }

    Icon _statusIcon(String status) {
      switch (status) {
        case 'pending':
          return const Icon(Icons.pending, size: 32, color: Colors.orange);
        case 'confirmed':
          return const Icon(Icons.check_circle, size: 32, color: Colors.green);
        case 'completed':
          return const Icon(Icons.event_available, size: 32, color: Colors.blue);
        case 'cancelled':
          return const Icon(Icons.cancel, size: 32, color: Colors.red);
        default:
          return const Icon(Icons.help, size: 32);
      }
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final reservationsState = ref.watch(reservationProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text(widget.restaurantName),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => ref.read(reservationProvider.notifier).getReservations(widget.restaurantId),
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
                message:
                    'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                      .format(simulatedTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
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
                    value: 'all',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: {_selectedFilter},
                onSelectionChanged: (value) {
                  setState(() {
                    _selectedFilter = value.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: reservationsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _ ) => Center(child: Text('Erreur: $error')),
                data: (reservations) {
                  final filteredReservations = _selectedFilter == 'all'
                      ? reservations
                      : reservations.where((r) => r.status == _selectedFilter).toList();
                  if (filteredReservations.isEmpty) {
                    return const Center(child: Text('Aucune réservation trouvée.'));
                  }
                  return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredReservations.length,
                  itemBuilder: (context, index) {
                    final reservation = filteredReservations[index];
                    return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/reservation_details_manager', arguments: {
                          'reservationId' : reservation.id
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            _statusIcon(reservation.status),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reservation.clientName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.restaurant, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.restaurantName,
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('EEE dd/MM/yyyy HH:mm', 'fr_FR').format(reservation.datetime),
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.people, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${reservation.number_of_guests} convive${reservation.number_of_guests > 1 ? 's' : ''}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
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
        ),      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant),
            label: 'Tables',
          ),
        ],
      ),
    );
  }
}
