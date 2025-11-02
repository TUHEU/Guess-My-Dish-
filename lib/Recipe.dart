class Recipe {
  final String name;
  final List<String> ingredients;
  final String mood;
  final int time;
  final String instructions;
  final String imageUrl;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.mood,
    required this.time,
    required this.instructions,
    this.imageUrl = '',
  });

  // Helper method to check if recipe matches filters
  bool matchesFilters({
    required List<String> selectedIngredients,
    required String? selectedMood,
    required int maxTime,
  }) {
    // Check mood
    if (selectedMood != null && mood != selectedMood) {
      return false;
    }

    // Check time
    if (time > maxTime) {
      return false;
    }

    // Check ingredients (at least one match)
    if (selectedIngredients.isNotEmpty) {
      final matchingIngredients = selectedIngredients
          .where((ingredient) => ingredients.contains(ingredient))
          .length;
      if (matchingIngredients == 0) {
        return false;
      }
    }

    return true;
  }

  // Get matching score for sorting
  int matchingScore(List<String> selectedIngredients) {
    if (selectedIngredients.isEmpty) return 0;
    return selectedIngredients
        .where((ingredient) => ingredients.contains(ingredient))
        .length;
  }
}

// Recipe database
class RecipeDatabase {
  static final List<Recipe> recipes = [
    Recipe(
      name: "Quick Chicken Stir Fry",
      ingredients: ["chicken", "rice", "vegetables", "soy sauce"],
      mood: "quick",
      time: 20,
      instructions: "1. Cook rice according to package instructions.\n\n"
          "2. Cut chicken into bite-sized pieces and stir-fry in a hot pan with oil.\n\n"
          "3. Add mixed vegetables and continue stir-frying.\n\n"
          "4. Add soy sauce and other seasonings to taste.\n\n"
          "5. Serve hot over rice.",
    ),
    Recipe(
      name: "Healthy Salad Bowl",
      ingredients: ["lettuce", "tomato", "cucumber", "chicken", "olive oil"],
      mood: "healthy",
      time: 15,
      instructions: "1. Wash and chop lettuce, tomato, and cucumber.\n\n"
          "2. Grill or pan-sear chicken breast until cooked through.\n\n"
          "3. Slice chicken and arrange over the salad.\n\n"
          "4. Drizzle with olive oil and your favorite dressing.\n\n"
          "5. Toss gently and serve immediately.",
    ),
    Recipe(
      name: "Comfort Mac & Cheese",
      ingredients: ["pasta", "cheese", "milk", "butter"],
      mood: "comfort",
      time: 25,
      instructions: "1. Cook pasta according to package instructions.\n\n"
          "2. In a separate pan, melt butter and add milk.\n\n"
          "3. Gradually add shredded cheese, stirring until smooth.\n\n"
          "4. Combine cheese sauce with drained pasta.\n\n"
          "5. Bake for 10 minutes until bubbly (optional).",
    ),
    Recipe(
      name: "Lazy Microwave Burrito",
      ingredients: ["tortilla", "beans", "cheese", "salsa"],
      mood: "lazy",
      time: 5,
      instructions: "1. Place tortilla on a microwave-safe plate.\n\n"
          "2. Spread beans and cheese in the center.\n\n"
          "3. Microwave for 1-2 minutes until cheese melts.\n\n"
          "4. Add salsa and any other toppings.\n\n"
          "5. Roll up and enjoy!",
    ),
    Recipe(
      name: "Energetic Protein Smoothie",
      ingredients: ["banana", "yogurt", "protein powder", "milk", "berries"],
      mood: "energetic",
      time: 5,
      instructions: "1. Peel banana and place in blender.\n\n"
          "2. Add yogurt, protein powder, milk, and berries.\n\n"
          "3. Blend until smooth and creamy.\n\n"
          "4. Pour into glass and enjoy immediately.\n\n"
          "5. Add ice for a colder smoothie.",
    ),
    Recipe(
      name: "Hearty Beef Stew",
      ingredients: ["beef", "potatoes", "carrots", "onions", "broth"],
      mood: "hungry",
      time: 60,
      instructions: "1. Cut beef into cubes and brown in a large pot.\n\n"
          "2. Add chopped onions and cook until softened.\n\n"
          "3. Add potatoes, carrots, and broth.\n\n"
          "4. Simmer for 45-50 minutes until meat is tender.\n\n"
          "5. Season with salt and pepper to taste.",
    ),
    Recipe(
      name: "Quick Veggie Omelette",
      ingredients: ["eggs", "bell pepper", "onion", "cheese", "spinach"],
      mood: "quick",
      time: 10,
      instructions: "1. Beat eggs in a bowl with salt and pepper.\n\n"
          "2. Chop vegetables and sauté briefly.\n\n"
          "3. Pour eggs over vegetables in the pan.\n\n"
          "4. Add cheese and cook until set.\n\n"
          "5. Fold and serve hot.",
    ),
    Recipe(
      name: "Simple Avocado Toast",
      ingredients: ["bread", "avocado", "lemon", "salt", "pepper"],
      mood: "healthy",
      time: 5,
      instructions: "1. Toast bread until golden brown.\n\n"
          "2. Mash avocado with lemon juice, salt, and pepper.\n\n"
          "3. Spread avocado mixture on toast.\n\n"
          "4. Add optional toppings like chili flakes or eggs.\n\n"
          "5. Serve immediately.",
    ),
  ];

  static List<String> get allIngredients {
    final ingredients = <String>{};
    for (final recipe in recipes) {
      ingredients.addAll(recipe.ingredients);
    }
    return ingredients.toList()..sort();
  }
}

// Mood options
class Mood {
  final String name;
  final String value;
  final IconData icon;

  Mood({required this.name, required this.value, required this.icon});
}

class MoodOptions {
  static final List<Mood> moods = [
    Mood(name: "Quick", value: "quick", icon: Icons.flash_on),
    Mood(name: "Healthy", value: "healthy", icon: Icons.favorite),
    Mood(name: "Comfort", value: "comfort", icon: Icons.emoji_food_beverage),
    Mood(name: "Lazy", value: "lazy", icon: Icons.beach_access),
    Mood(name: "Energetic", value: "energetic", icon: Icons.fitness_center),
    Mood(name: "Hungry", value: "hungry", icon: Icons.restaurant),
  ];
}
