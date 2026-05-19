class ReservationClient {
  final int id;
  final String status;
  final String restaurantName;
  final String restaurantCity;
  final DateTime datetime;
  final int numberOfGuests;

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
    required this.restaurantName,
    required this.restaurantCity,
    required this.datetime,
    required this.numberOfGuests,
  });


  // Constructeur permettant de convertir des données json (récupérées via appel au backend) en instance de la classe
  factory ReservationClient.fromJson(Map<String, dynamic> json) {
    return ReservationClient(
      id: json['id'],
      status: json['status'],
      restaurantName: json['restaurant_name'],
      restaurantCity: json['restaurant_city'],
      datetime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'],
    );
  }
}