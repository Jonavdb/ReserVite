import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/views/screens/assign_tables.dart';
import 'package:prbd_2526_f03/views/screens/edit_service.dart';
import 'package:prbd_2526_f03/views/screens/list_reservations_client.dart';
import 'package:prbd_2526_f03/views/screens/list_reservations_manager.dart';
import 'package:prbd_2526_f03/views/screens/list_restaurants_manager.dart';
import 'package:prbd_2526_f03/views/screens/reservation_details_manager.dart';
import 'package:prbd_2526_f03/views/screens/restaurant_management_services.dart';
import 'package:prbd_2526_f03/views/screens/restaurant_management_tables.dart';
import '../views/screens/add_reservation.dart';
import '../views/screens/edit_reservation.dart';
import '../views/screens/edit_table.dart';
import '../views/screens/login.dart';
import '../views/screens/restaurant_details.dart';
import '../views/screens/search_restaurants.dart';
import '../views/screens/signup.dart';
import '../views/screens/view_reservation_details.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReserVite',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: Login(),
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/list_restaurants_manager': (context) => ListRestaurantsManager(),
        '/list_reservation_client': (context) => ListReservationsClient(),
        '/view_reservation_client': (context) => ViewReservationClient(),
        '/search_restaurants': (context) => SearchRestaurants(),
        '/add_reservation': (context) => AddReservation(),
        '/edit_reservation': (context) => EditReservation(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/list_reservations_manager') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                ListReservationsManager(restaurantId: args['restaurantId'], restaurantName: args['restaurantName']),
          );
        }
        if (settings.name == '/reservation_details_manager') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ReservationDetailsManager(reservationId: args['reservationId']),
          );
        }
        if (settings.name == '/assign_tables') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AssignTables(
              reservationId: args['reservationId'],
              restaurantId: args['restaurantId'],
              date: args['date'],
            ),
          );
        }
        if (settings.name == '/restaurant_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(builder: (context) => RestaurantDetailsScreen(restaurantId: args['restaurantId']));
        }
        if (settings.name == '/restaurant_management_services') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RestaurantManagementServices(
              restaurantId: args['restaurantId'],
              restaurantName: args['restaurantName'],
            ),
          );
        }
        if (settings.name == '/restaurant_management_tables') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                RestaurantManagementTables(restaurantId: args['restaurantId'], restaurantName: args['restaurantName']),
          );
        }
        if (settings.name == '/edit_service') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditService(restaurantId: args['restaurantId'], serviceId: args['serviceId']),
          );
        }
        if (settings.name == '/edit_table') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditTable(restaurantId: args['restaurantId'], table: args['table']),
          );
        }
        return null;
      },
    );
  }
}
