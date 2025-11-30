import 'package:flutter/material.dart';
import '../models/behavior.dart';
import '../services/database_helper.dart';

class LibraryProvider with ChangeNotifier {
  List<Behavior> _allBehaviors = [];
  List<Behavior> _filteredBehaviors = [];
  bool _isLoading = true;

  List<Behavior> get behaviors => _filteredBehaviors;
  bool get isLoading => _isLoading;

  // Filters
  String _searchQuery = '';
  String? _selectedMood;
  String? _selectedCategory;

  LibraryProvider() {
    loadBehaviors();
  }

  Future<void> loadBehaviors() async {
    _isLoading = true;
    notifyListeners();

    _allBehaviors = await DatabaseHelper.instance.getBehaviors();
    _applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByMood(String? mood) {
    _selectedMood = mood == _selectedMood ? null : mood; // Toggle
    _applyFilters();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category == _selectedCategory ? null : category; // Toggle
    _applyFilters();
  }

  void _applyFilters() {
    _filteredBehaviors = _allBehaviors.where((behavior) {
      final matchesSearch = behavior.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          behavior.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesMood = _selectedMood == null || behavior.mood == _selectedMood;
      final matchesCategory = _selectedCategory == null || behavior.category == _selectedCategory;

      return matchesSearch && matchesMood && matchesCategory;
    }).toList();

    notifyListeners();
  }
}
