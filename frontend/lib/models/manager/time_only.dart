class TimeOnly implements Comparable<TimeOnly> {
  final int hour;
  final int minute;
  final int second;

  const TimeOnly({
    required this.hour,
    required this.minute,
    required this.second
  });

  factory TimeOnly.fromString(String time){
    final parts = time.split(':');
    return TimeOnly(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        second: int.parse(parts[2])
    );
  }

  @override
  String toString(){
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  int toMinutes(){
    return hour * 60 + minute;
  }
  bool isBefore(TimeOnly other){
    return this.toMinutes() < other.toMinutes();
  }
  bool isAfter(TimeOnly other){
    return this.toMinutes() > other.toMinutes();
  }

  @override
  int compareTo(TimeOnly other) {
    return toMinutes().compareTo(other.toMinutes());
  }
}