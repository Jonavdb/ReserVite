class RestaurantService {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  RestaurantService({required this.dayOfWeek, required this.startTime, required this.endTime});

  factory RestaurantService.fromJson(Map<String, dynamic> json) {
    return RestaurantService(
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  // Helper pour afficher le nom du jour
  String get dayName {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[dayOfWeek - 1];
  }
}
