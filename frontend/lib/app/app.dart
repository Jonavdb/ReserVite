import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/views/screens/list_reservations_client.dart';
import 'package:prbd_2526_f03/views/screens/my_restaurants.dart';
import '../views/screens/login.dart';
import '../views/screens/signup.dart';

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
        '/my_restaurants': (context) => MyRestaurants(),
        '/list_reservation_client': (context) => const ListReservationsClient(),
      },
    );
  }
}
