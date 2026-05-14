import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_f03/views/screens/home_client_mockup.dart';
import 'package:prbd_2526_f03/views/screens/my_restaurants_mockup.dart';
import '../providers/security_provider.dart';
import '../views/screens/login_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityNotifier = ref.read(securityProvider.notifier);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReserVite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      routes: {
        '/my_restaurants': (context) => const MyRestaurantsMockupScreen(),
        '/home_client': (context) => const HomeClientMockupScreen(),
      },
    );
  }
}
