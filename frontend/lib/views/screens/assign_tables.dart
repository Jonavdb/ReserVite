import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/models/manager/table.dart';
import '../../models/manager/reservation_detail.dart';
import '../../providers/manager/manager_state_provider.dart';

class AssignTables extends ConsumerStatefulWidget {
  final int reservationId;
  final int restaurantId;
  final DateTime date;
  const AssignTables({super.key, required this.reservationId, required this.restaurantId, required this.date});

  @override
  ConsumerState<AssignTables> createState() => _AssignTablesScreen();
}

class _AssignTablesScreen extends ConsumerState<AssignTables> {
  final Set<int> _selectedTableIds = {};
  int _get_totalCapacity(List<RestaurantTable> tables) {
    int total = 0;
    for (final table in tables){
      if (_selectedTableIds.contains(table.id)) {
        total += table.capacity;
      }
    }
    return total;
  }
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(managerStateProvider.notifier).loadAvailableTables(widget.restaurantId, widget.date));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final assignTablesState = ref.watch(managerStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {Navigator.pop(context);},
        ),
        title: const Text('Assigner des tables'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => ref.read(managerStateProvider.notifier).loadAvailableTables(widget.restaurantId, widget.date),
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
        child : assignTablesState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Erreur: $error')),
            data: (managerState) {
              final reservation = managerState.reservations;
              final reservationDetail = reservation.cast<ReservationDetail?>().firstWhere((res) =>
              res?.id == widget.reservationId, orElse: () => null,);
              final tables = ref
                  .read(managerStateProvider).value?.availableTables ?? [];
              bool _isenough = _get_totalCapacity(tables) >= reservationDetail!.numberOfGuests;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Réservation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('${reservationDetail.numberOfGuests} convives'),
                            Text(DateFormat('EEE dd/MM/yyyy HH:mm', 'fr_FR').format(reservationDetail.datetime)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedTableIds.isNotEmpty) ... [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        color: _isenough ? Colors.green.shade50 : Colors.yellow.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                _isenough ? Icons.check_circle : Icons.warning,
                                color: _isenough ? Colors.green[700] : Colors.yellow[700],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Capacité totale: ${_get_totalCapacity(tables)} places',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isenough ?
                                      ' V Capacité suffisante pour ${reservationDetail.numberOfGuests} convives'
                                          : 'X Capacité insuffisante pour ${reservationDetail
                                          .numberOfGuests} convives',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _isenough ? Colors.green.shade700 : Colors.yellow.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sélectionnez les tables disponibles',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: tables.length,
                      itemBuilder: (context, index) {
                        final table = tables[index];
                        final isSelected = _selectedTableIds.contains(table.id);
                        final isAvailable = table.isAvailable ?? true;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: isAvailable ? (checked) {
                              setState(() {
                                if (checked == true)
                                  _selectedTableIds.add(table.id);
                                else
                                  _selectedTableIds.remove(table.id);
                              });
                            } : null,

                            title: Text('Table ${table.number}', style: TextStyle(decoration: isAvailable ? null : TextDecoration.lineThrough),),
                            subtitle:  Text( isAvailable ?
                              'Capacité: ${table.capacity} personnes' : "Occupée pour ce service",
                            style: TextStyle(
                              color: isAvailable ? null : Colors.red,
                            ),
                            ),
                            secondary: const Icon(Icons.table_restaurant),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isenough ? () {
                          ref.read(managerStateProvider.notifier).confirmReservation(reservationDetail,
                            _selectedTableIds.toList(),);
                          Navigator.pop(context);
                        } : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Confirmer la réservation'),
                      ),
                    ),
                  ),
                ],
              );
            },
        ),
      ),
    );
  }
}
