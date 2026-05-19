import 'dart:convert';

import 'package:prbd_2526_f03/models/client/reservation_client.dart';

import '../../core/services/api_client.dart';

/*
      Cette classe contient les données d'un client (ex : list de ses réservations 'en attente')
      Ces données sont observées par les vues qui affichent les données de la classe
      Exemple :
      > list_reservations_client.dart regarde client_state_provider.dart..
      > lorsque le notifier du provider effectue des modifications sur le clientState..
      > list_reservations_client.dart affiche les nouvelles données retournées après modifications
 */
class ClientState {
  final String currentFilter;
  final List<ReservationClient> reservations;

  ClientState({
      required this.currentFilter, // filtre d'affichage des réservations ('pending', 'confirmed' etc)
      required this.reservations // liste des réservations du clients
  });

  /*
      Fonction qui fait appel au backend pour récupérer les réservations du client connecté
      avec le filtre renseigné ie status. Si aucun filtre, la fonction retourne toutes les réservations du client
   */
  static Future<List<ReservationClient>> fetchReservations(String? status) async {

    // on formatte le paramètre status pour l'appel au backend
    final Map<String, String?> params = {};
    if (status != null) {
      params['status_filter'] = status;
    }

    // appel au backend
    final response = await ApiClient.post(
      'get_client_reservations',
      body: params.isNotEmpty ? json.encode(params) : null,
      anonymous: false,
    );

    // en cas d'erreur
    if (response.statusCode != 200) {
      throw Exception('Failed to load reservations from database');
    }


    // on récupère les données retournées par le backend
    final dynamic body = json.decode(response.body);

    List<ReservationClient> reservations = [];
    // pour chaque élément de la réponse
    for (var res in body) {
      // on encapsule l'élément dans un type custom ReservationClient..
      var myRes = ReservationClient.fromJson(res);
      reservations.add(myRes);
    }

    // on retourne la liste remplie
    return reservations;
  }


}