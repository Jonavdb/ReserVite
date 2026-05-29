import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_f03/providers/reference_time_provider.dart';
import 'package:prbd_2526_f03/providers/simulated_time_provider.dart';

/*
  Widget custom pour modifier la date simulée de l'application
 */
class DateTimePicker extends ConsumerWidget {
  const DateTimePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final appTimeProvider = ref.watch(referenceTimeProvider);
    final simulatedTimeNotifier = ref.watch(simulatedTimeProvider.notifier);

    // style custom pour l'affichage de la date
    final dateTextStyle = TextStyle(
      fontSize: 10,
      color: Colors.grey[400],
      fontWeight: FontWeight.normal,
    );

    return Tooltip(
      message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
      child: InkWell(
        onTap: () { // se déclenche quand on appuie sur le temps tout en haut de l'écran

          // on récupère le temps simulé via le ReferenceTimeProvider
          // qui lui même le récupère en observant le SimulatedTimeProvider
          final DateTime currentDateTime = appTimeProvider.value ?? DateTime.now();

          // on ouvre une boite de dialogue
          showDialog(
            context: context,
            builder: (BuildContext context) {

              // variable temporaire du temps avant édition, au cas ou on quitte sans n'avoir rien changé
              DateTime tempDateTime = currentDateTime;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Modifier le temps simulé'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // --- LIGNE 1 : EDITION DATE (onPressed => amène au calendrier) ---
                        ListTile(
                          leading: const Icon(Icons.calendar_month),
                          title: const Text('Date'),
                          subtitle: Text(DateFormat('dd/MM/yyyy', 'fr_FR').format(tempDateTime)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async { // onTap : à l'appui sur la zone
                            // on déclenche l'édition de la date via showDatePicker
                            // ça ouvre le calendrier
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: tempDateTime, // initial date : la date à l'ouverture
                              firstDate: DateTime(currentDateTime.year - 10), // first date : la première date disponible
                              lastDate: DateTime(currentDateTime.year + 10), // first date : la dernière date disponible

                              // on met l'orientation du calendrier en portrait
                              // que du setup, pas besoin de se concentrer sur ça
                              builder: (BuildContext context, Widget? child) {
                                final Size screenSize = MediaQuery.of(context).size;
                                return MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    size: Size(screenSize.shortestSide, screenSize.longestSide),
                                  ),
                                  child: child!,
                                );
                              },
                            ); // ici, on est sortie du calendier

                            // si à la sortie de la boite de dialogue calendrier une date a été choisie (ie. bouton valider a été appuyé),
                            // la variable tempDateTime du début est mise à jour avec la nouvelle date choisie
                            if (pickedDate != null) {
                              setState(() {
                                tempDateTime = DateTime(
                                  pickedDate.year, pickedDate.month, pickedDate.day,
                                  tempDateTime.hour, tempDateTime.minute,
                                );
                              });
                            }
                          },
                        ),

                        // espace vide entre l'edition de la date et l'editiond de l'heure
                        const Divider(height: 1),

                        // --- LIGNE 1 : EDITION HEURE (onPressed => amène à l'horloge) ---
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Heure'),
                          subtitle: Text(DateFormat('HH:mm', 'fr_FR').format(tempDateTime)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async { // onTap : à l'appui sur la zone
                            final TimeOfDay? selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(tempDateTime), // heure affichée à l'ouverture
                            );

                            // si à la sortie de la boite de dialogue horloge une heure a été choisie (ie. bouton valider a été appuyé),
                            // la variable tempDateTime du début est mise à jour avec la nouvelle heure
                            if (selectedTime != null) {
                              setState(() {
                                tempDateTime = DateTime(
                                  tempDateTime.year, tempDateTime.month, tempDateTime.day,
                                  selectedTime.hour, selectedTime.minute,
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    actions: [
                      // --- BOUTONS ---
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Déclenche un appel au notifier du simulatedTimeProvider pour mettre une nouvelle date
                          // Mettre à null revient à dire au backend de retourner la date courante
                          simulatedTimeNotifier.setSimulatedTime(null);
                          Navigator.pop(context);
                        },
                        child: const Text('Effacer (null)'),
                      ),
                      TextButton(
                        onPressed: () {
                          // On met à jour le temps de l'app avec la valeur de tempDateTime qu'on a modifié à travers le calendrier et l'horloge
                          // via le notifier du simulatedTimeProvider, pas le referenceTimeProvider, car ce dernier ne s'occupe que de fournir la date
                          // il ne fait aucune action
                          simulatedTimeNotifier.setSimulatedTime(tempDateTime);
                          Navigator.pop(context);
                        },
                        child: const Text('Valider'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },

        // Ici, on se contente d'afficher la date du referenceTimeProvider
        // qui lui même le récupère en observant le SimulatedTimeProvider
        child: appTimeProvider.when(
          data: (date) {
            return Text(
              DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR').format(date),
              style: dateTextStyle,
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stackTrace) => Text(
            "Error: $err",
            style: dateTextStyle,
          ),
        ),
      ),
    );
  }
}