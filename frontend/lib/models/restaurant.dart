class Restaurant {
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;

  /*
      Cette classe contient les données d'un restaurant
   */
  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
  });

  // Constructeur permettant de convertir des données json (récupérées via appel au backend) en instance de la classe
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
        id: json['id'],
        name: json['_name'],
        address: json['address'],
        city: json['city'],
        phone: json['phone'],
    );
  }
}

