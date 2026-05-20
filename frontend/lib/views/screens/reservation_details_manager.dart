import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/models/manager/reservation_detail.dart';
import 'package:prbd_2526_f03/providers/manager_state_provider.dart';
import 'package:prbd_2526_f03/providers/manager/reservation_detail_provider.dart';
import 'package:prbd_2526_f03/providers/manager/reservation_detail_provider.dart';

class ReservationDetailsManager extends ConsumerStatefulWidget {
  final int reservationId;

  const ReservationDetailsManager({super.key, required this.reservationId});

  @override
  ConsumerState<ReservationDetailsManager> createState() => _ReservationDetailsManagerMockupScreenState();
}

class _ReservationDetailsManagerMockupScreenState extends ConsumerState<ReservationDetailsManager> {
  @override
  void initState() {
    super.initState();
    // charger les réservations au démarrage
    // ref n'est pas encore disponible dans InitState donc on utilise Future.microTask
    Future.microtask(() => ref.read(managerStateProvider.notifier).getReservation(widget.reservationId));
  }

  Color _colorStatus(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
        ;
      case 'confirmed':
        return const Color(0xFF4CAF50);
      case 'completed':
        return const Color(0xFF2196F3);
      case 'cancelled':
        return const Color(0xFFF4432C);
      default:
        return Colors.grey;
    }
  }
  
  String _statusInFrench(String status) {
    switch (status) {
      case 'pending':
        return "En attente";
      case 'confirmed':
        return "Confirmée";
      case 'completed':
        return "Completée";
      case 'cancelled':
        return "Annulée";
      default:
        return "";
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final reservationDetailState = ref.watch(managerStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Détails de la réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => ref.read(managerStateProvider.notifier).getReservation(widget.reservationId),
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
        child: reservationDetailState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur: $error')),
          data: (reservation) {
            final reservationDetail = reservation.cast<ReservationDetail?>().firstWhere((res) => res?.id == widget.reservationId, orElse: () => null,
            );
            if (reservationDetail == null) {
              return const Center(child: Text('Aucune informations concernant cette reservation'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations client',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 20),
                              const SizedBox(width: 8),
                              Text('Nom: ${reservationDetail.clientName}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 20),
                              const SizedBox(width: 8),
                              Text('Email: ${reservationDetail.clientEmail}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Téléphone: ${reservationDetail.clientPhone ?? "Non Renseigné"}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Détails de la réservation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.restaurant, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reservationDetail.restaurantName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(DateFormat('EEE dd/MM/yyyy HH:mm', 'fr_FR').format(reservationDetail.datetime)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 8),
                              Text(DateFormat('HH:mm').format(reservationDetail.datetime)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.people, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                reservationDetail.number_of_guests > 1
                                    ? 'Nombre de convives: ${reservationDetail.number_of_guests}'
                                    : 'Pas de convives',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.info, size: 20),
                              const SizedBox(width: 8),
                              const Text('Statut: '),
                              Chip(
                                label: Text(_statusInFrench(reservationDetail.status), style: TextStyle(fontSize: 12, color: Colors.white)),
                                backgroundColor: _colorStatus(reservationDetail.status),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text('Demandes spéciales', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            reservationDetail.special_requests?.isNotEmpty == true
                                ? reservationDetail.special_requests!
                                : 'Aucune requêtes spéciales',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tables assignées', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child : reservationDetail.tableNumbers == null || reservationDetail.tableNumbers!.isEmpty
                          ? Text('Aucune table assignée')
                       : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(reservationDetail.tableNumbers!.length,
                                (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.table_restaurant, size: 20),
                                const SizedBox(width: 8),
                                Text('Table ${reservationDetail.tableNumbers![index]}'),
                                const SizedBox(width: 16),
                                Text('${reservationDetail.tableCapacities![index]} places', style: TextStyle(color: Colors.grey[600])
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (reservationDetail.status == 'pending')
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/assign_tables', arguments: {
                          'reservationId' : reservationDetail.id,
                          'restaurantId' : reservationDetail.restaurant,
                          'date' : reservationDetail.datetime,
                        });
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirmer et assigner les tables'),
                    ),

                  if (reservationDetail.status == 'confirmed')
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Marquer comme terminée'),
                    ),
                  if (reservationDetail.status != 'cancelled' && reservationDetail.status != 'completed') ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(onPressed: () {
                      showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('test Modale'),
                          content: const Text ('supprimer ?'),
                          actions : [
                            TextButton(onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                            ),
                            TextButton(onPressed: () => _cancel(context, reservationDetail) ,
                            child: const Text('Confirmer')
                            ),
                          ],
                        );
                      },
                      );
                    }, icon: const Icon(Icons.cancel), label: const Text('Annuler')),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  _cancel(BuildContext context, ReservationDetail res) async {
    final notifier = ref.read(managerStateProvider.notifier);
    notifier.cancelledReservation(res);
    if (context.mounted) {
      ref.read(managerStateProvider.notifier).getReservation(widget.reservationId);
      Navigator.of(context).pop(null);
    }
  }
}
