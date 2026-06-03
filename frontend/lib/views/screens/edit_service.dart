import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/models/manager/service.dart';
import 'package:prbd_2526_f03/models/manager/time_only.dart';
import 'package:prbd_2526_f03/providers/manager/manager_state_provider.dart';

import '../../core/widgets/simulated_date_time_picker_widget.dart';

class EditService extends ConsumerStatefulWidget {
  final int restaurantId;
  final int ?serviceId;

  const EditService({super.key, required this.restaurantId, this.serviceId});

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
  bool is_long_enough = true;
  bool start_before_end = true;

  @override
  void initState() {
    super.initState();
    if (widget.serviceId != null) {
      Future.microtask(() => ref.read(managerStateProvider.notifier).getService(widget.serviceId!));
    }
    Future.microtask(() => ref.read(managerStateProvider.notifier).resetImpacts());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editServiceState = ref.watch(managerStateProvider);

    editServiceState.whenData((managerState) {
      _isSavable = managerState.impactedReservations == 0 && managerState.impactedServices == 0 && _validateTime();
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.serviceId != null ? 'Modifier le service' : 'Ajouter un service'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: _isSavable == false ? null :
                _service != null ?
                    () => _update(context, _service!)
                    : () => _insert(context),
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
              child: const SimulatedDateTimePicker(),
          ),
          ),
        ),
      ),
      body: SafeArea(
        child : editServiceState.when (
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Erreur: $error') ),
          data : (managerState) {
            _isSavable = managerState.impactedReservations == 0 && managerState.impactedServices == 0 && _validateTime();
            final int gapInterval = managerState.currentRestaurantGap!;

            if (widget.serviceId != null) {
              final service = managerState.services.firstWhere((service) => service.id == widget.serviceId);
              _service = service;
              _newDayOfWeek ??= service.dayOfWeek;
              _startHour ??= service.startTime.hour;
              _startMinute ??= service.startTime.minute;
              _endHour ??= service.endTime.hour;
              _endMinute ??= service.endTime.minute;
            }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: widget.serviceId == null ? null : _service!.day.toString(),
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
                    _checkImpacted();
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
                            'Ce service chevauche avec un service existant le ${Service.getDayOfWeek(_newDayOfWeek!)}',
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
                        initialValue: widget.serviceId == null ? null :  _startHour,
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
                          _checkImpacted();
                          _validateTime();
                        },
                      ),
                      ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue : widget.serviceId == null ? null : _startMinute,
                        decoration: InputDecoration(
                          labelText: "Minutes",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 60; h+= gapInterval)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} min'),
                            ),
                        ],
                        onChanged: (val) {
                          _startMinute = val;
                          _checkImpacted();
                          _validateTime();
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
                        initialValue: widget.serviceId == null ? null : _endHour,
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
                          _checkImpacted();
                          _validateTime();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: widget.serviceId == null ? null : _endMinute,
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 60; h+= gapInterval)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} min'),
                            ),
                        ],
                        onChanged: (val) {
                          _endMinute = val;
                          _checkImpacted();
                          _validateTime();
                        },
                      ),
                    ),
                  ],
                ),
                if (!start_before_end) ... [
                  Card (
                      color: null,
                      child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'L\'heure de début doit être avant l\'heure de fin',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          )
                      )
                  ),
                ]
                else if (!is_long_enough) ... [
                  Card (
                      color: null,
                      child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'La durée du service doit être d\'au moins 1 heure',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          )
                      )
                  ),
                ]
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service mis à jour avec succès')),
      );
      // ref.read(managerStateProvider.notifier).loadServices(widget.restaurantId);
      Navigator.of(context).pop(null);
    }
  }

  void _insert(BuildContext context) async {
    final notifier = ref.read(managerStateProvider.notifier);
    await notifier.createService(widget.restaurantId, _newDayOfWeek!,TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0), TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service créé avec succès')),
      );
      // ref.read(managerStateProvider.notifier).loadServices(widget.restaurantId);
      Navigator.of(context).pop(null);
    }
  }

  bool _validateTime() {
    if (_startHour == null || _startMinute == null || _endHour == null || _endMinute == null){
      return false;
    }
    final startTime = TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0);
    final endTime = TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0);
    int duration = endTime.toMinutes() - startTime.toMinutes();
    is_long_enough = duration >= 60;
    start_before_end = startTime.isBefore(endTime);
    return is_long_enough && start_before_end;
  }

  void _checkImpacted() async {
    if (_newDayOfWeek == null || _startHour == null || _startMinute == null || _endHour == null || _endMinute == null) {
      return;
    }
    final startTime = TimeOnly(hour: _startHour!, minute: _startMinute!, second: 0);
    final endTime = TimeOnly(hour: _endHour!, minute: _endMinute!, second: 0);
    if (widget.serviceId != null){
      await ref.read(managerStateProvider.notifier).countImpactedReservations(widget.restaurantId, _newDayOfWeek!, startTime, endTime, widget.serviceId!);
      await ref.read(managerStateProvider.notifier).countImpactedServices(widget.restaurantId,  _newDayOfWeek!, startTime, endTime, widget.serviceId!);

    } else {
      await ref.read(managerStateProvider.notifier).countImpactedServices(widget.restaurantId,  _newDayOfWeek!, startTime, endTime, -1);
    }
  }
}
