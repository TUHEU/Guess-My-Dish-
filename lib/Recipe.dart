class AppState {
  final bool isLoading;
  final String currentScreen;
  final List<String> selectedIngredients;
  final String? selectedMood;
  final int selectedTime;

  const AppState({
    this.isLoading = false,
    this.currentScreen = '/',
    this.selectedIngredients = const [],
    this.selectedMood,
    this.selectedTime = 30,
  });

  AppState copyWith({
    bool? isLoading,
    String? currentScreen,
    List<String>? selectedIngredients,
    String? selectedMood,
    int? selectedTime,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      currentScreen: currentScreen ?? this.currentScreen,
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
      selectedMood: selectedMood ?? this.selectedMood,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}

// Mock data for Sprint 1 UI development
class MockData {
  static const List<String> sampleIngredients = [
    'chicken',
    'rice',
    'vegetables',
    'pasta',
    'cheese',
    'tomato',
    'eggs',
    'bread',
  ];

  static const List<Map<String, dynamic>> sampleRecipes = [
    {
      'name': 'Quick Chicken Stir Fry',
      'time': 20,
      'mood': 'Quick',
      'ingredients': ['chicken', 'rice', 'vegetables'],
    },
    {
      'name': 'Healthy Salad Bowl',
      'time': 15,
      'mood': 'Healthy',
      'ingredients': ['lettuce', 'tomato', 'chicken'],
    },
    {
      'name': 'Comfort Mac & Cheese',
      'time': 25,
      'mood': 'Comfort',
      'ingredients': ['pasta', 'cheese', 'milk'],
    },
  ];
}
