import 'dart:async';
import 'package:flutter/material.dart';
import '../models/behavior.dart';
import '../services/database_helper.dart';

class LibraryProvider with ChangeNotifier {
  List<Behavior> _allBehaviors = [];
  List<Behavior> _filteredBehaviors = [];
  bool _isLoading = true;
  String? _error;

  List<Behavior> get behaviors => _filteredBehaviors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filters
  String _searchQuery = '';
  Set<String> _selectedMoods = {};
  Set<String> _selectedCategories = {};
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
    } catch (e) {
      _error = 'Failed to load behaviors. Please try again.';
      debugPrint('Error loading behaviors: $e');
      _allBehaviors = [];
      _filteredBehaviors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
