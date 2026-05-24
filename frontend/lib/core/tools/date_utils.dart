import 'package:intl/intl.dart';

// permet d'avoir "aujourd'hui / hier / date complète"
String formatRelativeDate(DateTime? date, DateTime simulatedNow) {
  if (date == null) return '';

  // on efface les heures/minutes pour comparer uniquement les jours
  final justDate = DateTime(date.year, date.month, date.day);
  final justNow = DateTime(simulatedNow.year, simulatedNow.month, simulatedNow.day);
  final differenceInDays = justNow.difference(justDate).inDays;

  if (differenceInDays == 0) {
    return "aujourd'hui";
  } else if (differenceInDays == 1) {
    return "hier";
  } else {
    // Format : mer. 04/12/2024
    return DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(date);
  }
}
