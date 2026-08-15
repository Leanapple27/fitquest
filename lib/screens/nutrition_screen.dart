import 'package:flutter/material.dart';

import '../theme/theme.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<_FoodItem> _foods = _foodLibrary;
  final List<_LoggedFood> _loggedFoods = [];

  String _selectedCategory = 'All';
  String _searchQuery = '';

  double get _calories =>
      _loggedFoods.fold(0, (total, item) => total + item.calories);

  double get _protein =>
      _loggedFoods.fold(0, (total, item) => total + item.protein);

  double get _carbs =>
      _loggedFoods.fold(0, (total, item) => total + item.carbs);

  double get _fat =>
      _loggedFoods.fold(0, (total, item) => total + item.fat);

  double get _fiber =>
      _loggedFoods.fold(0, (total, item) => total + item.fiber);

  double get _water =>
      _loggedFoods.fold(0, (total, item) => total + item.waterMl);

  static const List<String> _categories = [
    'All',
    'Fruits',
    'Vegetables',
    'Grains',
    'Protein',
    'Dairy',
    'Nuts & Seeds',
    'Meals',
    'Drinks',
  ];

  List<_FoodItem> get _filteredFoods {
    return _foods.where((food) {
      final categoryMatches =
          _selectedCategory == 'All' ||
          food.category == _selectedCategory;

      final queryMatches =
          _searchQuery.trim().isEmpty ||
          food.name.toLowerCase().contains(
                _searchQuery.trim().toLowerCase(),
              );

      return categoryMatches && queryMatches;
    }).toList();
  }



  void _addFood(_FoodItem food) {
    setState(() {
      _loggedFoods.add(
        _LoggedFood(
          name: food.name,
          category: food.category,
          serving: food.serving,
          calories: food.calories,
          protein: food.protein,
          carbs: food.carbs,
          fat: food.fat,
          fiber: food.fiber,
          waterMl: food.waterMl,
        ),
      );
    });
  }

  void _removeFood(int index) {
    setState(() {
      _loggedFoods.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _loggedFoods.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FqColors.scaffold,
      appBar: AppBar(
        title: const Text('Nutrition'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),
        children: [
          _buildHero(),
          const SizedBox(height: 22),
          _buildNutritionSummary(),
          const SizedBox(height: 22),
          _buildDateSelector(),
          const SizedBox(height: 22),
          _buildSearch(),
          const SizedBox(height: 14),
          _buildCategories(),
          const SizedBox(height: 18),
          _buildFoodLibrary(),
          const SizedBox(height: 24),
          _buildTodayFoods(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: FqColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: FqRadii.heroBorder,
        boxShadow: FqShadows.heroBrand(),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fuel your progress',
                  style: FqTypography.cardTitle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track what you eat and learn how food fuels your activity.',
                  style: FqTypography.body(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('TODAY\'S NUTRITION'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: FqColors.surface,
            borderRadius: FqRadii.cardBorder,
            boxShadow: FqShadows.cardSoft(),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _nutritionStat(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Calories',
                      value: '${_calories.round()}',
                      unit: 'kcal',
                      accent: FqColors.energy,
                    ),
                  ),
                  Expanded(
                    child: _nutritionStat(
                      icon: Icons.fitness_center_rounded,
                      label: 'Protein',
                      value: '${_protein.round()}',
                      unit: 'g',
                      accent: FqColors.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 26),
              Row(
                children: [
                  Expanded(
                    child: _nutritionStat(
                      icon: Icons.grain_rounded,
                      label: 'Carbs',
                      value: '${_carbs.round()}',
                      unit: 'g',
                      accent: FqColors.accent,
                    ),
                  ),
                  Expanded(
                    child: _nutritionStat(
                      icon: Icons.water_drop_rounded,
                      label: 'Water',
                      value: '${(_water / 1000).toStringAsFixed(1)}',
                      unit: 'L',
                      accent: FqColors.primaryMid,
                    ),
                  ),
                ],
              ),
              const Divider(height: 26),
              Row(
                children: [
                  Expanded(
                    child: _nutritionStat(
                      icon: Icons.opacity_rounded,
                      label: 'Fat',
                      value: '${_fat.round()}',
                      unit: 'g',
                      accent: FqColors.accent,
                    ),
                  ),
                  Expanded(
                    child: _nutritionStat(
                      icon: Icons.eco_rounded,
                      label: 'Fiber',
                      value: '${_fiber.round()}',
                      unit: 'g',
                      accent: FqColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nutritionStat({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color accent,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FqTypography.body(
                  color: FqColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: FqTypography.cardTitle(
                        color: FqColors.ink,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: FqTypography.body(
                        color: FqColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        Expanded(
          child: Text(
            _selectedDate.day == DateTime.now().day &&
                    _selectedDate.month == DateTime.now().month &&
                    _selectedDate.year == DateTime.now().year
                ? 'Today'
                : _formatDate(_selectedDate),
            style: FqTypography.cardTitle(
              color: FqColors.ink,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _selectDate,
          icon: const Icon(Icons.calendar_month_rounded),
          label: const Text('Change date'),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      decoration: InputDecoration(
        hintText: 'Search food...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.clear_rounded),
              ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedCategory = category;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildFoodLibrary() {
    final foods = _filteredFoods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('FOOD LIBRARY'),
        const SizedBox(height: 10),
        if (foods.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: FqColors.surface,
              borderRadius: FqRadii.cardBorder,
            ),
            child: Center(
              child: Text(
                'No food items found.',
                style: FqTypography.body(
                  color: FqColors.muted,
                ),
              ),
            ),
          )
        else
          ...foods.map(
            (food) => _foodTile(food),
          ),
      ],
    );
  }

  Widget _foodTile(_FoodItem food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: FqColors.surface,
        borderRadius: FqRadii.cardBorder,
        boxShadow: FqShadows.cardSoft(),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: FqColors.lavender.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              food.emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Text(
          food.name,
          style: FqTypography.cardTitle(
            color: FqColors.ink,
          ),
        ),
        subtitle: Text(
          '${food.serving} • ${food.calories.round()} kcal',
          style: FqTypography.body(
            color: FqColors.muted,
          ),
        ),
        trailing: IconButton(
          tooltip: 'Add food',
          onPressed: () => _addFood(food),
          icon: const Icon(
            Icons.add_circle_rounded,
            color: FqColors.primary,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayFoods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('TODAY\'S FOOD'),
        const SizedBox(height: 10),
        if (_loggedFoods.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FqColors.surface,
              borderRadius: FqRadii.cardBorder,
            ),
            child: Text(
              'Nothing logged yet. Choose a food above to get started.',
              style: FqTypography.body(
                color: FqColors.muted,
              ),
            ),
          )
        else
          ...List.generate(
            _loggedFoods.length,
            (index) => _loggedFoodTile(
              _loggedFoods[index],
              index,
            ),
          ),
      ],
    );
  }

  Widget _loggedFoodTile(_LoggedFood food, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: FqColors.surface,
        borderRadius: FqRadii.cardBorder,
      ),
      child: ListTile(
        title: Text(
          food.name,
          style: FqTypography.cardTitle(
            color: FqColors.ink,
          ),
        ),
        subtitle: Text(
          '${food.serving} • ${food.calories.round()} kcal • '
          '${food.protein.round()}g protein',
          style: FqTypography.body(
            color: FqColors.muted,
          ),
        ),
        trailing: IconButton(
          onPressed: () => _removeFood(index),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: FqColors.danger,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: FqTypography.sectionLabel(
        color: FqColors.muted,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _FoodItem {
  final String name;
  final String category;
  final String emoji;
  final String serving;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double waterMl;

  const _FoodItem({
    required this.name,
    required this.category,
    required this.emoji,
    required this.serving,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.waterMl,
  });
}

class _LoggedFood {
  final String name;
  final String category;
  final String serving;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double waterMl;

  const _LoggedFood({
    required this.name,
    required this.category,
    required this.serving,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.waterMl,
  });

}

const List<_FoodItem> _foodLibrary = [
  _FoodItem(
    name: 'Apple',
    category: 'Fruits',
    emoji: '🍎',
    serving: '1 medium',
    calories: 95,
    protein: 0.5,
    carbs: 25,
    fat: 0.3,
    fiber: 4.4,
    waterMl: 155,
  ),
  _FoodItem(
    name: 'Banana',
    category: 'Fruits',
    emoji: '🍌',
    serving: '1 medium',
    calories: 105,
    protein: 1.3,
    carbs: 27,
    fat: 0.4,
    fiber: 3.1,
    waterMl: 88,
  ),
  _FoodItem(
    name: 'Orange',
    category: 'Fruits',
    emoji: '🍊',
    serving: '1 medium',
    calories: 62,
    protein: 1.2,
    carbs: 15.4,
    fat: 0.2,
    fiber: 3.1,
    waterMl: 116,
  ),
  _FoodItem(
    name: 'Mango',
    category: 'Fruits',
    emoji: '🥭',
    serving: '1 cup',
    calories: 99,
    protein: 1.4,
    carbs: 25,
    fat: 0.6,
    fiber: 2.6,
    waterMl: 138,
  ),
  _FoodItem(
    name: 'Spinach',
    category: 'Vegetables',
    emoji: '🥬',
    serving: '1 cup',
    calories: 7,
    protein: 0.9,
    carbs: 1.1,
    fat: 0.1,
    fiber: 0.7,
    waterMl: 30,
  ),
  _FoodItem(
    name: 'Broccoli',
    category: 'Vegetables',
    emoji: '🥦',
    serving: '1 cup',
    calories: 55,
    protein: 3.7,
    carbs: 11.2,
    fat: 0.6,
    fiber: 5.1,
    waterMl: 81,
  ),
  _FoodItem(
    name: 'Carrot',
    category: 'Vegetables',
    emoji: '🥕',
    serving: '1 medium',
    calories: 25,
    protein: 0.6,
    carbs: 6,
    fat: 0.1,
    fiber: 1.7,
    waterMl: 59,
  ),
  _FoodItem(
    name: 'Tomato',
    category: 'Vegetables',
    emoji: '🍅',
    serving: '1 medium',
    calories: 22,
    protein: 1.1,
    carbs: 4.8,
    fat: 0.3,
    fiber: 1.5,
    waterMl: 116,
  ),
  _FoodItem(
    name: 'Potato',
    category: 'Vegetables',
    emoji: '🥔',
    serving: '1 medium',
    calories: 163,
    protein: 4.3,
    carbs: 37,
    fat: 0.2,
    fiber: 4.7,
    waterMl: 119,
  ),
  _FoodItem(
    name: 'Rice',
    category: 'Grains',
    emoji: '🍚',
    serving: '1 cup cooked',
    calories: 205,
    protein: 4.3,
    carbs: 44.5,
    fat: 0.4,
    fiber: 0.6,
    waterMl: 120,
  ),
  _FoodItem(
    name: 'Oats',
    category: 'Grains',
    emoji: '🥣',
    serving: '1 cup cooked',
    calories: 166,
    protein: 5.9,
    carbs: 28,
    fat: 3.6,
    fiber: 4,
    waterMl: 197,
  ),
  _FoodItem(
    name: 'Bread',
    category: 'Grains',
    emoji: '🍞',
    serving: '2 slices',
    calories: 160,
    protein: 6,
    carbs: 28,
    fat: 2,
    fiber: 2,
    waterMl: 30,
  ),
  _FoodItem(
    name: 'Roti',
    category: 'Grains',
    emoji: '🫓',
    serving: '1 medium',
    calories: 120,
    protein: 3.5,
    carbs: 18,
    fat: 3,
    fiber: 2.5,
    waterMl: 12,
  ),
  _FoodItem(
    name: 'Egg',
    category: 'Protein',
    emoji: '🥚',
    serving: '1 large',
    calories: 78,
    protein: 6.3,
    carbs: 0.6,
    fat: 5.3,
    fiber: 0,
    waterMl: 37,
  ),
  _FoodItem(
    name: 'Chicken',
    category: 'Protein',
    emoji: '🍗',
    serving: '100 g',
    calories: 165,
    protein: 31,
    carbs: 0,
    fat: 3.6,
    fiber: 0,
    waterMl: 65,
  ),
  _FoodItem(
    name: 'Fish',
    category: 'Protein',
    emoji: '🐟',
    serving: '100 g',
    calories: 120,
    protein: 26,
    carbs: 0,
    fat: 2,
    fiber: 0,
    waterMl: 70,
  ),
  _FoodItem(
    name: 'Dal',
    category: 'Protein',
    emoji: '🥣',
    serving: '1 cup',
    calories: 230,
    protein: 18,
    carbs: 40,
    fat: 1,
    fiber: 15,
    waterMl: 170,
  ),
  _FoodItem(
    name: 'Chickpeas',
    category: 'Protein',
    emoji: '🫘',
    serving: '1 cup cooked',
    calories: 269,
    protein: 14.5,
    carbs: 45,
    fat: 4.2,
    fiber: 12.5,
    waterMl: 119,
  ),
  _FoodItem(
    name: 'Milk',
    category: 'Dairy',
    emoji: '🥛',
    serving: '1 cup',
    calories: 122,
    protein: 8.1,
    carbs: 12,
    fat: 4.8,
    fiber: 0,
    waterMl: 220,
  ),
  _FoodItem(
    name: 'Curd',
    category: 'Dairy',
    emoji: '🥣',
    serving: '1 cup',
    calories: 149,
    protein: 8.5,
    carbs: 11.4,
    fat: 8,
    fiber: 0,
    waterMl: 215,
  ),
  _FoodItem(
    name: 'Paneer',
    category: 'Dairy',
    emoji: '🧀',
    serving: '100 g',
    calories: 265,
    protein: 18,
    carbs: 6,
    fat: 20,
    fiber: 0,
    waterMl: 50,
  ),
  _FoodItem(
    name: 'Almonds',
    category: 'Nuts & Seeds',
    emoji: '🌰',
    serving: '28 g',
    calories: 164,
    protein: 6,
    carbs: 6.1,
    fat: 14.2,
    fiber: 3.5,
    waterMl: 1,
  ),
  _FoodItem(
    name: 'Peanuts',
    category: 'Nuts & Seeds',
    emoji: '🥜',
    serving: '28 g',
    calories: 161,
    protein: 7.3,
    carbs: 4.6,
    fat: 14,
    fiber: 2.4,
    waterMl: 2,
  ),
  _FoodItem(
    name: 'Chia Seeds',
    category: 'Nuts & Seeds',
    emoji: '🌱',
    serving: '28 g',
    calories: 138,
    protein: 4.7,
    carbs: 11.9,
    fat: 8.7,
    fiber: 9.8,
    waterMl: 1,
  ),
  _FoodItem(
    name: 'Dal Rice',
    category: 'Meals',
    emoji: '🍛',
    serving: '1 bowl',
    calories: 350,
    protein: 12,
    carbs: 58,
    fat: 7,
    fiber: 8,
    waterMl: 180,
  ),
  _FoodItem(
    name: 'Roti Sabzi',
    category: 'Meals',
    emoji: '🍽️',
    serving: '1 plate',
    calories: 320,
    protein: 10,
    carbs: 48,
    fat: 9,
    fiber: 7,
    waterMl: 100,
  ),
  _FoodItem(
    name: 'Poha',
    category: 'Meals',
    emoji: '🥣',
    serving: '1 bowl',
    calories: 250,
    protein: 5,
    carbs: 45,
    fat: 6,
    fiber: 3,
    waterMl: 100,
  ),
  _FoodItem(
    name: 'Upma',
    category: 'Meals',
    emoji: '🥣',
    serving: '1 bowl',
    calories: 220,
    protein: 6,
    carbs: 35,
    fat: 7,
    fiber: 3,
    waterMl: 100,
  ),
  _FoodItem(
    name: 'Water',
    category: 'Drinks',
    emoji: '💧',
    serving: '250 ml',
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    waterMl: 250,
  ),
  _FoodItem(
    name: 'Coconut Water',
    category: 'Drinks',
    emoji: '🥥',
    serving: '1 cup',
    calories: 46,
    protein: 2,
    carbs: 9,
    fat: 0.5,
    fiber: 2.6,
    waterMl: 240,
  ),
];