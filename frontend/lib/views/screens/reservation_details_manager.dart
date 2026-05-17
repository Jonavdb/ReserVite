import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/providers/reservation_detail_provider.dart';

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
    Future.microtask(() => ref.read(reservationDetailProvider.notifier).getReservation(widget.reservationId));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final reservationDetailState = ref.watch(reservationDetailProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Détails de la réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () => ref.read(reservationDetailProvider.notifier).getReservation(widget.reservationId),
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
            if (reservation == null) {
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
                              Text('Nom:${reservation.clientName}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 20),
                              const SizedBox(width: 8),
                              Text('Email: ${reservation.clientEmail}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Téléphone: ${reservation.clientPhone ?? "Non Renseigné"}',
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
                                  reservation.restaurantName,
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
                              Text(DateFormat('EEE dd/MM/yyyy HH:mm', 'fr_FR').format(reservation.datetime)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 8),
                              Text(DateFormat('HH:mm').format(reservation.datetime)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.people, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                reservation.number_of_guests > 1
                                    ? 'Nombre de convives: ${reservation.number_of_guests}'
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
                                label: Text(reservation.status, style: TextStyle(fontSize: 12, color: Colors.white)),
                                backgroundColor: _colorStatus(reservation.status),
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
                            reservation.special_requests?.isNotEmpty == true
                                ? reservation.special_requests!
                                : 'Aucune request spéciale',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.table_restaurant, size: 20),
                                const SizedBox(width: 8),
                                const Text('Table 2'),
                                const SizedBox(width: 16),
                                Text('(4 places)', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.table_restaurant, size: 20),
                              const SizedBox(width: 8),
                              const Text('Table 3'),
                              const SizedBox(width: 16),
                              Text('(6 places)', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (reservation.status == 'pending')
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirmer et assigner les tables'),
                    ),

                  if (reservation.status == 'confirmed')
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Marquer comme terminée'),
                    ),
                  if (reservation.status != 'cancelled' && reservation.status != 'completed') ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.cancel), label: const Text('Annuler')),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
