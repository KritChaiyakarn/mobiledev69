import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pet_model.dart';
import '../models/care_log_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- PET CRUD ---

  Future<List<Pet>> fetchPets(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pets/'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Pet.fromJson(json)).toList();
    } else {
      throw Exception('ไม่สามารถดึงข้อมูลสัตว์เลี้ยงได้ (${response.statusCode})');
    }
  }

  Future<Pet> createPet(String token, Pet pet) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pets/'),
      headers: _headers(token),
      body: jsonEncode(pet.toJson()),
    );

    if (response.statusCode == 201) {
      return Pet.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('ไม่สามารถเพิ่มสัตว์เลี้ยงได้');
    }
  }

  Future<void> deletePet(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pets/$id/'),
      headers: _headers(token),
    );

    if (response.statusCode != 204) {
      throw Exception('ไม่สามารถลบสัตว์เลี้ยงได้');
    }
  }

  // --- CARE LOG CRUD ---

  Future<CareLog> createCareLog(String token, CareLog log) async {
    final response = await http.post(
      Uri.parse('$baseUrl/care-logs/'),
      headers: _headers(token),
      body: jsonEncode(log.toJson()),
    );

    if (response.statusCode == 201) {
      return CareLog.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('ไม่สามารถเพิ่มบันทึกการดูแลได้');
    }
  }

  Future<void> toggleCareLogComplete(String token, int logId, bool isCompleted) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/care-logs/$logId/'),
      headers: _headers(token),
      body: jsonEncode({'is_completed': isCompleted}),
    );

    if (response.statusCode != 200) {
      throw Exception('ไม่สามารถอัปเดตสถานะการดูแลได้');
    }
  }

  Future<void> deleteCareLog(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/care-logs/$id/'),
      headers: _headers(token),
    );

    if (response.statusCode != 204) {
      throw Exception('ไม่สามารถลบบันทึกได้');
    }
  }
}