import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/core/widgets/simulated_date_time_picker_widget.dart';
import 'package:prbd_2526_f03/providers/reference_time_provider.dart';
import 'package:prbd_2526_f03/providers/simulated_time_provider.dart';
import '../../models/client/reservation_client.dart';
import '../../providers/client/client_state_provider.dart';

class ViewReservationClient extends ConsumerWidget {
  const ViewReservationClient({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // on stock l'état courant des données du client connecté
    final clientStateAsync = ref.watch(clientStateProvider);

    // on recupère le temps simulé courant
    final referenceTime = ref.watch(referenceTimeProvider);

    // theme de la page
    final theme = Theme.of(context);

    // on récupère l'id de la réservation selectionnée
    final reservationId = ModalRoute.of(context)!.settings.arguments as int;

    // on récupère toutes les réservations du client
    final reservations = clientStateAsync.value?.reservations ?? [];

    // on récupère la réservation du client dans la liste de toutes les réservations
    final clientReservation = reservations.where((r) => r.id == reservationId).firstOrNull;

    // variable gestion d'état boutons d'action (Modifier et Annuler)
    final reservationDateTime = clientReservation?.datetime;
    final reservationStatus = clientReservation?.status;
    final appTime = referenceTime.value ?? DateTime.now();
    final isCompleted = reservationStatus == 'completed';
    final isCancelled = reservationStatus == 'cancelled';
    final isDisabled = reservationDateTime != null ? reservationDateTime.compareTo(appTime) <= 0 : false;

    // variables de gestion de l'affichage de la réservation selectionnée
    String statusLabel = '';
    Color statusColor = Colors.grey;
    if(clientReservation != null) {
      switch (clientReservation.status) {
        case 'pending':
          statusLabel = 'En attente';
          statusColor = Colors.orange;
          break;
        case 'confirmed':
          statusLabel = 'Confirmée';
          statusColor = Colors.green;
          break;
        case 'completed':
          statusLabel = 'Terminée';
          statusColor = Colors.blue;
          break;
        case 'cancelled':
        default:
          statusLabel = 'Annulée';
          statusColor = Colors.red;
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Retour vers la liste des réservations du client connecté
            Navigator.pop(context);
          },
        ),
        title: const Text('Détails de la réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(clientStateProvider.notifier).refreshSingleReservation(reservationId);
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
      body: SafeArea(
        // on indique ce qui s'affiche en fonction de l'état du client connecté
        child: clientReservation == null
          ? const Center(child: Text("Aucune réservation trouvée"))
          : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restaurant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              clientReservation.restaurant.name, // nom du resto
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              clientReservation.restaurant.address, // adresse du resto
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            clientReservation.restaurant.phone, // numéro du resto
                            style: TextStyle(color: Colors.grey[600]),
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
                          Text( // Format : Date: jour. 06/12/2024
                            'Date: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(clientReservation.datetime)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                           // format : Heure: 20:00
                          Text(
                            'Heure: ${DateFormat('HH:mm').format(clientReservation.datetime)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                          // Format : 'Nombre de convives: 4'
                          Text('Nombre de convives: ${clientReservation.numberOfGuests}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info, size: 20),
                          const SizedBox(width: 8),
                          const Text('Statut: '),
                          Chip(
                            // format : 'En attente','Confirmée', 'Complétée', 'Annulée'
                            label: Text(
                              statusLabel,
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            backgroundColor: statusColor,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Demandes spéciales',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clientReservation.specialRequests,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Visibility(
                      visible: !isCompleted && !isCancelled,
                      child: ElevatedButton.icon(
                        // ACTION DE SÉCURITÉ ET TRANSFERT : pousse l'ID dans la route d'édition
                        onPressed: isDisabled ? null : () {
                          Navigator.pushNamed(
                            context,
                            '/edit_reservation',
                            arguments: reservationId,
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Visibility(
                      visible: !isCompleted && !isCancelled,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Annuler la réservation'),
                                content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Non')),
                                  TextButton(
                                    onPressed: () => _cancel(context, ref, clientReservation),
                                    child: const Text('Oui', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        }, label: const Text('Annuler'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancel(BuildContext context, WidgetRef ref, ReservationClient res) async {
    final notifier = ref.read(clientStateProvider.notifier);
    await notifier.cancelledReservation(res);
    if (context.mounted) {
      Navigator.of(context).pop(null);
    }
  }

}
