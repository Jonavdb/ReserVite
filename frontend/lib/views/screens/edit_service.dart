import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/models/manager/service.dart';
import 'package:prbd_2526_f03/models/manager/time_only.dart';
import 'package:prbd_2526_f03/providers/manager/manager_state_provider.dart';

class EditService extends ConsumerStatefulWidget {
  final int restaurantId;
  final int serviceId;

  const EditService({super.key, required this.restaurantId, required this.serviceId});

  @override
  ConsumerState<EditService> createState() => _EditServiceState();

}
class _EditServiceState extends ConsumerState<EditService> {
  int? _newDayOfWeek;
  int? _startHour;
  int? _startMinute;
  int? _endHour;
  int? _endMinute;
  Service? _service;
  bool? _isSavable;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(managerStateProvider.notifier).getService(widget.serviceId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final editServiceState = ref.watch(managerStateProvider);

    editServiceState.whenData((managerState) {
      _isSavable = managerState.impactedReservations == 0 && managerState.impactedServices == 0;
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Modifier le service'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: _isSavable == false ? null : () => _update(context, _service!),
            icon: const Icon(Icons.save),
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
        child : editServiceState.when (
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur: $error') ),
          data : (managerState) {
            final service = managerState.services.firstWhere((service) => service.id == widget.serviceId);
            _service = service;
            _isSavable = managerState.impactedReservations == 0;
            _newDayOfWeek ??= service.dayOfWeek;
            _startHour ??= service.startTime.hour;
            _startMinute ??= service.startTime.minute;
            _endHour ??= service.endTime.hour;
            _endMinute ??= service.endTime.minute;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: service.day.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Lundi', child: Text('Lundi')),
                    DropdownMenuItem(value: 'Mardi', child: Text('Mardi')),
                    DropdownMenuItem(value: 'Mercredi', child: Text('Mercredi')),
                    DropdownMenuItem(value: 'Jeudi', child: Text('Jeudi')),
                    DropdownMenuItem(value: 'Vendredi', child: Text('Vendredi')),
                    DropdownMenuItem(value: 'Samedi', child: Text('Samedi')),
                    DropdownMenuItem(value: 'Dimanche', child: Text('Dimanche')),
                  ],
                  onChanged: (val) {
                    _newDayOfWeek = Service.getDayNumber(val!);
                    ref.read(managerStateProvider.notifier).countImpactedReservations(widget.restaurantId, _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                    ref.read(managerStateProvider.notifier).countImpactedServices(widget.restaurantId,  _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                  },
                ),
                if (managerState.impactedReservations > 0) ... [
                  Card(
                    color: null,
                    child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          '${managerState.impactedReservations} réservation(s) seraient impactée(s) par ce changement',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  )
                  ),
                ],
                if (managerState.impactedServices > 0) ... [
                  Card(
                      color: null,
                      child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            '${managerState.impactedServices} services seraient impactée(s) par ce changement',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          )
                      )
                  ),
                ],

                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _startHour,
                        decoration: const InputDecoration(
                          labelText: 'Heure de début (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (val) {
                          _startHour = val;
                          ref.read(managerStateProvider.notifier).countImpactedReservations(widget.restaurantId, _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                          ref.read(managerStateProvider.notifier).countImpactedServices(widget.restaurantId,  _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                        },
                      ),
                      ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue : _startMinute,
                        decoration: InputDecoration(
                          labelText: "Minutes",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 60; h+= service.gap)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (val) {
                          _startMinute = val;
                          ref.read(managerStateProvider.notifier).countImpactedReservations(widget.restaurantId, _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                          ref.read(managerStateProvider.notifier).countImpactedServices(widget.restaurantId,  _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);

                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _endHour,
                        decoration: const InputDecoration(
                          labelText: 'Heure de fin (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (val) {
                          _endHour = val;
                          ref.read(managerStateProvider.notifier).countImpactedReservations(widget.restaurantId, _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                          ref.read(managerStateProvider.notifier).countImpactedServices(widget.restaurantId,  _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _endMinute,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 60; h+= service.gap)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (val) {
                          _endMinute = val;
                          ref.read(managerStateProvider.notifier).countImpactedReservations(widget.restaurantId, _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                          ref.read(managerStateProvider.notifier).countImpactedServices(widget.restaurantId,  _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0), widget.serviceId);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
          },
        ),
      ),
      );
    }

  void _update(BuildContext context, Service service) async {
    final notifier = ref.read(managerStateProvider.notifier);
    await notifier.updateService(service, _newDayOfWeek!, TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0));
    if (context.mounted) {
      ref.read(managerStateProvider.notifier).loadServices(widget.restaurantId);
      Navigator.of(context).pop(null);
    }
  }
}
