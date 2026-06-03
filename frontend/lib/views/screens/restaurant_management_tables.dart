import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/simulated_date_time_picker_widget.dart';
import '../../providers/manager/manager_state_provider.dart';

class RestaurantManagementTables extends ConsumerStatefulWidget {
  final int restaurantId;
  final String restaurantName;

  const RestaurantManagementTables({super.key, required this.restaurantId, required this.restaurantName});

  @override
  ConsumerState<RestaurantManagementTables> createState() => _RestaurantManagementTablesState();
}

class _RestaurantManagementTablesState extends ConsumerState<RestaurantManagementTables> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(managerStateProvider.notifier).getTables(widget.restaurantId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tablesManagementState = ref.watch(managerStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Le Gourmet'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(managerStateProvider.notifier).getTables(widget.restaurantId);
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
              child: const SimulatedDateTimePicker(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tables_fab',
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/edit_table',
            arguments: {'restaurantId': widget.restaurantId}, // CREATE (pas de table)
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: tablesManagementState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur : $error')),
          data: (managerState) {
            final tables = managerState.availableTables;

            if (tables.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "Aucune table n'est configurée pour l'instant.\n\nAppuyez sur le bouton + en bas à droite pour créer votre première table.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                  ),
                ),
              );
            }

            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: managerState.availableTables.length,
                  itemBuilder: (context, index) {
                    final currentTable = tables[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.table_restaurant, size: 40),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Table ${currentTable.number}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.people, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${currentTable.capacity} personnes',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit_table',
                                  arguments: {'restaurantId': widget.restaurantId, 'table': currentTable},
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(
              context,
              '/list_reservations_manager',
              arguments: {'restaurantId': widget.restaurantId, 'restaurantName': widget.restaurantName},
            );
          } else if (index == 1) {
            Navigator.pushNamed(
              context,
              '/restaurant_management_services',
              arguments: {'restaurantId': widget.restaurantId, 'restaurantName': widget.restaurantName},
            );
          } else if (index == 2) {
            Navigator.pushNamed(
              context,
              '/restaurant_management_tables',
              arguments: {'restaurantId': widget.restaurantId, 'restaurantName': widget.restaurantName},
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Réservations'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.table_restaurant), label: 'Tables'),
        ],
      ),
    );
  }
}
