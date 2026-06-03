import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/services/api_client.dart';


final simulatedTimeProvider = AsyncNotifierProvider<SimulatedTimeStateNotifier, DateTime?>(
        () => SimulatedTimeStateNotifier());

class SimulatedTimeStateNotifier extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() async {
    // A l'initialisation, le provider récupère le temps simulé dans la base de données
    return await fetchSimulatedTime();
  }

  Future<DateTime?> fetchSimulatedTime() async {
    final response = await ApiClient.post('get_current_date');

    if(response.statusCode != 200) {
      throw Exception('Failed to retrieve current date from database');
    }

    final String dateStr = json.decode(response.body);

    if (dateStr.isEmpty) {
      return null;
    }

    // Conversion en de la réponse en DateTime
    return DateTime.parse(dateStr.toString());

  }
/*
  Astuce pour les tests dans le fichier test.http :
  exemple:  "2026-05-28T10:43:25.000Z"
  format de la date entrée :
  - "[année]-[mois]-[jour]T[H:M:S].000Z"
  -  Il faut laisser le 'T' et le 'Z' tel quel à leur position respective
 */
  Future<void> setSimulatedTime(DateTime? newDate) async {
    //
    final previousState = state;

    //
    state = const AsyncLoading();

    try {
      Map<String, String> params = {};
      var sanitizedDate = newDate ?? DateTime.now();
      params['new_date'] = sanitizedDate.toIso8601String();

      final response = await ApiClient.post(
        'set_current_date',
        body: params.isNotEmpty ? json.encode(params) : null,
        anonymous: false,
      );

      if(response.statusCode != 200) {
        throw Exception('Failed to update current date in database');
      }
      state = AsyncData(newDate);
    } catch (error, stackTrace) {
      state = previousState;
      state = AsyncError(error, stackTrace);
    }
  }
}