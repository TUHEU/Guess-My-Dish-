import 'package:flutter/material.dart';
import '../models/recipe.dart';
import 'results_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> _selectedIngredients = [];
  String? _selectedMood;
  double _selectedTime = 30.0;

  final List<int> _timeOptions = [5, 10, 15, 20, 30, 45, 60];

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = _selectedMood == mood ? null : mood;
    });
  }

  void _findRecipes() {
    final filteredRecipes = RecipeDatabase.recipes
        .where((recipe) => recipe.matchesFilters(
              selectedIngredients: _selectedIngredients,
              selectedMood: _selectedMood,
              maxTime: _selectedTime.round(),
            ))
        .toList();

    // Sort by number of matching ingredients
    filteredRecipes.sort((a, b) => b
        .matchingScore(_selectedIngredients)
        .compareTo(a.matchingScore(_selectedIngredients)));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          recipes: filteredRecipes,
          selectedIngredients: _selectedIngredients,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PickMyDish'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

            // Ingredients Section
            _buildIngredientsSection(),
            const SizedBox(height: 32),

            // Mood Section
            _buildMoodSection(),
            const SizedBox(height: 32),

            // Time Section
            _buildTimeSection(),
            const SizedBox(height: 40),

            // Find Recipes Button
            _buildFindButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Should I Eat Today?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us what you have and how you feel, we\'ll suggest the perfect meal!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. What ingredients do you have?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RecipeDatabase.allIngredients.map((ingredient) {
            final isSelected = _selectedIngredients.contains(ingredient);
            return FilterChip(
              label: Text(ingredient),
              selected: isSelected,
              onSelected: (_) => _toggleIngredient(ingredient),
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade700,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. How are you feeling?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: MoodOptions.moods.map((mood) {
              final isSelected = _selectedMood == mood.value;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => _selectMood(mood.value),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade300
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          mood.icon,
                          size: 32,
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3. How much time do you have?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Slider(
              value: _selectedTime,
              min: 5,
              max: 60,
              divisions: 11,
              label: '${_selectedTime.round()} minutes',
              onChanged: (value) {
                setState(() {
                  _selectedTime = value;
                });
              },
              activeColor: Colors.blue.shade700,
              inactiveColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              'Maximum time: ${_selectedTime.round()} minutes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFindButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _findRecipes,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Find My Meal!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
