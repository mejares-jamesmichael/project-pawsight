import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/behavior.dart';
import '../services/database_helper.dart';

class LibraryProvider with ChangeNotifier {
  List<Behavior> _allBehaviors = [];
  List<Behavior> _filteredBehaviors = [];
  bool _isLoading = true;
  String? _error;
  
  // Spotlight behavior - changes daily
  Behavior? _spotlightBehavior;

  List<Behavior> get behaviors => _filteredBehaviors;
  List<Behavior> get allBehaviors => _allBehaviors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Behavior? get spotlightBehavior => _spotlightBehavior;

  // Filters
  String _searchQuery = '';
  final Set<String> _selectedMoods = {};
  final Set<String> _selectedCategories = {};
  String _sortBy = 'name'; // Options: 'name', 'category', 'mood'

  // Search debouncing
  Timer? _searchDebounceTimer;

  // Expose selected filters for UI
  Set<String> get selectedMoods => _selectedMoods;
  Set<String> get selectedCategories => _selectedCategories;
  String get sortBy => _sortBy;

  LibraryProvider() {
    loadBehaviors();
  }

  Future<void> loadBehaviors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allBehaviors = await DatabaseHelper.instance.getBehaviors();
      _applyFilters();
      _selectSpotlightBehavior();
    } catch (e) {
      _error = 'Failed to load behaviors. Please try again.';
      debugPrint('Error loading behaviors: $e');
      _allBehaviors = [];
      _filteredBehaviors = [];
      _spotlightBehavior = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects a spotlight behavior based on the day of year
  /// This ensures the same behavior is shown all day, but changes daily
  void _selectSpotlightBehavior() {
    if (_allBehaviors.isEmpty) {
      _spotlightBehavior = null;
      return;
    }
    
    // Use day of year as seed for consistent daily selection
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final random = Random(dayOfYear);
    
    _spotlightBehavior = _allBehaviors[random.nextInt(_allBehaviors.length)];
  }

  /// Get a random behavior for spotlight (can be called to refresh)
  Behavior? getRandomBehavior() {
    if (_allBehaviors.isEmpty) return null;
    final random = Random();
    return _allBehaviors[random.nextInt(_allBehaviors.length)];
  }

  void search(String query) {
    _searchQuery = query;
    // Cancel existing timer
    _searchDebounceTimer?.cancel();
    // Start new timer with 300ms delay
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  void toggleMoodFilter(String mood) {
    if (_selectedMoods.contains(mood)) {
      _selectedMoods.remove(mood);
    } else {
      _selectedMoods.add(mood);
    }
    _applyFilters();
  }

  void toggleCategoryFilter(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _applyFilters();
  }

  void clearAllFilters() {
    _selectedMoods.clear();
    _selectedCategories.clear();
    _searchQuery = '';
    _error = null;
    _applyFilters();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setSorting(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredBehaviors = _allBehaviors.where((behavior) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          behavior.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          behavior.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesMood =
          _selectedMoods.isEmpty || _selectedMoods.contains(behavior.mood);
      final matchesCategory =
          _selectedCategories.isEmpty || _selectedCategories.contains(behavior.category);

      return matchesSearch && matchesMood && matchesCategory;
    }).toList();

    // Apply sorting
    _filteredBehaviors.sort((a, b) {
      switch (_sortBy) {
        case 'category':
          final categoryCompare = a.category.compareTo(b.category);
          return categoryCompare != 0 ? categoryCompare : a.name.compareTo(b.name);
        case 'mood':
          final moodCompare = a.mood.compareTo(b.mood);
          return moodCompare != 0 ? moodCompare : a.name.compareTo(b.name);
        case 'name':
        default:
          return a.name.compareTo(b.name);
}

    });

    notifyListeners();
  }
}

