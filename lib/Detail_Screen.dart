import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/results_screen.dart';
import '../screens/recipe_detail_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String results = '/results';
  static const String recipeDetail = '/recipe-detail';

  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const MainScreen(),
      results: (context) => const ResultsScreen(),
      recipeDetail: (context) => const RecipeDetailScreen(),
    };
  }

  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static void replaceWith(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }
}
