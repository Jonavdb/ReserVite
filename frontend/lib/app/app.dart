import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/views/screens/list_reservations_client.dart';
import 'package:prbd_2526_f03/views/screens/list_reservations_manager.dart';
import 'package:prbd_2526_f03/views/screens/my_restaurants.dart';
import 'package:prbd_2526_f03/views/screens/reservation_details_manager.dart';
import '../views/screens/login.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReserVite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/my_restaurants': (context) => MyRestaurantsScreen(),
        '/list_reservation_client': (context) => const ListReservationsClient(),
      },
      onGenerateRoute: (settings){
        if (settings.name == '/list_reservations_manager') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
              builder: (context) => ListReservationsManager(
                restaurantId: args['restaurantId'],
                restaurantName: args['restaurantName'],
              ),
          );
        }
        if (settings.name == '/reservation_details_manager') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
              builder: (context) => ReservationDetailsManager(
                  reservationId: args['reservationId']
              )
          );
        }
        return null;
      },
    );
  }
}
