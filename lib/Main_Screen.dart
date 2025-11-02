import 'package:flutter/material.dart';
import 'routes.dart';
import '../screens/splash_screen.dart';

class PickMyDishApp extends StatelessWidget {
  const PickMyDishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PickMyDish',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
