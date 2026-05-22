import 'package:prbd_2526_f03/models/restaurant.dart';

class ReservationClient {
  final int id;
  final String status;
  final DateTime datetime;
  final int numberOfGuests;
  final Restaurant restaurant;

  /*
      Cette classe contient les données d'une réservation client
      ex : list_reservations_client.dart affiche pour chaque réservation :
      - son status sous forme d'icone
      - le nom du restaurant
      - la ville
      - etc
   */
  ReservationClient({
    required this.id,
    required this.status,
    required this.datetime,
    required this.numberOfGuests,
    required this.restaurant
  });


  // Constructeur permettant de convertir des données json (récupérées via appel au backend) en instance de la classe
  factory ReservationClient.fromJson(Map<String, dynamic> json) {
    return ReservationClient(
      id: json['id'],
      status: json['status'],
      datetime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'],
      restaurant: Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
    );
  }
}