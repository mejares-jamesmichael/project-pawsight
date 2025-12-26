import 'package:flutter/material.dart';
import '../models/vet_contact.dart';
import '../services/database_helper.dart';

/// Provider for managing vet hotline contacts
class HotlineProvider extends ChangeNotifier {
  List<VetContact> _contacts = [];
  bool _isLoading = false;
  String? _error;

  List<VetContact> get contacts => _contacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get emergency contacts (24/7 services)
  List<VetContact> get emergencyContacts =>
      _contacts.where((contact) => contact.isEmergency).toList();

  /// Get regular clinic contacts
  List<VetContact> get regularContacts =>
      _contacts.where((contact) => !contact.isEmergency).toList();

  /// Load all vet contacts from database
  Future<void> loadContacts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contacts = await DatabaseHelper.instance.getVetContacts();
    } catch (e) {
      _error = 'Failed to load vet contacts. Please try again.';
      debugPrint('Error loading vet contacts: $e');
      _contacts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Future methods for add/edit/delete functionality
  // These will be implemented when user adds real vet contacts
  
  // Future<void> addContact(VetContact contact) async {
  //   // TODO: Implement add contact to database
  // }
  
  // Future<void> updateContact(VetContact contact) async {
  //   // TODO: Implement update contact in database
  // }
  
  // Future<void> deleteContact(int id) async {
  //   // TODO: Implement delete contact from database
  // }
}
