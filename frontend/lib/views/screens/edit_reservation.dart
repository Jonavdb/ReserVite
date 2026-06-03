import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/core/widgets/simulated_date_time_picker_widget.dart';
import 'package:prbd_2526_f03/providers/client/client_state_provider.dart';
import 'package:prbd_2526_f03/providers/reference_time_provider.dart';
import '../../models/restaurant/restaurant_services.dart';

class EditReservation extends HookConsumerWidget {
  // L'id est désormais récupéré de façon identique à AddReservation ou ViewReservation depuis les arguments de la route
  const EditReservation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Extraction de l'ID passé en argument de navigation par la vue précédente
    final reservationId = ModalRoute.of(context)!.settings.arguments as int;

    // Écoute de l'état global du client (contient la liste des réservations en cache)
    final clientStateAsync = ref.watch(clientStateProvider);
    final initialTime = ref.read(referenceTimeProvider).value;

    // 1. Extraction de la réservation cible et de son restaurant associés à l'ID reçu
    final currentReservation = clientStateAsync.value?.reservations
        .where((r) => r.id == reservationId)
        .firstOrNull;
    final restaurant = currentReservation?.restaurant;

    // 2. Initialisation des états de formulaire (Synchrone et direct via la réservation trouvée)
    final date = useState<DateTime?>(currentReservation?.datetime ?? initialTime);
    final nbGuests = useState<int>(currentReservation?.numberOfGuests ?? 2);
    final selectedTimeSlot = useState<String?>(
        currentReservation != null ? DateFormat('HH:mm').format(currentReservation.datetime) : null
    );
    final specialRequestsController = useTextEditingController(text: currentReservation?.specialRequests ?? '');

    final isOverloaded = useState<bool>(false);
    final isFormValid = useState<bool>(true);
    final hasInitialFetched = useState<bool>(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    Map<int, String> formatServicesByDay(List<RestaurantService>? services) {
      final Map<int, List<String>> grouped = {};
      if (services == null || services.isEmpty) {
        return {};
      }

      for (var service in services) {
        grouped.putIfAbsent(service.dayOfWeek, () => []);
        // nettoie les secondes (08:00:00 -> 08:00) si besoin
        final start = service.startTime.substring(0, 5);
        final end = service.endTime.substring(0, 5);
        grouped[service.dayOfWeek]!.add('$start - $end');
      }

      // transforme la liste des horaires d'un jour en une seule string séparée par des virgules
      return grouped.map<int, String>((day, times) {
        return MapEntry(day, times.join(',\n'));
      });
    }

    List<String> formatTimeSlots(List<DateTime> slots) {
      if (slots.isEmpty) {
        return List.empty();
      }
      final DateFormat formatter = DateFormat('HH:mm');
      return slots.map((slot) => formatter.format(slot)).toList();
    }

    Future<void> triggerCapacityVerification(int currentRestaurantId, int currentGuests) async {
      isFormValid.value = formKey.currentState?.validate() ?? false;

      if (selectedTimeSlot.value == null || date.value == null) {
        isOverloaded.value = false;
        return;
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(date.value!);
      final fullTargetTimestamp = DateTime.parse('${dateStr}T${selectedTimeSlot.value!}:00');

      final hasCapacity = await ref.read(clientStateProvider.notifier).checkSlotCapacity(
        currentRestaurantId,
        fullTargetTimestamp,
        currentGuests,
        ignoreReservationId: reservationId,
      );

      isOverloaded.value = !hasCapacity;
    }

    final formattedServices = formatServicesByDay(clientStateAsync.value?.selectedRestaurant?.services);

    // 3. Premier chargement automatique des créneaux horaires disponibles ET de la capacité initiale
    if (!hasInitialFetched.value && date.value != null && restaurant != null) {
      hasInitialFetched.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(clientStateProvider.notifier).getAvailableTimeSlots(
          restaurant.id,
          date.value!,
          ignoreReservationId: reservationId,
        );
        // Vérification de la capacité immédiate à l'ouverture pour afficher l'alerte si surréservation existante
        await triggerCapacityVerification(restaurant.id, nbGuests.value);
      });
    }

