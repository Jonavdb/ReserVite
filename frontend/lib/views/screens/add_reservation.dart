import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/core/widgets/simulated_date_time_picker_widget.dart';
import 'package:prbd_2526_f03/providers/client/client_state_provider.dart';
import 'package:prbd_2526_f03/providers/reference_time_provider.dart';
import '../../models/restaurant/restaurant_services.dart';

class AddReservation extends HookConsumerWidget {
  const AddReservation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final nbGuests = useState(2);

    final initialTime = ref.read(referenceTimeProvider).value;
    final date = useState<DateTime?>(initialTime);

    final hasInitialFetched = useState(false);

    final selectedTimeSlot = useState<String?>(null);
    final isOverloaded = useState<bool>(false);

    final specialRequestsController = useTextEditingController();

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isFormValid = useState(false);


    Map<int, String> formatServicesByDay(List<RestaurantService>? services) {
      final Map<int, List<String>> grouped = {};

      if(services == null || services.isEmpty) {
        print("null / aucun service pour aucun jour à ce resto");
        return grouped.map((day, times) => MapEntry(day, times.join(',\n')));
      }

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
    List<String> formatTimeSlots(List<DateTime> slots) {
      if(slots.isEmpty) {
        return List.empty();
      }
      final DateFormat formatter = DateFormat('HH:mm');
      return slots.map((slot) => formatter.format(slot)).toList();
    }

    final clientStateAsync = ref.watch(clientStateProvider);
    final restaurant = clientStateAsync.value?.selectedRestaurant;
    final formattedServices = formatServicesByDay(restaurant?.services);

    ref.listen(referenceTimeProvider, (previous, next) {
      if (next.value != null && restaurant != null) {
        date.value = next.value!;

        selectedTimeSlot.value = null;
        isOverloaded.value = false;
        isFormValid.value = false;

        ref.read(clientStateProvider.notifier).getAvailableTimeSlots(
          restaurant.id,
          next.value!,
        );
      }
    });

    if (!hasInitialFetched.value && date.value != null && restaurant != null) {
      hasInitialFetched.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(clientStateProvider.notifier).getAvailableTimeSlots(restaurant.id, date.value!);
      });
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
      );

      isOverloaded.value = !hasCapacity;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Nouvelle réservation'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              if (restaurant != null && date.value != null) {
                selectedTimeSlot.value = null;
                isOverloaded.value = false;
                isFormValid.value = false;
                ref.read(clientStateProvider.notifier).getAvailableTimeSlots(restaurant.id, date.value!);
              }
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
      body: date.value == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            isFormValid.value = formKey.currentState?.validate() ?? false;
          },
          child: clientStateAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Erreur : $error')),
            data: (clientState) {
              final restaurant = clientState.selectedRestaurant;
              if (restaurant == null) return const Center(child: Text("Restaurant introuvable"));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              // onTap : à l'appui sur la zone
                              // on déclenche l'édition de la date via showDatePicker
                              // ça ouvre le calendrier
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: date.value!, // initial date : la date à l'ouverture

                                firstDate: initialTime!,
                                lastDate: DateTime(date.value!.year + 10), // last date : la dernière date disponible

                                builder: (BuildContext context, Widget? child) {
                                  final Size screenSize = MediaQuery.of(context).size;
                                  return MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                      size: Size(screenSize.shortestSide, screenSize.longestSide),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if(pickedDate == null) return;

                              date.value = pickedDate;

                              ref.read(clientStateProvider.notifier).getAvailableTimeSlots(restaurant.id, pickedDate);
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
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: date.value != null && initialTime != null && (
                            date.value!.year > initialTime.year ||
                                (date.value!.year == initialTime.year && date.value!.month > initialTime.month) ||
                                (date.value!.year == initialTime.year && date.value!.month == initialTime.month && date.value!.day > initialTime.day)
                        )
                            ? () async {
                          final newDate = date.value!.subtract(const Duration(days: 1));
                          date.value = newDate;

                          ref.read(clientStateProvider.notifier).getAvailableTimeSlots(restaurant.id, newDate);
                          await triggerCapacityVerification(restaurant.id, nbGuests.value);
                        }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final newDate = date.value!.add(const Duration(days: 1));
                          date.value = newDate;

                          ref.read(clientStateProvider.notifier).getAvailableTimeSlots(restaurant.id, newDate);
                          await triggerCapacityVerification(restaurant.id, nbGuests.value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      final int currentDay = date.value!.weekday;

                      // =========================================================================
                      // SCÉNARIO 1 : LE RESTAURANT EST FERMÉ
                      // =========================================================================
                      if (formattedServices[currentDay] == null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Le restaurant est fermé ce jour-là.',
                                  style: TextStyle(color: Colors.orange, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Créneaux disponibles',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            clientStateAsync.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, stack) => Center(child: Text('Error: $error')),
                              data: (clientState) {
                                final formattedTimeSlots = formatTimeSlots(clientState.availableTimeSlots ?? []);

                                // =========================================================================
                                // SCÉNARIO 2 : LE RESTAURANT EST OUVERT, MAIS TOUS LES CRÉNEAUX SONT COMPLETS
                                // =========================================================================
                                if (formattedTimeSlots.isEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.event_busy, color: Colors.red.shade700),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Pas de créneaux disponibles",
                                            style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                          await triggerCapacityVerification(restaurant.id, nbGuests.value);
                                        },
                                        child: Container(
                                          width: 80,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: selectedTimeSlot.value == time
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.surface,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: selectedTimeSlot.value == time
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.outline,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              time,
                                              style: TextStyle(
                                                color: selectedTimeSlot.value == time
                                                    ? theme.colorScheme.onPrimary
                                                    : theme.colorScheme.onSurface,
                                                fontSize: 14,
                                                fontWeight: selectedTimeSlot.value == time
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
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
                                      await triggerCapacityVerification(restaurant.id, nbGuests.value);
                                    }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: nbGuests.value < 10
                                        ? () async {
                                      nbGuests.value++;
                                      await triggerCapacityVerification(restaurant.id, nbGuests.value);
                                    }
                                        : null,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                            if (isOverloaded.value)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.warning, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Surréservation (capacité)',
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'La capacité du restaurant pour ce créneau pourrait être insuffisante pour le nombre de convives demandé.',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: specialRequestsController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return null;
                      }

                      if (value.trim().length < 10) {
                        return 'Les demandes spéciales doivent contenir au moins 10 caractères';
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Demandes spéciales (optionnel)',
                      border: OutlineInputBorder(),
                      hintText: 'Allergies, preferences...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    // =========================================================================
                    // SÉCURISATION DES CONDITIONS D'ACTIVATION DU BOUTON
                    // =========================================================================
                    onPressed: (date.value != null &&
                        selectedTimeSlot.value != null &&
                        isFormValid.value &&
                        formattedServices[date.value!.weekday] != null && // Vérifie que le resto est ouvert ce jour-là
                        (clientState.availableTimeSlots ?? []).any((slot) => DateFormat('HH:mm').format(slot) == selectedTimeSlot.value)) // Vérifie que le créneau précédemment sélectionné fait toujours partie des créneaux valides renvoyés
                        ? () {
                      print("Envoi de la réservation pour : ${selectedTimeSlot.value}");
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer la réservation'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}