import 'package:flutter/material.dart';

void main() {
  runApp(const PickMyDishApp());
}

class PickMyDishApp extends StatelessWidget {
  const PickMyDishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PickMyDish',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
