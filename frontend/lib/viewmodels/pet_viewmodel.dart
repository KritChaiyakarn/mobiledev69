import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../models/care_log_model.dart';
import '../services/api_service.dart';

class PetViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedSpecies = 'All';

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedSpecies => _selectedSpecies;

  // คำนวณรายการสัตว์เลี้ยงหลังผ่านการกรอง (Search & Filter)
  List<Pet> get filteredPets {
    return _pets.where((pet) {
      // 1. ตรวจสอบคำค้นหา (Search Query)
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          pet.name.toLowerCase().contains(query) ||
          pet.species.toLowerCase().contains(query) ||
          (pet.breed != null && pet.breed!.toLowerCase().contains(query));

      // 2. ตรวจสอบการกรองชนิด (Species Filter)
      bool matchesSpecies = false;
      if (_selectedSpecies == 'All') {
        matchesSpecies = true;
      } else if (_selectedSpecies == 'อื่นๆ') {
        // ถ้าเลือก "อื่นๆ" ให้แสดงชนิดที่ไม่ใช่ สุนัข, แมว, นก
        final mainSpecies = ['สุนัข', 'แมว', 'นก'];
        matchesSpecies = !mainSpecies.contains(pet.species);
      } else {
        matchesSpecies = pet.species.toLowerCase() == _selectedSpecies.toLowerCase();
      }

      return matchesSearch && matchesSpecies;
    }).toList();
  }

  // --- Actions ---

  Future<void> loadPets(String? token) async {
    if (token == null || token.isEmpty) {
      _errorMessage = 'ไม่พบ Token กรุณาล็อกอินใหม่';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pets = await _apiService.fetchPets(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPet(String? token, Pet pet) async {
    if (token == null || token.isEmpty) {
      _errorMessage = 'ไม่พบ Token กรุณาล็อกอินใหม่';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    try {
      final newPet = await _apiService.createPet(token, pet);
      _pets.add(newPet);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePet(String? token, int id) async {
    if (token == null || token.isEmpty) return false;

    _errorMessage = null;
    try {
      await _apiService.deletePet(token, id);
      _pets.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCareLog(String? token, CareLog log) async {
    if (token == null || token.isEmpty) return false;

    _errorMessage = null;
    try {
      await _apiService.createCareLog(token, log);
      await loadPets(token); // โหลดข้อมูลใหม่เพื่ออัปเดต List
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleCareLog(String? token, int logId, bool isCompleted) async {
    if (token == null || token.isEmpty) return;

    _errorMessage = null;
    try {
      await _apiService.toggleCareLogComplete(token, logId, isCompleted);
      await loadPets(token);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCareLog(String? token, int logId) async {
    if (token == null || token.isEmpty) return;

    _errorMessage = null;
    try {
      await _apiService.deleteCareLog(token, logId);
      await loadPets(token);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ฟังก์ชันอัปเดตค่า Search Query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ฟังก์ชันอัปเดตค่า Filter Species
  void setSelectedSpecies(String species) {
    _selectedSpecies = species;
    notifyListeners();
  }
}