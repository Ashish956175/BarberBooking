import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Try to auto-login on app start
  Future<bool> tryAutoLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        return false;
      }

      // Fetch current user profile from backend
      // Add timeout to fail fast if server unreachable
      await loadUserProfile().timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      print('Auto-login failed: $e');
      return false;
    }
  }

  // Load user profile from backend
  Future<void> loadUserProfile() async {
    try {
      final response = await _apiService.get('/auth/profile');
      _user = User.fromJson(response);
      notifyListeners();
    } catch (e) {
      print('Failed to load user profile: $e');
      throw e;
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      _user = User.fromJson(response);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _user!.token!);
      await prefs.setString('userId', _user!.id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> register(String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      _user = User.fromJson(response);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _user!.token!);
      await prefs.setString('userId', _user!.id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateProfile({String? name, String? profilePic, String? location, String? email, String? password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (password != null) body['password'] = password;
      if (profilePic != null) body['profilePic'] = profilePic;
      if (location != null && location.isNotEmpty) {
        body['location'] = location; // Send as string directly
      }

      final response = await _apiService.put('/auth/profile', body);
      
      // Update local user object
      _user = User.fromJson(response);
      
      // Save updated user data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', response.toString());
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  void logout() async {
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
