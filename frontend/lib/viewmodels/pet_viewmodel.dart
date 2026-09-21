import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../models/care_log_model.dart';
import '../services/api_service.dart';

class PetViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPets(String? token) async {
    if (token == null) return;
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
    if (token == null) return false;
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
    if (token == null) return false;
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
    if (token == null) return false;
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
    if (token == null) return;
    try {
      await _apiService.toggleCareLogComplete(token, logId, isCompleted);
      await loadPets(token);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCareLog(String? token, int logId) async {
    if (token == null) return;
    try {
      await _apiService.deleteCareLog(token, logId);
      await loadPets(token);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}