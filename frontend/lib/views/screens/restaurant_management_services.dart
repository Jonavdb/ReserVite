
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/models/manager/service.dart';
import 'package:prbd_2526_f03/providers/manager/manager_state_provider.dart';

class RestaurantManagementServices extends ConsumerStatefulWidget{
  final int restaurantId;
  final String restaurantName;


  const RestaurantManagementServices({super.key, required this.restaurantId, required this.restaurantName});

  @override
  ConsumerState<RestaurantManagementServices> createState() => _RestaurantManagementServicesState();
}

class _RestaurantManagementServicesState extends ConsumerState<RestaurantManagementServices> {

  @override
  void initState() {
    super.initState();
    // charger les services au démarrage
    // ref n'est pas encore disponible dans InitState donc on utilise Future.microTask
    Future.microtask(() => ref.read(managerStateProvider.notifier).loadServices(widget.restaurantId));
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final servicesManagementState = ref.watch(managerStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.restaurantName),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: ()
              => ref.read(managerStateProvider.notifier).loadServices(widget.restaurantId),
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
        child : servicesManagementState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _ ) => Center(child: Text('Erreur : $error')),
            data : (managerState) {
              final services = managerState.services;
              final Map<int, List<Service>> servicesByDay = {};
              for (int i = 1; i <= 7; i++) {
               servicesByDay[i] = services.where((s) => s.dayOfWeek == i).toList();
              }
              // on stocke les services en fonction du jour de la semaine dans une map

              return Stack(
                  children:
                  [ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final dayServices = servicesByDay[day] ?? [];
                      final dayName = Service.getDayOfWeek(day);
                      if (dayServices.isEmpty){
                        return  Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          color: Colors.grey[100],
                          child: ListTile(
                            leading: const Icon(Icons.schedule, color: Colors.grey),
                            title: Text(
                              dayName,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            subtitle: const Text(
                              'Aucun service',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      if (dayServices.length == 1){
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: const Icon(Icons.schedule),
                            title:  Text(dayName),
                            subtitle:  Text('${dayServices[0].startTime} - ${dayServices[0].endTime}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/edit_service', arguments: {
                                      'serviceId' : dayServices[0].id,
                                      'restaurantId' : widget.restaurantId
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: dayServices[0].isDeletable ? Colors.red : null),
                                  onPressed: dayServices[0].isDeletable ? () {
                                    showDialog(context: context, builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Supprimer le service'),
                                        content: Text ('Êtes-vous sûr de vouloir supprimer le service du ${dayName} (${dayServices[0].startTime} - ${dayServices[0].endTime})?'),
                                        actions : [
                                          TextButton(onPressed: () => Navigator.pop(context),
                                            child: const Text('Non'),
                                          ),
                                          TextButton(onPressed: () => _delete(context, dayServices[0]) ,
                                              child: const Text('Oui', style: TextStyle(color: Colors.red),)
                                          ),
                                        ],
                                      );
                                    },
                                    );
                                  } : null,
                                  tooltip: dayServices[0].isDeletable ? 'Supprimer le service' : 'Impossible de supprimer : des réservations non annulées utilisent ce service',
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (dayServices.length > 1) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            leading: const Icon(Icons.schedule),
                            title: Text(dayName),
                            subtitle: Text(dayServices.map((s) => '${s.startTime} - ${s.endTime}').join(', ')),
                            // on concatène les horaires des services d'un jour en faisant du map
                            children: dayServices.map((service) => ListTile(
                            // pour chaque service d'un jour précis, on affiche un ListTile en mappant les services du jour
                                title: Text('${service.startTime} - ${service.endTime}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/edit_service', arguments: {
                                          'serviceId' : service.id,
                                          'restaurantId' : widget.restaurantId
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: service.isDeletable ? Colors.red : null),
                                      onPressed: service.isDeletable ?  () {
                                        showDialog(context: context, builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Supprimer le service'),
                                            content: Text ('Êtes-vous sûr de vouloir supprimer le service du ${dayName} (${service.startTime} - ${service.endTime})?'),
                                            actions : [
                                              TextButton(onPressed: () => Navigator.pop(context),
                                                child: const Text('Non'),
                                              ),
                                              TextButton(onPressed: () => _delete(context, service) ,
                                                  child: const Text('Oui', style: TextStyle(color: Colors.red),)
                                              ),
                                            ],
                                          );
                                        },
                                        );
                                      } : null,
                                      tooltip: service.isDeletable ? 'Supprimer le service' : 'Impossible de supprimer : des réservations non annulées utilisent ce service',
                                    ),
                                  ],
                                ),
                              )
                            ).toList(),
                          ),
                        );
                      }
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'services_fab',
                      onPressed: () {},
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              );
            }
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
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

  void _delete(BuildContext context, Service service) async {
    final notifier = ref.read(managerStateProvider.notifier);
    notifier.deleteService(service);
    if (context.mounted) {
      ref.read(managerStateProvider.notifier).loadServices(widget.restaurantId);
      Navigator.of(context).pop(null);
    }
  }
}