    ref.listen(referenceTimeProvider, (previous, next) {
      if (next.value != null && restaurant != null) {
        date.value = next.value!;
        selectedTimeSlot.value = null;
        isOverloaded.value = false;
        isFormValid.value = false;

        ref.read(clientStateProvider.notifier).getAvailableTimeSlots(
          restaurant.id,
          next.value!,
          ignoreReservationId: reservationId,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Modifier une réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              if (restaurant != null && date.value != null) {
                ref.read(clientStateProvider.notifier).getAvailableTimeSlots(
                  restaurant.id,
                  date.value!,
                  ignoreReservationId: reservationId,
                );
              }
            },
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: const Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: SimulatedDateTimePicker(),
            ),
          ),
        ),
      ),
      body: currentReservation == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            isFormValid.value = formKey.currentState?.validate() ?? false;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                restaurant?.name ?? 'Restaurant',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: date.value!,
                          firstDate: initialTime ?? DateTime.now(),
                          lastDate: DateTime(date.value!.year + 10),
                        );

                        if (pickedDate == null) return;

                        date.value = pickedDate;
                        selectedTimeSlot.value = null;

                        ref.read(clientStateProvider.notifier).getAvailableTimeSlots(
                          restaurant!.id,
                          pickedDate,
                          ignoreReservationId: reservationId,
                        );
                        await triggerCapacityVerification(restaurant.id, nbGuests.value);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Date'),
                                  Text(
                                    DateFormat('EEEE d/MM/yyyy', 'fr_FR').format(date.value!)[0].toUpperCase() +
                                        DateFormat('EEEE d/MM/yyyy', 'fr_FR').format(date.value!).substring(1),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () async {
                      final newDate = date.value!.subtract(const Duration(days: 1));
                      date.value = newDate;
                      selectedTimeSlot.value = null;

                      ref.read(clientStateProvider.notifier).getAvailableTimeSlots(
                        restaurant!.id,
                        newDate,
                        ignoreReservationId: reservationId,
                      );
                      await triggerCapacityVerification(restaurant.id, nbGuests.value);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final newDate = date.value!.add(const Duration(days: 1));
                      date.value = newDate;
                      selectedTimeSlot.value = null;

                      ref.read(clientStateProvider.notifier).getAvailableTimeSlots(
                        restaurant!.id,
                        newDate,
                        ignoreReservationId: reservationId,
                      );
                      await triggerCapacityVerification(restaurant.id, nbGuests.value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Créneaux disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              clientStateAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Erreur : $error')),
                data: (clientState) {
                  final formattedTimeSlots = formatTimeSlots(clientState.availableTimeSlots ?? []);

                  if (formattedTimeSlots.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Text("Pas de créneaux disponibles", style: TextStyle(color: Colors.red)),
                    );
                  }

                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      for (final time in formattedTimeSlots)
                        GestureDetector(
                          onTap: () async {
                            selectedTimeSlot.value = time;
                            await triggerCapacityVerification(restaurant!.id, nbGuests.value);
                          },
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedTimeSlot.value == time ? theme.colorScheme.primary : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selectedTimeSlot.value == time ? theme.colorScheme.primary : theme.colorScheme.outline,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                time,
                                style: TextStyle(
                                  color: selectedTimeSlot.value == time ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                  fontWeight: selectedTimeSlot.value == time ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Nombre de convives'),
                subtitle: Text('${nbGuests.value}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: nbGuests.value > 1
                          ? () async {
                        nbGuests.value--;
                        await triggerCapacityVerification(restaurant!.id, nbGuests.value);
                      } : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: nbGuests.value < 10
                          ? () async {
                        nbGuests.value++;
                        await triggerCapacityVerification(restaurant!.id, nbGuests.value);
                      } : null,
                    ),
                  ],
                ),
              ),

              if (isOverloaded.value)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                      'La capacité du restaurant pour ce créneau pourrait être insuffisante pour le nombre de convives demandé.',
                      style: TextStyle(color: Colors.orange)
                  ),
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: specialRequestsController,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty && value.trim().length < 10) {
                    return 'Les demandes spéciales doivent contenir au moins 10 caractères';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Demandes spéciales (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                // Non-bloquant : On retire l'exclusion !isOverloaded.value de la validation
                onPressed: (date.value != null &&
                    selectedTimeSlot.value != null &&
                    isFormValid.value)
                    ? () async {
                  final dateStr = DateFormat('yyyy-MM-dd').format(date.value!);
                  final fullReservationTimestamp = DateTime.parse('${dateStr}T${selectedTimeSlot.value!}:00');

                  if (currentReservation.status == 'confirmed') {
                    final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Modifier une réservation confirmée'),
                          content : const Text('Cette réservation est confirmée. La modifier la remettra en attente et les tables associées seront libérées. Souhaitez-vous continuer ? '),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child : const Text('Annuler'),
                            ),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    if (confirm != true){
                      return;
                  }
                  }

                  final success = await ref.read(clientStateProvider.notifier).editReservation(
                    reservationId,
                    restaurant!.id,
                    fullReservationTimestamp,
                    nbGuests.value,
                    specialRequestsController.text,
                  );

                  if (!context.mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Réservation modifiée avec succès !'),
                        behavior: SnackBarBehavior.fixed,
                      ),
                    );
                    Navigator.pushReplacementNamed(context, '/view_reservation_client', arguments: reservationId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Erreur lors de la modification de la réservation.'),
                        backgroundColor: theme.colorScheme.error,
                        behavior: SnackBarBehavior.fixed,
                      ),
                    );
                  }
                } : null,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                icon: const Icon(Icons.edit),
                label: const Text('Modifier la réservation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}